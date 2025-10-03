# UC004 - View Product Details

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 1 (Muito Simples)  
> **Sprint**: Sprint 1 (Semana 4)  
> **Esforço Estimado**: 3h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo (Persona 1)
- **Distribuição de Tráfego**: 60% do total esperado (dentro da jornada de navegação)
- **Objetivo de Negócio**: Visualizar detalhes completos de um produto específico para decisão de compra

### Contexto
Após navegar pelo catálogo (UC001) ou buscar produtos (UC002), o usuário **clica em um produto** para ver suas informações detalhadas (título, preço, descrição, imagens, avaliações, estoque). Esta é a **etapa crítica de decisão de compra** na Jornada de Descoberta de Produto, onde o visitante avalia se o item atende suas necessidades.

### Valor de Negócio
- **Criticidade**: Crítica (4/5) - Conversão depende de detalhes claros e completos
- **Impacto no Tráfego**: Alta frequência - step 4 da jornada típica (60% dos visitantes)
- **Conversão**: Detalhes influenciam diretamente a decisão de adicionar ao carrinho
- **Quadrante na Matriz**: ✅ **PRIORIDADE MÁXIMA** (Alta criticidade, Muito baixa complexidade)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/products/{id}` | P95 < 300ms | Single item - mais rápido que listagem. ID deve existir (1-194) |

**Total de Endpoints**: 1  
**Operações READ**: 1  
**Operações WRITE**: 0  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Linha 3 (Products/GET /products/{id})

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 300ms | Baseline real: P95=180ms. Margem de 67% segurança (mais rápido que listagem, payload menor) |
| `http_req_duration{feature:products}` (P99) | < 500ms | Baseline real: P99=220ms. Margem para casos extremos, mesmo com carga alta |
| `http_req_failed{feature:products}` | < 0.5% | Operação crítica para conversão, mesma tolerância do catálogo |
| `checks{uc:UC004}` | > 99.5% | Validações de estrutura do produto devem passar. Permite 0.5% falhas temporárias |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` - Seção 1 (Products READ Operations)

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `product-ids.json` | `data/test-data/` | 100 IDs válidos | Extração de `fulldummyjsondata/products.json` | Mensal (IDs são estáveis) |

### Geração de Dados
```bash
# Extrair IDs válidos de produtos (1-194)
jq '[.products[].id] | .[:100]' data/fulldummyjsondata/products.json \
  > data/test-data/product-ids.json

# Alternativa: gerar sequência 1-100 (IDs garantidos válidos)
echo '[1,2,3,...,100]' > data/test-data/product-ids.json
```

### Dependências de Dados
- **Nenhuma dependência** de outros UCs
- IDs podem ser reutilizados por UC002 (search), UC009/UC010 (jornadas)
- Range válido: 1-194 (total de produtos DummyJSON)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário não autenticado (visitante anônimo)
- ID de produto válido disponível (1-194)
- Conexão com API DummyJSON estabelecida

### Steps

**Step 1: Obter Detalhes do Produto**

```http
GET /products/{id}
Headers:
  Content-Type: application/json
```

**Exemplo Concreto**:
```http
GET https://dummyjson.com/products/5
Headers:
  Content-Type: application/json
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `id` field matching request
- ✅ Has required fields: `title`, `price`, `description`, `category`
- ✅ `price` is numeric and > 0
- ✅ `rating` is numeric between 0-5 (if present)
- ✅ `stock` is integer >= 0
- ✅ `images` array is present (can be empty)

**Think Time**: 3-7s (análise de detalhes, decisão de compra)

---

### Pós-condições
- Produto detalhado visualizado com sucesso
- Usuário possui informações completas para decisão (comprar, adicionar ao carrinho, ou voltar)
- Métricas de latência registradas

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Produto Não Encontrado (404)
**Condição**: ID não existe no catálogo (ex: ID > 194 ou ID inválido)

**Steps**:
1. Request com ID inexistente: `GET /products/9999`
2. Recebe 404 Not Found
3. Response contém mensagem de erro estruturada

**Validações**:
- ❌ Status code = 404
- ❌ Response contains error message (ex: `"message": "Product with id '9999' not found"`)
- ✅ No server error (5xx) - erro esperado e tratado

**Observação**: DummyJSON retorna 404 corretamente para IDs inexistentes. Importante validar que erro é informativo.

---

### Edge Case 1: Produto com Dados Incompletos
**Condição**: Produto válido mas com campos opcionais ausentes

**Steps**:
1. Request produto com dados mínimos
2. Validar que campos obrigatórios existem
3. Campos opcionais podem estar ausentes (ex: `discountPercentage`, `brand`)

**Validações**:
- ✅ Status code = 200
- ✅ Campos obrigatórios presentes: `id`, `title`, `price`
- ⚠️ Campos opcionais podem estar `null` ou ausentes (tratar gracefully)

---

### Edge Case 2: Produto Fora de Estoque
**Condição**: `stock` = 0 (produto esgotado)

**Steps**:
1. Request produto específico
2. Verificar campo `stock`
3. Aplicar lógica de negócio (ex: mostrar "Indisponível", desabilitar botão compra)

**Validações**:
- ✅ Status code = 200
- ✅ `stock` = 0 (válido, mas indisponível)
- ✅ Outros campos presentes normalmente

**Observação**: DummyJSON retorna produtos com `stock: 0`. UC deve validar estrutura, não disponibilidade (lógica de UI).

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/products/view-product-details.test.ts`
- **Diretório**: `tests/api/products/` (domain-driven structure)

