# UC001 - Browse Products Catalog

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 1 (Muito Simples)  
> **Sprint**: Sprint 1 (Semana 4)  
> **Esforço Estimado**: 4h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo (Persona 1)
- **Distribuição de Tráfego**: 60% do total esperado
- **Objetivo de Negócio**: Explorar catálogo de produtos disponíveis para descoberta e navegação inicial

### Contexto
Usuário acessa a página inicial do e-commerce e deseja visualizar a lista de produtos disponíveis. Esta é a primeira interação típica da **Jornada de Descoberta de Produto**, onde o visitante explora o catálogo sem autenticação prévia. Representa o ponto de entrada principal para 100% das jornadas de compra.

### Valor de Negócio
- **Criticidade**: Essencial (5/5) - Endpoint mais usado, fundação para todo e-commerce
- **Impacto no Tráfego**: 60% do volume total (Persona Visitante Anônimo)
- **Conversão**: Base para navegação que leva a ~15% de conversão para login
- **Quadrante na Matriz**: ✅ **PRIORIDADE MÁXIMA** (Alta criticidade, Baixa complexidade)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/products` | P95 < 300ms | Paginação padrão (30 itens), suporta `limit` e `skip` |

**Total de Endpoints**: 1  
**Operações READ**: 1  
**Operações WRITE**: 0  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Linha 2 (Products/GET /products)

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 300ms | Baseline real: P95=250ms. Margem de 20% segurança para variação de rede/carga |
| `http_req_duration{feature:products}` (P99) | < 500ms | Baseline real: P99=320ms. Margem para casos extremos sem degradação UX |
| `http_req_failed{feature:products}` | < 0.5% | Operação crítica (60% tráfego), tolerância mínima. Alta frequência exige confiabilidade |
| `checks{uc:UC001}` | > 99.5% | Validações core devem passar. Permite 0.5% falhas temporárias de rede |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md`  
**Medição Original**: P50=180ms, P95=250ms, P99=320ms, Max=450ms, Error Rate=0%

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `products-sample.json` | `data/test-data/` | 100 produtos | Extração de `data/fulldummyjsondata/products.json` | Mensal ou quando API DummyJSON atualizar |

### Geração de Dados
```bash
# Extrair amostra de 100 produtos do dump completo
jq '.products[0:100]' data/fulldummyjsondata/products.json > data/test-data/products-sample.json

# Validar estrutura (deve ter id, title, price, category mínimo)
jq '.[0] | keys' data/test-data/products-sample.json
```

### Dependências de Dados
- **Nenhuma** - UC Tier 0 (independente, não requer dados de outros UCs)
- Dados autocontidos para smoke/baseline tests

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC001 listado como independente

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário **não autenticado** (Visitante Anônimo)
- API DummyJSON disponível em https://dummyjson.com
- Nenhuma sessão ativa requerida
- Navegador/cliente HTTP funcional

### Steps

**Step 1: Listar Produtos com Paginação Padrão**  
```http
GET /products?limit=20&skip=0
Headers:
  Content-Type: application/json
```

**Validações** (human-readable checks):
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has products array'` → Response contains `products` array
- ✅ `'has total field'` → Response contains `total` field (número total de produtos)
- ✅ `'products count valid'` → `products.length` <= 20 (respeitando limit)
- ✅ `'products have required fields'` → Each product has `id`, `title`, `price`, `category`

**Think Time**: `2-5s` (navegação casual - usuário lendo/visualizando lista)  
**Fonte Think Time**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 1 (Visitante): 2-5s entre ações

---

**Step 2: Navegação por Paginação (Simulando Scroll/Próxima Página)**  
```http
GET /products?limit=20&skip=${randomInt(20, 80)}
Headers:
  Content-Type: application/json
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'products array present'` → Response contains `products` array
- ✅ `'skip parameter applied'` → Different products returned (offset working)

**Think Time**: `3-7s` (decisão de avançar página, leitura de mais produtos)

---

