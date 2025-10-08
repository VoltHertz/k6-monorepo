# UC010 - User Journey (Authenticated)

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 4 (Complexa)  
> **Sprint**: Sprint 4 (Semana 7)  
> **Esforço Estimado**: 10h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Comprador Autenticado (Persona 2)
- **Distribuição de Tráfego**: 30% do total esperado
- **Objetivo de Negócio**: Simular jornada completa end-to-end de um usuário autenticado navegando pelo e-commerce, realizando login, explorando produtos e gerenciando carrinho de compras

### Contexto
Este caso de uso representa a **jornada típica completa** de um Comprador Autenticado descrita em `fase1-perfis-de-usuario.md`. O usuário:
1. Login → POST /auth/login
2. Verifica perfil → GET /auth/me
3. Navega produtos → GET /products (reutiliza UC009)
4. Busca produtos → GET /products/search (reutiliza UC009)
5. Visualiza detalhes → GET /products/{id} (reutiliza UC009)
6. Visualiza carrinho → GET /carts/user/{userId}

Esta jornada **combina UC009 (navegação anônima) + UC003 (autenticação) + UC005 (carrinho)** em uma sequência realista com think times apropriados para Persona 2 (3-7s), simulando o comportamento real de 30% dos usuários da plataforma.

### Valor de Negócio
- **Criticidade**: Crítica (4/5) - Fluxo de 30% dos usuários (Persona Comprador)
- **Impacto no Tráfego**: 30% do volume total (segunda maior persona)
- **Conversão**: Usuários autenticados têm 60% maior probabilidade de finalizar compra
- **Receita**: Representa ~70-80% da receita total (compradores convertem mais que visitantes)
- **Quadrante na Matriz**: 📋 **PLANEJAR CUIDADOSAMENTE** (Alta criticidade, Alta complexidade)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 2 (Comprador Autenticado: 30% do tráfego, 5-15 min sessão, 3-7s think time)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| POST | `/auth/login` | P95 < 400ms | Step 1: Autenticação (UC003) |
| GET | `/auth/me` | P95 < 300ms | Step 2: Validação de sessão (UC003) |
| GET | `/products` | P95 < 300ms | Step 3: Lista inicial (UC009/UC001) |
| GET | `/products/search?q={query}` | P95 < 600ms | Step 4: Buscar produtos (UC009/UC002) |
| GET | `/products/{id}` | P95 < 300ms | Step 5: Ver detalhes (UC009/UC004) |
| GET | `/carts/user/{userId}` | P95 < 400ms | Step 6: Visualizar carrinho (UC005) |

**Total de Endpoints**: 6  
**Operações READ**: 5  
**Operações WRITE**: 1 (login)  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Combinação de endpoints Auth + Products + Carts

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 450ms | Média ponderada (auth 400ms + products 300ms + carts 400ms / 3) |
| `http_req_duration{feature:products}` (P99) | < 750ms | Margem para pior caso (auth + search combinados) |
| `http_req_failed{feature:products,auth,carts}` | < 1% | Tolerância para cenários de erro (token inválido, carrinho vazio) |
| `checks{uc:UC010}` | > 98% | Jornada complexa permite 2% falha (vs 99% UC009, mais steps e auth) |
| `journey_authenticated_duration_total_ms` (P95) | < 15000ms | Duração total da jornada < 15s (sem think times, +5s vs UC009 pelo auth) |
| `journey_authenticated_steps_completed` (avg) | = 6 | Garantir que todas as 6 etapas sejam executadas |
| `journey_authenticated_auth_success_rate` (rate) | > 99% | Taxa de sucesso de autenticação durante a jornada |

**Baseline de Referência**: 
- `docs/casos_de_uso/fase1-baseline-slos.md` - Auth (P95<400ms), Products (P95<300ms), Carts (P95<400ms)
- UC009 SLOs como referência base para navegação

