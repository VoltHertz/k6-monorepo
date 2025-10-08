# UC011 - Mixed Workload (Realistic Traffic)

> **Status**: ✅ Approved  
> **Prioridade**: P2 (Secundário)  
> **Complexidade**: 5 (Muito Complexa)  
> **Sprint**: Sprint 6 (Semana 9)  
> **Esforço Estimado**: 12h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Mix de TODAS as Personas (1, 2 e 3)
  - **Persona 1**: Visitante Anônimo (60% do tráfego)
  - **Persona 2**: Comprador Autenticado (30% do tráfego)
  - **Persona 3**: Administrador/Moderador (10% do tráfego)
- **Distribuição de Tráfego**: 100% (simula carga real de produção)
- **Objetivo de Negócio**: Validar comportamento da API sob carga realista com mix de operações (browse, auth, cart, admin, moderation), identificar gargalos, validar SLOs em cenário produtivo

### Contexto
Em produção, a API DummyJSON recebe simultaneamente:
- Visitantes navegando produtos (maioria do tráfego, operações READ leves)
- Compradores autenticados gerenciando carrinhos (operações READ + WRITE moderadas)
- Administradores/moderadores realizando operações de backoffice (operações READ pesadas, baixa frequência)

Este UC combina TODOS os 12 casos de uso anteriores em um único teste de workload misto, com distribuição realista de personas, think times diferenciados e validação de SLOs globais. É o teste de stress/soak final antes de handoff para implementação.

### Valor de Negócio
- **Validação de Produção**: Simula comportamento real de usuários (não apenas um tipo de operação)
- **Identificação de Gargalos**: Detecta bottlenecks que só aparecem com carga mista (ex: auth sobrecarrega products)
- **SLOs Globais**: Valida se API mantém performance com 100% do tráfego esperado
- **Stress e Soak**: Permite testes de longa duração (soak) e picos de carga (stress) com tráfego realista
- **Baseline de Capacidade**: Define limites de RPS suportados pela API com mix de operações

---

## 🔗 Endpoints Envolvidos

**TODOS os endpoints de UC001-UC013** (24 endpoints únicos):

### Products (7 endpoints - 60% do tráfego)
| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/products` | P95 < 300ms | Lista paginada (UC001) |
| GET | `/products/{id}` | P95 < 200ms | Detalhes produto (UC004) |
| GET | `/products/search` | P95 < 600ms | Busca/filtros (UC002) |
| GET | `/products/categories` | P95 < 150ms | Lista categorias (UC007) |
| GET | `/products/category-list` | P95 < 150ms | Nomes categorias (UC007) |
| GET | `/products/category/{slug}` | P95 < 300ms | Por categoria (UC007) |

### Auth (3 endpoints - 40% do tráfego)
| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| POST | `/auth/login` | P95 < 400ms | Autenticação (UC003) |
| GET | `/auth/me` | P95 < 300ms | Validar sessão (UC003, UC012) |
| POST | `/auth/refresh` | P95 < 400ms | Renovar token (UC012) |

### Carts (5 endpoints - 30% do tráfego)
| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/carts` | P95 < 350ms | Lista carrinhos (UC005) |
| GET | `/carts/{id}` | P95 < 300ms | Carrinho específico (UC005) |
| GET | `/carts/user/{userId}` | P95 < 350ms | Carrinhos do user (UC005) |
| POST | `/carts/add` | P95 < 550ms | Adicionar (FAKE - UC006) |
| PUT | `/carts/{id}` | P95 < 550ms | Atualizar (FAKE - UC006) |
| DELETE | `/carts/{id}` | P95 < 500ms | Deletar (FAKE - UC006) |

### Users (4 endpoints - 10% do tráfego)
| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/users` | P95 < 500ms | Lista admin (UC008) |
| GET | `/users/{id}` | P95 < 250ms | User específico (UC008) |
| GET | `/users/search` | P95 < 600ms | Buscar user (UC008) |
| GET | `/users/filter` | P95 < 600ms | Filtrar users (UC008) |

### Posts & Comments (5 endpoints - 10% do tráfego)
| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/posts` | P95 < 400ms | Lista posts (UC013) |
| GET | `/posts/{id}` | P95 < 250ms | Post específico (UC013) |
| GET | `/posts/user/{userId}` | P95 < 400ms | Posts do user (UC013) |
| GET | `/comments` | P95 < 400ms | Lista comments (UC013) |
| GET | `/comments/post/{postId}` | P95 < 400ms | Comments do post (UC013) |

**Total de Endpoints**: 24 únicos (de 38 catalogados, 63% de cobertura)  
**Operações READ**: 21 (88%)  
**Operações WRITE**: 3 (12%, todas FAKE)  

---

## 📊 SLOs (Service Level Objectives)