### Pós-condições
- Usuário visualizou lista de produtos (20-40 produtos dependendo dos steps)
- Sistema retornou dados válidos com paginação funcional
- **Próximos passos típicos** (jornada):
  - **UC004** - View Product Details (clicar em produto específico)
  - **UC002** - Search & Filter Products (refinar busca)
  - **UC007** - Browse by Category (navegar por categoria)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Jornada Típica Visitante

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: API Indisponível
**Condição**: Servidor DummyJSON fora do ar, timeout de rede, ou erro 5xx

**Steps**:
1. Request GET /products falha com timeout (> 5s) ou erro 5xx
2. k6 registra `http_req_failed` = 1

**Validações**:
- ❌ `'API is unavailable'` → Status code >= 500 OR response time > 5000ms
- ❌ `'connection failed'` → Network error ocorreu

**Recuperação**: Retry com exponential backoff (não implementado neste UC base, ver UC012 para resiliência)

---

### Edge Case 1: Limite Inválido
**Condição**: Parâmetro `limit` com valor inválido (ex: limit=0, limit=1000, limit=-1)

**Steps**:
1. GET /products?limit=0
2. API pode retornar:
   - Default de 30 itens (comportamento DummyJSON observado)
   - Ou erro 400 Bad Request

**Validações**:
- ✅ `'handles invalid limit gracefully'` → Status code = 200 (default) OR 400 (validation error)
- ✅ `'returns safe product count'` → Se 200, verificar `products.length` <= 30

---

### Edge Case 2: Skip Além do Total
**Condição**: Parâmetro `skip` maior que total de produtos (~100 na DummyJSON)

**Steps**:
1. GET /products?skip=10000
2. API retorna array vazio (sem produtos disponíveis nessa faixa)

**Validações**:
- ✅ `'status is 200 for out of bounds skip'` → Status code = 200
- ✅ `'products array is empty'` → `products` array vazio `[]`
- ✅ `'total field still present'` → `total` field ainda presente com valor correto (~100)

---

### Edge Case 3: Payload Grande (Limit Máximo)
**Condição**: Request com `limit=100` (máximo permitido)

**Steps**:
1. GET /products?limit=100
2. API retorna todos ~100 produtos

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'returns max products'` → `products.length` = ~100
- ⚠️ **Observação**: Latência aumenta ~40% (P95 ~350ms vs 250ms baseline)

**Fonte**: `docs/casos_de_uso/fase1-baseline-slos.md` - Seção "Payload Size Impact"

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/products/browse-catalog.test.ts`
- **Padrão de Nome**: `<action>-<resource>.test.ts` (browse-catalog)

### Configuração de Cenário
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';

// Custom Metrics
const productListDuration = new Trend('product_list_duration_ms');
const productListSuccess = new Counter('product_list_success');
const productListErrors = new Counter('product_list_errors');

