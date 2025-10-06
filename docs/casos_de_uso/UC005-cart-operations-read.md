# UC005 - Cart Operations (Read)

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 2 (Simples)  
> **Sprint**: Sprint 3 (Semana 6)  
> **Esforço Estimado**: 6h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Comprador Autenticado (Persona 2: 30% do tráfego)
- **Distribuição de Tráfego**: 30% do total (parte do fluxo de compra)
- **Objetivo de Negócio**: Visualizar carrinho de compras antes do checkout, verificar itens, quantidades, preços e totais calculados

### Contexto
Usuário autenticado (já realizou login via UC003) deseja visualizar o conteúdo do seu carrinho de compras antes de proceder para checkout. Esta é uma operação **crítica de pré-checkout** que permite ao comprador revisar itens adicionados, verificar preços totais (com descontos aplicados) e tomar decisão de compra. O fluxo típico é: Login → Navegação/Busca de Produtos → **Visualização de Carrinho** → (Opcional) Atualização de Carrinho → Checkout.

### Valor de Negócio
- **Criticidade**: Crítico (4/5) - Visualização pré-checkout essencial para conversão
- **Impacto**: Habilita decisão de compra informada, reduz abandonos de carrinho
- **Conversão**: Usuários que visualizam carrinho têm 60% maior probabilidade de finalizar compra
- **Dependências**: Bloqueado por UC003 (requer autenticação), bloqueia UC006 (Cart Write) e UC010 (User Journey Auth)
- **Quadrante na Matriz**: ✅ **PRIORIDADE MÁXIMA** (Alta criticidade, Baixa complexidade)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 2 (Comprador Autenticado: 30% do tráfego)  
**Fonte**: `docs/casos_de_uso/fase2-matriz-priorizacao.md` - UC005 (Criticidade 4, Complexidade 2)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/carts` | P95 < 400ms | Lista todos os carrinhos (admin view), retorna 30 itens padrão |
| GET | `/carts/{id}` | P95 < 350ms | Obtém carrinho específico por ID, single cart (mais rápido) |
| GET | `/carts/user/{userId}` | P95 < 400ms | Carrinhos de um usuário específico (operação principal deste UC) |

**Total de Endpoints**: 3  
**Operações READ**: 3  
**Operações WRITE**: 0  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Linhas 21-23 (Carts/GET /carts, GET /carts/{id}, GET /carts/user/{userId})

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:carts}` (P95) | < 400ms | Baseline Fase 1: GET /carts/user/{userId} P95 real = 270ms. Margem de 48% conforme recomendação baseline |
| `http_req_duration{feature:carts}` (P99) | < 600ms | Baseline Fase 1: P99 real = 350ms. Margem de 71% para casos extremos |
| `http_req_failed{feature:carts}` | < 1% | Operação crítica pré-checkout, tolerância para userId inválido ou carrinho vazio |
| `checks{uc:UC005}` | > 99% | Validações de estrutura de carrinho devem passar. Permite 1% falhas temporárias |
| `cart_view_duration_ms` (P95) | < 400ms | Métrica customizada de latência específica da visualização de carrinho (alinhada com threshold geral) |
| `cart_view_success` (count) | > 0 | Garantir que visualizações bem-sucedidas ocorrem durante o teste |
| `cart_items_total` (avg) | > 0 | Média de itens por carrinho (indicador de engajamento) |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (Carts Operations)  
**Medição Original**: GET /carts - P50=200ms, P95=300ms, P99=390ms, Max=520ms, Error Rate=0%  
**Medição Original**: GET /carts/{id} - P50=150ms, P95=220ms, P99=290ms, Max=380ms, Error Rate=0%  
**Medição Original**: GET /carts/user/{userId} - P50=180ms, P95=270ms, P99=350ms, Max=460ms, Error Rate=0%

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `cart-ids.json` | `data/test-data/` | 30 cart IDs | Extração de `data/fulldummyjsondata/carts.json` | Mensal ou quando DummyJSON atualizar |
| `users-with-carts.json` | `data/test-data/` | 20 userIds com carrinhos | Filtrado de `fulldummyjsondata/carts.json` por `userId` | Mensal |
| `users-credentials.csv` | `data/test-data/` | 50 usuários (reuso UC003) | Extração de `fulldummyjsondata/users.json` | Mensal (criado em UC003) |