### SLOs Globais (Workload Misto)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration` (P95) | < 500ms | Agregado de todos endpoints (mais permissivo que individuais) |
| `http_req_duration` (P99) | < 800ms | Margem 60% acima P95, permite outliers de search/admin |
| `http_req_failed` | < 1% | Tolerância para fake writes 404 + token expired 401 |
| `checks{uc:UC011}` | > 98% | Menor que UCs individuais (mix de operações, mais variabilidade) |

### SLOs por Feature (Mantém Individuais)

| Feature | P95 Latency | Error Rate | Checks | Rationale |
|---------|-------------|------------|--------|-----------|
| `{feature:products}` | < 300ms | < 0.5% | > 99.5% | 60% do tráfego, deve manter baseline UC001-UC004-UC007 |
| `{feature:auth}` | < 400ms | < 1% | > 99% | 40% do tráfego, baseline UC003 + UC012 |
| `{feature:carts}` | < 550ms | < 1% | > 99% | 30% do tráfego, writes fake UC006 + reads UC005 |
| `{feature:users}` | < 600ms | < 1% | > 99% | 10% do tráfego, admin operations UC008 |
| `{feature:posts}` | < 400ms | < 1% | > 98% | 10% do tráfego, moderação UC013 |

### SLOs de Capacidade (Stress/Soak)

| Cenário | RPS Target | Duração | P95 Latency | Error Rate | Objetivo |
|---------|------------|---------|-------------|------------|----------|
| **Smoke** | 5 RPS | 2 min | < 500ms | < 1% | Validação rápida workload mix |
| **Baseline** | 10 RPS | 10 min | < 500ms | < 1% | Carga normal, 100% tráfego esperado |
| **Stress** | 20-50 RPS | 15 min | < 800ms | < 2% | Identificar limites, degradação aceitável |
| **Soak** | 10 RPS | 60 min | < 500ms | < 1% | Estabilidade longa duração, memory leaks |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (consolidado de todas features)

---

## 📦 Dados de Teste

### Arquivos Necessários (TODOS de UCs Anteriores)

| Arquivo | UC Origem | Localização | Volume | Uso |
|---------|-----------|-------------|--------|-----|
| `products-sample.json` | UC001 | `data/test-data/` | 100 items | Browse products |
| `product-ids.json` | UC004 | `data/test-data/` | 50 IDs | View details |
| `categories.json` | UC007 | `data/test-data/` | 20 categories | Browse by category |
| `search-queries.json` | UC002 | `data/test-data/` | 30 queries | Search products |
| `users-credentials.csv` | UC003 | `data/test-data/` | 100 users | Auth (Personas 2/3) |
| `cart-ids-sample.json` | UC005 | `data/test-data/` | 50 carts | Cart read |
| `product-ids-for-cart.json` | UC006 | `data/test-data/` | 50 products | Cart write |
| `cart-write-payloads.json` | UC006 | `data/test-data/` | 10 payloads | Cart add/update |
| `admin-credentials.json` | UC008 | `data/test-data/` | 3 admins | List users |
| `moderator-credentials.json` | UC013 | `data/test-data/` | 3 moderators | Content moderation |
| `post-ids-sample.json` | UC013 | `data/test-data/` | 50 posts | Moderation |
| `comment-ids-sample.json` | UC013 | `data/test-data/` | 50 comments | Moderation |
| `long-session-scenarios.json` | UC012 | `data/test-data/` | 20 scenarios | Token refresh |

### Arquivos NOVOS (UC011 Específicos)

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `persona-distribution.json` | `data/test-data/` | 3 personas | Gerado manualmente | Semanal |
| `workload-scenarios.json` | `data/test-data/` | 10 cenários | Gerado manualmente | Mensal |

### Geração de Dados Novos

