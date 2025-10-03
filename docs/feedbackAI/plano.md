Volt, bora desenhar esse monorepo de k6 como se fosse para durar 10 anos. Vou te entregar estrutura, padrões de código, bibliotecas que realmente ajudam, políticas de PR, e um pipeline do GitHub Actions que já nasce com “quality gates” (thresholds) e artefatos de relatório. Como fonte do domínio, vamos ancorar os cenários nas rotas do DummyJSON (products, users, auth, etc.) e no material que você guardou em `docs/dummyJson`, parametrizando dados a partir de `data/fulldummyjsondata/`.

---

# 1) Objetivo & filosofia

* **Monorepo único**, com *design modular* e **contratos de manutenção** claros (nomenclatura, padrões, revisões).
* **Tests-as-code em TypeScript** (k6 compila TS nativamente com esbuild — dá pra `k6 run script.ts`; o suporte remove tipos em tempo de execução, mas mantém o DX. Para *type safety*, rodamos `tsc --noEmit` no CI). ([Grafana Labs][1])
* **Workload declarativo** por *cenário* (open model com `constant-arrival-rate`/`ramping-arrival-rate`) e **quality gates** via `thresholds` (o processo falha quando o SLO não é atendido). ([Grafana Labs][2])
* **Domínio realista**: endpoints públicos & previsíveis do DummyJSON (products, users, auth, carts, etc.). ([DummyJSON][3])

---

# 2) Layout de pastas (monorepo)

```
repo-root/
├─ docs/
│  └─ dummyJson/
│     ├─ 000-readme.md
│     ├─ templates/
│     │  ├─ test-case.md        # modelo de caso de teste não-funcional
│     │  └─ scenario.yaml       # modelo de cenário (workload, SLOs)
│     └─ specs/
│        ├─ products.md         # linka trechos da doc oficial
│        └─ users-auth.md
├─ data/
│  └─ fulldummyjsondata/        # insumos de dados (JSON/CSV) para parametrização
├─ tests/
│  └─ api/
│     ├─ products/
│     │  ├─ browse.catalog.ts
│     │  ├─ search.products.ts
│     │  └─ crud.simulado.ts    # POST/PUT/DELETE “fake” do DummyJSON
│     ├─ users/
│     │  ├─ login.ts
│     │  └─ get.me.ts
│     └─ carts/
│        └─ add.items.ts
├─ libs/                        # reutilizáveis
│  ├─ http/
│  │  ├─ client.ts              # wrapper http, headers, retry/backoff
│  │  └─ checks.ts              # checks e validações
│  ├─ data/
│  │  ├─ loader.ts              # open() / shared arrays
│  │  └─ generators.ts          # uuid, random, etc.
│  ├─ scenarios/
│  │  └─ profiles.ts            # fábrica de executors e tags
│  └─ reporting/
│     └─ summary.ts             # handleSummary (JSON / JUnit opcional)
├─ configs/
│  ├─ envs/
│  │  ├─ local.json             # baseURL, limites
│  │  └─ ci.json
│  └─ scenarios/
│     ├─ smoke.yaml
│     ├─ baseline.yaml
│     ├─ stress.yaml
│     └─ soak.yaml
├─ .github/
│  └─ workflows/
│     ├─ k6-pr-smoke.yml
│     ├─ k6-main-baseline.yml
│     └─ k6-on-demand.yml
├─ package.json
├─ tsconfig.json
└─ README.md
```

**Por quê assim?**

* Separe **domínio** (em `tests/api/<resource>/...`) de **infra** (`libs`, `configs`), e de **documentação funcional** (`docs/dummyJson`).
* Dados grandes e estáticos entram por `open()` no **init context** (memória compartilhada e bundling correto). Para volumes grandes/streaming, use `k6/experimental/fs`. ([Grafana Labs][4])
* **Remote modules** de utilidades (uuid, random, jsonpath) vêm do `jslib.k6.io`, versão fixada. ([jslib.k6.io][5])

---

# 3) Bibliotecas & utilidades recomendadas

* **Oficiais k6 (built-in):** `k6/http`, `k6/metrics`, `k6/execution`, `k6/net/grpc` (pensando futuro gRPC). ([Grafana Labs][6])
* **jslib.k6.io** (mantido pela própria equipe k6):

  * `k6-utils` (random, uuidv4, etc.)
  * `jsonpath` (extração de campos aninhados) ([jslib.k6.io][5])