### Estrutura de `cart-ids.json`
```json
[
  { "id": 1, "userId": 142, "totalProducts": 5, "totalQuantity": 20 },
  { "id": 2, "userId": 13, "totalProducts": 3, "totalQuantity": 8 },
  { "id": 3, "userId": 89, "totalProducts": 4, "totalQuantity": 12 }
]
```

### Estrutura de `users-with-carts.json`
```json
[
  {
    "userId": 5,
    "cartIds": [19],
    "totalCarts": 1,
    "username": "sophiab"
  },
  {
    "userId": 13,
    "cartIds": [2, 15],
    "totalCarts": 2,
    "username": "williamm"
  }
]
```

### Geração de Dados
```bash
# Extrair IDs de carrinhos do dump completo (primeiros 30)
jq '[.carts[0:30] | .[] | {id: .id, userId: .userId, totalProducts: .totalProducts, totalQuantity: .totalQuantity}]' \
  data/fulldummyjsondata/carts.json > data/test-data/cart-ids.json

# Gerar mapeamento userId → cartIds (agrupar carrinhos por usuário)
jq '[.carts | group_by(.userId) | .[] | {
  userId: .[0].userId,
  cartIds: [.[] | .id],
  totalCarts: length
}]' data/fulldummyjsondata/carts.json > data/test-data/users-with-carts.json

# Validar estrutura dos arquivos gerados
jq 'length' data/test-data/cart-ids.json
jq 'length' data/test-data/users-with-carts.json

# Verificar carrinhos existentes (smoke check)
curl -s https://dummyjson.com/carts/1 | jq '.id, .userId, .totalProducts'
```

### Dependências de Dados
- **UC003** - Requer `users-credentials.csv` para autenticação (login antes de visualizar carrinho)
- **Fornece para**: UC006 (Cart Write usa cart IDs para update/delete), UC010 (User Journey Auth integra visualização de carrinho)
- Dados autocontidos extraídos de `fulldummyjsondata/carts.json`

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC005 depende de UC003 (Auth), fornece para UC006 e UC010

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário **autenticado** (possui `accessToken` válido de UC003)
- API DummyJSON disponível em https://dummyjson.com
- Usuário tem pelo menos um carrinho associado ao seu `userId` (ou testa carrinho vazio)

### Steps

**Step 1: Obter Carrinhos do Usuário Autenticado**  
```http
GET /carts/user/{userId}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Exemplo Concreto**:
```http
GET /carts/user/5
Headers:
  Content-Type: application/json
  Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has carts array'` → Response contains `carts` array
- ✅ `'carts have products'` → Each cart has `products` array (pode estar vazio)
- ✅ `'has totals'` → Each cart has `total`, `discountedTotal`, `totalProducts`, `totalQuantity`
- ✅ `'userId matches'` → Each cart has `userId` matching request parameter

**Response Esperado** (exemplo):
```json
{
  "carts": [
    {
      "id": 19,
      "products": [
        {
          "id": 144,
          "title": "Cricket Helmet",
          "price": 44.99,
          "quantity": 4,
          "total": 179.96,
          "discountPercentage": 11.47,
          "discountedTotal": 159.32,
          "thumbnail": "https://cdn.dummyjson.com/products/images/..."
        }
      ],
      "total": 2492,
      "discountedTotal": 2140,
      "userId": 5,
      "totalProducts": 5,
      "totalQuantity": 14
    }
  ],
  "total": 1,
  "skip": 0,
  "limit": 1
}
```

**Think Time**: 3-7s (usuário analisa itens do carrinho, verifica preços)

**Fonte Think Time**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Fluxo 2 (Comprador): 3-7s entre ações

---

**Step 2: Obter Detalhes de um Carrinho Específico (Opcional)**  
```http
GET /carts/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Exemplo Concreto**:
```http
GET /carts/19
Headers:
  Content-Type: application/json
  Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has cart id'` → Response contains `id` matching request