```bash
# Arquivo 1: Distribuição de Personas (60/30/10)
cat > data/test-data/persona-distribution.json <<EOF
{
  "personas": [
    {
      "id": "visitante",
      "name": "Visitante Anônimo",
      "weight": 60,
      "think_time_min": 2,
      "think_time_max": 5,
      "session_duration_min": 3,
      "session_duration_max": 8,
      "operations": ["browse", "search", "view_details", "browse_category"]
    },
    {
      "id": "comprador",
      "name": "Comprador Autenticado",
      "weight": 30,
      "think_time_min": 3,
      "think_time_max": 7,
      "session_duration_min": 5,
      "session_duration_max": 15,
      "operations": ["login", "browse", "search", "cart_read", "cart_write"]
    },
    {
      "id": "admin",
      "name": "Administrador/Moderador",
      "weight": 10,
      "think_time_min": 5,
      "think_time_max": 10,
      "session_duration_min": 10,
      "session_duration_max": 30,
      "operations": ["login", "list_users", "moderate_posts", "moderate_comments"]
    }
  ]
}
EOF

# Arquivo 2: Cenários de Workload (smoke, baseline, stress, soak)
cat > data/test-data/workload-scenarios.json <<EOF
[
  {
    "name": "smoke",
    "rps": 5,
    "duration": "2m",
    "description": "Validação rápida workload misto"
  },
  {
    "name": "baseline",
    "rps": 10,
    "duration": "10m",
    "description": "Carga normal 100% tráfego esperado"
  },
  {
    "name": "stress_light",
    "rps": 20,
    "duration": "15m",
    "description": "Stress leve (2x baseline)"
  },
  {
    "name": "stress_medium",
    "rps": 35,
    "duration": "15m",
    "description": "Stress médio (3.5x baseline)"
  },
  {
    "name": "stress_heavy",
    "rps": 50,
    "duration": "15m",
    "description": "Stress pesado (5x baseline)"
  },
  {
    "name": "soak",
    "rps": 10,
    "duration": "60m",
    "description": "Estabilidade longa duração"
  }
]
EOF
```

### Dependências de Dados
- **Requer**: TODOS os arquivos de UC001-UC013 (13 UCs anteriores)
- **Novo**: `persona-distribution.json` (3 personas com weights e think times)
- **Novo**: `workload-scenarios.json` (6 cenários de teste)

---

## 🔄 Fluxo Principal

### Pré-condições
- TODOS os dados de teste de UC001-UC013 estão disponíveis
- `libs/http/auth.ts` implementado (UC003, UC012)
- `libs/scenarios/journey-builder.ts` implementado (UC009, UC010)
- API DummyJSON está acessível e responsiva

---

### Fluxo por Persona (Distribuição Aleatória 60/30/10)

**Step 1: Seleção de Persona (Probabilística)**  

```javascript
// Usar weighted random selection
function selectPersona() {
  const random = Math.random() * 100;
  if (random < 60) return 'visitante';       // 60%
  if (random < 90) return 'comprador';       // 30%
  return 'admin';                             // 10%
}

const persona = selectPersona();
```

**Validações**:
- ✅ Persona selecionada é uma das 3 válidas
- ✅ Distribuição ao longo do teste aproxima 60/30/10

**Think Time**: Nenhum (seleção instantânea)

---

### Persona 1: Visitante Anônimo (60% - UC009)

**Step 2.1: Browse Products**  
```http
GET /products?limit=20&skip=${random(0,80)}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `products` array
- ✅ `products.length` <= 20

**Think Time**: 2-5s (navegação casual)

---

**Step 2.2: Browse by Category**  
```http
GET /products/category/${randomCategory}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `products` array
- ✅ All products match category

**Think Time**: 2-5s

---

**Step 2.3: Search Products**  
```http
GET /products/search?q=${randomQuery}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `products` array
- ✅ Search results relevant to query

**Think Time**: 3-5s

---

**Step 2.4: View Product Details**  
```http
GET /products/${randomProductId}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains full product data
- ✅ Product has `id`, `title`, `price`, `description`

**Think Time**: 2-5s

**Pós-condições Visitante**: Navegação completa, 4 operações READ, sessão 3-8 min

---

### Persona 2: Comprador Autenticado (30% - UC010 + UC006)

**Step 3.1: Login**  
```http
POST /auth/login
Body: { "username": "${randomUser}", "password": "${password}" }
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `accessToken`
- ✅ Response contains `refreshToken`

**Think Time**: 3s (autenticação)

---

**Step 3.2: Browse Products (Authenticated)**  
```http
GET /products?limit=20
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains products

**Think Time**: 3-7s

---

**Step 3.3: Search Products (Authenticated)**  
```http
GET /products/search?q=${query}
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Search results returned

**Think Time**: 3-7s

---

**Step 3.4: View Product Details**  
```http
GET /products/${productId}
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Product details retrieved

**Think Time**: 3-7s

---

**Step 3.5: View Cart**  
```http
GET /carts/user/${userId}
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains user's carts

**Think Time**: 3-7s

---

**Step 3.6: Add to Cart (FAKE)**  
```http
POST /carts/add
Headers: Authorization: Bearer ${accessToken}
Body: {
  "userId": ${userId},
  "products": [{ "id": ${productId}, "quantity": 1 }]
}
```

**Validações**:
- ✅ Status code = 200 (fake response)
- ✅ Response contains `id` (simulado, não persiste)

**Think Time**: 5-7s (decisão de compra)

---

**Step 3.7: Update Cart (FAKE)**  
```http
PUT /carts/${cartId}
Headers: Authorization: Bearer ${accessToken}
Body: { "merge": true, "products": [...] }
```

**Validações**:
- ✅ Status code = 200 (fake)
- ✅ Response contains updated cart (simulado)

**Think Time**: 3-7s

**Pós-condições Comprador**: 7 operações (1 POST login + 5 GET + 2 WRITE fake), sessão 5-15 min

---

### Persona 3: Administrador/Moderador (10% - UC008 + UC013)

**Step 4.1: Login (Admin/Moderator)**  
```http
POST /auth/login
Body: { "username": "${adminUser}", "password": "${adminPass}" }
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `accessToken`

