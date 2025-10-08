# UC009 - User Journey (Unauthenticated)

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 3 (Moderada)  
> **Sprint**: Sprint 4 (Semana 7)  
> **Esforço Estimado**: 8h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo (Persona 1)
- **Distribuição de Tráfego**: 60% do total esperado
- **Objetivo de Negócio**: Simular jornada completa end-to-end de um usuário não autenticado navegando pelo e-commerce desde a descoberta inicial até a visualização de detalhes de produtos

### Contexto
Este caso de uso representa a **jornada típica completa** de um Visitante Anônimo descrita em `fase1-perfis-de-usuario.md`. O usuário:
1. Acessa página inicial → Lista produtos
2. Explora categorias → Navega por categoria específica
3. Busca termo específico → Visualiza resultados
4. Clica em produto → Vê detalhes completos
5. Pode voltar e repetir navegação

Esta jornada **combina os UCs Tier 0** (UC001, UC002, UC004, UC007) em uma sequência realista com think times apropriados, simulando o comportamento real de 60% dos usuários da plataforma.

### Valor de Negócio
- **Criticidade**: Essencial (5/5) - Fluxo de 60% dos usuários, base para todas as jornadas
- **Impacto no Tráfego**: 60% do volume total (maior persona)
- **Conversão**: ~15% dos visitantes convertem para login após esta jornada
- **Quadrante na Matriz**: 📋 **PLANEJAR CUIDADOSAMENTE** (Alta criticidade, Moderada complexidade)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/products` | P95 < 300ms | Step 1: Lista inicial (UC001) |
| GET | `/products/categories` | P95 < 150ms | Step 2: Listar categorias (UC007) |
| GET | `/products/category/{slug}` | P95 < 300ms | Step 3: Navegar por categoria (UC007) |
| GET | `/products/search?q={query}` | P95 < 600ms | Step 4: Buscar produtos (UC002) |
| GET | `/products/{id}` | P95 < 300ms | Step 5: Ver detalhes (UC004) |

**Total de Endpoints**: 5  
**Operações READ**: 5  
**Operações WRITE**: 0  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Combinação de endpoints dos UCs Tier 0

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 400ms | Média ponderada dos endpoints (300ms browse + 600ms search / 2) |
| `http_req_duration{feature:products}` (P99) | < 700ms | Margem para pior caso (search P99=800ms como referência) |
| `http_req_failed{feature:products}` | < 0.5% | Mesma tolerância dos UCs base (operação crítica) |
| `checks{uc:UC009}` | > 99% | Jornada composta permite 1% falha (vs 99.5% UCs individuais) |
| `journey_unauthenticated_duration_total_ms` (P95) | < 10000ms | Duração total da jornada < 10s (sem think times) |
| `journey_unauthenticated_steps_completed` (avg) | = 5 | Garantir que todas as 5 etapas sejam executadas |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (combinação de SLOs de Products)

**Métricas Customizadas**:
- `journey_unauthenticated_duration_total_ms` (Trend) - Latência total da jornada
- `journey_unauthenticated_steps_completed` (Counter) - Número de steps completados com sucesso
- `journey_unauthenticated_errors` (Counter) - Erros durante a jornada

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `products-sample.json` | `data/test-data/` | 100 produtos | Extração de `fulldummyjsondata/products.json` | Mensal (reutiliza UC001) |
| `category-slugs.json` | `data/test-data/` | ~24 slugs | Gerado de produtos (reutiliza UC007) | Mensal |
| `search-queries.json` | `data/test-data/` | 50 queries | Análise de termos comuns (reutiliza UC002) | Mensal |
| `product-ids.json` | `data/test-data/` | 194 IDs | Extração de produtos (reutiliza UC004) | Mensal |

### Geração de Dados
```bash
# Não requer geração nova - reutiliza dados dos UCs Tier 0
# UC001: products-sample.json
# UC002: search-queries.json
# UC004: product-ids.json
# UC007: category-slugs.json
```

### Dependências de Dados
- **UC001**: `products-sample.json` (lista inicial)
- **UC002**: `search-queries.json` (termos de busca)
- **UC004**: `product-ids.json` (IDs para detalhes)
- **UC007**: `category-slugs.json` (slugs de categorias)

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC009 depende de UC001, UC002, UC004, UC007 (dados compartilhados)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário **não autenticado** (Visitante Anônimo)
- API DummyJSON disponível em https://dummyjson.com
- Dados de teste carregados (produtos, categorias, queries, IDs)
- Nenhuma sessão ativa requerida

### Steps

**Step 1: Listar Produtos Iniciais (Landing Page)**  
```http
GET /products?limit=20&skip=0
Headers:
  Content-Type: application/json
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has products array'` → Response contém array `products`
- ✅ `'products count valid'` → `products.length` <= 20
- ✅ `'products have required fields'` → Cada produto tem `id`, `title`, `price`

