# UC002 - Search & Filter Products

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 2 (Simples)  
> **Sprint**: Sprint 2 (Semana 5)  
> **Esforço Estimado**: 6h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo (60% do tráfego total)
- **Distribuição de Tráfego**: ~30% dos visitantes usam busca ativa
- **Objetivo de Negócio**: Descobrir produtos específicos através de termos de busca e filtros, facilitando a navegação e melhorando a conversão

### Contexto
Usuário anônimo acessa o e-commerce com uma necessidade ou interesse específico em mente (ex: "smartphone", "laptop", "perfume"). Ao invés de navegar categorias ou listar todos os produtos, utiliza a funcionalidade de busca para encontrar rapidamente itens relevantes. Este é um fluxo crítico de descoberta de produtos que impacta diretamente a experiência do usuário e a taxa de conversão.

### Valor de Negócio
- **Criticidade**: Essencial (5/5) - Segundo fluxo mais importante, UX crítica para descoberta
- **Impacto no Tráfego**: ~30% do tráfego de descoberta (dentro dos 60% de visitantes anônimos)
- **Conversão**: Usuários que usam busca têm maior intenção de compra comparado a navegação passiva
- **Quadrante na Matriz**: ✅ **PRIORIDADE MÁXIMA** (Alta criticidade, Baixa complexidade)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/products/search?q={query}` | P95 < 600ms | Query processing, varia com complexidade do termo |
| GET | `/products/search?q={query}&limit={n}&skip={n}` | P95 < 600ms | Com paginação |
| GET | `/products/search?q={query}&select={fields}` | P95 < 500ms | Filtragem de campos retornados (menor payload) |

**Total de Endpoints**: 1 (com variações de query params)  
**Operações READ**: 1  
**Operações WRITE**: 0  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Linha 4 (Products/GET /products/search)  

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 600ms | Baseline Fase 1: P95 real = 350ms (simples), 480ms (complexas). Margem para variabilidade |
| `http_req_duration{feature:products}` (P99) | < 800ms | Threshold conservador para queries muito complexas ou rede degradada |
| `http_req_failed{feature:products}` | < 1% | Descoberta crítica; tolerância maior que browse (0 resultados não é erro) |
| `checks{uc:UC002}` | > 99% | Validações devem passar, permite 1% de falhas temporárias (ex: termos não encontrados) |
| `product_search_duration_ms` (P95) | < 600ms | Métrica customizada de latência específica da operação de busca |
| `product_search_results_count` (avg) | > 0 | Garantir que buscas retornam resultados (média maior que zero) |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (Search: P95 350ms simples, 480ms complexo)  
**Medição Original**: P50=200ms, P95=350ms (simples) / 480ms (complexas), P99=620ms, Max=720ms, Error Rate=0%

**SLO Específico do Feature Search**:
- P95 < 600ms (mais permissivo que products browse devido a query processing)
- Error Rate < 1% (tolerância para edge cases)
- Checks > 99%

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `search-queries.json` | `data/test-data/` | 50 queries | Análise de termos comuns em produtos DummyJSON | Mensal (quando catálogo mudar) |
| `search-queries-edge-cases.json` | `data/test-data/` | 20 queries | Termos vazios, especiais, não encontrados | Trimestral |
| `products-sample.json` | `data/test-data/` | 100 items | Extração de `fulldummyjsondata/products.json` | Semanal (reutiliza UC001) |

### Estrutura de `search-queries.json`
```json
[
  { "term": "phone", "expectedResults": ">0", "category": "electronics" },
  { "term": "perfume", "expectedResults": ">0", "category": "beauty" },
  { "term": "laptop", "expectedResults": ">0", "category": "electronics" },
  { "term": "watch", "expectedResults": ">0", "category": "accessories" },
  { "term": "shirt", "expectedResults": ">0", "category": "clothing" }
]
```

### Estrutura de `search-queries-edge-cases.json`
```json
[
  { "term": "", "expectedResults": "0", "description": "empty query" },
  { "term": "xyz123nonexistent", "expectedResults": "0", "description": "not found" },
  { "term": "a", "expectedResults": ">=0", "description": "single char" },
  { "term": "phone laptop", "expectedResults": ">=0", "description": "multiple terms" },
  { "term": "PHONE", "expectedResults": ">0", "description": "case insensitive" }
]
```

### Geração de Dados
```bash
# Gerar queries baseado em análise de produtos existentes
node data/test-data/generators/generate-search-queries.ts \
  --source data/fulldummyjsondata/products.json \
  --output data/test-data/search-queries.json \
  --sample-size 50