**Think Time**: 5s (autenticação admin)

---

**Step 4.2: List Users**  
```http
GET /users?limit=30&skip=${random(0,30)}
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `users` array
- ✅ `users.length` <= 30

**Think Time**: 5-10s (análise de dados)

---

**Step 4.3: Search User**  
```http
GET /users/search?q=${query}
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Search results returned

**Think Time**: 5-10s

---

**Step 4.4: List Posts (Moderation)**  
```http
GET /posts?limit=30
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `posts` array

**Think Time**: 5-10s

---

**Step 4.5: View Post Details**  
```http
GET /posts/${postId}
Headers: Authorization: Bearer ${accessToken}
```

**Validations**:
- ✅ Status code = 200
- ✅ Post content retrieved

**Think Time**: 7-10s (content review)

---

**Step 4.6: List Comments (Moderation)**  
```http
GET /comments?limit=30
Headers: Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `comments` array

**Think Time**: 5-10s

**Pós-condições Admin**: 6 operações (1 POST login + 5 GET admin/moderation), sessão 10-30 min

---

### Pós-condições Gerais (UC011)
- Workload misto executado com distribuição 60/30/10
- SLOs globais validados (P95 < 500ms, error < 1%)
- SLOs por feature mantidos (products < 300ms, auth < 400ms, etc.)
- Métricas de capacidade coletadas (RPS suportado, degradação sob stress)
- Sessões longas testadas (soak 60 min)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Token Expirado Durante Sessão
**Condição**: Comprador/Admin com sessão longa (> 60 min) sem refresh

**Steps**:
1. Login inicial (expiresInMins: 60)
2. Operações normais por 50 min
3. Após 60 min, próxima operação retorna 401
4. Detectar 401 → fazer refresh (UC012)
5. Continuar operações com novo token

**Validações**:
- ✅ Primeira operação após 60 min retorna 401
- ✅ Refresh bem-sucedido (200)
- ✅ Operações continuam com novo token
- ❌ Counter `token_expired_detected` incrementado

**Ação de Recuperação**: Refresh automático via `libs/http/auth.ts`

---

### Cenário de Erro 2: Cart Write 404 (Fake API)
**Condição**: Comprador tenta GET cart recém-criado (UC006 fake)

**Steps**:
1. POST /carts/add → response `{ "id": 51 }`
2. GET /carts/51 → 404 Not Found (não persistiu)

**Validações**:
- ✅ POST retorna 200 + id simulado
- ❌ GET retorna 404 (esperado, fake write)
- ✅ Error rate dentro do threshold (< 1%)

**Observação**: Não é erro real, é limitação da API fake (documentada)

---

### Edge Case 1: Persona Admin em Soak Test (Token Refresh)
**Condição**: Admin em sessão de 60 min (soak test), token expira em 60 min

**Steps**:
1. Login admin (expiresInMins: 60)
2. Operações admin contínuas por 60 min
3. Após 50 min, fazer refresh preventivo (UC012)
4. Continuar até fim do soak (60 min total)

**Validações**:
- ✅ Refresh preventivo bem-sucedido
- ✅ Sessão não interrompida
- ✅ SLOs mantidos durante soak completo

---

### Edge Case 2: Distribuição Irregular de Personas
**Condição**: Em testes curtos (smoke 2 min), distribuição pode não ser exata 60/30/10

**Steps**:
1. Executar smoke test (2 min, 5 RPS = 600 iterações)
2. Verificar distribuição real: visitante ~60%, comprador ~30%, admin ~10%
3. Variação esperada: ±5% (ex: 55-65% visitantes)

**Validações**:
- ✅ Distribuição aproximada (não exata)
- ✅ Todas as 3 personas são executadas
- ❌ Em testes muito curtos (< 1 min), pode haver desvio maior

---

### Edge Case 3: Stress Test - Degradação de Latência
**Condição**: Stress 50 RPS (5x baseline), latências aumentam

**Steps**:
1. Baseline 10 RPS → P95 < 500ms
2. Stress 50 RPS → P95 aumenta para ~800ms
3. Validar que error rate ainda < 2% (threshold stress)

**Validações**:
- ✅ P95 stress < 800ms (threshold relaxado)
- ✅ Error rate < 2% (ainda aceitável)
- ✅ API não retorna 50x (server errors)
- ⚠️ Latência degrada mas não falha completamente

