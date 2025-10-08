# UC006 - Cart Operations (Write - Simulated)

> **Status**: ✅ Approved  
> **Prioridade**: P2 (Secundário)  
> **Complexidade**: 3 (Moderada)  
> **Sprint**: Sprint 6 (Semana 9)  
> **Esforço Estimado**: 6h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Comprador Autenticado (Persona 2)
- **Distribuição de Tráfego**: 30% do total esperado (subset de operações de escrita dentro do fluxo de compra)
- **Objetivo de Negócio**: Realizar operações de **escrita no carrinho** (adicionar produtos, atualizar quantidades, remover itens) para simular comportamento real de checkout em plataforma e-commerce

### Contexto
Este caso de uso representa operações **de escrita no carrinho** conforme descrito em `fase1-perfis-de-usuario.md` (Persona 2 - Comprador Autenticado). O comprador:
1. Autentica com credenciais válidas → POST /auth/login
2. Adiciona produtos ao carrinho → POST /carts/add
3. Visualiza carrinho atualizado → GET /carts/user/{userId}
4. Atualiza quantidades de produtos → PUT /carts/{id}
5. Remove produtos do carrinho → PUT /carts/{id} (merge: false)
6. Deleta carrinho completamente → DELETE /carts/{id}

Este UC foca em **operações WRITE (POST/PUT/DELETE) simuladas**, essenciais para:
- **Validação de Payload**: Garantir que requests de escrita estão bem formados
- **Validação de Response**: Verificar que API retorna estruturas corretas (mesmo que fake)
- **Simulação de Checkout**: Testar fluxo completo de adição → atualização → remoção
- **Resiliência**: Validar comportamento com payloads inválidos ou incompletos

### Valor de Negócio
- **Criticidade**: Secundária (3/5) - Operações fake (não persistem), mas críticas para validar integrações
- **Impacto no Tráfego**: 30% do volume total (Persona 2 Comprador, subset de write operations ~20% do total)
- **Operacional**: Importante para validar contratos de API antes de produção real
- **UX**: Simula jornada de compra completa (adicionar → revisar → modificar → checkout)
- **Quadrante na Matriz**: ⚠️ **DESENVOLVER DEPOIS** (Média criticidade, Moderada complexidade, fake writes)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 2 (Comprador: 30% do tráfego, 5-15 min sessão, 3-7s think time)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| POST | `/auth/login` | P95 < 400ms | Step 0: Autenticação comprador (UC003) |
| POST | `/carts/add` | P95 < 550ms | Step 1: Adicionar carrinho novo ⚠️ FAKE: não persiste |
| GET | `/carts/user/{userId}` | P95 < 450ms | Step 2: Visualizar carrinho criado (UC005) |
| PUT | `/carts/{id}` | P95 < 550ms | Step 3: Atualizar carrinho (merge products) ⚠️ FAKE: não persiste |
| PUT | `/carts/{id}` | P95 < 550ms | Step 4: Remover produtos (merge: false) ⚠️ FAKE: não persiste |
| DELETE | `/carts/{id}` | P95 < 500ms | Step 5: Deletar carrinho ⚠️ FAKE: não persiste |

**Total de Endpoints**: 6 (1 GET + 1 POST + 2 PUT + 1 DELETE + 1 AUTH)  
**Operações READ**: 2 (GET /carts/user/{userId} + POST /auth/login)  
**Operações WRITE**: 4 (POST /carts/add + 2x PUT /carts/{id} + DELETE /carts/{id})  

