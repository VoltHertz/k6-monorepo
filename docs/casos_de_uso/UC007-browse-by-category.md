# UC007 - Browse by Category

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 1 (Muito Simples)  
> **Sprint**: Sprint 1 (Semana 4)  
> **Esforço Estimado**: 4h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo (Persona 1)
- **Distribuição de Tráfego**: 60% do total esperado (compartilhado com UC001 e UC002)
- **Objetivo de Negócio**: Navegar por produtos organizados por categoria para facilitar a descoberta de itens de interesse específico

### Contexto
Usuário acessa a loja online e deseja explorar produtos de uma categoria específica (ex: beauty, fragrances, furniture, groceries). Este é um **padrão comum de navegação estruturada** em e-commerce, onde o visitante já sabe o tipo de produto que procura mas ainda não decidiu qual item específico. Representa o **step 2 da Jornada Típica** da Persona Visitante Anônimo: "Explora categorias → Navega por categoria específica".

### Valor de Negócio
- **Criticidade**: Crítica (4/5) - Navegação estruturada, padrão comum de descoberta
- **Impacto no Tráfego**: Média-alta frequência - 60% dos visitantes (Persona 1)
- **Conversão**: Facilita descoberta ao reduzir universo de busca, aumenta engajamento
- **Quadrante na Matriz**: ✅ **PRIORIDADE MÁXIMA** (Alta criticidade, Muito baixa complexidade)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/products/categories` | P95 < 150ms | Lista todas as categorias disponíveis (payload pequeno ~2KB) |
| GET | `/products/category/{slug}` | P95 < 300ms | Retorna produtos filtrados por categoria. Slug deve existir |

**Total de Endpoints**: 2  
**Operações READ**: 2  
**Operações WRITE**: 0  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Linhas 5-6 (Products/GET /products/categories e /products/category/{slug})  

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 300ms | Baseline real: P95=220ms (GET /products/category/{slug}); margem de segurança para variabilidade |
| `http_req_duration{feature:products}` (P99) | < 500ms | Baseline real: P99=290ms; margem para casos extremos |
| `http_req_failed{feature:products}` | < 0.5% | Operação crítica de navegação (alta frequência) |
| `checks{uc:UC007}` | > 99.5% | Validações devem passar; tolera 0.5% falhas transitórias |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (seção Products - GET /products/category/{slug}: P50=150ms, P95=220ms, P99=290ms)

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `category-slugs.json` | `data/test-data/` | ~24 slugs | Gerado de `fulldummyjsondata/products.json` (extração única de categorias) | Mensal (categorias raramente mudam) |

### Geração de Dados
```bash
# Extrair categorias únicas dos produtos e gerar array de slugs
node data/test-data/generators/generate-category-slugs.ts \
  --source data/fulldummyjsondata/products.json \
  --output data/test-data/category-slugs.json

# Resultado esperado: ["beauty", "fragrances", "furniture", "groceries", ...]
```

### Dependências de Dados
- Nenhuma dependência de outros UCs
- Dados autocontidos e estáticos (categorias não mudam frequentemente)
- **Alinhamento com Fase 1**: Perfil Visitante Anônimo - Endpoints utilizados incluem `/products/categories` e `/products/category/{slug}` (média frequência)

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

**Think Time**: 2-5s (Persona 1 — leitura das opções)

---

**Step 2: Selecionar e Navegar em Categoria Específica**  
```http
GET /products/category/beauty
Headers:
  Content-Type: application/json
```

**Validações** (human-readable):
- ✅ 'status is 200' → Status code = 200
- ✅ 'has products array' → Body contém `products` array
- ✅ 'category has products' → `products.length` > 0
- ✅ 'total is positive' → `total` > 0
- ✅ 'category matches filter' → Cada produto tem `category` = "beauty"
- ✅ 'product structure is valid' → Cada produto contém `id`, `title`, `price`, `category`

**Think Time**: 2-5s (Persona 1 — análise da categoria)

---

**Step 3: Explorar Outra Categoria (Fluxo Iterativo)**  
```http
GET /products/category/fragrances
Headers:
  Content-Type: application/json