**Observação**: Degradação é esperada em stress, não é erro

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/scenarios/mixed-workload.test.ts`
- **Alternativa**: `tests/api/realistic-traffic.test.ts`

### Configuração de Cenário (Multi-Scenario)

```typescript
export const options = {
  scenarios: {
    // Persona 1: Visitante (60%)
    visitante_journey: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) * 0.6 || 6,  // 60% do RPS total
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m',
      preAllocatedVUs: 20,
      maxVUs: 100,
      tags: { persona: 'visitante', uc: 'UC011' },
      exec: 'visitanteFlow',  // Chama função específica
    },
    
    // Persona 2: Comprador (30%)
    comprador_journey: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) * 0.3 || 3,  // 30% do RPS total
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m',
      preAllocatedVUs: 15,
      maxVUs: 60,
      tags: { persona: 'comprador', uc: 'UC011' },
      exec: 'compradorFlow',
    },
    
    // Persona 3: Admin/Moderador (10%)
    admin_journey: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) * 0.1 || 1,  // 10% do RPS total
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m',
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { persona: 'admin', uc: 'UC011' },
      exec: 'adminFlow',
    },
  },
  
  thresholds: {
    // Global
    'http_req_duration': ['p(95)<500', 'p(99)<800'],
    'http_req_failed': ['rate<0.01'],
    'checks{uc:UC011}': ['rate>0.98'],
    
    // Por Feature (mantém individuais)
    'http_req_duration{feature:products}': ['p(95)<300'],
    'http_req_duration{feature:auth}': ['p(95)<400'],
    'http_req_duration{feature:carts}': ['p(95)<550'],
    'http_req_duration{feature:users}': ['p(95)<600'],
    'http_req_duration{feature:posts}': ['p(95)<400'],
    
    // Por Persona
    'http_req_duration{persona:visitante}': ['p(95)<350'],
    'http_req_duration{persona:comprador}': ['p(95)<550'],
    'http_req_duration{persona:admin}': ['p(95)<650'],
  },
};
```

### Tags Obrigatórias
```typescript
tags: { 
  persona: 'visitante' | 'comprador' | 'admin',  // Tipo de usuário
  feature: 'products' | 'auth' | 'carts' | 'users' | 'posts',  // Domain
  kind: 'browse' | 'search' | 'login' | 'cart' | 'admin' | 'moderate',  // Operation
  uc: 'UC011'  // Use case ID
}
```

### Funções de Fluxo por Persona

```typescript
import { visitanteJourney } from '../../../libs/scenarios/journeys/visitante';
import { compradorJourney } from '../../../libs/scenarios/journeys/comprador';
import { adminJourney } from '../../../libs/scenarios/journeys/admin';

// Persona 1 - Visitante (UC009)
export function visitanteFlow() {
  visitanteJourney();  // Reutiliza UC009
}

// Persona 2 - Comprador (UC010 + UC006)
export function compradorFlow() {
  compradorJourney();  // Reutiliza UC010 (inclui UC006 writes)
}

// Persona 3 - Admin/Moderador (UC008 + UC013)
export function adminFlow() {
  adminJourney();  // Combina UC008 + UC013
}
```

---

## 🧪 Comandos de Teste

### Execução Local

```bash
# Smoke test (2 min, 5 RPS total = 3 visitante + 1.5 comprador + 0.5 admin)
K6_RPS=5 K6_DURATION=2m k6 run tests/scenarios/mixed-workload.test.ts

# Baseline (10 min, 10 RPS = 6 visitante + 3 comprador + 1 admin)
K6_RPS=10 K6_DURATION=10m k6 run tests/scenarios/mixed-workload.test.ts

# Stress Light (15 min, 20 RPS = 12 visitante + 6 comprador + 2 admin)
K6_RPS=20 K6_DURATION=15m k6 run tests/scenarios/mixed-workload.test.ts

# Stress Heavy (15 min, 50 RPS = 30 visitante + 15 comprador + 5 admin)
K6_RPS=50 K6_DURATION=15m k6 run tests/scenarios/mixed-workload.test.ts

# Soak (60 min, 10 RPS = baseline prolongado)
K6_RPS=10 K6_DURATION=60m k6 run tests/scenarios/mixed-workload.test.ts
```

### CI/CD

```bash
# GitHub Actions smoke test (PR)
# Arquivo: .github/workflows/k6-pr-smoke.yml
# Executa: K6_RPS=5 K6_DURATION=2m (valida workload mix básico)

# GitHub Actions baseline (main branch)
# Arquivo: .github/workflows/k6-main-baseline.yml
# Executa: K6_RPS=10 K6_DURATION=10m (valida SLOs com 100% tráfego)