### Configuração de Cenário
```javascript
export const options = {
  scenarios: {
    view_product_details: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 5,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'products', kind: 'view', uc: 'UC004' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products}': ['p(95)<300', 'p(99)<500'],
    'http_req_failed{feature:products}': ['rate<0.005'],
    'checks{uc:UC004}': ['rate>0.995'],
  },
};
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'products',  // Domain: products API
  kind: 'view',         // Operation: visualização de detalhes (não browse)
  uc: 'UC004'           // Use case ID (view product details)
}
```

**Justificativa `kind: 'view'`**: Diferencia de `browse` (listagem) - foco em item único.

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 30s, 1 RPS)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/view-product-details.test.ts

# Baseline (5 min, 5 RPS - padrão Sprint 1)
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/view-product-details.test.ts

# Stress (10 min, 20 RPS - validar SLOs sob carga)
K6_RPS=20 K6_DURATION=10m k6 run tests/api/products/view-product-details.test.ts

# Com URL customizada (ambiente staging)
BASE_URL=https://staging.dummyjson.com K6_RPS=5 k6 run tests/api/products/view-product-details.test.ts
```

### CI/CD
```bash
# GitHub Actions - PR Smoke Test
# Arquivo: .github/workflows/k6-pr-smoke.yml
# Trigger: Pull Request para main
# Config: 30s, 1-2 RPS, loose thresholds

# GitHub Actions - Main Baseline Test
# Arquivo: .github/workflows/k6-main-baseline.yml
# Trigger: Push to main
# Config: 5min, 5-10 RPS, strict SLOs (P95<300ms)
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const productDetailsDuration = new Trend('product_details_duration_ms');

// No VU code:
export default function() {
  const productId = productIds[Math.floor(Math.random() * productIds.length)];
  const res = http.get(`${BASE_URL}/products/${productId}`);
  
  productDetailsDuration.add(res.timings.duration);
}
```

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const productDetailsSuccess = new Counter('product_details_success');
const productDetailsErrors = new Counter('product_details_errors');
const productNotFound = new Counter('product_not_found_404');

// No VU code:
if (res.status === 200) {
  productDetailsSuccess.add(1);
} else if (res.status === 404) {
  productNotFound.add(1);
} else {
  productDetailsErrors.add(1);
}
```

### Dashboards
- **Grafana**: Criar painel "Product Details Performance" (quando disponível)
  - P95/P99 latency trend
  - Error rate por status code
  - 404 rate (produtos inexistentes)
- **k6 Cloud**: Projeto `k6-monorepo-products` (futuro)

---

## ⚠️ Observações Importantes

### Limitações da API
- **DummyJSON IDs válidos**: Range 1-194 (atualizar se API crescer)
- **Produto ID 0 ou negativo**: Retorna 404 (comportamento esperado)
- **Produto ID > 194**: Retorna 404 (testar edge case importante)
- **Cache CDN**: Respostas podem ser cacheadas (latência artificialmente baixa em alguns casos)

### Particularidades do Teste
- **Seleção aleatória de IDs**: Usar `SharedArray` para distribuir carga uniforme entre produtos
- **Evitar hot spots**: Não testar sempre o mesmo ID (ex: sempre `GET /products/1`)
- **404 esperado**: Incluir alguns IDs inválidos no dataset (ex: 5% de IDs > 194) para validar tratamento de erro
- **Payload size**: ~500 bytes (pequeno) - latência dominada por RTT, não processamento