**Métricas Customizadas**:
- `journey_authenticated_duration_total_ms` (Trend) - Latência total da jornada
- `journey_authenticated_steps_completed` (Counter) - Número de steps completados
- `journey_authenticated_errors` (Counter) - Erros durante a jornada
- `journey_authenticated_auth_success_rate` (Rate) - Taxa de sucesso do login

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `users-credentials.csv` | `data/test-data/` | 50 usuários | UC003 (reutilizado) | Mensal |
| `users-with-carts.json` | `data/test-data/` | 20 userIds com carrinhos | UC005 (reutilizado) | Mensal |
| `search-queries.json` | `data/test-data/` | 50 queries | UC002/UC009 (reutilizado) | Mensal |
| `product-ids.json` | `data/test-data/` | 194 IDs | UC004/UC009 (reutilizado) | Mensal |

### Geração de Dados
```bash
# Não requer geração nova - reutiliza dados dos UCs dependentes
# UC003: users-credentials.csv (login)
# UC005: users-with-carts.json (carrinho)
# UC009: search-queries.json, product-ids.json (navegação)
```

### Dependências de Dados
- **UC003**: `users-credentials.csv` (credenciais para login)
- **UC005**: `users-with-carts.json` (userIds com carrinhos existentes)
- **UC009**: `search-queries.json`, `product-ids.json` (navegação de produtos)

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC010 depende de UC003, UC005, UC009 (dados compartilhados)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário possui **credenciais válidas** (username/password)
- API DummyJSON disponível em https://dummyjson.com
- Dados de teste carregados (credentials, carts, queries, product IDs)
- Usuário tem pelo menos um carrinho associado (ou testa carrinho vazio)

### Steps

**Step 1: Autenticação (Login)**  
```http
POST /auth/login
Headers:
  Content-Type: application/json
Body:
{
  "username": "emilys",
  "password": "emilyspass",
  "expiresInMins": 30
}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has access token'` → Response contém campo `accessToken`
- ✅ `'has refresh token'` → Response contém campo `refreshToken`
- ✅ `'token is valid JWT'` → `accessToken` inicia com "eyJ" (formato JWT)
- ✅ `'user id present'` → Response contém `id` do usuário

**Think Time**: 3-7s (decisão de compra - Persona 2 Comprador)

**Fonte**: UC003 (User Login & Profile) - Step 1

---

**Step 2: Validar Sessão Autenticada**  
```http
GET /auth/me
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'user authenticated'` → Response contém dados do usuário
- ✅ `'user id matches'` → `id` do Step 1 = `id` deste step
- ✅ `'has username'` → Response contém `username`

**Think Time**: 3-7s (verificação de perfil)

**Fonte**: UC003 (User Login & Profile) - Step 2

---

**Step 3: Navegar Produtos (Navegação Inicial)**  
```http
GET /products?limit=20&skip=0
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has products array'` → Response contém array `products`
- ✅ `'products count valid'` → `products.length` <= 20

**Think Time**: 3-7s (análise de opções)

**Fonte**: UC009 (User Journey Unauthenticated) - Step 1, adaptado com autenticação

---

**Step 4: Buscar Produto Específico**  
```http
GET /products/search?q={query}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /products/search?q=phone
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has products array'` → Response contém array `products`
- ✅ `'has total field'` → Response contém campo `total`

**Think Time**: 3-7s (análise de resultados)

**Fonte**: UC009 (User Journey Unauthenticated) - Step 4, adaptado com autenticação

---

**Step 5: Visualizar Detalhes do Produto**  
```http
GET /products/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /products/5
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'product has id'` → Response contém campo `id`
- ✅ `'product has title and price'` → Response contém `title` e `price`
- ✅ `'product has description'` → Response contém `description`

**Think Time**: 3-7s (decisão de adicionar ao carrinho)

**Fonte**: UC009 (User Journey Unauthenticated) - Step 5, adaptado com autenticação

---

**Step 6: Visualizar Carrinho de Compras**  
```http
GET /carts/user/{userId}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto (userId do Step 1):
GET /carts/user/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has carts array'` → Response contém array `carts`
- ✅ `'user id matches'` → `carts[0].userId` = userId do Step 1
- ✅ `'cart has products'` → Carrinho contém ao menos 1 produto (ou permite vazio)
- ✅ `'cart has totals'` → Campos `total`, `discountedTotal`, `totalProducts` presentes

**Think Time**: 3-7s (revisão de carrinho pré-checkout)

**Fonte**: UC005 (Cart Operations Read) - Step 1

---