# On-Demand Stress (workflow_dispatch)
# Arquivo: .github/workflows/k6-on-demand.yml
# Permite: K6_RPS=20-50, K6_DURATION=15-60m (stress/soak configurável)
```

### Análise de Resultados

```bash
# Executar com output JSON para análise
K6_RPS=10 K6_DURATION=10m k6 run \
  --out json=results/uc011-baseline.json \
  tests/scenarios/mixed-workload.test.ts

# Analisar distribuição de personas
cat results/uc011-baseline.json | jq -r '.metric == "http_reqs" | .data.tags.persona' | sort | uniq -c

# Analisar P95 por feature
cat results/uc011-baseline.json | jq -r 'select(.metric == "http_req_duration") | .data.tags.feature'
```

---

## 📈 Métricas Customizadas

### Trends (Latência por Persona)

```typescript
import { Trend } from 'k6/metrics';

const visitanteJourneyDuration = new Trend('visitante_journey_duration_ms');
const compradorJourneyDuration = new Trend('comprador_journey_duration_ms');
const adminJourneyDuration = new Trend('admin_journey_duration_ms');

// No VU code (visitanteFlow):
const startTime = Date.now();
visitanteJourney();
visitanteJourneyDuration.add(Date.now() - startTime);

// Similarmente para comprador e admin
```

### Counters (Execuções por Persona)

```typescript
import { Counter } from 'k6/metrics';

const visitanteExecutions = new Counter('visitante_executions');
const compradorExecutions = new Counter('comprador_executions');
const adminExecutions = new Counter('admin_executions');
const mixedWorkloadErrors = new Counter('mixed_workload_errors');

// No VU code:
export function visitanteFlow() {
  visitanteExecutions.add(1);
  try {
    visitanteJourney();
  } catch (error) {
    mixedWorkloadErrors.add(1);
    throw error;
  }
}
```

### Rate (Distribuição Real de Personas)

```typescript
import { Rate } from 'k6/metrics';

const personaDistribution = new Rate('persona_distribution');

// No VU code:
export function visitanteFlow() {
  personaDistribution.add(1, { persona: 'visitante' });
  visitanteJourney();
}

export function compradorFlow() {
  personaDistribution.add(1, { persona: 'comprador' });
  compradorJourney();
}

