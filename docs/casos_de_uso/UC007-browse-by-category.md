# UC007 - Browse by Category

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 1 (Muito Simples)  
> **Sprint**: Sprint 1 (Semana 4)  
> **Esforço Estimado**: 4h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo
- **Distribuição de Tráfego**: 60% do total (compartilhado com UC001 e UC002)
- **Objetivo de Negócio**: Navegar por produtos organizados por categoria para facilitar a descoberta de itens de interesse específico

### Contexto
Usuário acessa a loja online e deseja explorar produtos de uma categoria específica (ex: beauty, fragrances, furniture, groceries). Este é um padrão comum de navegação em e-commerce onde o usuário já sabe o tipo de produto que procura mas ainda não decidiu qual item específico.

### Valor de Negócio
- Representa uma parte significativa dos 60% de tráfego de visitantes anônimos
- Navegação por categoria é o segundo caminho mais comum após listagem geral
- Facilita a descoberta de produtos ao reduzir o universo de busca
- Crítico para UX: organização clara aumenta conversão

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/products/categories` | P95 < 150ms | Lista todas as categorias disponíveis (payload pequeno) |
| GET | `/products/category/{slug}` | P95 < 300ms | Retorna produtos filtrados por categoria |

**Total de Endpoints**: 2  
**Operações READ**: 2  
**Operações WRITE**: 0  

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products,kind:category}` (P95) | < 300ms | Baseline Fase 1: GET /products/category/{slug} P95 = 220ms, margem 36% para variabilidade de categoria |
| `http_req_duration{feature:products,kind:category}` (P99) | < 500ms | Margem de segurança para categorias com maior volume de produtos |
| `http_req_failed{feature:products,kind:category}` | < 0.5% | Operação crítica de navegação, mesma tolerância de UC001 |
| `checks{uc:UC007}` | > 99.5% | Validações core devem passar, permite 0.5% falhas temporárias de rede |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (seção Products)

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `categories.json` | `data/test-data/` | ~24 categorias | Gerado de `fulldummyjsondata/products.json` (extração única) | Mensal (categorias raramente mudam) |
| `category-slugs.json` | `data/test-data/` | ~24 slugs | Derivado de `categories.json` | Mensal |

### Geração de Dados
```bash
# Extrair categorias únicas dos produtos
node data/test-data/generators/generate-categories.ts \
  --source data/fulldummyjsondata/products.json \
  --output data/test-data/categories.json

# Gerar lista de slugs para randomização
node data/test-data/generators/extract-category-slugs.ts \
  --source data/test-data/categories.json \
  --output data/test-data/category-slugs.json
```

### Dependências de Dados
- Nenhuma dependência de outros UCs
- Dados autocontidos e estáticos (categorias não mudam frequentemente)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário não autenticado (navegação anônima)
- API DummyJSON disponível
- Categorias existentes no sistema

### Steps

**Step 1: Listar Categorias Disponíveis**  
```http
GET /products/categories
Headers:
  Content-Type: application/json
```

**Validações**:
- ✅ Status code = 200
- ✅ Response é um array
- ✅ Array contém objetos com propriedades `slug`, `name`, `url`
- ✅ Array não está vazio (mínimo 1 categoria)
- ✅ Cada categoria tem `slug` válido (string não vazia)

**Think Time**: 2-3s (usuário lê as opções de categoria)

---

**Step 2: Selecionar e Navegar em Categoria Específica**  
```http
GET /products/category/beauty
Headers:
  Content-Type: application/json
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contém `products` array
- ✅ `products.length` > 0 (categoria tem produtos)
- ✅ `total` > 0 (total de produtos na categoria)
- ✅ Cada produto tem `category` = "beauty" (validação de filtro)
- ✅ Estrutura de produto válida (`id`, `title`, `price`, `category`)

**Think Time**: 3-5s (usuário analisa produtos da categoria)

---

**Step 3: Explorar Outra Categoria (Fluxo Iterativo)**  
```http
GET /products/category/fragrances
Headers:
  Content-Type: application/json
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contém `products` array
- ✅ Cada produto tem `category` = "fragrances"

**Think Time**: 3-5s (navegação contínua)

---

### Pós-condições
- Usuário visualizou produtos de pelo menos uma categoria
- Pode prosseguir para UC004 (View Product Details) se encontrar item de interesse
- Pode retornar para UC001 (Browse Products Catalog) ou continuar navegando categorias

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Categoria Inválida
**Condição**: Usuário tenta acessar categoria inexistente (slug inválido)

**Steps**:
1. Request: `GET /products/category/invalid-category-slug`
2. Recebe status 404 Not Found
3. Response contém mensagem de erro: `"Category not found"`

**Validações**:
- ✅ Status code = 404
- ✅ Error message presente no body

**Ação de Recuperação**: Usuário retorna à lista de categorias (Step 1)

---

### Edge Case 1: Categoria Vazia
**Condição**: Categoria existe mas não possui produtos (cenário raro no DummyJSON)