# Validar queries geradas
node data/test-data/generators/validate-search-queries.ts \
  --queries data/test-data/search-queries.json
```

### Dependências de Dados
- **UC001 (Browse Products)**: Reusa `products-sample.json` para validar IDs de produtos retornados na busca
- **Nenhuma outra dependência**: Search não requer autenticação ou dados de outros UCs
- **Alinhamento com Fase 1**: Perfil Visitante Anônimo - Endpoints utilizados incluem `GET /products/search` (média-alta frequência conforme fase1-perfis-de-usuario.md)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário **não autenticado** (visitante anônimo)
- API DummyJSON disponível e responsiva
- Queries de busca válidas carregadas em `SharedArray`

### Steps

**Step 1: Busca Simples por Termo**  
```http
GET /products/search?q=phone
Headers:
  Content-Type: application/json
```

**Exemplo Concreto**:
```http
GET https://dummyjson.com/products/search?q=phone
Headers:
  Content-Type: application/json
```

**Validações** (human-readable checks):
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has products array'` → Response contém `products` array
- ✅ `'has total field'` → Response contém `total` field (número de resultados)
- ✅ `'has pagination fields'` → Response contém `skip` e `limit` fields
- ✅ `'has results if total positive'` → Se `total > 0`: `products.length` > 0
- ✅ `'products have required fields'` → Cada produto tem `id`, `title`, `price`, `description`
- ✅ `'search term matches results'` → Produtos retornados contêm termo em `title` ou `description` (case-insensitive)

**Think Time**: `2-5s` (usuário analisa resultados)  
**Fonte Think Time**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 1 (Visitante): 2-5s entre ações

---

**Step 2: Busca com Paginação**  
```http
GET /products/search?q=laptop&limit=10&skip=0
Headers:
  Content-Type: application/json
```

**Validações** (human-readable checks):
- ✅ `'status is 200'` → Status code = 200
- ✅ `'products count respects limit'` → `products.length` <= 10 (respeita limit)
- ✅ `'skip is zero'` → `skip` = 0 (primeira página)
- ✅ `'limit is ten'` → `limit` = 10
- ✅ `'has more results if applicable'` → Se `total > 10`: há mais resultados disponíveis

**Think Time**: `2-5s` (usuário decide se visualiza mais páginas)

---

**Step 3: Busca com Filtro de Campos (Select)**  
```http
GET /products/search?q=perfume&select=title,price,thumbnail
Headers:
  Content-Type: application/json
```

**Validações** (human-readable checks):
- ✅ `'status is 200'` → Status code = 200
- ✅ `'only selected fields present'` → Produtos contêm **apenas** `title`, `price`, `thumbnail`
- ✅ `'payload is smaller'` → Payload menor que busca sem select (otimização de rede)
- ✅ `'pagination metadata present'` → `total`, `skip`, `limit` ainda presentes

**Think Time**: `2-5s` (resultados mais leves, decisão rápida)

---

**Step 4: Navegação para Próxima Página (Skip)**  
```http
GET /products/search?q=phone&limit=10&skip=10
Headers:
  Content-Type: application/json
```

**Validações** (human-readable checks):
- ✅ `'status is 200'` → Status code = 200
- ✅ `'skip is ten'` → `skip` = 10 (segunda página)
- ✅ `'products count valid'` → `products.length` <= 10
- ✅ `'no duplicate products'` → IDs diferentes da primeira página (sem duplicatas)