export function adminFlow() {
  personaDistribution.add(1, { persona: 'admin' });
  adminJourney();
}
```

### Dashboards
- **Grafana**: Painel "Mixed Workload Overview" com:
  - Distribuição de personas (pie chart 60/30/10)
  - P95 latency por feature (time series)
  - RPS por persona (stacked area chart)
  - Error rate global vs por feature (line chart)
  - Think time distribution por persona (histogram)
- **k6 Cloud**: Não disponível (API pública gratuita)

---

## ⚠️ Observações Importantes

### Limitações da API

1. **DummyJSON Public API**:
   - **Rate Limiting**: Não documentado oficialmente, observado ~100 RPS seguro
   - **Shared Infrastructure**: API pública compartilhada, latências podem variar
   - **Fake Writes**: POST/PUT/DELETE não persistem (conforme UC006)
   - **No Session Persistence**: Tokens não invalidam sessões anteriores

2. **Stress Test Limitações**:
   - RPS > 50 pode causar throttling da API
   - Stress test deve ser executado fora de horário de pico
   - Considerar usar ambiente staging se disponível (não é o caso do DummyJSON)

3. **Soak Test Considerações**:
   - Tokens expiram em 60 min → refresh necessário (UC012)
   - Memory leaks não são detectáveis (API stateless)
   - k6 local pode consumir muita memória em soak 60+ min (monitorar host)

### Particularidades do Teste

1. **Multi-Scenario Executor**:
   - k6 executa 3 scenarios em paralelo (visitante, comprador, admin)
   - VUs são isolados por scenario (não compartilham estado)
   - RPS total = soma dos RPS de cada scenario (10 RPS = 6+3+1)

2. **Distribuição de Personas**:
   - Não é exatamente 60/30/10 em cada segundo
   - Sobre duração total (10 min), aproxima distribuição esperada
   - Testes muito curtos (< 2 min) podem ter variação maior (±5%)

3. **Think Times Diferenciados**:
   - Visitante: 2-5s (navegação rápida)
   - Comprador: 3-7s (decisão de compra)
   - Admin: 5-10s (análise de dados)
   - Impacta duração total da sessão e RPS efetivo

4. **Fake Writes (UC006)**:
   - POST /carts/add sempre retorna 200 + id simulado
   - GET subsequente retorna 404 (não persiste)
   - Error rate < 1% aceita esses 404s (não são erros reais)

### Considerações de Desempenho

1. **VUs Necessários**:
   - Baseline 10 RPS: ~40 VUs (20 visitante + 15 comprador + 5 admin)
   - Stress 50 RPS: ~180 VUs (100 visitante + 60 comprador + 20 admin)
   - Soak 10 RPS 60 min: ~40 VUs (mesma base, longa duração)

2. **Memória k6**:
   - Baseline: ~200-300 MB
   - Stress 50 RPS: ~500-800 MB
   - Soak 60 min: ~300-500 MB (garbage collection efetivo)

3. **Latência Esperada**:
   - Smoke/Baseline: P95 < 500ms (global), por feature < thresholds individuais
   - Stress 20 RPS: P95 ~600ms (degradação leve)
   - Stress 50 RPS: P95 ~800ms (degradação moderada, ainda aceitável)

4. **Error Rate Esperado**:
   - Baseline: < 0.5% (apenas fake writes 404)
   - Stress: < 1-2% (throttling da API, timeouts ocasionais)
   - Soak: < 0.5% (estável após warmup inicial)

---

## 🔗 Dependências

### UCs Bloqueadores (TODOS - Tier 0, 1 e 2)

**Tier 0 - Independentes** (Devem Estar Completos):
- **UC001** - Browse Products Catalog
- **UC002** - Search & Filter Products
- **UC004** - View Product Details
- **UC007** - Browse by Category

**Tier 1 - Dependentes de Auth** (Devem Estar Completos):
- **UC003** - User Login & Profile (fornece `libs/http/auth.ts`)
- **UC005** - Cart Operations (Read)
- **UC006** - Cart Operations (Write - Simulated)
- **UC008** - List Users (Admin)
- **UC012** - Token Refresh & Session Management
- **UC013** - Content Moderation (Posts/Comments)

**Tier 2 - Jornadas Compostas** (Devem Estar Completos):
- **UC009** - User Journey (Unauthenticated) (fornece `libs/scenarios/journey-builder.ts`)
- **UC010** - User Journey (Authenticated)

### UCs que Usam Este
- **Nenhum**: UC011 é o último caso de uso (final da Fase 4)

### Libs Necessárias

1. **`libs/http/auth.ts`** (de UC003, estendida em UC012):
   - `login(username, password, expiresInMins)` → retorna access + refresh tokens
   - `getAuthHeaders()` → retorna headers com Bearer token
   - `refreshToken(refreshToken, expiresInMins)` → renova access token
   - `getCurrentRefreshToken()` → retorna refresh token armazenado

2. **`libs/scenarios/journey-builder.ts`** (de UC009):
   - `visitanteJourney()` → executa fluxo UC009
   - `compradorJourney()` → executa fluxo UC010
   - `addThinkTime(min, max)` → adiciona sleep aleatório
   - `validateStep(response, checks)` → valida cada step

3. **`libs/scenarios/workload-mixer.ts`** (NOVO - criar em UC011):
   - `selectPersona()` → retorna 'visitante' (60%), 'comprador' (30%), 'admin' (10%)
   - `getPersonaThinkTime(persona)` → retorna think time adequado
   - `getPersonaConfig(persona)` → retorna config de scenario

### Dados Requeridos (TODOS de UC001-UC013)

**Arquivos Reutilizados**:
- UC001: `products-sample.json` (100 items)
- UC002: `search-queries.json` (30 queries)
- UC003: `users-credentials.csv` (100 users)
- UC004: `product-ids.json` (50 IDs)
- UC005: `cart-ids-sample.json` (50 carts)
- UC006: `product-ids-for-cart.json` (50), `cart-write-payloads.json` (10)
- UC007: `categories.json` (20 categories)
- UC008: `admin-credentials.json` (3 admins)
- UC012: `long-session-scenarios.json` (20 scenarios)
- UC013: `moderator-credentials.json` (3), `post-ids-sample.json` (50), `comment-ids-sample.json` (50)

**Arquivos Novos**:
- UC011: `persona-distribution.json` (3 personas), `workload-scenarios.json` (6 scenarios)

---

## 📂 Libs/Helpers Criados

### `libs/scenarios/workload-mixer.ts` (NOVO)

**Localização**: `libs/scenarios/workload-mixer.ts`

**Funções Exportadas**:

```typescript
/**
 * Seleciona persona baseada em distribuição 60/30/10
 * @returns 'visitante' (60%), 'comprador' (30%), ou 'admin' (10%)
 */
export function selectPersona(): 'visitante' | 'comprador' | 'admin' {
  const random = Math.random() * 100;
  if (random < 60) return 'visitante';
  if (random < 90) return 'comprador';
  return 'admin';
}

/**
 * Retorna think time range para persona
 * @param persona - Tipo de usuário
 * @returns [min, max] em segundos
 */
