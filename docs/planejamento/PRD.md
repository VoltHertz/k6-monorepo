# Product Requirements Document (PRD)
## Monorepo de Testes de Performance com k6 + TypeScript

**Versão:** 1.0  
**Data:** 03 de Outubro de 2025  
**Owner:** Codex CLI (GPT‑5) — Agente de IA (branch `feature/codex-implementation`)  
**Status:** 🟡 Em implementação nesta branch

---

## 📋 Sumário Executivo

Este documento define os requisitos, arquitetura, governança e roadmap para a construção de um **monorepo enterprise-grade de testes de performance** utilizando Grafana k6 com TypeScript. O projeto visa estabelecer uma plataforma de testes não-funcionais escalável, sustentável e com qualidade de código superior, projetada para durar 10+ anos.

### Objetivos Principais

1. **Centralização**: Monorepo único com design modular e contratos de manutenção claros
2. **Type Safety**: TypeScript como linguagem principal com checagem estática no CI/CD
3. **Quality Gates**: Thresholds automatizados que falham builds quando SLOs são violados
4. **Observabilidade**: Relatórios, métricas customizadas e rastreabilidade end-to-end
5. **Domínio Realista**: Casos de uso baseados em DummyJSON API com dados parametrizados

### Métricas de Sucesso

| Métrica | Baseline Atual | Meta Q1 2026 | Meta Q4 2026 |
|---------|---------------|--------------|--------------|
| Cobertura de UCs (UC001–UC013) | 0% | 70% | 100% |
| Tempo de Execução (Smoke) | N/A | < 2 min | < 1 min |
| Taxa de Falsos Positivos | N/A | < 5% | < 1% |
| Reutilização de Código | N/A | 40% | 70% |
| Time to Market (novo teste) | N/A | 4h | 1h |

---

## 🤖 Execução por Agentes de IA (Branch Codex)

- Implementador: Codex CLI (GPT‑5), atuando de forma autônoma nesta branch.
- Concorrência: GitHub Copilot (Claude Sonnet 4.5) implementa em `feature/copilot-implementation`. Sem colaboração cruzada; comparação final por maturidade, estabilidade e aderência ao PRD/UCs.
- Escopo mínimo desta branch:
  - 13/13 UCs implementadas (UC001–UC013) com testes k6 executáveis.
  - 3 libs reutilizáveis: `libs/observability`, `libs/data`, `libs/http`.
  - 15+ arquivos em `data/test-data/` (curados, determinísticos quando possível).
- Política de trabalho: “patch‑first”, diffs pequenos, commits/push somente com aprovação.
- Restrições e ética: uso moderado do DummyJSON (open model, RPS baixo em CI); módulos remotos versionados; sem segredos no repo.

---

## 🎯 Contexto e Motivação

### Problema Atual

- **Ausência de testes não-funcionais** sistematizados
- Falta de visibilidade sobre performance/latência das APIs
- Impossibilidade de detectar regressões de performance em PRs
- Dados de teste desorganizados e sem versionamento
- Zero automação de quality gates

### Solução Proposta

Um monorepo baseado no **k6-template-typescript oficial** da Grafana, estendido com:

- Estrutura modular por domínio (products, users, auth, carts, etc.)
- Bibliotecas compartilhadas (`libs/`) para reuso máximo
- Configurações declarativas em YAML (scenarios, envs)
- Pipeline GitHub Actions com smoke/baseline/stress/soak
- Casos de uso documentados em `/docs/casos_de_uso`
- Estratégia de dados separando "dados da aplicação" de "massa de teste"

---

## 🏗️ Arquitetura e Estrutura

### 1. Layout do Monorepo