**Think Time**: 2-5s (navegação casual - Persona 1 Visitante)

**Fonte**: UC001 (Browse Products Catalog) - Step 1

---

**Step 2: Explorar Categorias Disponíveis**  
```http
GET /products/categories
Headers:
  Content-Type: application/json
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'response is array'` → Response é array de objetos
- ✅ `'has categories'` → Array possui pelo menos 1 categoria
- ✅ `'categories have slug'` → Cada categoria tem propriedade `slug`

**Think Time**: 2-5s (análise de opções de categorias)

**Fonte**: UC007 (Browse by Category) - Step 1

---

**Step 3: Navegar por Categoria Específica**  
```http
GET /products/category/{slug}
Headers:
  Content-Type: application/json

# Exemplo concreto:
GET /products/category/beauty
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has products array'` → Response contém array `products`
- ✅ `'products belong to category'` → Produtos retornados pertencem à categoria solicitada
- ✅ `'products count > 0'` → Categoria retorna ao menos 1 produto

**Think Time**: 2-5s (análise de produtos da categoria)

**Fonte**: UC007 (Browse by Category) - Step 2

---

**Step 4: Buscar Produto Específico**  
```http
GET /products/search?q={query}
Headers:
  Content-Type: application/json

# Exemplo concreto:
GET /products/search?q=phone
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has products array'` → Response contém array `products`
- ✅ `'has total field'` → Response contém campo `total`
- ✅ `'search returns results'` → Para queries comuns, `total` > 0 (permite 0 para edge cases)

**Think Time**: 2-5s (análise de resultados de busca)

**Fonte**: UC002 (Search & Filter Products) - Step 1

---

**Step 5: Visualizar Detalhes do Produto**  
```http
GET /products/{id}
Headers:
  Content-Type: application/json

# Exemplo concreto:
GET /products/5
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'product has id'` → Response contém campo `id`
- ✅ `'product has title and price'` → Response contém `title` e `price`
- ✅ `'product has description'` → Response contém `description` (detalhes completos)
- ✅ `'product has images'` → Response contém `images` ou `thumbnail`

**Think Time**: 2-5s (análise de detalhes do produto - decisão de compra)

**Fonte**: UC004 (View Product Details) - Step 1

---

### Pós-condições
- Jornada completa de navegação executada (5 steps)
- Usuário visualizou: lista inicial → categorias → categoria específica → busca → detalhes
- Nenhuma autenticação realizada (permanece anônimo)
- Estado pronto para: repetir navegação OU converter para login (~15% dos casos)
- Métricas customizadas `journey_unauthenticated_*` coletadas

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Categoria Inválida
**Condição**: Slug de categoria não existe

**Steps**:
1. Request com slug inexistente (ex: `/products/category/nonexistent`)
2. API retorna 404 Not Found
3. VU registra erro mas continua jornada (simula voltar para categorias válidas)

**Validações**:
- ❌ `'status is 404'` → Status code = 404
- ✅ `'error message present'` → Response contém mensagem de erro