* **TypeScript DX:** `@types/k6` para autocomplete e checagem estática no CI. ([NPM][7])
* **Relatórios (opcionais):**

  * `handleSummary` + export JSON (nativo). ([Grafana Labs][8])
  * Converter para **JUnit** no CI (ex.: `l-ross/k6-junit` CLI) ou lib JS `simbadltd/k6-junit` em `handleSummary`. ([GitHub][9])
* **Extensões futuras (xk6)**:

  * **SQL Server** (para testes com base de dados de apoio): `xk6-sql` + driver `xk6-sql-driver-sqlserver`. ([GitHub][10])
  * **Kafka** (EDA “de verdade”): `xk6-kafka`. ([GitHub][11])
    A própria doc do k6 lista extensões oficiais e comunitárias e como usá-las. ([Grafana Labs][12])

---

# 4) Padrões de script (TS) — exemplo mínimo

```ts
// tests/api/products/browse.catalog.ts
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

export const options = {
  scenarios: {
    browse_products: {
      executor: 'constant-arrival-rate',
      rate: __ENV.K6_RPS ? Number(__ENV.K6_RPS) : 5, // open model
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '1m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'products', kind: 'browse' },
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500'], // SLO genérico
    http_req_failed:   ['rate<0.01'],
    'checks{feature:products}': ['rate>0.99'],
  },
};

const tList = new Trend('products_list_ms');

const BASE = __ENV.BASE_URL || 'https://dummyjson.com';

export default function () {
  const res = http.get(`${BASE}/products?limit=10&skip=${Math.floor(Math.random()*30)}`);
  tList.add(res.timings.duration);
  check(res, {
    '200 OK': (r) => r.status === 200,
    'tem payload': (r) => r.json('products.length') > 0,
  });
  // opcional: explorar uma categoria aleatória
  const categories = http.get(`${BASE}/products/category-list`).json();
  const cat = randomItem(categories);
  const r2 = http.get(`${BASE}/products/category/${cat}`);
  check(r2, { 'cat 200': (r) => r.status === 200 });
  sleep(1);
}
```

* O **open model** (`constant-arrival-rate`) é o padrão para API; evita que um único VU “prenda” throughput. Para rampas, `ramping-arrival-rate`. ([Grafana Labs][2])
* **Thresholds** são o *quality gate* (quebra o job se violados). ([Grafana Labs][13])
* Endpoints DummyJSON usados (listagem, categorias) — baseados na doc oficial. ([DummyJSON][3])

> Nota sobre **CRUD no DummyJSON**: ele oferece rotas `add/update/delete` que retornam respostas simuladas; não assuma persistência. Prefira GET/SEARCH para métricas estáveis. ([DummyJSON][3])

---

# 5) Parametrização de dados

* Use `open()` no **init** para ler `data/fulldummyjsondata/*.json` e colocar em *SharedArray* (economiza memória e é thread-safe para leitura). ([Grafana Labs][4])
* Gere *payloads realistas* com `k6-utils` (ex.: `uuidv4`, ranges randômicos). ([jslib.k6.io][5])
* Cole um **mapa** no `docs/dummyJson/specs/*.md` ligando cada caso de teste aos campos do dataset (traçabilidade).

---

# 6) Catálogo inicial de cenários (DummyJSON)

Baseie os casos a partir de `docs/dummyJson` e solidifique estes **fluxos**:

* **Browse & Search de produtos**: `/products`, `/products/search`, filtros/ordenadores/paginação. ([DummyJSON][3])
* **Categorias**: `/products/categories`, `/products/category-list`, `/products/category/{slug}`. ([DummyJSON][3])
* **Login & Perfil**: `/auth/login` → cookies/tokens; `/auth/me`. Use um usuário da lista de `/users`. ([DummyJSON][14])
* **Carrinhos básicos**: `/carts` leitura e (se precisar) `add` simulado. ([DummyJSON][3])

Para cada fluxo, crie um `scenario.yaml` (em `configs/scenarios/`) com: objetivo, padrões de workload (RPS, duração), dados, **SLO/thresholds** e tags.

---

# 7) Workload & SLOs (padrão do repo)

* **Smoke (PR):** 30–60s, `rate=1–2 rps`, thresholds “largos” para fisgar regressões óbvias.
* **Baseline (main):** 5–10 min, `rate=5–10 rps`, P95 < 500 ms, error-rate < 1%.
* **Stress (manual):** rampa com `ramping-arrival-rate` para achar a inflexão de latência.
* **Soak (cron):** 30–60 min, RPS moderado, foco em estabilidade/leaks.