```
k6-monorepo/
├── .github/
│   ├── workflows/
│   │   ├── k6-pr-smoke.yml           # Smoke em PRs (30-60s)
│   │   ├── k6-main-baseline.yml      # Baseline em main (5-10min)
│   │   ├── k6-stress.yml             # Stress test sob demanda
│   │   └── k6-soak.yml               # Soak test (30-60min, cron)
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   │   ├── new-scenario.md
│   │   └── bug-report.md
│   └── CODEOWNERS
│
├── docs/
│   ├── planejamento/
│   │   ├── PRD.md                    # Este documento
│   │   └── ADRs/                     # Architectural Decision Records
│   │       ├── 001-typescript-adoption.md
│   │       ├── 002-open-model-executors.md
│   │       └── 003-data-strategy.md
│   ├── casos_de_uso/
│   │   ├── README.md
│   │   ├── UC001-browse-products.md
│   │   ├── UC002-search-filter.md
│   │   ├── UC003-user-login.md
│   │   ├── UC004-cart-operations.md
│   │   └── templates/
│   │       └── use-case-template.md
│   ├── dummyJson/                    # Docs da API DummyJSON
│   │   └── (arquivos existentes)
│   └── runbooks/
│       ├── troubleshooting.md
│       └── performance-analysis.md
│
├── data/
│   ├── fulldummyjsondata/            # ⚠️ Dados reais - SOMENTE LEITURA
│   │   └── (arquivos existentes)
│   └── test-data/                    # Massa de teste gerada
│       ├── users.csv
│       ├── products.csv
│       ├── search-queries.csv
│       └── generators/               # Scripts para gerar massa
│           ├── generate-users.ts
│           └── generate-products.ts
│
├── tests/
│   ├── api/
│   │   ├── products/
│   │   │   ├── browse-catalog.test.ts
│   │   │   ├── search-products.test.ts
│   │   │   ├── filter-category.test.ts
│   │   │   └── crud-simulated.test.ts
│   │   ├── users/
│   │   │   ├── login.test.ts
│   │   │   ├── get-me.test.ts
│   │   │   └── list-users.test.ts
│   │   ├── carts/
│   │   │   ├── add-items.test.ts
│   │   │   └── view-cart.test.ts
│   │   └── auth/
│   │       ├── refresh-token.test.ts
│   │       └── session-validation.test.ts
│   └── scenarios/                    # Cenários compostos (jornadas)
│       ├── user-journey-browse.test.ts
│       └── user-journey-checkout.test.ts
│
├── libs/
│   ├── http/
│   │   ├── client.ts                 # Wrapper HTTP com retry/backoff
│   │   ├── checks.ts                 # Checks reutilizáveis
│   │   └── interceptors.ts           # Logging, headers padrão
│   ├── data/
│   │   ├── loader.ts                 # SharedArray com open()
│   │   ├── generators.ts             # UUID, random, faker
│   │   └── parsers.ts                # CSV/JSON parsing
│   ├── scenarios/
│   │   ├── profiles.ts               # Fábrica de executors
│   │   ├── tags.ts                   # Tag strategy
│   │   └── workloads.ts              # Padrões de carga
│   ├── metrics/
│   │   ├── custom-metrics.ts         # Trends, Counters customizados
│   │   └── slo-validator.ts          # Validação de SLOs
│   └── reporting/
│       ├── summary.ts                # handleSummary (JSON/JUnit)
│       ├── html-reporter.ts          # Geração de HTML (opcional)
│       └── slack-notifier.ts         # Notificações (futuro)
│
├── configs/
│   ├── envs/
│   │   ├── local.json                # Configurações locais
│   │   ├── ci.json                   # Configurações CI
│   │   └── prod-like.json            # Ambiente prod-like
│   ├── scenarios/
│   │   ├── smoke.yaml                # 30-60s, 1-2 RPS
│   │   ├── baseline.yaml             # 5-10min, 5-10 RPS
│   │   ├── stress.yaml               # Rampa até breaking point
│   │   └── soak.yaml                 # 30-60min, RPS moderado
│   └── thresholds/
│       ├── default.yaml              # Thresholds padrão
│       └── strict.yaml               # Thresholds rigorosos
│
├── scripts/
│   ├── setup-local.sh                # Setup ambiente local
│   ├── validate-data.sh              # Valida massa de teste
│   └── generate-report.sh            # Converte summary → HTML/JUnit
│
├── .vscode/
│   ├── settings.json
│   ├── extensions.json
│   └── launch.json                   # Debug configs
│
├── package.json
├── tsconfig.json
├── .eslintrc.js
├── .prettierrc
├── .gitignore
├── .nvmrc
└── README.md
```

### 2. Decisões Arquiteturais (ADRs)

#### ADR-001: Adoção do TypeScript
- **Decisão**: TypeScript como linguagem principal
- **Rationale**: Type safety, autocomplete, refactoring seguro, `tsc --noEmit` no CI
- **Trade-offs**: Requer compilação, mas k6 suporta nativamente via esbuild

#### ADR-002: Open Model Executors
- **Decisão**: Usar `constant-arrival-rate` e `ramping-arrival-rate` como padrão
- **Rationale**: Open model reflete comportamento real de usuários, evita bottleneck de VUs
- **Trade-offs**: Mais complexo configurar, mas métricas mais realistas