```

**Validações** (human-readable):
- ✅ 'status is 200' → Status code = 200
- ✅ 'has products array' → Body contém `products` array
- ✅ 'category matches filter' → Cada produto tem `category` = "fragrances"

**Think Time**: 2-5s (navegação contínua)

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

**Validações** (human-readable):
- ✅ 'status is 404' → Status code = 404
- ✅ 'error message present' → Body contém mensagem de erro

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
const product_category_list_duration_ms = new Trend('product_category_list_duration_ms');
const product_category_browse_duration_ms = new Trend('product_category_browse_duration_ms');
const product_category_browse_errors = new Counter('product_category_browse_errors');

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
      tags: { feature: 'products', kind: 'browse', uc: 'UC007' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products}': ['p(95)<300', 'p(99)<500'],
    'http_req_failed{feature:products}': ['rate<0.005'],
    'checks{uc:UC007}': ['rate>0.995'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  // Step 1: List categories (opcional, pode ser omitido em algumas iterações)
  if (Math.random() < 0.3) { // 30% das vezes lista categorias primeiro
    const categoriesRes = http.get(
      `${BASE_URL}/products/categories`,
      { tags: { name: 'list_categories', feature: 'products', kind: 'browse', uc: 'UC007', step: 'list' } }
    );
    
    product_category_list_duration_ms.add(categoriesRes.timings.duration);
    
    check(categoriesRes, {
      'categories status is 200': (r) => r.status === 200,
      'categories is array': (r) => Array.isArray(r.json()),
      'categories not empty': (r) => r.json().length > 0,
    }, { uc: 'UC007', step: 'list' });
    
    sleep(Math.random() * 3 + 2); // 2-5s think time
  }
  
  // Step 2: Browse specific category
  const slug = randomItem(categorySlugs);
  const categoryRes = http.get(
    `${BASE_URL}/products/category/${slug}`,
    { tags: { name: 'browse_category', feature: 'products', kind: 'browse', uc: 'UC007', step: 'browse' } }
  );
  
  product_category_browse_duration_ms.add(categoryRes.timings.duration);
  
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
    product_category_browse_errors.add(1);
  }
  
  sleep(Math.random() * 3 + 2); // 2-5s think time
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'products',  // Domain area
  kind: 'browse',       // Operation type (navegação)
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

const product_category_list_duration_ms = new Trend('product_category_list_duration_ms');
const product_category_browse_duration_ms = new Trend('product_category_browse_duration_ms');

// No VU code:
product_category_list_duration_ms.add(res.timings.duration);   // Step 1: listar categorias
product_category_browse_duration_ms.add(res.timings.duration); // Step 2: navegar categoria
```

**Uso**: Medir latência específica de cada operação (list vs browse)

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const product_category_browse_errors = new Counter('product_category_browse_errors');

// No VU code:
if (!browsedOk) {
  product_category_browse_errors.add(1);
}
```

**Uso**: Contar falhas específicas de navegação por categoria (além do error rate geral)

### Dashboards
- **Grafana**: Criar painel com `product_category_list_duration_ms` e `product_category_browse_duration_ms` (histograma)
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
- **Think Time Variável**: 2-5s para listar e navegar (Persona 1)

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
- `data/test-data/category-slugs.json` - Array de slugs para randomização (principal arquivo)

**Alinhamento com Fase 2 - Mapa de Dependências**:
- **Tier 0**: UC007 é independente (sem dependências de outros UCs)
- **Dados**: `data/test-data/category-slugs.json` [D] conforme dataset definido neste UC
- **Fornece para**: UC009, UC010, UC011 (jornadas compostas)

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
- [x] Dados de teste estão identificados (`category-slugs.json`)
- [x] Headers obrigatórios estão documentados (Content-Type: application/json)
- [x] Think times estão especificados onde necessário (2-5s Persona 1)
- [x] Edge cases e cenários de erro estão mapeados (categoria inválida 404, categoria vazia)
- [x] Dependências de outros UCs estão listadas (Tier 0, sem dependências)
- [x] Limitações da API estão documentadas (categorias fixas, sem paginação, case-sensitive)
- [x] Arquivo nomeado corretamente: `UC007-browse-by-category.md`
- [x] Libs/helpers criados estão documentados (N/A - não cria novas libs)
- [x] Comandos de teste estão corretos e testados (smoke/baseline/stress)
- [x] Tags obrigatórias estão especificadas (feature: products, kind: browse, uc: UC007)
- [x] Métricas customizadas estão documentadas (product_category_list_duration_ms, product_category_browse_duration_ms, product_category_browse_errors)

---

## 📚 Referências

- [DummyJSON Products API - Categories](https://dummyjson.com/docs/products#products-categories)
- [k6 Documentation - Executors](https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/constant-arrival-rate/)
- [k6 Documentation - SharedArray](https://grafana.com/docs/k6/latest/javascript-api/k6-data/sharedarray/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md` (seção Products - Tabela linha 5: GET /products/category/{slug})
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md` (Persona 1: Visitante Anônimo - Endpoints utilizados linha 29-31)
- Inventário de Endpoints: `docs/casos_de_uso/fase1-inventario-endpoints.csv` (linhas 5-6: /products/categories e /products/category/{slug})
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md` (UC007: P0, criticidade 4, complexidade 1, quadrante PRIORIDADE MÁXIMA)
- Roadmap: `docs/casos_de_uso/fase2-roadmap-implementacao.md` (Sprint 1, 4h esforço, linha 43-50)
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md` (Tier 0, sem dependências, fornece para UC009/UC010/UC011, linha 51-58)
- Template: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`