**Steps**:
1. Request com categoria válida mas vazia
2. Recebe status 200 mas `products` array vazio

**Validações**:
- ✅ Status code = 200
- ✅ `products` é array vazio `[]`
- ✅ `total` = 0

**Nota**: No DummyJSON atual todas as categorias têm produtos, mas validação garante robustez.

---

### Edge Case 2: Navegação Sequencial de Múltiplas Categorias
**Condição**: Usuário explora 3+ categorias diferentes em sequência

**Steps**:
1. GET /products/categories (lista)
2. GET /products/category/beauty (1ª categoria)
3. GET /products/category/fragrances (2ª categoria)
4. GET /products/category/furniture (3ª categoria)
5. Think time: 2-5s entre cada navegação

**Validações**:
- ✅ Cada request retorna status 200
- ✅ Produtos filtrados corretamente em cada categoria

**Observação**: Padrão realista de usuário indeciso explorando opções.

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/products/browse-by-category.test.ts`
- **Diretório**: `tests/api/products/`

### Configuração de Cenário
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom Metrics
const categoryListDuration = new Trend('category_list_duration_ms');
const categoryBrowseDuration = new Trend('category_browse_duration_ms');
const categoryBrowseErrors = new Counter('category_browse_errors');

// Test Data
const categorySlugs = new SharedArray('categorySlugs', function() {
  return JSON.parse(open('../../../data/test-data/category-slugs.json'));
});

export const options = {
  scenarios: {
    browse_by_category: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 5,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'products', kind: 'category', uc: 'UC007' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products,kind:category}': ['p(95)<300'],
    'http_req_failed{feature:products,kind:category}': ['rate<0.005'],
    'checks{uc:UC007}': ['rate>0.995'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  // Step 1: List categories (opcional, pode ser omitido em algumas iterações)
  if (Math.random() < 0.3) { // 30% das vezes lista categorias primeiro
    const categoriesRes = http.get(
      `${BASE_URL}/products/categories`,
      { tags: { name: 'list_categories', uc: 'UC007', step: 'list' } }
    );
    
    categoryListDuration.add(categoriesRes.timings.duration);
    
    check(categoriesRes, {
      'categories status is 200': (r) => r.status === 200,
      'categories is array': (r) => Array.isArray(r.json()),
      'categories not empty': (r) => r.json().length > 0,
    }, { uc: 'UC007', step: 'list' });
    
    sleep(2 + Math.random() * 1); // 2-3s think time
  }
  
  // Step 2: Browse specific category
  const slug = randomItem(categorySlugs);
  const categoryRes = http.get(
    `${BASE_URL}/products/category/${slug}`,
    { tags: { name: 'browse_category', uc: 'UC007', step: 'browse' } }
  );
  
  categoryBrowseDuration.add(categoryRes.timings.duration);
  
  const browsedOk = check(categoryRes, {
    'category status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
    'products not empty': (r) => r.json('products').length > 0,
    'products match category': (r) => {
      const products = r.json('products');
      return products.every(p => p.category === slug);
    },
  }, { uc: 'UC007', step: 'browse' });
  
  if (!browsedOk) {
    categoryBrowseErrors.add(1);
  }
  
  sleep(3 + Math.random() * 2); // 3-5s think time
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'products',  // Domain area
  kind: 'category',     // Operation type (navegação por categoria)
  uc: 'UC007'           // Use case ID
}
```

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 30s, 1 RPS)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/browse-by-category.test.ts

# Baseline (5 min, 5 RPS)
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/browse-by-category.test.ts

# Stress (10 min, 20 RPS)
K6_RPS=20 K6_DURATION=10m k6 run tests/api/products/browse-by-category.test.ts

# Com BASE_URL customizado
BASE_URL=https://api.example.com K6_RPS=5 k6 run tests/api/products/browse-by-category.test.ts
```

### CI/CD
```bash
# GitHub Actions smoke test (PR)
# Executado automaticamente em .github/workflows/k6-pr-smoke.yml

# GitHub Actions baseline (main branch)
# Executado automaticamente em .github/workflows/k6-main-baseline.yml
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const categoryListDuration = new Trend('category_list_duration_ms');
const categoryBrowseDuration = new Trend('category_browse_duration_ms');

// No VU code:
categoryListDuration.add(res.timings.duration);   // Step 1: listar categorias
categoryBrowseDuration.add(res.timings.duration); // Step 2: navegar categoria
```

**Uso**: Medir latência específica de cada operação (list vs browse)

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const categoryBrowseErrors = new Counter('category_browse_errors');

// No VU code:
if (!browsedOk) {
  categoryBrowseErrors.add(1);
}
```

**Uso**: Contar falhas específicas de navegação por categoria (além do error rate geral)

### Dashboards
- **Grafana**: Criar painel com `category_list_duration_ms` e `category_browse_duration_ms` (histograma)
- **k6 Cloud**: Métricas automáticas se upload habilitado (`k6 cloud tests/...`)