#### ADR-003: Estratégia de Dados
- **Decisão**: Separar dados da aplicação (`fulldummyjsondata/`) de massa de teste (`test-data/`)
- **Rationale**: 
  - `fulldummyjsondata/` = dump completo da API, usado APENAS para **referência e geração inicial**
  - `test-data/` = massa curada, versionada, otimizada para testes (CSV/JSON pequenos)
- **Trade-offs**: Duplicação de dados, mas isolamento e controle total

---

## 📊 Casos de Uso e Cenários

### Estrutura de Caso de Uso

Cada caso de uso em `/docs/casos_de_uso` deve seguir o template:

```markdown
# UC00X - [Nome do Caso de Uso]

## Descrição
[Descrição do perfil de acesso]

## Pré-condições
- Dados: [link para massa de teste]
- Auth: [tipo de autenticação necessária]

## Fluxo Principal
1. [Passo 1]
2. [Passo 2]
...

## Endpoints Envolvidos
- GET /endpoint1 (P95 < 300ms, error < 0.5%)
- POST /endpoint2 (P95 < 500ms, error < 1%)

## SLOs
| Métrica | Threshold |
|---------|-----------|
| http_req_duration{p95} | < 500ms |
| http_req_failed | < 1% |
| checks | > 99% |

## Dados de Teste
- Arquivo: `data/test-data/users.csv`
- Volume: 100 registros
- Gerador: `data/test-data/generators/generate-users.ts`

## Implementação
- Arquivo: `tests/api/users/login.test.ts`
- Cenário: `configs/scenarios/baseline.yaml`
```

### Casos de Uso Prioritários

Nota (branch Codex): a meta é cobrir UC001–UC013. A tabela abaixo representa uma ordem de arranque; os demais UCs seguem os templates e requisitos em `docs/casos_de_uso`.

| ID | Nome | Prioridade | Endpoints | Complexidade |
|----|------|------------|-----------|--------------|
| UC001 | Browse Products Catalog | P0 | `/products`, `/products/categories` | Baixa |
| UC002 | Search & Filter Products | P0 | `/products/search`, `/products/category/{slug}` | Média |
| UC003 | User Login & Profile | P0 | `/auth/login`, `/auth/me` | Baixa |
| UC004 | Cart Operations (Read) | P1 | `/carts`, `/carts/{id}` | Baixa |
| UC005 | Cart Operations (Write) | P1 | `/carts/add` (simulated) | Média |
| UC006 | User Journey: Browse → Search → View Details | P1 | Múltiplos | Alta |
| UC007 | Concurrent Users (Mixed Workload) | P2 | Múltiplos | Alta |

---

## 🛠️ Stack Tecnológico

### Core
- **k6**: v0.57+ (suporte nativo a TypeScript via esbuild)
- **TypeScript**: 5.x
- **Node.js**: 20.x LTS

### Bibliotecas k6
- **Built-in**: `k6/http`, `k6/metrics`, `k6/execution`
- **jslib.k6.io** (versionados):
  - `k6-utils@1.4.0` (randomItem, uuidv4)
  - `jsonpath@1.0.2` (extração de campos JSON aninhados)
- **@types/k6**: Para type checking no IDE/CI

### Extensões Futuras (xk6)
- **xk6-sql + driver SQL Server**: Para testes com DB auxiliar
- **xk6-kafka**: Para cenários event-driven
- **xk6-browser** (experimental): Para testes híbridos API + Browser

### DevOps & Reporting
- **GitHub Actions**: CI/CD
  - `grafana/setup-k6-action@v1`
  - `grafana/run-k6-action@v3`
- **Relatórios**:
  - `handleSummary` (nativo): JSON export
  - `simbadltd/k6-junit`: JUnit XML para GitHub Test Reports
  - HTML dashboard (via `k6-html-reporter` ou custom)

### Qualidade de Código
- **ESLint**: Linting TS
- **Prettier**: Formatação
- **Husky**: Git hooks (pre-commit, pre-push)
- **lint-staged**: Rodar linters apenas em arquivos modificados

---

## 📈 Estratégia de Workload e SLOs

### Matriz de Cenários