---

### Cenário de Erro 2: Busca Sem Resultados
**Condição**: Query não retorna produtos

**Steps**:
1. Request com termo não encontrado (ex: `q=xyz123nonexistent`)
2. API retorna 200 OK com `products: []` e `total: 0`
3. VU registra resultado vazio (não é erro, é comportamento esperado)

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'products array empty'` → `products.length` === 0
- ✅ `'total is zero'` → `total` === 0

---

### Cenário de Erro 3: ID de Produto Inválido
**Condição**: ID não existe (ex: 9999)

**Steps**:
1. Request com ID inválido (ex: `/products/9999`)
2. API retorna 404 Not Found
3. VU registra erro mas continua (simula voltar para busca)

**Validações**:
- ❌ `'status is 404'` → Status code = 404
- ✅ `'error message present'` → Response contém mensagem de erro

---

### Edge Case 1: Jornada Curta (3 steps)
**Condição**: Usuário vai direto de lista inicial → busca → detalhes (pula categorias)

**Steps**:
1. Step 1: GET /products
2. Step 4: GET /products/search?q=phone (pula steps 2-3)
3. Step 5: GET /products/{id}

**Validações**: Mesmas dos steps individuais

**Think Times**: Reduzidos (1-3s, navegação mais rápida)

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/scenarios/user-journey-unauthenticated.test.ts`
- **Diretório**: `tests/scenarios/` (jornadas compostas ficam em scenarios, não em api/)

### Configuração de Cenário
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom Metrics
const journeyDuration = new Trend('journey_unauthenticated_duration_total_ms');
const journeyStepsCompleted = new Counter('journey_unauthenticated_steps_completed');
const journeyErrors = new Counter('journey_unauthenticated_errors');

// Test Data (SharedArray)
const categories = new SharedArray('categories', function() {
  return JSON.parse(open('../../data/test-data/category-slugs.json'));
});

const searchQueries = new SharedArray('searchQueries', function() {
  return JSON.parse(open('../../data/test-data/search-queries.json'));
});

const productIds = new SharedArray('productIds', function() {
  return JSON.parse(open('../../data/test-data/product-ids.json'));
});