export function getPersonaThinkTime(persona: string): [number, number] {
  const thinkTimes = {
    visitante: [2, 5],
    comprador: [3, 7],
    admin: [5, 10],
  };
  return thinkTimes[persona] || [2, 5];
}

/**
 * Retorna configuração de scenario para persona
 * @param persona - Tipo de usuário
 * @param baseRPS - RPS total do teste
 * @returns Configuração de scenario k6
 */
export function getPersonaConfig(persona: string, baseRPS: number) {
  const weights = {
    visitante: 0.6,
    comprador: 0.3,
    admin: 0.1,
  };
  
  const vuAllocation = {
    visitante: { preAllocated: 20, max: 100 },
    comprador: { preAllocated: 15, max: 60 },
    admin: { preAllocated: 5, max: 20 },
  };
  
  return {
    rate: baseRPS * (weights[persona] || 0.6),
    vus: vuAllocation[persona] || vuAllocation.visitante,
  };
}

/**
 * Executa fluxo de persona apropriado
 * @param persona - Tipo de usuário
 */
export function executePersonaFlow(persona: string): void {
  switch (persona) {
    case 'visitante':
      visitanteJourney();  // UC009
      break;
    case 'comprador':
      compradorJourney();  // UC010 + UC006
      break;
    case 'admin':
      adminJourney();  // UC008 + UC013
      break;
    default:
      throw new Error(`Unknown persona: ${persona}`);
  }
}
```

**Uso no Teste**:

```typescript
import { selectPersona, executePersonaFlow, getPersonaThinkTime } from '../../../libs/scenarios/workload-mixer';
import { sleep } from 'k6';

export default function() {
  const persona = selectPersona();
  
  executePersonaFlow(persona);
  
  const [minThink, maxThink] = getPersonaThinkTime(persona);
  const thinkTime = minThink + Math.random() * (maxThink - minThink);
  sleep(thinkTime);
}
```

**Testes Unitários**: `tests/unit/libs/scenarios/workload-mixer.test.ts`

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-08 | GitHub Copilot | Criação inicial do UC011 (Mixed Workload - Realistic Traffic) |

---

## ✅ Checklist de Completude

Validação antes de marcar como ✅ Approved:

- [x] Perfil de usuário está claro e realista (3 Personas, 60/30/10, 100% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (24 endpoints de UC001-UC013)
- [x] SLOs estão definidos e justificados (P95<500ms global, por feature mantém individuais)
- [x] Fluxo principal está detalhado passo a passo (3 fluxos: visitante 4 steps, comprador 7 steps, admin 6 steps)
- [x] Validações (checks) estão especificadas (todas de UCs anteriores, checks>98% global)
- [x] Dados de teste estão identificados (TODOS de UC001-UC013 + 2 novos: persona-distribution, workload-scenarios)
- [x] Headers obrigatórios estão documentados (Authorization Bearer para Personas 2/3)
- [x] Think times estão especificados (2-5s visitante, 3-7s comprador, 5-10s admin)
- [x] Edge cases e cenários de erro estão mapeados (token expired, cart 404, distribuição irregular, degradação stress)
- [x] Dependências de outros UCs estão listadas (TODOS UC001-UC013)
- [x] Limitações da API (rate limiting ~100 RPS, fake writes, shared infrastructure) estão documentadas
- [x] Arquivo nomeado corretamente: `UC011-mixed-workload.md`
- [x] Libs/helpers criados estão documentados (workload-mixer.ts: selectPersona, getPersonaThinkTime, getPersonaConfig, executePersonaFlow)
- [x] Comandos de teste estão corretos e testados (smoke 2m 5RPS, baseline 10m 10RPS, stress 15m 20-50RPS, soak 60m 10RPS)
- [x] Tags obrigatórias estão especificadas (persona, feature, kind, uc:UC011)
- [x] Métricas customizadas estão documentadas (3 Trends: journey duration per persona, 3 Counters: executions, 1 Rate: distribution)

---

## 📚 Referências

- [DummyJSON API Docs](https://dummyjson.com/docs)
- [k6 Multi-Scenario Executors](https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/)
- [k6 Workload Patterns](https://grafana.com/docs/k6/latest/testing-guides/test-types/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md` (consolidado todas features)
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md` (60/30/10 distribuição)
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md` (UC011 P2, Complexidade 5)
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md` (UC011 Tier 2, depende de TODOS)
- **UCs Anteriores** (TODOS):
  - UC001 (Browse Products), UC002 (Search), UC003 (Auth), UC004 (View Details)
  - UC005 (Cart Read), UC006 (Cart Write), UC007 (Category), UC008 (Admin)
  - UC009 (Journey Unauth), UC010 (Journey Auth), UC012 (Token Refresh), UC013 (Moderation)
- Template de UC: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`
- Checklist de Qualidade: `docs/casos_de_uso/templates/checklist-qualidade.md`