| Cenário | Objetivo | Duração | RPS/Arrival Rate | VUs | Quando Rodar |
|---------|----------|---------|------------------|-----|--------------|
| **Smoke** | Validação funcional rápida | 30-60s | 1-2 rps | 5-10 | Todo PR |
| **Baseline** | Validação de performance padrão | 5-10min | 5-10 rps | 20-50 | Merge em `main`, daily |
| **Stress** | Encontrar breaking point | 10-20min | Rampa 1→50 rps | 10→200 | Sob demanda, semanal |
| **Soak** | Detectar memory leaks, degradação | 30-60min | 5-8 rps constante | 30-50 | Semanal (cron), pré-release |
| **Spike** | Resiliência a picos súbitos | 5-10min | 5→50→5 rps | 10→200→10 | Sob demanda |

### SLOs Padrão

```yaml
# configs/thresholds/default.yaml
thresholds:
  http_req_duration:
    - p(95) < 500    # 95% das requisições < 500ms
    - p(99) < 1000   # 99% das requisições < 1s
  http_req_failed:
    - rate < 0.01    # Taxa de erro < 1%
  checks:
    - rate > 0.99    # 99% dos checks passam
  http_req_waiting:
    - p(95) < 400    # Time to first byte
```

### SLOs por Feature (Tagged)

```javascript
thresholds: {
  'http_req_duration{feature:products}': ['p(95)<300'],      // Products mais rápidos
  'http_req_duration{feature:auth}': ['p(95)<400'],          // Auth pode ser < 400ms
  'http_req_duration{feature:search}': ['p(95)<600'],        // Search mais tolerante
  'checks{feature:products}': ['rate>0.995'],                // Products com 99.5% checks OK
}
```

---

## 🔄 Estratégia de Dados

### Princípios

1. **Imutabilidade**: Dados em `fulldummyjsondata/` são **read-only** (referência histórica)
2. **Geração Controlada**: Massa de teste em `test-data/` é gerada via scripts versionados
3. **Formato Otimizado**: CSV para volume, JSON para estruturas complexas
4. **Versionamento**: Massa de teste é commitada no Git (volumes pequenos)
5. **Refresh Strategy**: Regenerar massa de teste quando API DummyJSON mudar

### Fluxo de Geração de Massa

```bash
# 1. Analisa dados completos da aplicação
node data/test-data/generators/generate-users.ts \
  --source data/fulldummyjsondata/users.json \
  --output data/test-data/users.csv \
  --sample-size 100

# 2. Valida integridade
npm run validate:test-data

# 3. Commit no repo
git add data/test-data/
git commit -m "chore: update test data (sample 100 users)"
```

### Exemplo de Gerador

```typescript
// data/test-data/generators/generate-users.ts
import { readFileSync, writeFileSync } from 'fs';
import { parse } from 'json2csv';

const fullData = JSON.parse(readFileSync('data/fulldummyjsondata/users.json', 'utf-8'));
const sample = fullData.users.slice(0, 100); // Primeiros 100 usuários

const csv = parse(sample, { 
  fields: ['id', 'username', 'password', 'email', 'firstName', 'lastName'] 
});

writeFileSync('data/test-data/users.csv', csv);
console.log('✅ Generated users.csv with 100 records');
```

### Uso em Testes (SharedArray)

```typescript
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

const users = new SharedArray('users', function() {
  return papaparse.parse(open('../../data/test-data/users.csv'), { header: true }).data;
});

export default function() {
  const user = users[Math.floor(Math.random() * users.length)];
  // ...
}
```

---

## 🚀 Pipeline CI/CD

### GitHub Actions Workflows

#### 1. PR Smoke Test (`.github/workflows/k6-pr-smoke.yml`)

```yaml
name: k6 PR Smoke Test
on:
  pull_request:
    paths:
      - 'tests/**'
      - 'libs/**'
      - 'configs/**'
      - 'data/test-data/**'
      - 'package.json'
      - 'tsconfig.json'

jobs:
  quality-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - run: npm ci
      
      - name: Type Check
        run: npm run typecheck
      
      - name: Lint
        run: npm run lint
      
      - name: Setup k6
        uses: grafana/setup-k6-action@v1
        with:
          version: 'v0.57.0'
      
      - name: Run Smoke Tests
        uses: grafana/run-k6-action@v3
        with:
          paths: 'tests/api/**/*.test.ts'
          parallel: true
          fail-fast: true
        env:
          BASE_URL: https://dummyjson.com
          K6_RPS: "2"
          K6_DURATION: "45s"
          K6_ENV: "ci"
      
      - name: Generate Summary
        if: always()
        run: |
          mkdir -p reports
          k6 run --summary-export=reports/summary.json --quiet tests/api/products/browse-catalog.test.ts
      
      - name: Upload Reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: k6-smoke-reports
          path: reports/
          retention-days: 30
      
      - name: Comment PR
        if: always()
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = JSON.parse(fs.readFileSync('reports/summary.json', 'utf8'));
            const comment = `## k6 Smoke Test Results\n\n` +
              `- ✅ Requests: ${summary.metrics.http_reqs.count}\n` +
              `- ⏱️ P95 Latency: ${summary.metrics.http_req_duration['p(95)']}ms\n` +
              `- ❌ Error Rate: ${(summary.metrics.http_req_failed.rate * 100).toFixed(2)}%`;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