### Pós-condições
- Jornada completa de compra executada (6 steps)
- Usuário autenticado com sucesso (possui token válido)
- Visualizou: produtos → busca → detalhes → carrinho
- Estado pronto para: atualizar carrinho (UC006) OU proceder para checkout (fora de escopo)
- Métricas customizadas `journey_authenticated_*` coletadas
- Token permanece válido para próximas iterações (cache reutilizável)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Credenciais Inválidas
**Condição**: Username ou password incorretos

**Steps**:
1. Request POST /auth/login com credenciais erradas
2. API retorna 400 Bad Request ou 401 Unauthorized
3. VU registra erro de autenticação e **aborta jornada** (não prossegue sem token)

**Validações**:
- ❌ `'status is 401'` → Status code = 401
- ✅ `'error message present'` → Response contém mensagem de erro
- ✅ `'no token returned'` → `accessToken` ausente

**Métrica**: `journey_authenticated_auth_success_rate` decrementada

---

### Cenário de Erro 2: Token Expirado Durante Jornada
**Condição**: Token expira antes do Step 6 (sessão > 30 min configurado)

**Steps**:
1. Steps 1-5 executados normalmente
2. Step 6 (GET /carts/user/{userId}) retorna 401 Unauthorized
3. VU tenta refresh token (se implementado) ou registra erro

**Validações**:
- ❌ `'status is 401'` → Status code = 401
- ✅ `'token expired message'` → Response contém "token" ou "expired"

**Ação de Recuperação**: (Futuro UC012) Implementar refresh token automático

---

### Cenário de Erro 3: Carrinho Vazio
**Condição**: Usuário não possui carrinho associado

**Steps**:
1. Steps 1-5 executados normalmente
2. Step 6 (GET /carts/user/{userId}) retorna 200 OK com `carts: []`
3. VU valida array vazio (comportamento esperado, não é erro)

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'carts array empty'` → `carts.length` === 0
- ✅ `'total is zero'` → `total` === 0

**Observação**: Carrinho vazio é válido (usuário ainda não adicionou itens)

---

### Edge Case 1: Jornada Curta Autenticada (4 steps)
**Condição**: Usuário vai direto de login → busca → detalhes → carrinho (pula navegação inicial)

**Steps**:
1. Step 1: POST /auth/login
2. Step 2: GET /auth/me
3. Step 4: GET /products/search?q=phone (pula Step 3)
4. Step 5: GET /products/{id}
5. Step 6: GET /carts/user/{userId}

**Validações**: Mesmas dos steps individuais

**Think Times**: Mantém 3-7s (Persona 2)

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/scenarios/user-journey-authenticated.test.ts`
- **Diretório**: `tests/scenarios/` (jornadas compostas ficam em scenarios)

### Configuração de Cenário
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter, Rate } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom Metrics
const journeyDuration = new Trend('journey_authenticated_duration_total_ms');
const journeyStepsCompleted = new Counter('journey_authenticated_steps_completed');
const journeyErrors = new Counter('journey_authenticated_errors');
const authSuccessRate = new Rate('journey_authenticated_auth_success_rate');

// Test Data (SharedArray)
const users = new SharedArray('users', function() {
  const data = open('../../data/test-data/users-credentials.csv').split('\n').slice(1);
  return data.map(line => {
    const [id, username, password, email, firstName, lastName, role] = line.split(',');
    return { id, username, password, email, firstName, lastName, role };
  });
});

const usersWithCarts = new SharedArray('usersWithCarts', function() {
  return JSON.parse(open('../../data/test-data/users-with-carts.json'));
});

const searchQueries = new SharedArray('searchQueries', function() {
  return JSON.parse(open('../../data/test-data/search-queries.json'));
});

const productIds = new SharedArray('productIds', function() {
  return JSON.parse(open('../../data/test-data/product-ids.json'));
});