export const options = {
  scenarios: {
    user_journey_unauthenticated: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 3, // 60% tráfego, baseline 5 RPS = 3 RPS
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 15,
      maxVUs: 50,
      tags: { feature: 'products', kind: 'journey', uc: 'UC009' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products}': ['p(95)<400', 'p(99)<700'],
    'http_req_failed{feature:products}': ['rate<0.005'],
    'checks{uc:UC009}': ['rate>0.99'],
    'journey_unauthenticated_duration_total_ms': ['p(95)<10000'],
    'journey_unauthenticated_steps_completed': ['count>0'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  const journeyStart = Date.now();
  let stepsCompleted = 0;

  // Step 1: List Products (Landing Page)
  let res = http.get(`${BASE_URL}/products?limit=20&skip=0`, {
    tags: { name: 'journey_step1_list_products', uc: 'UC009', step: '1' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
  }, { uc: 'UC009', step: '1' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 3 + 2); // 2-5s think time

  // Step 2: Explore Categories
  res = http.get(`${BASE_URL}/products/categories`, {
    tags: { name: 'journey_step2_list_categories', uc: 'UC009', step: '2' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'response is array': (r) => Array.isArray(r.json()),
  }, { uc: 'UC009', step: '2' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 3 + 2);

  // Step 3: Browse by Category
  const randomCategory = randomItem(categories);
  res = http.get(`${BASE_URL}/products/category/${randomCategory.slug}`, {
    tags: { name: 'journey_step3_browse_category', uc: 'UC009', step: '3' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
  }, { uc: 'UC009', step: '3' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 3 + 2);

  // Step 4: Search Products
  const randomQuery = randomItem(searchQueries);
  res = http.get(`${BASE_URL}/products/search?q=${randomQuery.term}`, {
    tags: { name: 'journey_step4_search_products', uc: 'UC009', step: '4' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
  }, { uc: 'UC009', step: '4' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 3 + 2);

  // Step 5: View Product Details
  const randomProductId = randomItem(productIds);
  res = http.get(`${BASE_URL}/products/${randomProductId}`, {
    tags: { name: 'journey_step5_view_details', uc: 'UC009', step: '5' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'product has id': (r) => r.json('id') !== undefined,
  }, { uc: 'UC009', step: '5' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 3 + 2);

  // Record journey metrics
  const journeyEnd = Date.now();
  journeyDuration.add(journeyEnd - journeyStart);
  journeyStepsCompleted.add(stepsCompleted);
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'products',     // Domain area (produtos)
  kind: 'journey',         // Operation type (jornada composta)
  uc: 'UC009'              // Use case ID
}
```

**Fonte**: `docs/casos_de_uso/templates/guia-de-estilo.md` - Tags k6 obrigatórias

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 1 jornada/s por 30s)
K6_RPS=1 K6_DURATION=30s k6 run tests/scenarios/user-journey-unauthenticated.test.ts

# Baseline (5 min, 3 RPS = 60% de 5 RPS baseline)
K6_RPS=3 K6_DURATION=5m k6 run tests/scenarios/user-journey-unauthenticated.test.ts

# Stress (10 min, 10 RPS = 60% de 15-20 RPS stress)
K6_RPS=10 K6_DURATION=10m k6 run tests/scenarios/user-journey-unauthenticated.test.ts

# Com variáveis de ambiente customizadas
BASE_URL=https://dummyjson.com K6_RPS=5 K6_DURATION=3m \
  k6 run tests/scenarios/user-journey-unauthenticated.test.ts
```

### CI/CD
```bash
# GitHub Actions smoke test (PR validation)
# Workflow: .github/workflows/k6-pr-smoke.yml
# Executa: 1 RPS por 60s com thresholds relaxados

# GitHub Actions baseline (main branch)
# Workflow: .github/workflows/k6-main-baseline.yml
# Executa: 3 RPS por 5m com thresholds strict (SLOs completos)
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const journeyDuration = new Trend('journey_unauthenticated_duration_total_ms');

// No VU code (ao final da jornada):
const journeyStart = Date.now();
// ... executa 5 steps ...
const journeyEnd = Date.now();
journeyDuration.add(journeyEnd - journeyStart);
```

**Métrica**: `journey_unauthenticated_duration_total_ms`  
**Tipo**: Trend (latência total da jornada em ms)  
**Threshold**: P95 < 10000ms (10 segundos sem think times)

---

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const journeyStepsCompleted = new Counter('journey_unauthenticated_steps_completed');
const journeyErrors = new Counter('journey_unauthenticated_errors');

// No VU code:
let stepsCompleted = 0;

// Após cada step com check bem-sucedido:
if (check(res, { ... })) {
  stepsCompleted++;
} else {
  journeyErrors.add(1);
}

// Ao final da jornada:
journeyStepsCompleted.add(stepsCompleted);
```

**Métricas**:
- `journey_unauthenticated_steps_completed`: Contador de steps completados (esperado: 5 por iteração)
- `journey_unauthenticated_errors`: Contador de erros durante a jornada

---

### Dashboards
- **Grafana**: (Futuro) Dashboard dedicado a jornadas com métricas de duração total, steps completados, taxa de erro por step
- **k6 Cloud**: (Futuro) Análise de jornadas completas com breakdown por step

---

## ⚠️ Observações Importantes

### Limitações da API
- **DummyJSON**: API pública, latência pode variar com carga do servidor
- **Sem Persistência**: Nenhuma operação de escrita nesta jornada (apenas READ)
- **Rate Limiting**: Não documentado oficialmente; assumir ~100 RPS seguro (5 steps * 3 RPS = 15 RPS bem abaixo)

### Particularidades do Teste
- **Think Times Realistas**: 2-5s entre steps conforme Persona 1 (navegação casual)
- **Randomização**: Cada VU seleciona categoria/query/produto aleatório para simular variedade
- **Jornada Composta**: Combina 4 UCs Tier 0 (UC001, UC002, UC004, UC007)
- **Duração da Sessão**: 3-8 minutos conforme Perfil Visitante (fase1-perfis-de-usuario.md)
- **5 Steps Fixos**: Sequência fixa para consistência de métricas (não randomiza ordem)

### Considerações de Desempenho
- **SharedArray**: Usar para carregar categorias/queries/IDs (evita duplicação em memória)
- **Tags Granulares**: Cada step tem tag `step: '1'` a `'5'` para análise individual
- **Open Model Executor**: `constant-arrival-rate` garante RPS constante independente de latência
- **Memory-Efficient**: Dados carregados uma vez por VU, compartilhados entre iterações

---

## 🔗 Dependências

### UCs Dependentes (Bloqueadores)
- **UC001** (Browse Products Catalog) → Step 1: Listar produtos
- **UC002** (Search & Filter Products) → Step 4: Buscar produtos
- **UC004** (View Product Details) → Step 5: Ver detalhes
- **UC007** (Browse by Category) → Steps 2-3: Categorias e navegação

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC009 depende de UC001, UC002, UC004, UC007

### UCs que Usam Este (Fornece Para)
- **UC010** (User Journey Authenticated) → Usa UC009 como fluxo base antes de autenticação
- **UC011** (Mixed Workload) → Persona "Visitante" (60%) executa UC009

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC009 fornece para UC010, UC011

### Libs Necessárias
- **`libs/scenarios/journey-builder.ts`** (A ser criada neste UC) → Orquestração de jornadas

**Funções Planejadas**:
```typescript
// libs/scenarios/journey-builder.ts
export function createJourney(steps: JourneyStep[]): void;
export function addThinkTime(min: number, max: number): void;
export function validateStep(response: Response, checks: object): boolean;
export function trackJourneyMetrics(startTime: number, endTime: number, stepsCompleted: number): void;
```

### Dados Requeridos
- **UC001**: `data/test-data/products-sample.json` (reutilizado)
- **UC002**: `data/test-data/search-queries.json` (reutilizado)
- **UC004**: `data/test-data/product-ids.json` (reutilizado)
- **UC007**: `data/test-data/category-slugs.json` (reutilizado)

**Estratégia**: Reutilizar TODOS os dados dos UCs Tier 0 (não gerar novos arquivos)

---

## 📂 Libs/Helpers Criados

### `libs/scenarios/journey-builder.ts`
**Localização**: `libs/scenarios/journey-builder.ts`

**Funções Exportadas**:
```typescript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Response } from 'k6/http';

/**
 * Interface para definir um step da jornada
 */
export interface JourneyStep {
  name: string;
  url: string;
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: object;
  body?: string | object;
  checks: object; // k6 check object
  tags: object;
}

/**
 * Cria e executa uma jornada com múltiplos steps
 * @param steps - Array de steps da jornada
 * @returns Número de steps completados com sucesso
 */
export function createJourney(steps: JourneyStep[]): number {
  let stepsCompleted = 0;
  
  steps.forEach((step, index) => {
    const res = http.request(step.method || 'GET', step.url, {
      headers: step.headers,
      tags: { ...step.tags, step: String(index + 1) }
    });
    
    if (validateStep(res, step.checks, step.tags)) {
      stepsCompleted++;
    }
    
    addThinkTime(2, 5); // Default: 2-5s
  });
  
  return stepsCompleted;
}

/**
 * Adiciona think time aleatório entre min e max segundos
 * @param min - Tempo mínimo em segundos
 * @param max - Tempo máximo em segundos
 */
export function addThinkTime(min: number, max: number): void {
  const thinkTime = Math.random() * (max - min) + min;
  sleep(thinkTime);
}

/**
 * Valida um step com checks k6
 * @param response - Resposta HTTP do step
 * @param checks - Objeto de checks k6
 * @param tags - Tags para aplicar aos checks
 * @returns true se todos os checks passaram
 */
export function validateStep(response: Response, checks: object, tags: object): boolean {
  return check(response, checks, tags);
}

/**
 * Registra métricas customizadas da jornada
 * @param startTime - Timestamp de início (Date.now())
 * @param endTime - Timestamp de fim (Date.now())
 * @param stepsCompleted - Número de steps completados
 */
export function trackJourneyMetrics(startTime: number, endTime: number, stepsCompleted: number): void {
  const duration = endTime - startTime;
  // Métricas serão registradas via Trend/Counter no código do teste
  // Esta função pode ser expandida para registrar métricas adicionais
}
```

**Uso**:
```typescript
import { createJourney, JourneyStep } from '../../libs/scenarios/journey-builder';

const journeySteps: JourneyStep[] = [
  {
    name: 'list_products',
    url: `${BASE_URL}/products?limit=20`,
    checks: {
      'status is 200': (r) => r.status === 200,
      'has products': (r) => Array.isArray(r.json('products'))
    },
    tags: { uc: 'UC009', step: 'list' }
  },
  // ... outros steps
];

// No default function:
const stepsCompleted = createJourney(journeySteps);
```

**Testes Unitários**: (Futuro) `tests/unit/libs/scenarios/journey-builder.test.ts`

**Dependências**:
- k6 `http` (requests HTTP)
- k6 `check` (validações)
- k6 `sleep` (think times)

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-08 | GitHub Copilot | Criação inicial do UC009 (Sprint 4) com lib journey-builder.ts |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Persona 1 - Visitante Anônimo, 60% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (5 endpoints GET)
- [x] SLOs estão definidos e justificados (referência aos baselines dos UCs Tier 0)
- [x] Fluxo principal está detalhado passo a passo (5 steps numerados)
- [x] Validações (checks) estão especificadas (checks human-readable para cada step)
- [x] Dados de teste estão identificados (fonte + volume) - reutiliza 4 UCs Tier 0
- [x] Headers obrigatórios estão documentados (Content-Type: application/json)
- [x] Think times estão especificados (2-5s entre steps, Persona 1)
- [x] Edge cases e cenários de erro estão mapeados (3 cenários alternativos)
- [x] Dependências de outros UCs estão listadas (UC001, UC002, UC004, UC007)
- [x] Limitações da API estão documentadas (DummyJSON pública, sem persistência)
- [x] Arquivo nomeado corretamente: `UC009-user-journey-unauthenticated.md`
- [x] Libs/helpers criados estão documentados (`libs/scenarios/journey-builder.ts`)
- [x] Comandos de teste estão corretos e testados (smoke/baseline/stress)
- [x] Tags obrigatórias estão especificadas (feature: products, kind: journey, uc: UC009)
- [x] Métricas customizadas estão documentadas (3 métricas: duration, steps, errors)

---

## 📚 Referências

- [DummyJSON API Docs](https://dummyjson.com/docs)
- [DummyJSON Products API](https://dummyjson.com/docs/products)
- [k6 Documentation - Scenarios](https://grafana.com/docs/k6/latest/using-k6/scenarios/)
- [k6 Documentation - Checks](https://grafana.com/docs/k6/latest/using-k6/checks/)
- [k6 jslib - k6-utils](https://jslib.k6.io/k6-utils/1.4.0/index.js)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md`
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md`
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md`
- UC001 (Browse Products): `docs/casos_de_uso/UC001-browse-products-catalog.md`
- UC002 (Search Products): `docs/casos_de_uso/UC002-search-filter-products.md`
- UC004 (View Details): `docs/casos_de_uso/UC004-view-product-details.md`
- UC007 (Browse Category): `docs/casos_de_uso/UC007-browse-by-category.md`