#### 2. Main Baseline Test (`.github/workflows/k6-main-baseline.yml`)

- Similar ao smoke, mas:
  - `K6_RPS: "10"`
  - `K6_DURATION: "10m"`
  - Roda apenas em push para `main`
  - Armazena resultados históricos (trend analysis)

#### 3. On-Demand Stress/Soak (`.github/workflows/k6-on-demand.yml`)

```yaml
name: k6 On-Demand Test
on:
  workflow_dispatch:
    inputs:
      scenario:
        description: 'Scenario to run'
        required: true
        type: choice
        options:
          - stress
          - soak
          - spike
      rps:
        description: 'Target RPS (or max for ramps)'
        required: false
        default: '20'
      duration:
        description: 'Duration (e.g., 10m, 1h)'
        required: false
        default: '10m'

jobs:
  run-test:
    runs-on: ubuntu-latest
    steps:
      # ... (similar setup)
      - name: Run k6 Test
        run: |
          k6 run \
            --config configs/scenarios/${{ inputs.scenario }}.yaml \
            --env K6_RPS=${{ inputs.rps }} \
            --env K6_DURATION=${{ inputs.duration }} \
            --summary-export=reports/summary-${{ inputs.scenario }}.json \
            tests/scenarios/user-journey-browse.test.ts
```

### Quality Gates (Fail Conditions)

1. **Type Check**: `tsc --noEmit` deve passar
2. **Linting**: `eslint` sem erros críticos
3. **Smoke Test**: Thresholds devem passar (P95 < 500ms, error < 1%)
4. **Code Coverage** (futuro): Min 60% das funções em `libs/` testadas

---

## 📚 Padrões de Código

### Estrutura de Teste

```typescript
// tests/api/products/browse-catalog.test.ts
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import { getConfig } from '../../../libs/scenarios/profiles';
import { baseHeaders } from '../../../libs/http/interceptors';

// Custom Metrics
const productListDuration = new Trend('product_list_duration_ms');
const productListErrors = new Counter('product_list_errors');

// Test Data
const categories = new SharedArray('categories', function() {
  return JSON.parse(open('../../../data/test-data/categories.json'));
});

// Scenario Configuration
export const options = getConfig('baseline', {
  scenarios: {
    browse_catalog: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 5,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'products', kind: 'browse', uc: 'UC001' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products}': ['p(95)<300'],
    'http_req_failed{feature:products}': ['rate<0.005'],
    'checks{uc:UC001}': ['rate>0.995'],
    product_list_duration_ms: ['p(95)<250'],
  },
});

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  // 1. Browse main catalog
  const listRes = http.get(
    `${BASE_URL}/products?limit=20&skip=${Math.floor(Math.random() * 80)}`,
    { headers: baseHeaders(), tags: { name: 'list_products' } }
  );
  
  productListDuration.add(listRes.timings.duration);
  
  const listOk = check(listRes, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => r.json('products') && Array.isArray(r.json('products')),
    'products not empty': (r) => r.json('products').length > 0,
  }, { uc: 'UC001', step: 'list' });
  
  if (!listOk) {
    productListErrors.add(1);
  }
  
  // 2. Explore random category
  const category = randomItem(categories);
  const catRes = http.get(
    `${BASE_URL}/products/category/${category.slug}`,
    { headers: baseHeaders(), tags: { name: 'get_category' } }
  );
  
  check(catRes, {
    'category status 200': (r) => r.status === 200,
    'category has products': (r) => r.json('products').length > 0,
  }, { uc: 'UC001', step: 'category' });
  
  sleep(1);
}

// Teardown (opcional)
export function teardown(data) {
  console.log('✅ Test completed');
}
```