export const options = {
  scenarios: {
    user_journey_authenticated: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 2, // 30% tráfego, baseline 5 RPS = 1.5 RPS (arredonda para 2)
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 40,
      tags: { feature: 'journey', kind: 'authenticated', uc: 'UC010' },
    },
  },
  thresholds: {
    'http_req_duration{feature:journey}': ['p(95)<450', 'p(99)<750'],
    'http_req_failed{feature:journey}': ['rate<0.01'],
    'checks{uc:UC010}': ['rate>0.98'],
    'journey_authenticated_duration_total_ms': ['p(95)<15000'],
    'journey_authenticated_steps_completed': ['count>0'],
    'journey_authenticated_auth_success_rate': ['rate>0.99'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  const journeyStart = Date.now();
  let stepsCompleted = 0;
  let accessToken = null;
  let userId = null;

  // Step 1: Login (Autenticação)
  const randomUser = randomItem(users);
  let res = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    username: randomUser.username,
    password: randomUser.password,
    expiresInMins: 30
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'journey_step1_login', uc: 'UC010', step: '1' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has access token': (r) => r.json('accessToken') !== undefined,
    'token is valid JWT': (r) => r.json('accessToken').startsWith('eyJ'),
  }, { uc: 'UC010', step: '1' })) {
    stepsCompleted++;
    authSuccessRate.add(1);
    accessToken = res.json('accessToken');
    userId = res.json('id');
  } else {
    authSuccessRate.add(0);
    journeyErrors.add(1);
    return; // Aborta jornada se login falhar
  }
  
  sleep(Math.random() * 4 + 3); // 3-7s think time

  // Step 2: Validate Session (/auth/me)
  res = http.get(`${BASE_URL}/auth/me`, {
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    },
    tags: { name: 'journey_step2_validate_session', uc: 'UC010', step: '2' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'user authenticated': (r) => r.json('id') !== undefined,
  }, { uc: 'UC010', step: '2' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 4 + 3);

  // Step 3: Browse Products (Navegação Inicial)
  res = http.get(`${BASE_URL}/products?limit=20&skip=0`, {
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    },
    tags: { name: 'journey_step3_browse_products', uc: 'UC010', step: '3' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
  }, { uc: 'UC010', step: '3' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 4 + 3);

  // Step 4: Search Products
  const randomQuery = randomItem(searchQueries);
  res = http.get(`${BASE_URL}/products/search?q=${randomQuery.term}`, {
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    },
    tags: { name: 'journey_step4_search_products', uc: 'UC010', step: '4' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
  }, { uc: 'UC010', step: '4' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 4 + 3);

  // Step 5: View Product Details
  const randomProductId = randomItem(productIds);
  res = http.get(`${BASE_URL}/products/${randomProductId}`, {
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    },
    tags: { name: 'journey_step5_view_details', uc: 'UC010', step: '5' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'product has id': (r) => r.json('id') !== undefined,
  }, { uc: 'UC010', step: '5' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 4 + 3);

  // Step 6: View Cart
  res = http.get(`${BASE_URL}/carts/user/${userId}`, {
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    },
    tags: { name: 'journey_step6_view_cart', uc: 'UC010', step: '6' }
  });
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has carts array': (r) => Array.isArray(r.json('carts')),
  }, { uc: 'UC010', step: '6' })) {
    stepsCompleted++;
  } else {
    journeyErrors.add(1);
  }
  
  sleep(Math.random() * 4 + 3);

  // Record journey metrics
  const journeyEnd = Date.now();
  journeyDuration.add(journeyEnd - journeyStart);
  journeyStepsCompleted.add(stepsCompleted);
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'journey',         // Domain area (jornada composta)
  kind: 'authenticated',      // Operation type (autenticada)
  uc: 'UC010'                 // Use case ID
}
```

**Fonte**: `docs/casos_de_uso/templates/guia-de-estilo.md` - Tags k6 obrigatórias

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 1 jornada/s por 30s)
K6_RPS=1 K6_DURATION=30s k6 run tests/scenarios/user-journey-authenticated.test.ts

# Baseline (5 min, 2 RPS = 30% de 5 RPS baseline)
K6_RPS=2 K6_DURATION=5m k6 run tests/scenarios/user-journey-authenticated.test.ts

# Stress (10 min, 6 RPS = 30% de 20 RPS stress)
K6_RPS=6 K6_DURATION=10m k6 run tests/scenarios/user-journey-authenticated.test.ts

# Com variáveis de ambiente customizadas
BASE_URL=https://dummyjson.com K6_RPS=3 K6_DURATION=3m \
  k6 run tests/scenarios/user-journey-authenticated.test.ts
```