- ✅ `'has products details'` → Each product has `id`, `title`, `price`, `quantity`, `total`, `discountPercentage`, `discountedTotal`, `thumbnail`
- ✅ `'totals are calculated'` → `total` = sum of product totals, `discountedTotal` < `total`
- ✅ `'has user association'` → Response contains `userId`

**Think Time**: 3-7s (análise de detalhes do produto no carrinho)

**Fonte Think Time**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 2 (Comprador): 3-7s entre ações

---

### Pós-condições
- Usuário visualizou conteúdo do carrinho (itens, quantidades, preços)
- Dados de carrinho disponíveis para decisão de compra
- Usuário pode proceder para:
  - UC006 (Cart Write - adicionar/remover itens)
  - Checkout (fora do escopo deste projeto - DummyJSON não tem endpoint de checkout)
  - Continuar navegação (voltar para UC001/UC002)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Usuário Não Autenticado (Missing Token)
**Condição**: GET /carts/user/{userId} sem header `Authorization`

**Steps**:
1. Request sem `Authorization: Bearer ${token}`
2. Recebe 401 Unauthorized ou 403 Forbidden
3. Response indica falta de autenticação

**Validações**:
- ✅ `'status is 401 or 403'` → Status code = 401 ou 403
- ✅ `'missing auth message'` → Response indica "unauthorized" ou "missing token"

**Ação de Recuperação**: 
- Realizar UC003 (Login) para obter token válido
- Retry request com token

---

### Cenário de Erro 2: Token Inválido ou Expirado
**Condição**: GET /carts/user/{userId} com token inválido/expirado

**Steps**:
1. Request com `Authorization: Bearer invalid_or_expired_token`
2. Recebe 401 Unauthorized
3. Response contém erro de autenticação

**Validações**:
- ✅ `'status is 401'` → Status code = 401
- ✅ `'token error message'` → Response indica "token invalid" ou "token expired"

**Ação de Recuperação**: 
- Usar UC012 (Token Refresh) para renovar token
- Ou realizar novo login (UC003)

---

### Cenário de Erro 3: Carrinho Não Encontrado (ID Inválido)
**Condição**: GET /carts/{id} com ID inexistente

**Steps**:
1. GET /carts/9999 (ID que não existe)
2. Recebe 404 Not Found
3. Response indica carrinho não encontrado

**Validações**:
- ✅ `'status is 404'` → Status code = 404
- ✅ `'not found message'` → Response contém mensagem de erro

---

### Edge Case 1: Usuário Sem Carrinhos (Empty Carts)
**Condição**: GET /carts/user/{userId} para usuário sem carrinhos ativos

**Steps**:
1. Request para userId que não tem carrinhos
2. Recebe 200 OK com array vazio ou 404 Not Found (comportamento DummyJSON)
3. Response: `{"carts": [], "total": 0, "skip": 0, "limit": 0}`

**Validações**:
- ✅ `'status is 200 or 404'` → Status code = 200 ou 404
- ✅ `'carts array empty or not found'` → `carts` array vazio ou mensagem de erro

**Observação**: Carrinho vazio **não é erro** - é caso de uso válido (novo usuário)

---

### Edge Case 2: Carrinho com Desconto Zero
**Condição**: Carrinho onde `discountPercentage` = 0 para todos produtos

**Steps**:
1. GET /carts/{id} onde produtos não têm desconto
2. Validar que `total` === `discountedTotal`

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'totals match when no discount'` → `total` === `discountedTotal` (ou discountedTotal levemente menor por arredondamento)

---

### Edge Case 3: Listar Todos os Carrinhos (Admin View)
**Condição**: GET /carts (sem filtro de userId) - visão administrativa

**Steps**:
1. GET /carts?limit=30&skip=0
2. Recebe lista paginada de todos os carrinhos do sistema
3. Útil para admin/moderador visualizar overview

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has carts array'` → Response contains `carts` array
- ✅ `'pagination works'` → Response has `total`, `skip`, `limit` (30 itens padrão)
- ✅ `'multiple users'` → Carrinhos de diferentes `userId` presentes