---

## ⚠️ Observações Importantes

### Limitações da API
- **Categorias Fixas**: DummyJSON tem ~24 categorias predefinidas (não é possível criar novas via API)
- **Filtro Apenas por Slug**: Não suporta múltiplas categorias em um request (ex: `?category=beauty,fragrances`)
- **Paginação Limitada**: `/products/category/{slug}` não suporta `limit` e `skip` (retorna todos os produtos da categoria)
- **Case-Sensitive Slugs**: Slug deve ser lowercase exato (ex: `beauty` funciona, `Beauty` não)

### Particularidades do Teste
- **SharedArray para Slugs**: Usar `SharedArray` para carregar `category-slugs.json` evita duplicação em memória entre VUs
- **Randomização Ponderada**: Poderia adicionar peso às categorias mais populares (ex: beauty 30%, electronics 20%), mas atual usa distribuição uniforme
- **Think Time Variável**: 2-3s para listar (rápido), 3-5s para navegar (análise de produtos)

### Considerações de Desempenho
- **Endpoint Leve**: `/products/categories` retorna apenas metadados (~2KB), muito rápido (P95 < 150ms)
- **Endpoint Médio**: `/products/category/{slug}` varia por categoria (5-30 produtos), mas ainda rápido (P95 < 300ms)
- **Cache-Friendly**: Categorias raramente mudam, ideal para CDN caching

---

## 🔗 Dependências

### UCs Bloqueadores (Dependências)
- **Nenhum** ✅ UC007 é independente (Tier 0)

### UCs que Usam Este (Fornece Para)
- **UC009** - User Journey (Unauthenticated): Integra navegação por categoria no fluxo de visitante
- **UC010** - User Journey (Authenticated): Pode incluir navegação por categoria antes de adicionar ao carrinho
- **UC011** - Mixed Workload (Realistic Traffic): Usa como parte da distribuição 60% visitante

### Libs Necessárias
- **Nenhuma lib customizada necessária**
- Usar funções nativas k6: `http`, `check`, `sleep`
- Usar jslib remote: `randomItem` de `https://jslib.k6.io/k6-utils/1.4.0/index.js`

### Dados Requeridos
- `data/test-data/categories.json` - Lista completa de categorias
- `data/test-data/category-slugs.json` - Array de slugs para randomização

---

## 📂 Libs/Helpers Criados

**Não aplicável** - UC007 não cria novas libs.

Reutiliza padrões existentes:
- `SharedArray` para dados (k6 nativo)
- `randomItem` para seleção aleatória (jslib.k6.io)
- Padrão de custom metrics (`Trend`, `Counter`)

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-03 | GitHub Copilot | Criação inicial do UC007 - Sprint 1, Fase 4 |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Visitante Anônimo, 60% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (GET /products/categories, GET /products/category/{slug})
- [x] SLOs estão definidos e justificados (P95 < 300ms baseado em baseline Fase 1)
- [x] Fluxo principal está detalhado passo a passo (3 steps: listar, navegar, explorar)
- [x] Validações (checks) estão especificadas (status 200, array válido, filtro correto)
- [x] Dados de teste estão identificados (categories.json, category-slugs.json)
- [x] Headers obrigatórios estão documentados (Content-Type: application/json)
- [x] Think times estão especificados onde necessário (2-3s listar, 3-5s navegar)
- [x] Edge cases e cenários de erro estão mapeados (categoria inválida 404, categoria vazia)
- [x] Dependências de outros UCs estão listadas (Tier 0, sem dependências)
- [x] Limitações da API estão documentadas (categorias fixas, sem paginação, case-sensitive)
- [x] Arquivo nomeado corretamente: `UC007-browse-by-category.md`
- [x] Libs/helpers criados estão documentados (N/A - não cria novas libs)
- [x] Comandos de teste estão corretos e testados (smoke/baseline/stress)
- [x] Tags obrigatórias estão especificadas (feature: products, kind: category, uc: UC007)
- [x] Métricas customizadas estão documentadas (category_list_duration_ms, category_browse_duration_ms, category_browse_errors)

---

## 📚 Referências

- [DummyJSON Products API - Categories](https://dummyjson.com/docs/products#products-categories)
- [k6 Documentation - Executors](https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/constant-arrival-rate/)
- [k6 Documentation - SharedArray](https://grafana.com/docs/k6/latest/javascript-api/k6-data/sharedarray/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md` (seção Products)
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md` (Visitante Anônimo)
- Inventário de Endpoints: `docs/casos_de_uso/fase1-inventario-endpoints.csv` (linha 5-6: /products/categories e /products/category/{slug})
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md` (UC007: P0, complexidade 1)
- Roadmap: `docs/casos_de_uso/fase2-roadmap-implementacao.md` (Sprint 1, 4h esforço)
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md` (Tier 0, sem dependências)
- Template: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`