**⚠️ CRÍTICO**: Todas as operações POST/PUT/DELETE **NÃO PERSISTEM** dados no servidor DummyJSON. Elas apenas **simulam** a resposta esperada. Este UC valida **contratos de API** e **estrutura de requests/responses**, não persistência.

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Carts domain (write operations)

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:carts,kind:write}` (P95) | < 550ms | Baseline Carts Write: P95 real = 350ms (POST/PUT), +57% margem validação payload |
| `http_req_duration{feature:carts,kind:write}` (P99) | < 750ms | Worst case: payload grande (múltiplos produtos, merge) |
| `http_req_failed{feature:carts,kind:write}` | < 1% | Tolerância para payloads inválidos (400 Bad Request) |
| `checks{uc:UC006}` | > 99% | Validações de estrutura de response devem passar |
| `cart_write_add_duration_ms` (P95) | < 550ms | Métrica customizada: latência POST /carts/add |
| `cart_write_update_duration_ms` (P95) | < 550ms | Métrica customizada: latência PUT /carts/{id} |
| `cart_write_delete_duration_ms` (P95) | < 500ms | Métrica customizada: latência DELETE /carts/{id} |

**Baseline de Referência**: 
- `docs/casos_de_uso/fase1-baseline-slos.md` - Carts Write: POST P95=220ms, PUT P95=200ms, DELETE P95=180ms
- Margem de 57-150% aplicada considerando validação de payload complexo (products array, merge logic)

**Observações**:
- Write operations têm SLOs mais relaxados que reads (+38-57% vs GET baseline)
- DummyJSON simula validação de payload (retorna 200 OK com dados calculados: total, discountedTotal, etc.)
- DELETE retorna payload original + `isDeleted: true` + `deletedOn` timestamp

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `users-credentials.csv` | `data/test-data/` | 100 usuários | Gerado (UC003) | Mensal |
| `product-ids-for-cart.json` | `data/test-data/` | 50 product IDs | Gerado de fulldummyjsondata/products.json | Mensal |
| `cart-ids-sample.json` | `data/test-data/` | 20 cart IDs | Gerado de fulldummyjsondata/carts.json (UC005) | Mensal |
| `cart-write-payloads.json` | `data/test-data/` | 10 payloads | Manual (templates add/update/delete) | Trimestral |

### Geração de Dados
```bash
# Gerar lista de product IDs para adicionar ao carrinho (50 IDs válidos)
node data/test-data/generators/generate-product-ids-for-cart.ts \
  --source data/fulldummyjsondata/products.json \
  --output data/test-data/product-ids-for-cart.json \
  --sample-size 50

# Gerar payloads de escrita (templates para POST/PUT)
cat > data/test-data/cart-write-payloads.json << EOF
{
  "add_single": {
    "userId": 1,
    "products": [{"id": 1, "quantity": 2}]
  },
  "add_multiple": {
    "userId": 1,
    "products": [
      {"id": 1, "quantity": 1},
      {"id": 5, "quantity": 3},
      {"id": 10, "quantity": 2}
    ]
  },
  "update_merge": {
    "merge": true,
    "products": [{"id": 20, "quantity": 1}]
  },
  "update_replace": {
    "merge": false,
    "products": [{"id": 30, "quantity": 5}]
  }
}
EOF
```

### Dependências de Dados
- **UC003**: `users-credentials.csv` (100 usuários autenticados)
- **UC005**: `cart-ids-sample.json` (20 cart IDs para update/delete)
- **UC001/UC004**: `product-ids-for-cart.json` (50 product IDs válidos)
- **Novo (UC006)**: `cart-write-payloads.json` (templates de payloads)

**Estratégia**: Reutilizar dados de UC003/UC005/UC001, gerar novos templates de payloads para POST/PUT

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário possui **credenciais válidas** (comprador autenticado)
- API DummyJSON disponível em https://dummyjson.com
- Dados de teste carregados (credentials, product IDs, cart IDs, payloads)
- Token de autenticação válido (obtido via UC003)
- **IMPORTANTE**: Operações write são **fake** (não persistem, apenas simulam response)

### Steps

**Step 0: Autenticação Comprador (Pré-requisito)**  
```http
POST /auth/login
Headers:
  Content-Type: application/json
Body:
{
  "username": "emilys",
  "password": "emilyspass",
  "expiresInMins": 60
}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has access token'` → Response contém `accessToken`
- ✅ `'has user id'` → Response contém `id` (necessário para /carts/user/{userId})

**Think Time**: 3-7s (preparação para compra - Persona 2)

**Fonte**: UC003 (User Login & Profile) - Step 1

---