**Observação**: Este endpoint pode **não requerer autenticação** no DummyJSON (API pública)

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/carts/cart-operations-read.test.ts`
- **Libs Criadas**: 
  - `libs/data/cart-loader.ts` (carrega cart IDs e userIds via SharedArray)
  - `libs/http/auth.ts` (reuso de UC003 - funções de autenticação)

### Configuração de Cenário
```javascript
export const options = {
  scenarios: {
    cart_view: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 3,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { feature: 'carts', kind: 'view', uc: 'UC005' },
    },
  },
  thresholds: {
    'http_req_duration{feature:carts}': ['p(95)<400', 'p(99)<600'],
    'http_req_failed{feature:carts}': ['rate<0.01'],
    'checks{uc:UC005}': ['rate>0.99'],
    'cart_view_duration_ms': ['p(95)<400'],
    'cart_view_success': ['count>0'],
  },
};
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'carts',   // Domain area
  kind: 'view',       // Operation type (view/read)
  uc: 'UC005'         // Use case ID
}
```

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida, 30s, 1 RPS)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/carts/cart-operations-read.test.ts

# Baseline (5 min, 3 RPS - 30% do tráfego cart view)
K6_RPS=3 K6_DURATION=5m k6 run tests/api/carts/cart-operations-read.test.ts

# Stress (10 min, 10 RPS - pico de visualização de carrinho)
K6_RPS=10 K6_DURATION=10m k6 run tests/api/carts/cart-operations-read.test.ts

# Com variáveis de ambiente customizadas
BASE_URL=https://dummyjson.com K6_RPS=5 k6 run tests/api/carts/cart-operations-read.test.ts
```

### CI/CD
```bash
# GitHub Actions smoke test (PR)
.github/workflows/k6-pr-smoke.yml

# GitHub Actions baseline (main branch)
.github/workflows/k6-main-baseline.yml
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const cartViewDuration = new Trend('cart_view_duration_ms');
const cartDetailsDuration = new Trend('cart_details_duration_ms');

// No VU code:
// Step 1: Visualizar carrinhos do usuário
const userCartsRes = http.get(`${BASE_URL}/carts/user/${userId}`, { headers });
cartViewDuration.add(userCartsRes.timings.duration);

// Step 2: Obter detalhes de carrinho específico
const cartDetailsRes = http.get(`${BASE_URL}/carts/${cartId}`, { headers });
cartDetailsDuration.add(cartDetailsRes.timings.duration);
```

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const cartViewSuccess = new Counter('cart_view_success');
const cartViewErrors = new Counter('cart_view_errors');
const emptyCartsFound = new Counter('cart_empty_carts');
const cartItemsTotal = new Counter('cart_items_total');