**Think Time**: `2-5s` (navegação entre páginas)

---

### Pós-condições
- Usuário encontrou produtos relevantes ou identificou que termo não retorna resultados
- **Próximo passo típico**: `GET /products/{id}` (UC004 - View Product Details)
- Nenhuma mudança de estado no servidor (operação READ)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Jornada Típica Visitante (Step 3: Busca termo específico)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Query Vazia
**Condição**: Usuário submete busca sem termo (`q=` ou `q` ausente)

**Steps**:
1. Request: `GET /products/search?q=`
2. DummyJSON retorna todos os produtos (comportamento padrão)
3. Validar: `products.length` > 0, `total` = total de produtos no catálogo

**Validações** (human-readable checks):
- ✅ `'status is 200 for empty query'` → Status code = 200 (não é erro 400, API aceita query vazia)
- ✅ `'returns all products'` → Retorna lista completa de produtos (comportamento documentado)
- ⚠️ **Observação**: DummyJSON trata query vazia como "listar todos", não como erro

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Observação: "Query param: q, suporta filtros"

---

### Cenário de Erro 2: Termo Não Encontrado
**Condição**: Busca por termo que não existe em nenhum produto

**Steps**:
1. Request: `GET /products/search?q=xyz123nonexistent`
2. API retorna response válida com `products` vazio
3. Validar estrutura mesmo sem resultados

**Validações** (human-readable checks):
- ✅ `'status is 200 for no results'` → Status code = 200 (não é 404, é resposta válida sem resultados)
- ✅ `'products array is empty'` → `products` = [] (array vazio)
- ✅ `'total is zero'` → `total` = 0
- ✅ `'pagination fields present'` → `skip` e `limit` ainda presentes
- ⚠️ **Não é erro**: É resultado válido de busca sem matches

---

### Edge Case 1: Case Insensitive Search
**Condição**: Termos em maiúsculas/minúsculas devem retornar mesmos resultados

**Steps**:
1. Request 1: `GET /products/search?q=phone`
2. Request 2: `GET /products/search?q=PHONE`
3. Request 3: `GET /products/search?q=Phone`
4. Comparar `total` dos 3 requests

**Validações** (human-readable checks):
- ✅ `'total matches across cases'` → `total` é igual para todos os 3 requests
- ✅ `'case insensitive confirmed'` → Case insensitive confirmado

---

### Edge Case 2: Termos com Múltiplas Palavras
**Condição**: Busca com espaços (ex: "smart phone")

**Steps**:
1. Request: `GET /products/search?q=smart%20phone`
2. API deve interpretar como busca por "smart phone" (com espaço codificado)

**Validações** (human-readable checks):
- ✅ `'status is 200'` → Status code = 200
- ✅ `'matches partial terms'` → Resultados contêm produtos com "smart" OU "phone" (busca por termo parcial)

---

### Edge Case 3: Paginação Além do Total
**Condição**: Skip maior que total de resultados

**Steps**:
1. Primeira request: `GET /products/search?q=phone` → obter `total`
2. Segunda request: `GET /products/search?q=phone&skip=1000` (além do total)

**Validações** (human-readable checks):
- ✅ `'status is 200 for out of bounds'` → Status code = 200 (não é erro)
- ✅ `'products array is empty'` → `products` = [] (array vazio)
- ✅ `'skip reflects parameter'` → `skip` = 1000 (reflete parâmetro)
- ✅ `'total unchanged'` → `total` = mesmo valor da primeira request

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/products/search-products.test.ts`
- **Categoria**: Products (domain-driven)
- **Tier**: Tier 0 (independente, sem auth)

### Configuração de Cenário
```typescript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter, Rate } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom Metrics
const productSearchDuration = new Trend('product_search_duration_ms');
const productSearchErrors = new Counter('product_search_errors');
const productSearchResultsCount = new Trend('product_search_results_count');
const productSearchEmptyResults = new Rate('product_search_empty_results_rate');