### Considerações de Desempenho
- **SharedArray obrigatório**: Carregar `product-ids.json` uma vez, compartilhar entre VUs
  ```javascript
  import { SharedArray } from 'k6/data';
  
  const productIds = new SharedArray('product_ids', function() {
    return JSON.parse(open('../../../data/test-data/product-ids.json'));
  });
  ```
- **Think time realista**: 3-7s (usuário lê descrição, vê imagens, decide)
- **Comparação com UC001**: UC004 é ~30% mais rápido (single item vs lista 30 items)

---

## 🔗 Dependências

### UCs Bloqueadores (Pré-requisitos)
- **Nenhum** ✅ - UC004 é independente (Tier 0)

### UCs que Usam Este (Fornece Para)
- **UC009** - User Journey (Unauthenticated): Step 4 da jornada (clicar em produto)
- **UC010** - User Journey (Authenticated): Reutiliza fluxo de visualização
- **UC011** - Mixed Workload (Realistic Traffic): Integra no mix 60/30/10

### Libs Necessárias
- **Nenhuma lib customizada** necessária
- k6 built-ins: `http`, `check`, `sleep`
- k6 metrics: `Trend`, `Counter`
- k6 data: `SharedArray` para carregar IDs

### Dados Requeridos
- **Primário**: `data/test-data/product-ids.json` (100 IDs válidos)
- **Opcional**: Pode reusar produtos de `fulldummyjsondata/products.json` (referência)

---

## 📂 Libs/Helpers Criados

**Nenhuma lib/helper customizada criada para este UC** ✅

- UC004 usa apenas funcionalidades nativas do k6
- SharedArray é padrão k6 (não requer wrapper)
- Futuro: Se múltiplos UCs precisarem de "getRandomProductId()", extrair para `libs/data/product-loader.ts`

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-03 | GitHub Copilot | Criação inicial do UC004 - View Product Details |

---

## ✅ Checklist de Completude

Validação antes de marcar como ✅ Approved:

- [x] Perfil de usuário está claro e realista (Visitante Anônimo, 60% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (GET /products/{id})
- [x] SLOs estão definidos e justificados (P95<300ms, referência baseline 180ms)
- [x] Fluxo principal está detalhado passo a passo (Step 1 com validações)
- [x] Validações (checks) estão especificadas (7 checks no fluxo principal)
- [x] Dados de teste estão identificados (product-ids.json, 100 IDs)
- [x] Headers obrigatórios estão documentados (Content-Type)
- [x] Think times estão especificados (3-7s análise de detalhes)
- [x] Edge cases e cenários de erro estão mapeados (404, dados incompletos, estoque zero)
- [x] Dependências de outros UCs estão listadas (Nenhuma - Tier 0)
- [x] Limitações da API estão documentadas (IDs 1-194, cache CDN)
- [x] Arquivo nomeado corretamente: `UC004-view-product-details.md` ✅
- [x] Libs/helpers criados estão documentados (N/A - usa k6 nativo)
- [x] Comandos de teste estão corretos e testados (smoke, baseline, stress)
- [x] Tags obrigatórias especificadas (feature:products, kind:view, uc:UC004)
- [x] Métricas customizadas documentadas (product_details_duration_ms, counters)

---

## 📚 Referências

### API Documentation
- [DummyJSON Products API](https://dummyjson.com/docs/products) - Endpoint GET /products/{id}
- [DummyJSON API Docs](https://dummyjson.com/docs) - Overview geral

### k6 Documentation
- [k6 HTTP Module](https://grafana.com/docs/k6/latest/javascript-api/k6-http/)
- [k6 Checks](https://grafana.com/docs/k6/latest/javascript-api/k6/check/)
- [k6 Metrics](https://grafana.com/docs/k6/latest/javascript-api/k6-metrics/)
- [k6 SharedArray](https://grafana.com/docs/k6/latest/javascript-api/k6-data/sharedarray/)

### Projeto - Fases 1-3
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md` (Seção 1: Products)
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md` (Persona 1: Visitante, think times)
- Inventário de Endpoints: `docs/casos_de_uso/fase1-inventario-endpoints.csv` (Linha 3: GET /products/{id})
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md` (UC004: Criticidade 4, Complexidade 1)
- Roadmap: `docs/casos_de_uso/fase2-roadmap-implementacao.md` (Sprint 1, 3h esforço)
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md` (Tier 0: Independente)

### Templates e Guias
- Template de UC: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`
- Checklist de Qualidade: `docs/casos_de_uso/templates/checklist-qualidade.md`