export const options = {
  scenarios: {
    browse_catalog: {
      executor: 'constant-arrival-rate',           // Open model (ADR-002)
      rate: Number(__ENV.K6_RPS) || 5,            // 5 RPS default (ajustável)
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',        // 5min default
      preAllocatedVUs: 10,                        // VUs iniciais
      maxVUs: 50,                                 // VUs máximos (auto-scaling)
      tags: { feature: 'products', kind: 'browse', uc: 'UC001' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products}': ['p(95)<300', 'p(99)<500'],
    'http_req_failed{feature:products}': ['rate<0.005'],
    'checks{uc:UC001}': ['rate>0.995'],
    'product_list_duration_ms': ['p(95)<300'],   // Custom metric threshold
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  const res = http.get(
    `${BASE_URL}/products?limit=20&skip=${Math.floor(Math.random() * 80)}`,
    { 
      headers: { 'Content-Type': 'application/json' },
      tags: { name: 'list_products', feature: 'products', kind: 'browse', uc: 'UC001' }
    }
  );
  
  productListDuration.add(res.timings.duration);
  
  const checkResult = check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
    'has total field': (r) => r.json('total') !== undefined,
    'products count valid': (r) => r.json('products').length <= 20,
  }, { uc: 'UC001', step: 'list' });
  
  if (checkResult) {
    productListSuccess.add(1);
  } else {
    productListErrors.add(1);
  }
  
  sleep(Math.random() * 3 + 2); // 2-5s think time (Persona 1)
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'products',  // Domain area (lowercase)
  kind: 'browse',       // Operation type (lowercase)
  uc: 'UC001'           // Use case ID (uppercase UC + 3 dígitos)
}
```

**Fonte**: `docs/casos_de_uso/templates/guia-de-estilo.md` - Seção "Tags k6"

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 30s, 1 RPS)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/browse-catalog.test.ts

# Baseline (5 min, 5 RPS - Sprint 1 target)
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/browse-catalog.test.ts

# Stress test (10 min, 20 RPS)
K6_RPS=20 K6_DURATION=10m k6 run tests/api/products/browse-catalog.test.ts

# Soak test (30 min, 10 RPS - estabilidade)
K6_RPS=10 K6_DURATION=30m k6 run tests/api/products/browse-catalog.test.ts
```

### CI/CD
```bash
# GitHub Actions - PR Smoke Test
# Arquivo: .github/workflows/k6-pr-smoke.yml
# Executa: 30-60s, 1-2 RPS, thresholds relaxados

# GitHub Actions - Main Baseline
# Arquivo: .github/workflows/k6-main-baseline.yml  
# Executa: 5-10min, 5-10 RPS, SLOs estritos (conforme tabela acima)

# GitHub Actions - On-Demand Stress/Soak
# Arquivo: .github/workflows/k6-on-demand.yml
# Trigger: workflow_dispatch (manual)
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const productListDuration = new Trend('product_list_duration_ms');

// No VU code:
export default function() {
  const res = http.get(`${BASE_URL}/products?limit=20`);
  productListDuration.add(res.timings.duration);  // Registra latência
}
```

**Nomenclatura**: `product_list_duration_ms` (snake_case: `<feature>_<action>_<unit>`)

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const productListSuccess = new Counter('product_list_success');
const productListErrors = new Counter('product_list_errors');