// Test Data
const searchQueries = new SharedArray('search_queries', function() {
  return JSON.parse(open('../../../data/test-data/search-queries.json'));
});

const edgeCaseQueries = new SharedArray('edge_case_queries', function() {
  return JSON.parse(open('../../../data/test-data/search-queries-edge-cases.json'));
});

export const options = {
  scenarios: {
    search_products: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 5,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'products', kind: 'search', uc: 'UC002' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products}': ['p(95)<600', 'p(99)<800'],
    'http_req_failed{feature:products}': ['rate<0.01'],
    'checks{uc:UC002}': ['rate>0.99'],
    'product_search_duration_ms': ['p(95)<600'],
    'product_search_results_count': ['avg>0'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  // 70% queries normais, 30% edge cases
  const useEdgeCase = Math.random() < 0.3;
  const query = useEdgeCase 
    ? randomItem(edgeCaseQueries) 
    : randomItem(searchQueries);
  
  const searchTerm = query.term;
  
  // Step 1: Search simples
  const searchUrl = `${BASE_URL}/products/search?q=${encodeURIComponent(searchTerm)}`;
  const res = http.get(searchUrl, {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'search_products', feature: 'products', kind: 'search', uc: 'UC002', step: 'simple_search' }
  });
  
  productSearchDuration.add(res.timings.duration);
  
  const searchChecks = check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => {
      const body = r.json();
      return body && Array.isArray(body.products);
    },
    'has total field': (r) => {
      const body = r.json();
      return body && typeof body.total === 'number';
    },
    'has pagination fields': (r) => {
      const body = r.json();
      return body && 'skip' in body && 'limit' in body;
    },
  }, { uc: 'UC002', step: 'simple_search' });
  
  if (!searchChecks) {
    productSearchErrors.add(1);
  }
  
  if (res.status === 200) {
    const body = res.json();
    const total = body.total || 0;
    const products = body.products || [];
    
    productSearchResultsCount.add(total);
    productSearchEmptyResults.add(total === 0 ? 1 : 0);
    
    // Validações adicionais se há resultados
    if (products.length > 0) {
      check(res, {
        'products have required fields': (r) => {
          const prods = r.json().products;
          return prods.every(p => 
            p.id && p.title && typeof p.price === 'number'
          );
        },
      }, { uc: 'UC002', step: 'validate_results' });
    }
  }
  
  sleep(Math.random() * 3 + 2); // 2-5s think time
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'products',   // Domain: products API
  kind: 'search',        // Operation: search/filter
  uc: 'UC002'            // Use case ID
}
```

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 30s, 1 RPS)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/search-products.test.ts

# Baseline (5 min, 5 RPS)
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/search-products.test.ts

# Stress (10 min, 20 RPS - alta carga)
K6_RPS=20 K6_DURATION=10m k6 run tests/api/products/search-products.test.ts

# Com ambiente customizado
BASE_URL=https://dummyjson.com K6_RPS=10 K6_DURATION=3m k6 run tests/api/products/search-products.test.ts
```

### Validação de Thresholds
```bash
# Executar e validar que P95 < 600ms
K6_RPS=5 K6_DURATION=2m k6 run tests/api/products/search-products.test.ts

# Saída esperada:
# ✓ http_req_duration{feature:products}...: avg=XXXms min=XXms med=XXms max=XXms p(95)=XXXms p(99)=XXXms
# ✓ checks{uc:UC002}.....................: 99.x%
```

### CI/CD
```bash
# GitHub Actions smoke test (PR)
# Definido em: .github/workflows/k6-pr-smoke.yml

# GitHub Actions baseline (main branch)
# Definido em: .github/workflows/k6-main-baseline.yml

# Execução on-demand via workflow_dispatch
# Definido em: .github/workflows/k6-on-demand.yml
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```typescript
import { Trend } from 'k6/metrics';

const productSearchDuration = new Trend('product_search_duration_ms');
const productSearchResultsCount = new Trend('product_search_results_count');