### Biblioteca de HTTP Client

```typescript
// libs/http/client.ts
import http from 'k6/http';
import { sleep } from 'k6';

export interface RetryConfig {
  maxRetries: number;
  backoffMs: number;
  retryOn: number[]; // status codes to retry
}

const DEFAULT_RETRY: RetryConfig = {
  maxRetries: 3,
  backoffMs: 100,
  retryOn: [502, 503, 504],
};

export function httpGetWithRetry(url: string, config: RetryConfig = DEFAULT_RETRY) {
  let attempts = 0;
  let response;
  
  while (attempts <= config.maxRetries) {
    response = http.get(url);
    
    if (!config.retryOn.includes(response.status)) {
      return response;
    }
    
    attempts++;
    if (attempts <= config.maxRetries) {
      sleep(config.backoffMs / 1000);
    }
  }
  
  return response;
}
```

### Biblioteca de Checks

```typescript
// libs/http/checks.ts
import { check } from 'k6';

export function checkStatus200(response: any, tags?: object) {
  return check(response, {
    'status is 200': (r) => r.status === 200,
  }, tags);
}

export function checkResponseTime(response: any, maxMs: number, tags?: object) {
  return check(response, {
    [`response time < ${maxMs}ms`]: (r) => r.timings.duration < maxMs,
  }, tags);
}

export function checkJsonShape(response: any, schema: object, tags?: object) {
  const checks = {};
  for (const [key, validator] of Object.entries(schema)) {
    checks[`has ${key}`] = (r) => validator(r.json(key));
  }
  return check(response, checks, tags);
}
```

---

## 🔐 Governança e Colaboração

### CODEOWNERS

```
# .github/CODEOWNERS
* @perf-team-leads

/tests/api/products/* @perf-team @product-team
/tests/api/users/* @perf-team @identity-team
/tests/api/auth/* @perf-team @security-team

/libs/** @perf-team-leads
/configs/** @perf-team-leads

/docs/casos_de_uso/* @perf-team @product-owners
/data/test-data/* @perf-team @qa-team
```

### Pull Request Template

```markdown
## PR Checklist

- [ ] Caso de uso documentado em `/docs/casos_de_uso/UC00X.md`
- [ ] Massa de teste gerada/atualizada em `/data/test-data/`
- [ ] Tags aplicadas (feature, uc, kind)
- [ ] Thresholds definidos no `options`
- [ ] Smoke test local executado com sucesso
- [ ] `npm run typecheck` passa
- [ ] `npm run lint` passa

## Scenario Details

- **Feature**: [products/users/auth/carts]
- **Use Case**: UC00X - [Nome]
- **Workload**: [smoke/baseline/stress/soak]
- **SLOs**: 
  - P95 < Xms
  - Error rate < Y%

## Local Test Results

```
✅ P95 latency: XXXms
✅ Error rate: X.XX%
✅ Checks passed: XX.X%
```

## Links

- Caso de Uso: [link]
- Documentação API: [link]
```

### Issue Template (New Scenario)

```markdown
---
name: New Performance Scenario
about: Proposta de novo cenário de teste não-funcional
title: '[SCENARIO] '
labels: performance, new-scenario
assignees: ''
---

## Scenario Overview

**Feature**: [products/users/auth/carts]
**Priority**: [P0/P1/P2]

## Business Context

[Por que este cenário é importante? Qual perfil de usuário representa?]

## Endpoints Involved

- [ ] GET /endpoint1
- [ ] POST /endpoint2
- [ ] ...

## Proposed SLOs

| Metric | Threshold |
|--------|-----------|
| P95 latency | < Xms |
| Error rate | < Y% |
| Checks | > Z% |

## Test Data Requirements

- [ ] Massa de teste existe em `/data/test-data/`
- [ ] Volume necessário: X registros
- [ ] Gerador criado: [sim/não]

## Acceptance Criteria

- [ ] Caso de uso documentado
- [ ] Script TS implementado
- [ ] Smoke test passa em CI
- [ ] Thresholds validados localmente
```

---

## 📅 Roadmap de Implementação

### Fase 0: Bootstrapping (Semana 1)

**Objetivo**: Estrutura base funcional com 1 teste exemplo