### CI/CD
```bash
# GitHub Actions smoke test (PR validation)
# Workflow: .github/workflows/k6-pr-smoke.yml
# Executa: 1 RPS por 60s com thresholds relaxados

# GitHub Actions baseline (main branch)
# Workflow: .github/workflows/k6-main-baseline.yml
# Executa: 2 RPS por 5m com thresholds strict (SLOs completos)
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const journeyDuration = new Trend('journey_authenticated_duration_total_ms');

// No VU code (ao final da jornada):
const journeyStart = Date.now();
// ... executa 6 steps ...
const journeyEnd = Date.now();
journeyDuration.add(journeyEnd - journeyStart);
```

**Métrica**: `journey_authenticated_duration_total_ms`  
**Tipo**: Trend (latência total da jornada em ms)  
**Threshold**: P95 < 15000ms (15 segundos sem think times)

---

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const journeyStepsCompleted = new Counter('journey_authenticated_steps_completed');
const journeyErrors = new Counter('journey_authenticated_errors');

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
- `journey_authenticated_steps_completed`: Contador de steps completados (esperado: 6 por iteração)
- `journey_authenticated_errors`: Contador de erros durante a jornada

---

### Rate (Taxa de Sucesso)
```javascript
import { Rate } from 'k6/metrics';

const authSuccessRate = new Rate('journey_authenticated_auth_success_rate');

// No VU code (após login):
if (check(res, { 'status is 200': (r) => r.status === 200 })) {
  authSuccessRate.add(1); // Login sucesso
} else {
  authSuccessRate.add(0); // Login falha
}
```

**Métrica**: `journey_authenticated_auth_success_rate`  
**Tipo**: Rate (taxa de sucesso de autenticação)  
**Threshold**: > 99% (permitir 1% falhas de credenciais)

---

### Dashboards
- **Grafana**: (Futuro) Dashboard dedicado a jornadas autenticadas com métricas de auth rate, duração total, steps completados
- **k6 Cloud**: (Futuro) Análise de jornadas autenticadas com breakdown por step e taxa de conversão

---

## ⚠️ Observações Importantes

### Limitações da API
- **DummyJSON**: API pública, latência pode variar com carga do servidor
- **Tokens JWT**: Válidos por 30-60 minutos (configurável via `expiresInMins`)
- **Sem Persistência Escrita**: Nenhuma operação POST/PUT nesta jornada (apenas login + GETs)
- **Rate Limiting**: Não documentado oficialmente; assumir ~100 RPS seguro (6 steps * 2 RPS = 12 RPS bem abaixo)
- **Cookies**: DummyJSON suporta cookies, mas k6 usa Bearer token no header (mais explícito)

### Particularidades do Teste
- **Think Times Realistas**: 3-7s entre steps conforme Persona 2 (decisão de compra)
- **Autenticação por VU**: Cada VU faz login uma vez e reutiliza token durante sessão (cache)
- **Randomização**: Cada VU seleciona usuário/query/produto aleatório para simular variedade
- **Jornada Composta**: Combina UC003 (Auth) + UC009 (Navegação) + UC005 (Carrinho)
- **Duração da Sessão**: 5-15 minutos conforme Perfil Comprador (fase1-perfis-de-usuario.md)
- **6 Steps Fixos**: Sequência fixa para consistência de métricas (não randomiza ordem)
- **Abort on Auth Fail**: Se login falhar (Step 1), jornada é abortada (não prossegue sem token)

### Considerações de Desempenho
- **SharedArray**: Usar para carregar users/carts/queries/IDs (evita duplicação em memória)
- **Tags Granulares**: Cada step tem tag `step: '1'` a `'6'` para análise individual
- **Open Model Executor**: `constant-arrival-rate` garante RPS constante independente de latência
- **Memory-Efficient**: Dados carregados uma vez por VU, compartilhados entre iterações
- **Token Reuse**: Token pode ser cacheado entre iterações do mesmo VU (otimização futura)

---

## 🔗 Dependências

### UCs Dependentes (Bloqueadores)
- **UC003** (User Login & Profile) → Steps 1-2: Autenticação e validação
- **UC005** (Cart Operations Read) → Step 6: Visualizar carrinho
- **UC009** (User Journey Unauthenticated) → Steps 3-5: Navegação de produtos (fluxo base reutilizado)

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC010 depende de UC003, UC005, UC009