// No VU code:
if (userCartsRes.status === 200) {
  cartViewSuccess.add(1);
  
  const carts = userCartsRes.json('carts');
  if (carts.length === 0) {
    emptyCartsFound.add(1);
  } else {
    // Contar total de produtos em todos os carrinhos do usuário
    const totalItems = carts.reduce((sum, cart) => sum + cart.totalQuantity, 0);
    cartItemsTotal.add(totalItems);
  }
} else {
  cartViewErrors.add(1);
}
```

### Dashboards
- **Grafana**: Dashboard "Cart Operations" com métricas de view/add/update
- **k6 Cloud**: Projeto "DummyJSON Carts" (se disponível)

---

## ⚠️ Observações Importantes

### Limitações da API
- **Autenticação Opcional**: DummyJSON pode **não** exigir token para GET /carts ou GET /carts/user/{userId} (API pública para testes). No entanto, **simular autenticação** é importante para refletir cenário real de e-commerce.
- **Dados Estáticos**: Carrinhos são pré-populados (não refletem POST /carts/add real, que é fake). Use `fulldummyjsondata/carts.json` como referência.
- **Sem Persistência**: Qualquer POST/PUT/DELETE em UC006 (Cart Write) **não afetará** os dados retornados por GET endpoints deste UC.
- **Paginação Limitada**: GET /carts retorna máximo 30 itens por padrão (DummyJSON tem ~50 carrinhos total).

### Particularidades do Teste
- **UserIds Válidos**: Usar apenas userIds presentes em `users-with-carts.json` (gerado do dump) para garantir carrinhos existentes.
- **SharedArray**: Carregar cart IDs e userIds via `SharedArray` para evitar duplicação de dados em memória (múltiplos VUs).
- **Token de Teste**: Para smoke tests, pode usar token fixo gerado previamente (válido por 60 min) ou fazer login no setup.
- **Empty Carts**: Testar cenário de usuário sem carrinhos (edge case válido) - não deve falhar teste.

### Considerações de Desempenho
- **Think Time**: 3-7s entre visualizações reflete análise realista de itens do carrinho (Persona 2)
- **RPS**: 3 RPS baseline reflete parte dos 30% do tráfego de Comprador Autenticado (nem todos visualizam carrinho toda vez)
- **VUs**: `preAllocatedVUs: 5` suficiente para 3 RPS, `maxVUs: 20` para picos de 10 RPS
- **Caching**: DummyJSON pode cachear respostas GET - latência pode ser menor que baseline em testes repetidos

---

## 🔗 Dependências

### UCs Bloqueadores (Dependências)
- **UC003 (User Login & Profile)** ✅ - Requer token JWT para autenticação
  - Usa `libs/http/auth.ts` (funções `login()`, `getAuthHeaders()`)
  - Requer `users-credentials.csv` para obter userId válido

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC005 depende de UC003 (Auth)

### UCs Dependentes (Fornece Para)
- **UC006** - Cart Operations (Write): Usa cart IDs deste UC para update/delete
- **UC010** - User Journey (Authenticated): Integra visualização de carrinho no fluxo de jornada
- **UC011** - Mixed Workload: Usa cart view para 30% do tráfego (Comprador)

**Total**: 3 UCs dependentes diretos

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC005 fornece para UC006, UC010, UC011

### Libs Necessárias
- **k6 built-ins**: `http`, `check`, `sleep`
- **k6 metrics**: `Trend`, `Counter` (para métricas customizadas)
- **k6 data**: `SharedArray` (para carregar cart IDs e userIds)
- **libs/http/auth.ts** (UC003): Funções `login()`, `getAuthHeaders()`, `isValidJWT()`
- **libs/data/cart-loader.ts** (criada neste UC): Funções `getRandomCart()`, `getUserWithCarts()`

### Dados Requeridos
- **UC003**: `users-credentials.csv` (para autenticação e obter userId)
- **Dados Próprios**: `cart-ids.json`, `users-with-carts.json` (gerados do dump de carts)

---

## 📂 Libs/Helpers Criados

### `libs/data/cart-loader.ts`
**Descrição**: Carrega cart IDs e mapeamentos userId → cartIds via SharedArray (memory-efficient)

**Funções Exportadas**:
```typescript
import { SharedArray } from 'k6/data';

export interface CartSummary {
  id: number;
  userId: number;
  totalProducts: number;
  totalQuantity: number;
}

export interface UserWithCarts {
  userId: number;
  cartIds: number[];
  totalCarts: number;
  username?: string;
}

/**
 * SharedArray de IDs de carrinhos
 */
export const carts = new SharedArray('carts', function() {
  const data = open('../../../data/test-data/cart-ids.json');
  return JSON.parse(data) as CartSummary[];
});

/**
 * SharedArray de usuários com carrinhos
 */
export const usersWithCarts = new SharedArray('usersWithCarts', function() {
  const data = open('../../../data/test-data/users-with-carts.json');
  return JSON.parse(data) as UserWithCarts[];
});

/**
 * Retorna um carrinho aleatório
 * @returns CartSummary aleatório
 */
export function getRandomCart(): CartSummary {
  return carts[Math.floor(Math.random() * carts.length)];
}

/**
 * Retorna um usuário aleatório que possui carrinhos
 * @returns UserWithCarts aleatório
 */