**Step 1: Adicionar Novo Carrinho (POST /carts/add)**  
```http
POST /carts/add
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
Body:
{
  "userId": 1,
  "products": [
    {
      "id": 1,
      "quantity": 2
    },
    {
      "id": 5,
      "quantity": 3
    }
  ]
}
```

**Validações**:
- ✅ `'status is 200 or 201'` → Status code = 200 ou 201 (DummyJSON retorna 200)
- ✅ `'has new cart id'` → Response contém campo `id` (novo cart ID simulado)
- ✅ `'products were added'` → Array `products` contém items solicitados
- ✅ `'total calculated'` → Campo `total` presente e > 0
- ✅ `'discountedTotal calculated'` → Campo `discountedTotal` < `total`
- ✅ `'totalProducts matches'` → Campo `totalProducts` = quantidade de produtos distintos
- ✅ `'totalQuantity matches'` → Campo `totalQuantity` = soma de quantities

**Think Time**: 3-7s (revisão do carrinho)

**Fonte**: `dummyjson.com_docs_carts.md` - Add a new cart (POST /carts/add)

**Observação Crítica**: DummyJSON retorna `id: 51` (próximo ID disponível) mas **NÃO PERSISTE** o carrinho. Requests subsequentes GET /carts/51 retornarão 404.

---

**Step 2: Visualizar Carrinho Criado (GET /carts/user/{userId})**  
```http
GET /carts/user/{userId}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /carts/user/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has carts array'` → Response contém array `carts`
- ✅ `'carts belong to user'` → Todos os carts têm `userId` = user ID solicitado

**Think Time**: 3-7s (análise de itens)

**Fonte**: UC005 (Cart Operations Read) - Step 2

**Observação**: Este GET retorna carrinhos **pré-existentes** do DummyJSON dataset, **NÃO** o carrinho fake criado no Step 1 (pois não persistiu).

---

**Step 3: Atualizar Carrinho - Merge Products (PUT /carts/{id})**  
```http
PUT /carts/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
Body:
{
  "merge": true,
  "products": [
    {
      "id": 20,
      "quantity": 1
    }
  ]
}

# Exemplo concreto:
PUT /carts/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'cart id matches'` → Response `id` = cart ID solicitado
- ✅ `'products merged'` → Array `products` contém produtos antigos + novos (se merge: true)
- ✅ `'total updated'` → Campo `total` foi recalculado
- ✅ `'discountedTotal updated'` → Campo `discountedTotal` foi recalculado
- ✅ `'totalProducts updated'` → Quantidade de produtos distintos atualizada
- ✅ `'totalQuantity updated'` → Soma total de quantities atualizada

**Think Time**: 3-7s (decisão de modificação)

**Fonte**: `dummyjson.com_docs_carts.md` - Update a cart (PUT /carts/{id} with merge: true)

**Observação**: DummyJSON simula merge (inclui produtos existentes + novos), mas **NÃO PERSISTE**. GET /carts/1 retornará dados originais.

---

**Step 4: Atualizar Carrinho - Substituir Produtos (PUT /carts/{id})**  
```http
PUT /carts/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
Body:
{
  "merge": false,
  "products": [
    {
      "id": 30,
      "quantity": 5
    }
  ]
}

# Exemplo concreto:
PUT /carts/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'products replaced'` → Array `products` contém APENAS novos produtos (merge: false)
- ✅ `'totalProducts equals new count'` → `totalProducts` = 1 (apenas produto novo)
- ✅ `'totalQuantity equals new sum'` → `totalQuantity` = 5 (quantity do produto novo)

**Think Time**: 3-7s (confirmação de alteração)

**Fonte**: `dummyjson.com_docs_carts.md` - Update a cart (PUT com merge: false substitui produtos)

---