// No VU code:
if (res.status === 200 && checkResult) {
  productListSuccess.add(1);
} else {
  productListErrors.add(1);
}
```

**Nomenclatura**: `product_list_success`, `product_list_errors` (snake_case: `<feature>_<action>_<event>`)

### Dashboards
- **Grafana**: Painel "UC001 - Products Browse" (a criar na Fase 5)
- **k6 Cloud**: [Link para projeto quando disponível]
- **Métricas a visualizar**: P95/P99 trends, error rate, success/error counters

**Fonte**: `docs/casos_de_uso/templates/guia-de-estilo.md` - Seção "Métricas Customizadas"

---

## ⚠️ Observações Importantes

### Limitações da API DummyJSON
- **Paginação Default**: Retorna 30 itens se `limit` não especificado
- **Total de Produtos**: API tem ~100 produtos fixos (não cresce dinamicamente)
- **Cache CDN**: Respostas GET podem ser cacheadas, variando latência
- **Rate Limiting**: Não documentado oficialmente, mas ~100 RPS observado como seguro
- **Dados Estáticos**: Produtos não mudam (dump fixo), ideal para testes reproduzíveis

**Fonte**: `docs/casos_de_uso/fase1-baseline-slos.md` - Seção "Limitações Identificadas"

### Particularidades do Teste
- **Paginação Realista**: Usar `skip` aleatório entre 0-80 para simular navegação variada (não sequencial)
- **Limit Padrão**: Testar com limit=20 (valor comum em UIs reais, não default de 30)
- **Think Time Variável**: 2-5s reflete comportamento real de Visitante lendo lista (não fixo)
- **Payload Size**: Com limit=20, payload ~5-8KB; com limit=100, ~25-35KB (+40% latência)

### Considerações de Desempenho
- **SharedArray**: Não necessário neste UC (dados vêm da API, não de arquivo local)
- **Sleep Obrigatório**: `sleep(1)` mínimo entre iterações para evitar hammering irreal
- **VUs Dinâmicos**: Open model (`constant-arrival-rate`) ajusta VUs automaticamente para atingir RPS
- **Memory Efficient**: Sem carga de dados externos, footprint baixo (~10MB por VU)

**Fonte ADR-002**: `docs/planejamento/PRD.md` e `.github/copilot-instructions.md` - Open Model Executors

---

## 🔗 Dependências

### UCs Bloqueadores (Dependências)
- **Nenhum** ✅ - UC001 é **Tier 0** (independente, sem dependências)
- Pode ser implementado imediatamente no Sprint 1

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - Seção "Tier 0 - Independentes"

### UCs que Usam Este (Fornece Para)
- **UC009** - User Journey (Unauthenticated): Integra browse no **Step 1** da jornada
- **UC010** - User Journey (Authenticated): Integra browse no fluxo autenticado
- **UC011** - Mixed Workload (Realistic Traffic): Usa como parte do tráfego Visitante (60%)

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC001 "Fornece para"

### Libs Necessárias
- **Nenhuma lib customizada** necessária neste UC (foundational)
- Usar **k6 built-ins**: `http`, `check`, `sleep` (módulos nativos)
- **Métricas**: `Trend`, `Counter` de `k6/metrics` (nativo)

**Libs serão criadas em UCs posteriores**:
- `libs/http/auth.ts` - Criada em **UC003** (User Login & Profile)
- `libs/scenarios/journey-builder.ts` - Criada em **UC009** (User Journey)
- `libs/data/product-loader.ts` - Possível criação futura (não Sprint 1)

### Dados Requeridos
- `data/test-data/products-sample.json` - **A ser gerado antes da implementação** (comando fornecido acima)
- Nenhum dado de outros UCs necessário (independente)

---

## 📂 Libs/Helpers Criados

**Nenhuma lib criada neste UC** - UC001 é foundational e usa apenas k6 built-ins.

Este UC serve como **baseline técnico** para:
- Validar executor `constant-arrival-rate` (open model)
- Estabelecer padrão de tags (`feature`, `kind`, `uc`)
- Definir estrutura de checks human-readable
- Configurar métricas customizadas básicas (Trend + Counter)

Libs serão introduzidas progressivamente:
- **Sprint 2 (UC003)**: `libs/http/auth.ts` para autenticação
- **Sprint 4 (UC009)**: `libs/scenarios/journey-builder.ts` para jornadas
- **Sprint 6 (UC011)**: `libs/scenarios/workload-mixer.ts` para mixed traffic

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-03 | GitHub Copilot | Criação inicial do UC001 (refatorado com todas as 9 entradas prioritárias das Fases 1-3) |

---

## ✅ Checklist de Completude

### Metadados e Identificação
- [x] ID do UC: `UC001` (3 dígitos, zero-padded) ✅
- [x] Nome do Arquivo: `UC001-browse-products-catalog.md` (kebab-case, < 50 chars) ✅
- [x] Status Badge: `✅ Approved` presente no topo ✅
- [x] Prioridade: `P0 (Crítico)` alinhada com matriz de priorização ✅
- [x] Complexidade: `1 (Muito Simples)` alinhada com roadmap ✅
- [x] Sprint: `Sprint 1 (Semana 4)` conforme roadmap ✅
- [x] Esforço: `4h` validado com roadmap ✅

### Descrição e Contexto
- [x] Perfil de Usuário: Visitante Anônimo (Persona 1) claramente definido ✅
- [x] Distribuição de Tráfego: 60% especificado conforme Fase 1 ✅
- [x] Objetivo de Negócio: Descoberta de produtos descrito ✅
- [x] Contexto: Quando/por que UC ocorre está claro ✅
- [x] Valor de Negócio: Justificativa de criticidade presente ✅

### Endpoints e API
- [x] Todos os Endpoints: GET /products documentado com método HTTP ✅
- [x] SLO Individual: P95 < 250ms especificado ✅
- [x] Observações: Paginação (30 itens default, limit/skip) documentada ✅
- [x] Total de Endpoints: 1 READ, 0 WRITE contabilizado ✅
- [x] Headers Obrigatórios: Content-Type: application/json ✅
- [x] Query Params: `limit` e `skip` especificados ✅

### SLOs
- [x] P95 Latency: < 300ms definido e justificado (baseline 250ms + 20%) ✅
- [x] P99 Latency: < 500ms definido (baseline 320ms + margem) ✅
- [x] Error Rate: < 0.5% definido (operação crítica) ✅
- [x] Checks: > 99.5% definido ✅
- [x] Rationale: Cada SLO com justificativa baseada em baseline ✅
- [x] Baseline: Referenciado `fase1-baseline-slos.md` ✅
- [x] Métrica Completa: Tags `{feature:products}` incluídas ✅

### Dados de Teste
- [x] Arquivos Necessários: `products-sample.json` em `data/test-data/` ✅
- [x] Volume: 100 produtos especificado ✅
- [x] Fonte: `fulldummyjsondata/products.json` documentada ✅
- [x] Estratégia de Refresh: Mensal definida ✅
- [x] Comando de Geração: `jq` command incluído ✅
- [x] Dependências de Dados: Nenhuma (Tier 0) identificado ✅

### Fluxo Principal
- [x] Pré-condições: Usuário não autenticado, API disponível ✅
- [x] Steps: 2 steps numerados sequencialmente ✅
- [x] Request Details: HTTP GET, endpoint, headers documentados ✅
- [x] Validações: 5 checks especificados com ✅ ✅
- [x] Checks Human-Readable: `'status is 200'` format ✅
- [x] Think Times: `2-5s (navegação casual)` especificado com fonte ✅
- [x] Pós-condições: Próximos steps típicos documentados ✅
- [x] Máximo 10 Steps: 2 steps (OK) ✅

### Fluxos Alternativos
- [x] Cenários de Erro: API Indisponível (5xx, timeout) ✅
- [x] Edge Cases: 3 documentados (limit inválido, skip overflow, payload grande) ✅
- [x] Ações de Recuperação: Retry mencionado (não implementado neste UC) ✅
- [x] Validações de Erro: Checks com ❌ para falhas ✅

### Implementação
- [x] Localização do Teste: `tests/api/products/browse-catalog.test.ts` ✅
- [x] Executor: `constant-arrival-rate` (open model ADR-002) ✅
- [x] Tags Obrigatórias: `feature`, `kind`, `uc` especificadas ✅
- [x] Thresholds: Alinhados com SLOs (4 thresholds) ✅
- [x] VUs: `preAllocatedVUs: 10`, `maxVUs: 50` ✅
- [x] Duration: `__ENV.K6_DURATION || '5m'` ✅
- [x] Rate/RPS: `__ENV.K6_RPS || 5` ✅

### Comandos de Teste
- [x] Smoke Test: `K6_RPS=1 K6_DURATION=30s` documentado ✅
- [x] Baseline Test: `K6_RPS=5 K6_DURATION=5m` documentado ✅
- [x] Stress Test: `K6_RPS=20 K6_DURATION=10m` documentado ✅
- [x] Variáveis de Ambiente: `K6_RPS`, `K6_DURATION` utilizadas ✅
- [x] CI/CD: Workflows `.github/workflows/` referenciados ✅

### Métricas Customizadas
- [x] Trends: `product_list_duration_ms` definida ✅
- [x] Counters: `product_list_success`, `product_list_errors` definidos ✅
- [x] Imports: `import { Trend, Counter } from 'k6/metrics'` presente ✅
- [x] Nomenclatura: snake_case `<feature>_<action>_<unit>` ✅

### Observações Importantes
- [x] Limitações da API: 5 limitações DummyJSON documentadas ✅
- [x] Particularidades do Teste: 4 particularidades documentadas ✅
- [x] Considerações de Desempenho: 4 considerações (SharedArray, sleep, VUs, memory) ✅
- [x] ADR-002: Open model executor justificado ✅

### Dependências
- [x] UCs Bloqueadores: Nenhum (Tier 0) documentado ✅
- [x] UCs que Usam Este: UC009, UC010, UC011 listados ✅
- [x] Libs Necessárias: Nenhuma (k6 built-ins) especificado ✅
- [x] Dados Requeridos: `products-sample.json` listado ✅
- [x] Fonte Dependências: `fase2-mapa-dependencias.md` referenciado ✅

### Libs/Helpers
- [x] Seção presente: Nenhuma lib criada neste UC ✅
- [x] Contexto: UC foundational, baseline técnico explicado ✅
- [x] Roadmap libs futuras: UC003 (auth), UC009 (journey), UC011 (mixer) ✅

### Histórico e Referências
- [x] Histórico de Mudanças: Tabela com data/autor/mudança ✅
- [x] Referências: 9 documentos de entrada citados ao longo do UC ✅
- [x] Checklist de Completude: Este checklist presente ✅

### Validação Final com Guia de Estilo
- [x] Emojis consistentes: 📋 Descrição, 🔗 Endpoints, 📊 SLOs, etc. ✅
- [x] Formatação: Code blocks com syntax highlighting ✅
- [x] Tabelas: Alinhamento correto (nomes à esquerda, números à direita) ✅
- [x] Links: Referências com texto descritivo ✅
- [x] Glossário: Termos técnicos consistentes (Threshold, Check, VU, etc.) ✅

---

## 📚 Referências

### Documentação de Entrada (9 Documentos Consultados)

**Fase 1 - Base de Requisitos e SLOs**:
1. [Inventário de Endpoints](fase1-inventario-endpoints.csv) - Linha 2: GET /products
2. [Perfis de Usuário](fase1-perfis-de-usuario.md) - Persona 1 (Visitante 60%), think times 2-5s
3. [Baseline de SLOs](fase1-baseline-slos.md) - Products: P95=250ms, P99=320ms, Error=0%

**Fase 2 - Ordem e Dependências**:
4. [Matriz de Priorização](fase2-matriz-priorizacao.md) - UC001: Criticidade 5, Complexidade 1, Quadrante Prioridade Máxima
5. [Roadmap de Implementação](fase2-roadmap-implementacao.md) - Sprint 1, 4h esforço, 60% tráfego meta
6. [Mapa de Dependências](fase2-mapa-dependencias.md) - Tier 0, sem dependências, fornece para UC009/010/011

**Fase 3 - Padrões e Qualidade**:
7. [Template de UC](templates/use-case-template.md) - Estrutura de 15 seções seguida
8. [Guia de Estilo](templates/guia-de-estilo.md) - Nomenclatura (UC00X, kebab-case, tags, métricas snake_case)
9. [Checklist de Qualidade](templates/checklist-qualidade.md) - 78 itens validados (seções 1-14)

### Documentação Externa
- [DummyJSON Products API](https://dummyjson.com/docs/products)
- [k6 Documentation - Scenarios](https://grafana.com/docs/k6/latest/using-k6/scenarios/)
- [k6 Documentation - Checks](https://grafana.com/docs/k6/latest/using-k6/checks/)
- [k6 Documentation - Metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)
- [k6 Open Model vs Closed Model](https://grafana.com/docs/k6/latest/using-k6/scenarios/concepts/open-vs-closed/)

### Arquitetura do Projeto
- ADR-001: TypeScript-First → `.github/copilot-instructions.md`
- ADR-002: Open Model Executors → `.github/copilot-instructions.md`
- ADR-003: Data Strategy → `.github/copilot-instructions.md`
- PRD Completo: `docs/planejamento/PRD.md`