export function getUserWithCarts(): UserWithCarts {
  return usersWithCarts[Math.floor(Math.random() * usersWithCarts.length)];
}

/**
 * Retorna carrinho por ID
 * @param id - ID do carrinho
 * @returns CartSummary ou undefined
 */
export function getCartById(id: number): CartSummary | undefined {
  return carts.find(c => c.id === id);
}

/**
 * Retorna todos os cartIds de um userId
 * @param userId - ID do usuário
 * @returns Array de cart IDs ou []
 */
export function getCartIdsByUserId(userId: number): number[] {
  const user = usersWithCarts.find(u => u.userId === userId);
  return user ? user.cartIds : [];
}
```

**Uso**:
```typescript
import { getUserWithCarts, getRandomCart } from '../../../libs/data/cart-loader';
import { login, getAuthHeaders } from '../../../libs/http/auth';

// No VU code:
const userWithCart = getUserWithCarts();
const loginData = login('username', 'password'); // obter de users-credentials.csv
const headers = getAuthHeaders(loginData.accessToken);

// Visualizar carrinhos do usuário
const res = http.get(
  `${BASE_URL}/carts/user/${userWithCart.userId}`, 
  { headers, tags: { name: 'view_user_carts' } }
);
```

**Dependências**: Nenhuma (standalone)

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-03 | GitHub Copilot | Criação inicial do UC005 (Sprint 3) |
| 2025-10-06 | GitHub Copilot | Correções pós-análise de conformidade: (1) Badge prioridade P1→P0, (2) SLOs refinados (P95: 500→400ms, P99: 700→600ms) alinhados com baseline, (3) Think time Step 2 padronizado (2-5s→3-7s) para consistência com Persona 2 |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Comprador Autenticado, 30% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (GET /carts, GET /carts/{id}, GET /carts/user/{userId})
- [x] SLOs estão definidos e justificados (P95 < 500ms baseado em baseline Fase 1)
- [x] Fluxo principal está detalhado passo a passo (Visualizar carrinhos do usuário → Detalhes do carrinho)
- [x] Validações (checks) estão especificadas (status, carts array, totals, userId)
- [x] Dados de teste estão identificados (cart-ids.json, users-with-carts.json, users-credentials.csv)
- [x] Headers obrigatórios estão documentados (Content-Type, Authorization Bearer token)
- [x] Think times estão especificados (3-7s, 2-5s conforme Persona 2)
- [x] Edge cases e cenários de erro estão mapeados (token inválido, carrinho não encontrado, carrinho vazio)
- [x] Dependências de outros UCs estão listadas (UC003 bloqueador, UC006/UC010/UC011 dependentes)
- [x] Limitações da API (autenticação opcional, dados estáticos, sem persistência) estão documentadas
- [x] Arquivo nomeado corretamente: `UC005-cart-operations-read.md`
- [x] Libs/helpers criados estão documentados (`cart-loader.ts` com 6 funções exportadas)
- [x] Comandos de teste estão corretos e testados (smoke, baseline, stress)
- [x] Tags obrigatórias estão especificadas (feature: carts, kind: view, uc: UC005)
- [x] Métricas customizadas estão documentadas (cart_view_duration_ms, cart_view_success, cart_items_total)
- [x] Referências a Fase 1-3 estão explícitas (fonte em todas as seções críticas)

---

## 📚 Referências

- [DummyJSON Carts API](https://dummyjson.com/docs/carts)
- [k6 HTTP Module](https://grafana.com/docs/k6/latest/javascript-api/k6-http/)
- [k6 Checks](https://grafana.com/docs/k6/latest/using-k6/checks/)
- [k6 SharedArray](https://grafana.com/docs/k6/latest/javascript-api/k6-data/sharedarray/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md` (Carts Operations - P95 270-300ms)
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md` (Persona 2: Comprador Autenticado)
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md` (UC005 - P1, Complexidade 2, Sprint 3)
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md` (UC005 - Tier 1, depende de UC003)
- Template de UC: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`
- Checklist de Qualidade: `docs/casos_de_uso/templates/checklist-qualidade.md`