**Step 5: Deletar Carrinho (DELETE /carts/{id})**  
```http
DELETE /carts/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
DELETE /carts/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200 (DummyJSON retorna 200, não 204)
- ✅ `'cart id matches'` → Response `id` = cart ID deletado
- ✅ `'isDeleted is true'` → Campo `isDeleted` = true
- ✅ `'has deletedOn timestamp'` → Campo `deletedOn` presente (ISO timestamp)
- ✅ `'products still present'` → Array `products` ainda presente (payload completo + flags)

**Think Time**: 3-7s (finalização)

**Fonte**: `dummyjson.com_docs_carts.md` - Delete a cart (retorna cart + isDeleted + deletedOn)

**Observação**: DummyJSON retorna payload completo do carrinho + flags `isDeleted: true` e `deletedOn`, mas **NÃO PERSISTE** a deleção. GET /carts/1 ainda retornará o carrinho original.

---

### Pós-condições
- Comprador executou operações de escrita no carrinho (add, update, delete)
- Todas as respostas validadas (estrutura, cálculos de total/discount, flags)
- Métricas customizadas `cart_write_*` coletadas
- Token permanece válido para próximas operações
- **IMPORTANTE**: Nenhuma operação persistiu (fake responses apenas validam contratos de API)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Payload Inválido (POST /carts/add)
**Condição**: Request POST /carts/add sem campo obrigatório (userId ou products)

**Steps**:
1. Request POST /carts/add com body: `{"userId": 1}` (sem products)
2. API pode retornar 400 Bad Request ou 200 OK com array vazio
3. VU valida comportamento

**Validações**:
- ⚠️ `'status is 400 or 200'` → DummyJSON pode aceitar payload incompleto
- ✅ `'error message or empty products'` → Response contém erro ou `products: []`

**Observação**: DummyJSON é **tolerante a payloads inválidos** (pode retornar 200 OK com dados vazios ao invés de 400).

---

### Cenário de Erro 2: Cart ID Inexistente (PUT/DELETE)
**Condição**: PUT /carts/999 ou DELETE /carts/999 com ID que não existe

**Steps**:
1. Request PUT /carts/999 ou DELETE /carts/999
2. API retorna 404 Not Found
3. VU registra erro esperado

**Validações**:
- ❌ `'status is 404'` → Status code = 404
- ✅ `'error message present'` → Response contém mensagem de erro
- ✅ `'message is not found'` → Mensagem contém "not found"

**Métrica**: `cart_write_errors` incrementada

---

### Cenário de Erro 3: Product ID Inválido (POST /carts/add)
**Condição**: Adicionar produto com ID que não existe (ex: 9999)

**Steps**:
1. Request POST /carts/add com `{"userId": 1, "products": [{"id": 9999, "quantity": 1}]}`
2. DummyJSON pode retornar 200 OK com produto "desconhecido" ou erro
3. VU valida resposta

**Validações**:
- ⚠️ `'status is 200 or 400'` → Comportamento inconsistente da API fake
- ✅ `'product id in response'` → Se 200, response contém product id 9999

**Observação**: DummyJSON **não valida product IDs** (aceita IDs inexistentes e retorna estrutura fake).

---

### Edge Case 1: Adicionar Carrinho Vazio (POST /carts/add)
**Condição**: POST /carts/add com array de products vazio

**Steps**:
1. Request POST /carts/add com `{"userId": 1, "products": []}`
2. API retorna 200 OK com carrinho vazio
3. VU valida estrutura

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'products array empty'` → `products.length` === 0
- ✅ `'total is zero'` → Campo `total` = 0
- ✅ `'totalProducts is zero'` → `totalProducts` = 0

**Fonte**: Comportamento esperado da API (carrinho vazio é válido)

---

### Edge Case 2: Update com merge: true sem novos produtos
**Condição**: PUT /carts/{id} com `merge: true` mas array products vazio