Executors & sintaxe: ver docs oficiais. ([Grafana Labs][2])

---

# 8) GitHub Actions — pipelines prontos

Usaremos as actions oficiais da Grafana para **instalar k6** e **rodar testes**:

* **setup:** `grafana/setup-k6-action`
* **run:** `grafana/run-k6-action` (suporta globs, paralelização, fail-fast) ([Grafana Labs][15])

## a) PR (smoke) — `.github/workflows/k6-pr-smoke.yml`

```yaml
name: k6 PR Smoke
on:
  pull_request:
    paths: [ "tests/**", "libs/**", "configs/**", "package.json", "tsconfig.json" ]

jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Type-check & lint para manter TS saudável (DX)
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm run typecheck # tsc --noEmit
      - run: npm run lint || true

      - uses: grafana/setup-k6-action@v1
        with: { version: 'v0.57.0' }

      - name: Run k6 smoke (glob tests/api/**/*.ts)
        uses: grafana/run-k6-action@v3
        with:
          paths: |
            tests/api/**/*.ts
          parallel: true
          fail-fast: true
        env:
          BASE_URL: https://dummyjson.com
          K6_RPS: "2"
          K6_DURATION: "45s"

      - name: Export k6 summary
        run: |
          mkdir -p reports
          k6 run --summary-export=reports/summary.json tests/api/products/browse.catalog.ts
      - uses: actions/upload-artifact@v4
        with:
          name: k6-smoke-summary
          path: reports/
```

## b) `main` (baseline) — `.github/workflows/k6-main-baseline.yml`

* Igual ao PR, mas com `K6_RPS=5–10`, `K6_DURATION=10m` e seleção de *alguns* cenários “padrão ouro”.

## c) On-demand (stress/soak) — `.github/workflows/k6-on-demand.yml`

* `workflow_dispatch` com inputs (cenário, RPS, duração).
* **Dica**: gere `JUnit` a partir do `summary.json` com `k6-junit` (CLI) para publicar nos “Test Reports” do GitHub. ([GitHub][9])

> Observação: como o DummyJSON é um serviço público, mantenha cargas **modestas** em CI para não ser bloqueado; use rampas curtas e limites de RPS configuráveis.

---

# 9) `handleSummary` (export JSON / JUnit opcional)

Em `libs/reporting/summary.ts`:

```ts
import { jUnit } from 'https://raw.githubusercontent.com/simbadltd/k6-junit/master/dist/index.js';

export function handleSummary(data) {
  return {
    'reports/summary.json': JSON.stringify(data),
    'reports/results.junit.xml': jUnit(data), // opcional
  };
}
```

* Alternativa: gerar apenas `summary.json` e converter via CLI (`l-ross/k6-junit`) num *step* do Actions. ([GitHub][16])

---

# 10) Boas práticas de código & observabilidade do teste

* **Tags em tudo** (`feature`, `kind`, `endpoint`) — ajudam a fatiar métricas.
* **Checks enxutos** (status, shape mínimo de payload) + **Thresholds** por *P95* e *error-rate* (quebram o build). ([Grafana Labs][13])
* **Requisições em lote** (`http.batch`) quando fizer sentido para paralelismo de pequenos GETs.
* **Dados idempotentes**: evite depender de “persistência” no DummyJSON; trate POST/PUT/DELETE como *mock response*. ([DummyJSON][3])
* **Remote modules versionados** (sempre com versão fixa no URL do `jslib.k6.io`). ([jslib.k6.io][5])
* **Typecheck no CI** com `@types/k6` (melhora muito o autocomplete/erros). ([NPM][7])

---

# 11) Estratégia de PR & governança

* **Branching**: `main` (estável) / `feat/*` (novos fluxos) / `fix/*`.
* **Templates**:

  * PR template exigindo: link do `scenario.yaml`, qual *feature* (tag), SLOs alvo, amostra de *summary* local.
  * Issue template para *novos cenários* (inputs: endpoints, dados, SLO preliminar, riscos).
* **CODEOWNERS**: `tests/api/products/* @equipe-perf`, etc.
* **Quality gates no PR**:

  1. `tsc --noEmit` ok
  2. Smoke passou sem violar thresholds
  3. Artefatos `summary.json` publicados

---

# 12) Roadmap (time de 2 pessoas)

* **Semana 1**

  * Bootstrap do repo (estrutura acima), 1–2 cenários (products browse/search), smoke no PR.