- [ ] Fork/clone do `k6-template-typescript` oficial
- [ ] Adaptar estrutura de pastas conforme PRD
- [ ] Configurar `package.json`, `tsconfig.json`, ESLint, Prettier
- [ ] Setup GitHub Actions (smoke no PR)
- [ ] Implementar UC001 (Browse Products) como prova de conceito
- [ ] Gerar primeira massa de teste (`users.csv`, `categories.json`)
- [ ] Documentar UC001 em `/docs/casos_de_uso/UC001-browse-products.md`

**Entregáveis**:
- ✅ Repo com estrutura completa
- ✅ 1 teste TS rodando no CI
- ✅ 1 caso de uso documentado
- ✅ Pipeline PR smoke funcional

---

### Fase 1: Fundações (Semanas 2-3)

**Objetivo**: Libs compartilhadas + 5 casos de uso core

**Casos de Uso**:
- [x] UC001 - Browse Products (já existe)
- [ ] UC002 - Search & Filter Products
- [ ] UC003 - User Login & Profile
- [ ] UC004 - Cart Operations (Read)
- [ ] UC005 - View Product Details

**Libs**:
- [ ] `libs/http/client.ts` (retry, backoff)
- [ ] `libs/http/checks.ts` (checks reutilizáveis)
- [ ] `libs/data/loader.ts` (SharedArray wrapper)
- [ ] `libs/scenarios/profiles.ts` (fábrica de configs)
- [ ] `libs/reporting/summary.ts` (handleSummary JSON/JUnit)

**CI/CD**:
- [ ] Baseline test em `main` (5min, 10 RPS)
- [ ] Artefatos de relatório (summary.json, JUnit XML)

**Entregáveis**:
- ✅ 5 casos de uso documentados + implementados
- ✅ Libs reutilizáveis funcionais
- ✅ Pipeline main com baseline

---

### Fase 2: Escalabilidade (Semanas 4-5)

**Objetivo**: Cenários compostos + on-demand tests

**Cenários Compostos**:
- [ ] User Journey: Browse → Search → View Details → Add to Cart
- [ ] Mixed Workload: 60% browse + 30% search + 10% login

**Workloads Avançados**:
- [ ] Stress test (ramping-arrival-rate até breaking point)
- [ ] Soak test (30min, detecção de memory leaks)
- [ ] Spike test (picos súbitos de 5→50→5 RPS)

**CI/CD**:
- [ ] Workflow on-demand (workflow_dispatch)
- [ ] Notificações Slack (opcional)

**Entregáveis**:
- ✅ 2 jornadas de usuário implementadas
- ✅ 3 workloads avançados (stress, soak, spike)
- ✅ Workflow on-demand funcional

---

### Fase 3: Observabilidade (Semanas 6-8)

**Objetivo**: Métricas customizadas + relatórios avançados

**Métricas Customizadas**:
- [ ] Trends por feature (product_list_duration, search_duration)
- [ ] Counters de business (products_viewed, carts_created)
- [ ] SLO Validator (validação automática de SLOs)

**Relatórios**:
- [ ] HTML dashboard (k6-html-reporter ou custom)
- [ ] Trend analysis (comparação histórica de baselines)
- [ ] Slack/Teams notifications com resumo

**Entregáveis**:
- ✅ 10+ custom metrics implementadas
- ✅ Dashboard HTML gerado automaticamente
- ✅ Notificações ativas

---

### Fase 4: Extensibilidade (Mês 3+)

**Objetivo**: Extensões xk6 + casos avançados

**Extensões**:
- [ ] `xk6-sql` + SQL Server driver (testes com DB)
- [ ] `xk6-kafka` (cenários event-driven)
- [ ] `xk6-browser` (experimental, híbrido API+UI)

**Casos Avançados**:
- [ ] Testes com DB auxiliar (validação de consistência)
- [ ] Testes de resiliência (circuit breaker, rate limiting)
- [ ] Chaos engineering (injeção de falhas)

**Entregáveis**:
- ✅ 1+ extensão xk6 integrada
- ✅ 3 casos de uso avançados
- ✅ Documentação de arquitetura atualizada

---

## 🎯 Critérios de Aceite — Branch Codex

Este PRD, para a branch `feature/codex-implementation`, considera concluída a implementação quando:

- [ ] 13/13 UCs implementadas e executáveis: UC001–UC013 em `docs/casos_de_uso/*` refletidos em `tests/api/**`.
- [ ] 3 libs reutilizáveis publicadas e usadas pelos testes:
  - `libs/observability` (tags, métricas, thresholds/summary helpers)
  - `libs/data` (loader/generators para `data/test-data/`)
  - `libs/http` (base URL, headers, retry/backoff simples)