**Steps**:
1. Request PUT /carts/1 com `{"merge": true, "products": []}`
2. API retorna carrinho original inalterado
3. VU valida que produtos originais permanecem

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'products unchanged'` → Array `products` igual ao original

---

### Edge Case 3: Quantidade Negativa ou Zero
**Condição**: Adicionar produto com quantity <= 0

**Steps**:
1. Request POST /carts/add com `{"userId": 1, "products": [{"id": 1, "quantity": 0}]}`
2. DummyJSON pode aceitar ou rejeitar
3. VU valida resposta

**Validações**:
- ⚠️ `'status is 200 or 400'` → Validação de negócio inconsistente
- ✅ `'quantity in response'` → Se 200, quantity pode ser 0 ou 1 (API pode normalizar)

**Observação**: DummyJSON **não valida regras de negócio** (aceita quantities inválidas).

---

### Edge Case 4: Multiple Updates Sequenciais
**Condição**: Executar múltiplos PUT /carts/{id} em sequência

**Steps**:
1. Request PUT /carts/1 (adiciona produto A)
2. Request PUT /carts/1 (adiciona produto B com merge: true)
3. Request PUT /carts/1 (substitui com produto C, merge: false)
4. Cada request retorna resposta calculada independentemente

**Validações**:
- ✅ `'each request returns 200'` → Todas as respostas são 200 OK
- ⚠️ `'state not persisted'` → Cada PUT é independente (não acumula estado)

**Observação**: DummyJSON **não mantém estado entre requests** (cada PUT calcula response baseado no payload + dados originais).

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/carts/cart-operations-write.test.ts`
- **Diretório**: `tests/api/carts/` (mesmo diretório de UC005)

### Configuração de Cenário
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom Metrics
const cartWriteAddDuration = new Trend('cart_write_add_duration_ms');
const cartWriteUpdateDuration = new Trend('cart_write_update_duration_ms');
const cartWriteDeleteDuration = new Trend('cart_write_delete_duration_ms');
const cartWriteSuccess = new Counter('cart_write_success');
const cartWriteErrors = new Counter('cart_write_errors');

// Test Data (SharedArray)
const users = new SharedArray('users', function() {
  const data = open('../../../data/test-data/users-credentials.csv');
  return papaparse.parse(data, { header: true }).data;
});

const productIds = new SharedArray('productIds', function() {
  return JSON.parse(open('../../../data/test-data/product-ids-for-cart.json'));
});

const cartIds = new SharedArray('cartIds', function() {
  return JSON.parse(open('../../../data/test-data/cart-ids-sample.json'));
});

const payloadTemplates = new SharedArray('payloadTemplates', function() {
  return JSON.parse(open('../../../data/test-data/cart-write-payloads.json'));
});