* **Semana 2**

  * Consolidar `libs/http` (retry/backoff, headers padrão), `libs/data` (open/SharedArray).
  * Baseline no `main` com 10 min.
* **Semana 3–4**

  * Adicionar login (`/auth/login`) + `/auth/me` e cenários de *mix navegacional*. ([DummyJSON][14])
  * Introduzir `handleSummary` + artefatos em todos os jobs.
* **Mês 2+**

  * Se precisar DB auxiliar, avaliar `xk6-sql` + driver SQL Server.
  * Se o stack migrar para gRPC, já há suporte first-class em `k6/net/grpc`. ([GitHub][10])

---

## Apêndices úteis (links de referência)

* **DummyJSON Docs** (products, users, auth): endpoints, filtros, listas de categorias. ([DummyJSON][3])
* **k6 — executors & thresholds**: base para workload model e quality gates. ([Grafana Labs][2])
* **TypeScript no k6**: `k6 run script.ts` (TS via esbuild), checagem com `@types/k6`. ([Grafana Labs][1])
* **jslib.k6.io**: utils & jsonpath como módulos remotos versionados. ([jslib.k6.io][5])
* **Actions oficiais**: instalar e rodar k6 no GitHub Actions. ([Grafana Labs][15])
* **Relatórios**: end-of-test summary (JSON); conversores para HTML/JUnit (awesome-k6). ([Grafana Labs][8])

---

## Fecho opinativo (de head de NFT 😎)

A regra de ouro para testes de API em CI com serviço público é **respeito** ao alvo: *open model* com RPS modesto, rampas curtas e thresholds que detectam regressão sem virar DoS. O monorepo acima te dá: **escala organizacional**, **reuso honesto**, e **gate de qualidade explícito**. Depois que isso “fecha ciclo” (PR → smoke → baseline), dá para plugar observabilidade mais parruda, resultados em JUnit/HTML e, quando fizer sentido, estender para SQL/Kafka/gRPC sem reescrever a casa inteira.

Quer que eu já te gere os primeiros arquivos (`package.json`, `tsconfig`, 2 scripts TS e 2 workflows YAML) seguindo esse blueprint?

[1]: https://grafana.com/docs/k6/latest/using-k6/javascript-typescript-compatibility-mode/?utm_source=chatgpt.com "JavaScript and TypeScript compatibility mode - Using k6"
[2]: https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/?utm_source=chatgpt.com "Executors | Grafana k6 documentation"
[3]: https://dummyjson.com/docs/products "Products - DummyJSON - Free Fake REST API for Placeholder JSON Data"
[4]: https://grafana.com/docs/k6/latest/javascript-api/init-context/open/?utm_source=chatgpt.com "open( filePath, [mode] ) | Grafana k6 documentation"
[5]: https://jslib.k6.io/?utm_source=chatgpt.com "jslib.k6.io - JS std lib"
[6]: https://grafana.com/docs/k6/latest/javascript-api/k6-net-grpc/?utm_source=chatgpt.com "k6/net/grpc"
[7]: https://www.npmjs.com/package/%40types/k6?utm_source=chatgpt.com "types/k6"
[8]: https://grafana.com/docs/k6/latest/get-started/results-output/?utm_source=chatgpt.com "Results output | Grafana k6 documentation"
[9]: https://github.com/l-ross/k6-junit?utm_source=chatgpt.com "CLI to convert k6 JSON summary in to JUnit XML format"
[10]: https://github.com/grafana/xk6-sql?utm_source=chatgpt.com "grafana/xk6-sql: Use SQL databases from k6 tests."
[11]: https://github.com/mostafa/xk6-kafka?utm_source=chatgpt.com "mostafa/xk6-kafka: k6 extension to load test Apache ..."
[12]: https://grafana.com/docs/k6/latest/extensions/explore/ "Explore extensions | Grafana k6 documentation
"
[13]: https://grafana.com/docs/k6/latest/using-k6/thresholds/?utm_source=chatgpt.com "Thresholds | Grafana k6 documentation"
[14]: https://dummyjson.com/docs/auth?utm_source=chatgpt.com "Auth - DummyJSON - Free Fake REST API for Placeholder ..."
[15]: https://grafana.com/blog/2024/07/15/performance-testing-with-grafana-k6-and-github-actions/?utm_source=chatgpt.com "Performance testing with Grafana k6 and GitHub Actions"
[16]: https://github.com/simbadltd/k6-junit?utm_source=chatgpt.com "k6 JUnit summary exporter libray"