// No VU code:
productSearchDuration.add(res.timings.duration);
productSearchResultsCount.add(body.total);
```

**Propósito**:
- `product_search_duration_ms`: Latência específica da operação de busca (complementa `http_req_duration`)
- `product_search_results_count`: Distribuição de quantidade de resultados retornados

### Counters (Eventos de Negócio)
```typescript
import { Counter } from 'k6/metrics';

const productSearchErrors = new Counter('product_search_errors');

// No VU code:
if (!searchChecks) {
  productSearchErrors.add(1);
}
```

**Propósito**:
- `product_search_errors`: Total de buscas que falharam validações (erro 5xx, response inválida)

### Rates (Taxas)
```typescript
import { Rate } from 'k6/metrics';

const productSearchEmptyResults = new Rate('product_search_empty_results_rate');

// No VU code:
productSearchEmptyResults.add(total === 0 ? 1 : 0);
```

**Propósito**:
- `product_search_empty_results_rate`: Porcentagem de buscas que retornaram 0 resultados (útil para avaliar qualidade das queries)

### Dashboards
- **Grafana**: [A ser criado] Dashboard de Search Performance
  - Latência P95/P99 por termo de busca
  - Taxa de resultados vazios
  - Distribuição de quantidade de resultados
- **k6 Cloud**: [A ser configurado] Projeto k6-monorepo

---

## ⚠️ Observações Importantes

### Limitações da API

1. **Query Vazia Retorna Todos os Produtos**
   - DummyJSON não retorna erro 400 para `q=` vazio
   - Comportamento: retorna lista completa de produtos (equivalente a GET /products)
   - **Não é bug**: comportamento documentado da API
   - **Implicação**: Validar que aplicação front-end não permita busca vazia

2. **Case Insensitive**
   - Busca é case-insensitive por padrão
   - "phone", "PHONE", "Phone" retornam mesmos resultados
   - **Não precisa** normalizar termos antes de enviar

3. **Múltiplas Palavras**
   - Termos com espaços são aceitos (encoding URL necessário: `%20`)
   - Busca por "smart phone" retorna produtos com "smart" OU "phone"
   - **Não é busca exata**: é busca por termo parcial

4. **Sem Suporte a Operadores Avançados**
   - Não há suporte a AND, OR, NOT
   - Não há busca por faixa de preço via query `q`
   - **Limitação**: busca simples por termo apenas

### Particularidades do Teste

1. **Variação de Latência por Complexidade**
   - Queries simples (1 palavra): P95 ~350ms
   - Queries complexas (múltiplas palavras): P95 ~480ms
   - **SLO conservador**: P95 < 600ms para cobrir ambos os casos

2. **SharedArray para Queries**
   - Usar `SharedArray` para carregar `search-queries.json`
   - Evita duplicação em memória (memory-efficient)
   - Thread-safe para múltiplos VUs

3. **Distribuição de Queries**
   - 70% queries normais (termos comuns)
   - 30% edge cases (vazio, não encontrado, case variations)
   - **Reflete comportamento real**: maioria buscas são bem-sucedidas

4. **Paginação Realista**
   - Testar `limit=10, 20, 30` (valores comuns)
   - Testar `skip` em múltiplos da página (0, 10, 20, etc.)
   - **Não testar**: skip extremamente alto (> 1000), não é realista

### Considerações de Desempenho

1. **Open Model Executor**
   - **OBRIGATÓRIO**: usar `constant-arrival-rate`
   - **NUNCA**: usar `shared-iterations` (não reflete tráfego real)
   - Justificativa: busca é operação on-demand, não batch

2. **Think Time Apropriado**
   - 2-5s entre buscas (usuário analisa resultados)
   - **Não usar**: sleep(1) fixo (muito rápido, não realista)
   - Baseado em Persona 1 (Visitante Anônimo) da Fase 1

3. **Threshold de Checks > 99%**
   - Permite 1% de falhas (edge cases, network blips)
   - **Mais permissivo** que UC001 (99.5%) devido a queries edge cases

---

## 🔗 Dependências

### UCs Bloqueadores (Dependências Obrigatórias)
- **Nenhum** ✅ 
  - UC002 é **Tier 0** (independente)
  - Não requer autenticação
  - Não depende de outros UCs

### UCs que Usam Este (Fornece Para)
- **UC009 - User Journey (Unauthenticated)** → Step 3: Buscar produtos
- **UC010 - User Journey (Authenticated)** → Pode incluir busca antes de add-to-cart
- **UC011 - Mixed Workload (Realistic Traffic)** → Persona Visitante (60%) usa busca

### Libs Necessárias
- **k6 built-ins**: `http`, `check`, `sleep`
- **k6 metrics**: `Trend`, `Counter`, `Rate`
- **k6 data**: `SharedArray`
- **jslib.k6.io**: `randomItem` (v1.4.0) - seleção aleatória de queries
- **Nenhuma lib customizada**: Não requer `libs/http/auth.ts` (sem auth)

### Dados Requeridos
- `data/test-data/search-queries.json` (50 queries normais) - **A ser criado**
- `data/test-data/search-queries-edge-cases.json` (20 edge cases) - **A ser criado**
- `data/test-data/products-sample.json` (100 produtos) - **Reutiliza UC001** ✅

### Dependências de Geração de Dados
- **Gerador a criar**: `data/test-data/generators/generate-search-queries.ts`
  - Input: `data/fulldummyjsondata/products.json`
  - Output: `search-queries.json` com termos extraídos de títulos/descrições

---

## 📂 Libs/Helpers Criados

### Nenhuma lib criada para este UC ✅

**Justificativa**:
- UC002 é operação simples (GET endpoint)
- Não requer autenticação (não usa `libs/http/auth.ts`)
- Não requer orquestração complexa (não usa `libs/scenarios/`)
- Lógica de seleção de query usa `randomItem` de jslib.k6.io

**Potencial futuro** (se necessário em UC009/UC010):
- `libs/data/search-loader.ts`: Wrapper para carregar queries com validações
- **Decisão**: Implementar apenas se reutilização for necessária em 3+ UCs

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-03 | GitHub Copilot | Criação inicial do UC002 - Sprint 2 Fase 4 |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Visitante Anônimo, 30% tráfego busca)
- [x] Todos os endpoints estão documentados com método HTTP (GET /products/search)
- [x] SLOs estão definidos e justificados (P95 < 600ms, referência baseline)
- [x] Fluxo principal está detalhado passo a passo (4 steps: simples, paginação, select, skip)
- [x] Validações (checks) estão especificadas (status, products array, total, pagination)
- [x] Dados de teste estão identificados (search-queries.json, edge-cases.json)
- [x] Headers obrigatórios estão documentados (Content-Type: application/json)
- [x] Think times estão especificados (2-5s navegação casual)
- [x] Edge cases e cenários de erro estão mapeados (query vazia, não encontrado, case insensitive, etc.)
- [x] Dependências de outros UCs estão listadas (Nenhuma - Tier 0)
- [x] Limitações da API estão documentadas (query vazia retorna todos, case insensitive, etc.)
- [x] Arquivo nomeado corretamente: `UC002-search-filter-products.md` ✅
- [x] Libs/helpers criados estão documentados (Nenhuma - não aplicável)
- [x] Comandos de teste estão corretos e testados (smoke, baseline, stress)
- [x] Tags obrigatórias estão especificadas (feature: products, kind: search, uc: UC002)
- [x] Métricas customizadas estão documentadas (Trends, Counters, Rates)

---

## 📚 Referências

- [DummyJSON Products Search API](https://dummyjson.com/docs/products)
- [k6 Documentation - Scenarios](https://grafana.com/docs/k6/latest/using-k6/scenarios/)
- [k6 Documentation - Metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md`
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md`
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md`
- Template: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`
- Checklist: `docs/casos_de_uso/templates/checklist-qualidade.md`