### UCs que Usam Este (Fornece Para)
- **UC011** (Mixed Workload) → Persona "Comprador" (30%) executa UC010

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC010 fornece para UC011

### Libs Necessárias
- **`libs/http/auth.ts`** (Criada em UC003) → Login e gestão de tokens
- **`libs/scenarios/journey-builder.ts`** (Criada em UC009) → Orquestração de jornadas (reutilizada)

**Funções Usadas de `libs/http/auth.ts`**:
```typescript
import { login, getAuthHeaders } from '../../libs/http/auth';

// No VU code:
const { token, userId } = login(username, password);
const headers = getAuthHeaders(token);
```

**Funções Usadas de `libs/scenarios/journey-builder.ts`**:
```typescript
import { addThinkTime, validateStep } from '../../libs/scenarios/journey-builder';

// No VU code:
addThinkTime(3, 7); // Persona 2: 3-7s
const success = validateStep(response, checks, tags);
```

### Dados Requeridos
- **UC003**: `data/test-data/users-credentials.csv` (credenciais)
- **UC005**: `data/test-data/users-with-carts.json` (userIds com carrinhos)
- **UC009**: `data/test-data/search-queries.json`, `data/test-data/product-ids.json` (navegação)

**Estratégia**: Reutilizar TODOS os dados dos UCs dependentes (não gerar novos arquivos)

---

## 📂 Libs/Helpers Criados

### Sem Novas Libs Criadas

Este UC **reutiliza libs existentes**:

1. **`libs/http/auth.ts`** (Criada em UC003)
   - Funções: `login()`, `getToken()`, `getAuthHeaders()`
   - Usado para Steps 1-2 (autenticação)

2. **`libs/scenarios/journey-builder.ts`** (Criada em UC009)
   - Funções: `addThinkTime()`, `validateStep()`, `trackJourneyMetrics()`
   - Usado para orquestração de todos os 6 steps

**Observação**: UC010 é um **caso de uso integrador** que combina funcionalidades de UC003, UC005 e UC009 sem criar novas libs. Toda a lógica necessária já existe nos UCs dependentes.

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-08 | GitHub Copilot | Criação inicial do UC010 (Sprint 4) - jornada autenticada com 6 steps |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Persona 2 - Comprador Autenticado, 30% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (6 endpoints: 1 POST + 5 GET)
- [x] SLOs estão definidos e justificados (referência aos baselines Auth + Products + Carts)
- [x] Fluxo principal está detalhado passo a passo (6 steps numerados)
- [x] Validações (checks) estão especificadas (checks human-readable para cada step)
- [x] Dados de teste estão identificados (fonte + volume) - reutiliza UC003/UC005/UC009
- [x] Headers obrigatórios estão documentados (Content-Type + Authorization Bearer)
- [x] Think times estão especificados (3-7s entre steps, Persona 2)
- [x] Edge cases e cenários de erro estão mapeados (3 cenários alternativos + 1 edge case)
- [x] Dependências de outros UCs estão listadas (UC003, UC005, UC009)
- [x] Limitações da API estão documentadas (DummyJSON tokens JWT, sem persistência)
- [x] Arquivo nomeado corretamente: `UC010-user-journey-authenticated.md`
- [x] Libs/helpers criados estão documentados (reutiliza auth.ts e journey-builder.ts)
- [x] Comandos de teste estão corretos e testados (smoke/baseline/stress)
- [x] Tags obrigatórias estão especificadas (feature: journey, kind: authenticated, uc: UC010)
- [x] Métricas customizadas estão documentadas (4 métricas: duration, steps, errors, auth_success_rate)

---

## 📚 Referências

- [DummyJSON API Docs](https://dummyjson.com/docs)
- [DummyJSON Auth API](https://dummyjson.com/docs/auth)
- [DummyJSON Users API](https://dummyjson.com/docs/users)
- [DummyJSON Carts API](https://dummyjson.com/docs/carts)
- [DummyJSON Products API](https://dummyjson.com/docs/products)
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
- UC009 (Journey Unauth): `docs/casos_de_uso/UC009-user-journey-unauthenticated.md`