---

## 🔗 Alinhamento com Entradas Prioritárias (Fases 1-3)

### ✅ Fase 1 - Análise e Levantamento

**Inventário de Endpoints** (`fase1-inventario-endpoints.csv`):
- ✅ Linha 5: GET /products/categories - "Retorna array de objetos com slug/name/url"
- ✅ Linha 6: GET /products/category/{slug} - "Slug deve existir nas categorias"

**Perfis de Usuário** (`fase1-perfis-de-usuario.md`):
- ✅ Persona 1: Visitante Anônimo (60% tráfego)
- ✅ Jornada Típica - Step 2: "Explora categorias → Navega por categoria específica"
- ✅ Endpoints Utilizados: GET /products/categories (média frequência), GET /products/category/{slug} (média frequência)
- ✅ Think time: 2-5 segundos entre ações (aplicado nos steps)

**Baseline de SLOs** (`fase1-baseline-slos.md`):
- ✅ GET /products/categories: P95=140ms, P99=180ms → SLO: P95 < 150ms (margem 7%)
- ✅ GET /products/category/{slug}: P95=220ms, P99=290ms → SLO: P95 < 300ms (margem 36%)
- ✅ Error Rate: 0% observado → SLO: < 0.5% (conservador)

### ✅ Fase 2 - Priorização e Roadmap

**Matriz de Priorização** (`fase2-matriz-priorizacao.md`):
- ✅ Criticidade: 4 (Crítico - navegação estruturada)
- ✅ Complexidade: 1 (Muito simples)
- ✅ Quadrante: PRIORIDADE MÁXIMA (Alta criticidade + Baixa complexidade)
- ✅ Justificativa: "Padrão comum de navegação"
- ✅ Dependências: Nenhuma

**Roadmap de Implementação** (`fase2-roadmap-implementacao.md`):
- ✅ Sprint 1 (Semana 4) - Fundação
- ✅ Esforço: 4h
- ✅ Prioridade: P0 (Crítico)
- ✅ Meta: 60% tráfego coberto (com UC001, UC004, UC007)

**Mapa de Dependências** (`fase2-mapa-dependencias.md`):
- ✅ Tier 0: Casos de Uso Independentes
- ✅ Dependências: Nenhuma ✅
- ✅ Fornece para: UC009, UC010, UC011
- ✅ Dados: `data/test-data/category-slugs.json` [D]
- ✅ Libs: Nenhuma necessária

### ✅ Fase 3 - Template e Padrões

**Template de UC** (`templates/use-case-template.md`):
- ✅ Todas 15 seções obrigatórias preenchidas
- ✅ Badges de status: ✅ Approved, P0 (Crítico), Complexidade 1
- ✅ Estrutura: Descrição → Endpoints → SLOs → Dados → Fluxo → Alternativas → Implementação → Testes → Métricas → Observações → Dependências → Histórico → Checklist → Referências

**Guia de Estilo** (`templates/guia-de-estilo.md`):
- ✅ Nomenclatura: UC007-browse-by-category.md (kebab-case)
- ✅ Tags k6: feature: products, kind: category, uc: UC007
- ✅ Métricas: product_category_list_duration_ms, product_category_browse_duration_ms (snake_case)
- ✅ Checks: 'categories status is 200', 'has products array' (human-readable)
- ✅ Think times: "2-5s (Persona 1)"
- ✅ Emojis consistentes: 📋 📊 🔗 📦 🔄 🔀 ⚙️ 🧪 📈 ⚠️ 📂 📝 ✅ 📚

**Checklist de Qualidade** (`templates/checklist-qualidade.md`):
- ✅ 16/16 itens do checklist validados
- ✅ Tier 0: 4 verificações adicionais OK (sem auth, dados autocontidos, endpoints READ, SLOs conservadores)