- [ ] 15+ arquivos em `data/test-data/` versionados, validados, sem PII.
- [ ] Executores open‑model apenas; thresholds por feature/UC ativos e quebrando o build em violação.
- [ ] Execução local documentada (ex.: `K6_RPS=5 K6_DURATION=2m k6 run tests/api/...`).
- [ ] README e ADRs atualizados para decisões chave (dados, thresholds, retries).

Os critérios abaixo (genéricos do PRD) continuam válidos como apoio.

## 🎯 Critérios de Aceite do PRD

### Must-Have (Fase 1)

- [ ] Estrutura de pastas implementada conforme layout
- [ ] 5 casos de uso documentados e implementados
- [ ] Pipeline PR smoke funcional (< 2min)
- [ ] Pipeline main baseline funcional (5-10min)
- [ ] Type checking (`tsc --noEmit`) no CI
- [ ] Massa de teste gerada e versionada
- [ ] Thresholds quebram build quando violados
- [ ] Documentação: README.md, ADRs, casos de uso

### Should-Have (Fase 2)

- [ ] 2 jornadas de usuário (cenários compostos)
- [ ] Stress, soak e spike tests implementados
- [ ] Workflow on-demand funcional
- [ ] Relatórios em JSON + JUnit XML
- [ ] 60% de cobertura de endpoints DummyJSON

### Nice-to-Have (Fase 3-4)

- [ ] HTML dashboard automatizado
- [ ] Notificações Slack/Teams
- [ ] Trend analysis (comparação histórica)
- [ ] 1+ extensão xk6 integrada
- [ ] 95% de cobertura de endpoints DummyJSON

---

## 📖 Apêndices

### A. Referências Técnicas

- [k6 Official Docs](https://grafana.com/docs/k6/latest/)
- [k6 TypeScript Template](https://github.com/grafana/k6-template-typescript)
- [jslib.k6.io](https://jslib.k6.io/)
- [DummyJSON API Docs](https://dummyjson.com/docs)
- [k6 Extensions](https://grafana.com/docs/k6/latest/extensions/explore/)
- [GitHub Actions - k6 Integration](https://grafana.com/blog/2024/07/15/performance-testing-with-grafana-k6-and-github-actions/)

### B. Templates e Boilerplates

- Template de Caso de Uso: `/docs/casos_de_uso/templates/use-case-template.md`
- Template de Cenário: `/configs/scenarios/template.yaml`
- Template de PR: `.github/PULL_REQUEST_TEMPLATE.md`
- Template de Issue: `.github/ISSUE_TEMPLATE/new-scenario.md`

### C. Glossário

- **Open Model**: Modelo de carga onde VUs são criados sob demanda para atingir RPS alvo
- **Closed Model**: Modelo onde número fixo de VUs executa iterações (não recomendado para APIs)
- **Threshold**: Condição que falha o teste se violada (quality gate)
- **Check**: Validação dentro do teste (não falha o teste, apenas métrica)
- **SharedArray**: Estrutura de dados compartilhada entre VUs (economia de memória)
- **Executor**: Estratégia de execução do cenário (constant-arrival-rate, ramping-vus, etc.)
- **SLO**: Service Level Objective (objetivo de nível de serviço)
- **P95**: Percentil 95 (95% das requisições são mais rápidas que este valor)

---

## 🚦 Próximos Passos (Branch Codex)

1. Consolidar backlog UC001–UC013 a partir de `docs/casos_de_uso/*`.
2. Criar esqueleto das libs `observability`, `data`, `http` e integrá-las no primeiro teste.
3. Preparar `data/test-data/` (15+ arquivos curados) e validar carregamento via `SharedArray`.
4. Subir primeiros cenários (products: browse/search) com thresholds e tags padrão.
5. Habilitar workflows de smoke e baseline; publicar `summary.json` como artefato.
6. Iterar por UCs restantes com diffs pequenos + documentação incremental.

---

**Aprovações Necessárias (Branch Codex)**:

- [Y] Aprovação do usuário para commits/pushes e abertura de PR

---

*Este PRD é um documento vivo e será atualizado conforme o projeto evolui. Versionamento em `docs/planejamento/PRD.md` no repositório.*

**Versão:** 1.0  
**Última Atualização:** 03 de Outubro de 2025  
**Próxima Revisão:** 01 de Novembro de 2025