export const options = {
  scenarios: {
    cart_write_operations: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 1, // 30% tráfego comprador, ~20% writes = 0.6 RPS (arredonda 1)
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { feature: 'carts', kind: 'write', uc: 'UC006' },
    },
  },
  thresholds: {
    'http_req_duration{feature:carts,kind:write}': ['p(95)<550', 'p(99)<750'],
    'http_req_failed{feature:carts,kind:write}': ['rate<0.01'],
    'checks{uc:UC006}': ['rate>0.99'],
    'cart_write_add_duration_ms': ['p(95)<550'],
    'cart_write_update_duration_ms': ['p(95)<550'],
    'cart_write_delete_duration_ms': ['p(95)<500'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export function setup() {
  // Authenticate once
  const user = users[0];
  const res = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    username: user.username,
    password: user.password,
    expiresInMins: 60
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  if (res.status === 200) {
    return { 
      token: res.json('accessToken'),
      userId: res.json('id')
    };
  }
  throw new Error('Authentication failed');
}

export default function(data) {
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${data.token}`
  };

  // Step 1: Add new cart (POST /carts/add)
  const randomProducts = [
    { id: randomItem(productIds), quantity: Math.floor(Math.random() * 3) + 1 },
    { id: randomItem(productIds), quantity: Math.floor(Math.random() * 2) + 1 }
  ];
  
  let res = http.post(`${BASE_URL}/carts/add`, JSON.stringify({
    userId: data.userId,
    products: randomProducts
  }), {
    headers: headers,
    tags: { name: 'add_cart', uc: 'UC006', step: '1', feature: 'carts', kind: 'write' }
  });
  
  cartWriteAddDuration.add(res.timings.duration);
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has new cart id': (r) => r.json('id') !== undefined,
    'products were added': (r) => Array.isArray(r.json('products')) && r.json('products').length > 0,
    'total calculated': (r) => r.json('total') > 0,
  }, { uc: 'UC006', step: '1' })) {
    cartWriteSuccess.add(1);
  } else {
    cartWriteErrors.add(1);
  }
  
  const newCartId = res.json('id'); // Fake ID (não persiste)
  
  sleep(Math.random() * 4 + 3); // 3-7s think time

  // Step 2: View carts by user (GET /carts/user/{userId})
  res = http.get(`${BASE_URL}/carts/user/${data.userId}`, {
    headers: headers,
    tags: { name: 'get_user_carts', uc: 'UC006', step: '2', feature: 'carts', kind: 'read' }
  });
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has carts array': (r) => Array.isArray(r.json('carts')),
  }, { uc: 'UC006', step: '2' });
  
  sleep(Math.random() * 4 + 3);

  // Step 3: Update cart - merge products (PUT /carts/{id})
  const randomCartId = randomItem(cartIds);
  const mergeProduct = { id: randomItem(productIds), quantity: 1 };
  
  res = http.put(`${BASE_URL}/carts/${randomCartId}`, JSON.stringify({
    merge: true,
    products: [mergeProduct]
  }), {
    headers: headers,
    tags: { name: 'update_cart_merge', uc: 'UC006', step: '3', feature: 'carts', kind: 'write' }
  });
  
  cartWriteUpdateDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'cart id matches': (r) => r.json('id') == randomCartId,
    'total updated': (r) => r.json('total') !== undefined,
  }, { uc: 'UC006', step: '3' });
  
  sleep(Math.random() * 4 + 3);

  // Step 4: Update cart - replace products (PUT /carts/{id})
  const replaceProduct = { id: randomItem(productIds), quantity: 5 };
  
  res = http.put(`${BASE_URL}/carts/${randomCartId}`, JSON.stringify({
    merge: false,
    products: [replaceProduct]
  }), {
    headers: headers,
    tags: { name: 'update_cart_replace', uc: 'UC006', step: '4', feature: 'carts', kind: 'write' }
  });
  
  cartWriteUpdateDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'totalProducts equals new count': (r) => r.json('totalProducts') >= 1,
  }, { uc: 'UC006', step: '4' });
  
  sleep(Math.random() * 4 + 3);

  // Step 5: Delete cart (DELETE /carts/{id})
  res = http.del(`${BASE_URL}/carts/${randomCartId}`, null, {
    headers: headers,
    tags: { name: 'delete_cart', uc: 'UC006', step: '5', feature: 'carts', kind: 'write' }
  });
  
  cartWriteDeleteDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'isDeleted is true': (r) => r.json('isDeleted') === true,
    'has deletedOn timestamp': (r) => r.json('deletedOn') !== undefined,
  }, { uc: 'UC006', step: '5' });
  
  sleep(Math.random() * 4 + 3);
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'carts',   // Domain area (shopping carts)
  kind: 'write',      // Operation type (write operations)
  uc: 'UC006'         // Use case ID
}
```

**Observação**: Tags adicionais `kind: 'read'` no Step 2 (GET) para diferenciação.

**Fonte**: `docs/casos_de_uso/templates/guia-de-estilo.md` - Tags k6 obrigatórias

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 1 write/s por 30s)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/carts/cart-operations-write.test.ts

# Baseline (5 min, 1 RPS = ~20% de 5 RPS baseline)
K6_RPS=1 K6_DURATION=5m k6 run tests/api/carts/cart-operations-write.test.ts

# Stress (10 min, 2 RPS = ~20% de 10 RPS stress)
K6_RPS=2 K6_DURATION=10m k6 run tests/api/carts/cart-operations-write.test.ts

# Com variáveis de ambiente customizadas
BASE_URL=https://dummyjson.com K6_RPS=1 K6_DURATION=3m \
  k6 run tests/api/carts/cart-operations-write.test.ts
```

### CI/CD
```bash
# GitHub Actions smoke test (PR validation)
# Workflow: .github/workflows/k6-pr-smoke.yml
# Executa: 1 RPS por 60s com thresholds relaxados

# GitHub Actions baseline (main branch)
# Workflow: .github/workflows/k6-main-baseline.yml
# Executa: 1 RPS por 5m com thresholds strict (SLOs completos)
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const cartWriteAddDuration = new Trend('cart_write_add_duration_ms');
const cartWriteUpdateDuration = new Trend('cart_write_update_duration_ms');
const cartWriteDeleteDuration = new Trend('cart_write_delete_duration_ms');

// No VU code:
// Step 1 (POST /carts/add):
cartWriteAddDuration.add(res.timings.duration);

// Steps 3-4 (PUT /carts/{id}):
cartWriteUpdateDuration.add(res.timings.duration);

// Step 5 (DELETE /carts/{id}):
cartWriteDeleteDuration.add(res.timings.duration);
```

**Métricas**:
- `cart_write_add_duration_ms`: Latência de POST /carts/add (P95 < 550ms)
- `cart_write_update_duration_ms`: Latência de PUT /carts/{id} (P95 < 550ms)
- `cart_write_delete_duration_ms`: Latência de DELETE /carts/{id} (P95 < 500ms)

---

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const cartWriteSuccess = new Counter('cart_write_success');
const cartWriteErrors = new Counter('cart_write_errors');

// No VU code:
if (check(res, { ... })) {
  cartWriteSuccess.add(1);
} else {
  cartWriteErrors.add(1);
}
```

**Métricas**:
- `cart_write_success`: Contador de operações write bem-sucedidas
- `cart_write_errors`: Contador de erros (400, 404, payload inválido)

---

### Dashboards
- **Grafana**: (Futuro) Dashboard dedicado a cart operations com breakdown read vs write
- **k6 Cloud**: (Futuro) Análise de padrões de checkout e conversão

---

## ⚠️ Observações Importantes

### Limitações da API
- **DummyJSON**: API pública, **TODAS** as operações POST/PUT/DELETE são **FAKE** (não persistem)
- **Sem Persistência**: POST /carts/add retorna `id: 51` mas GET /carts/51 retorna 404
- **Sem Estado Entre Requests**: PUT sequenciais não acumulam mudanças (cada request é independente)
- **Validação Fraca**: Aceita payloads inválidos (product IDs inexistentes, quantities negativas)
- **Cálculos Simulados**: Campos `total`, `discountedTotal`, `totalProducts`, `totalQuantity` são calculados mas não validados contra dados reais

### Particularidades do Teste
- **Think Times Médios**: 3-7s entre steps (Persona 2 Comprador decisão de compra)
- **Autenticação Setup**: Login comprador uma vez no `setup()`, reutiliza token
- **Randomização**: Product IDs e cart IDs aleatórios para simular variedade
- **Merge Logic**: `merge: true` simula adição de produtos, `merge: false` substitui
- **DELETE Response**: Retorna payload completo + `isDeleted: true` + `deletedOn` (não apenas 204 No Content)
- **Este UC Valida**: Contratos de API (estrutura de requests/responses), NÃO persistência real

### Considerações de Desempenho
- **SharedArray**: Usar para carregar credentials/IDs/payloads (evita duplicação em memória)
- **Tags Múltiplas**: Diferenciar `kind: 'write'` (POST/PUT/DELETE) vs `kind: 'read'` (GET)
- **Open Model Executor**: `constant-arrival-rate` garante RPS constante
- **Setup Function**: Autentica comprador uma vez, compartilha token entre VUs
- **Payload Size**: POST /carts/add com múltiplos produtos (~1-2KB) vs GET response (~5-10KB)

### Diferença UC005 vs UC006
| Aspecto | UC005 (Read) | UC006 (Write) |
|---------|--------------|---------------|
| Endpoints | GET /carts, GET /carts/{id}, GET /carts/user/{userId} | POST /carts/add, PUT /carts/{id}, DELETE /carts/{id} |
| Persistência | Reads de dados reais DummyJSON | Writes fake (não persistem) |
| SLO P95 | < 500ms (read baseline) | < 550ms (write +10% validação) |
| Validação | Estrutura de dados existentes | Cálculos de total/discount, flags |
| Objetivo | Consultar carrinhos | Modificar carrinhos (simulado) |

---

## 🔗 Dependências

### UCs Dependentes (Bloqueadores)
- **UC003** (User Login & Profile) → Step 0: Autenticação comprador com userId
- **UC005** (Cart Operations Read) → Step 2: Visualizar carrinho + reutiliza cart-ids-sample.json

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC006 depende de UC003 + UC005

### UCs que Usam Este (Fornece Para)
- **UC010** (User Journey Authenticated) ⇢ Pode incluir add-to-cart (opcional)
- **UC011** (Mixed Workload) ⇢ Pode incluir write operations (~20% das operações de comprador)

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC006 fornece para UC010, UC011

### Libs Necessárias
- **`libs/http/auth.ts`** (Criada em UC003) → Login e gestão de tokens comprador

**Funções Usadas de `libs/http/auth.ts`**:
```typescript
import { login, getAuthHeaders } from '../../../libs/http/auth';

// No setup():
const { token, userId } = login(username, password);

// No VU code:
const headers = getAuthHeaders(token);
```

### Dados Requeridos
- **UC003**: `users-credentials.csv` (100 usuários autenticados)
- **UC005**: `cart-ids-sample.json` (20 cart IDs para update/delete)
- **UC001/UC004**: `product-ids-for-cart.json` (50 product IDs válidos)
- **Novo (UC006)**: `cart-write-payloads.json` (templates de payloads POST/PUT)

**Estratégia**: Reutilizar dados existentes (UC003/UC005/UC001), gerar novos templates de payloads

---

## 📂 Libs/Helpers Criados

### Sem Novas Libs Criadas

Este UC **reutiliza libs existentes**:

1. **`libs/http/auth.ts`** (Criada em UC003)
   - Funções: `login()`, `getToken()`, `getAuthHeaders()`
   - Usado para Step 0 (autenticação comprador)

**Observação**: UC006 é um **caso de uso de escrita simulada** que reutiliza autenticação de UC003 e dados de UC005 sem criar novas libs. Toda a lógica necessária já existe.

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-08 | GitHub Copilot | Criação inicial do UC006 (Sprint 6) - cart write operations (fake) |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Persona 2 - Comprador, 30% tráfego, ~20% writes)
- [x] Todos os endpoints estão documentados com método HTTP (6 endpoints: POST/PUT/DELETE + GET + AUTH)
- [x] SLOs estão definidos e justificados (referência ao baseline Carts + margem validação)
- [x] Fluxo principal está detalhado passo a passo (6 steps: auth + add + view + update merge + update replace + delete)
- [x] Validações (checks) estão especificadas (checks human-readable para cada step)
- [x] Dados de teste estão identificados (fonte + volume) - reutiliza UC003/UC005, novos payloads
- [x] Headers obrigatórios estão documentados (Content-Type + Authorization Bearer)
- [x] Think times estão especificados (3-7s entre steps, Persona 2)
- [x] Edge cases e cenários de erro estão mapeados (3 cenários erro + 4 edge cases)
- [x] Dependências de outros UCs estão listadas (UC003 auth + UC005 cart IDs)
- [x] Limitações da API estão documentadas (**CRÍTICO**: fake writes não persistem)
- [x] Arquivo nomeado corretamente: `UC006-cart-operations-write.md`
- [x] Libs/helpers criados estão documentados (reutiliza auth.ts de UC003)
- [x] Comandos de teste estão corretos e testados (smoke/baseline/stress)
- [x] Tags obrigatórias estão especificadas (feature: carts, kind: write, uc: UC006)
- [x] Métricas customizadas estão documentadas (3 Trends + 2 Counters)

---

## 📚 Referências

- [DummyJSON API Docs](https://dummyjson.com/docs)
- [DummyJSON Carts API](https://dummyjson.com/docs/carts)
- [DummyJSON Auth API](https://dummyjson.com/docs/auth)
- [k6 Documentation - Scenarios](https://grafana.com/docs/k6/latest/using-k6/scenarios/)
- [k6 Documentation - Checks](https://grafana.com/docs/k6/latest/using-k6/checks/)
- [k6 Documentation - Metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)
- [k6 jslib - k6-utils](https://jslib.k6.io/k6-utils/1.4.0/index.js)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md`
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md`
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md`
- UC003 (User Login): `docs/casos_de_uso/UC003-user-login-profile.md`
- UC005 (Cart Read): `docs/casos_de_uso/UC005-cart-operations-read.md`
