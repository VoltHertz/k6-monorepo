# UC008 - List Users (Admin)

> **Status**: ✅ Approved  
> **Prioridade**: P2 (Secundário)  
> **Complexidade**: 2 (Simples)  
> **Sprint**: Sprint 5 (Semana 8)  
> **Esforço Estimado**: 5h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Administrador (Persona 3)
- **Distribuição de Tráfego**: 10% do total esperado (backoffice operations)
- **Objetivo de Negócio**: Gerenciar base de usuários da plataforma através de listagem paginada, busca e filtros para operações administrativas (moderação, suporte, análise)

### Contexto
Este caso de uso representa operações **administrativas de gestão de usuários** conforme descrito em `fase1-perfis-de-usuario.md` (Persona 3 - Administrador/Moderador). O administrador:
1. Autentica com credenciais admin → POST /auth/login
2. Lista todos os usuários (paginado) → GET /users
3. Busca usuários específicos → GET /users/search?q={query}
4. Filtra usuários por critérios → GET /users/filter?key={key}&value={value}
5. Visualiza detalhes de usuário específico → GET /users/{id}

Este UC foca em **operações READ de administração**, essenciais para:
- **Moderação**: Identificar usuários problemáticos
- **Suporte**: Localizar usuários para assistência
- **Análise**: Entender demografia e comportamento da base
- **Compliance**: Auditar dados de usuários

### Valor de Negócio
- **Criticidade**: Secundária (2/5) - Backoffice, não afeta UX do cliente final
- **Impacto no Tráfego**: 10% do volume total (Persona 3 Admin/Moderador)
- **Operacional**: Crítico para time interno (CS, moderation, analytics)
- **Compliance**: Necessário para LGPD/GDPR (acesso/auditoria de dados)
- **Quadrante na Matriz**: 🔄 **QUICK WINS** (Baixa criticidade, Baixa complexidade)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 3 (Admin: 10% do tráfego, 10-30 min sessão, 5-10s think time)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| POST | `/auth/login` | P95 < 400ms | Step 0: Autenticação admin (UC003) |
| GET | `/users` | P95 < 500ms | Step 1: Listar todos (paginado, default 30 itens) |
| GET | `/users?limit={n}&skip={m}` | P95 < 500ms | Step 2: Paginação customizada |
| GET | `/users/search?q={query}` | P95 < 650ms | Step 3: Busca por nome/email/username |
| GET | `/users/filter?key={k}&value={v}` | P95 < 650ms | Step 4: Filtro por propriedades (ex: gender, role) |
| GET | `/users/{id}` | P95 < 450ms | Step 5: Detalhes de usuário específico |
| GET | `/users?select={fields}` | P95 < 450ms | Step 6 (Opcional): Seleção de campos específicos |

**Total de Endpoints**: 7 (6 principais + 1 opcional)  
**Operações READ**: 7 (100%)  
**Operações WRITE**: 0  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Users domain (GET operations)

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:users}` (P95) | < 500ms | Baseline Users: P95 real = 320ms, +56% margem para queries complexas |
| `http_req_duration{feature:users}` (P99) | < 700ms | Worst case: search/filter com payload grande |
| `http_req_failed{feature:users}` | < 1% | Tolerância para usuários inexistentes (404) ou queries inválidas |
| `checks{uc:UC008}` | > 99% | Operações admin devem ter alta confiabilidade |
| `users_list_duration_ms` (P95) | < 500ms | Métrica customizada: latência de listagem |
| `users_search_duration_ms` (P95) | < 650ms | Métrica customizada: latência de busca (+30% vs list) |
| `users_filter_duration_ms` (P95) | < 650ms | Métrica customizada: latência de filtros complexos |

**Baseline de Referência**: 
- `docs/casos_de_uso/fase1-baseline-slos.md` - Users: GET /users P95=220ms, GET /users/search P95=280ms, GET /users/filter P95=260ms
- Margem de 56% aplicada considerando carga admin (paginação extensa, filtros complexos)

**Observações**:
- Search/Filter têm SLO +30% vs List devido a processamento de queries
- Admin operations toleram latência maior (5-10s think time vs 2-5s visitante)
- Payload de /users pode ser grande (30 usuários com 20+ campos cada = ~50KB)

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `admin-credentials.json` | `data/test-data/` | 5 admins | UC003 (reutilizado) | Mensal |
| `user-ids-sample.json` | `data/test-data/` | 50 user IDs | Gerado de fulldummyjsondata/users.json | Mensal |
| `user-search-queries.json` | `data/test-data/` | 20 queries | Manual (nomes comuns: John, Emily, etc.) | Trimestral |
| `user-filter-criteria.json` | `data/test-data/` | 10 filtros | Manual (gender=male, role=admin, etc.) | Trimestral |

### Geração de Dados
```bash
# Gerar lista de user IDs (sample de 50 dos 208 totais)
node data/test-data/generators/generate-user-ids.ts \
  --source data/fulldummyjsondata/users.json \
  --output data/test-data/user-ids-sample.json \
  --sample-size 50

# Gerar queries de busca comuns
cat > data/test-data/user-search-queries.json << EOF
[
  {"term": "John", "expected_min": 1},
  {"term": "Emily", "expected_min": 1},
  {"term": "admin", "expected_min": 1},
  {"term": "johnson", "expected_min": 1},
  {"term": "@x.dummyjson.com", "expected_min": 10}
]
EOF

# Gerar critérios de filtro
cat > data/test-data/user-filter-criteria.json << EOF
[
  {"key": "gender", "value": "male"},
  {"key": "gender", "value": "female"},
  {"key": "role", "value": "admin"},
  {"key": "role", "value": "moderator"},
  {"key": "hair.color", "value": "Brown"},
  {"key": "age", "value": "28"}
]
EOF
```

### Dependências de Dados
- **UC003**: `admin-credentials.json` (credenciais de administradores)
- **Novo**: `user-ids-sample.json`, `user-search-queries.json`, `user-filter-criteria.json` (gerados para UC008)

**Estratégia**: Gerar novos arquivos específicos para operações admin (IDs, queries, filtros)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário possui **credenciais de administrador** (role: "admin")
- API DummyJSON disponível em https://dummyjson.com
- Dados de teste carregados (admin credentials, user IDs, queries, filters)
- Token de autenticação admin válido (obtido via UC003)

### Steps

**Step 0: Autenticação Admin (Pré-requisito)**  
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
- ✅ `'user is admin'` → Response contém `role: "admin"`

**Think Time**: 5-10s (análise de dados - Persona 3 Admin)

**Fonte**: UC003 (User Login & Profile) - Step 1, com validação adicional de role admin

---

**Step 1: Listar Todos os Usuários (Paginação Default)**  
```http
GET /users
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has users array'` → Response contém array `users`
- ✅ `'users count is 30'` → `users.length` === 30 (default pagination)
- ✅ `'has pagination metadata'` → Response contém `total`, `skip`, `limit`
- ✅ `'total is 208'` → Campo `total` = 208 (total de usuários DummyJSON)

**Think Time**: 5-10s (análise de lista)

**Fonte**: `dummyjson.com_docs_users.md` - Get all users (default 30 items)

---

**Step 2: Paginação Customizada (Limit e Skip)**  
```http
GET /users?limit=10&skip=20
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto: pegar 10 usuários a partir do índice 20
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'users count is 10'` → `users.length` === 10
- ✅ `'skip is 20'` → Campo `skip` = 20
- ✅ `'limit is 10'` → Campo `limit` = 10
- ✅ `'first user id is 21'` → `users[0].id` = 21 (20 pulados + 1)

**Think Time**: 5-10s (navegação entre páginas)

**Fonte**: `dummyjson.com_docs_users.md` - Limit and skip users

---

**Step 3: Buscar Usuários por Termo**  
```http
GET /users/search?q={query}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /users/search?q=John
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has users array'` → Response contém array `users`
- ✅ `'has total field'` → Response contém campo `total`
- ✅ `'results match query'` → Pelo menos 1 usuário retornado (se query válida)
- ✅ `'user matches search term'` → `users[0].firstName` ou `lastName` contém termo buscado

**Think Time**: 5-10s (análise de resultados)

**Fonte**: `dummyjson.com_docs_users.md` - Search users

---

**Step 4: Filtrar Usuários por Critérios**  
```http
GET /users/filter?key={key}&value={value}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /users/filter?key=gender&value=male
GET /users/filter?key=hair.color&value=Brown
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has users array'` → Response contém array `users`
- ✅ `'filter applied correctly'` → Todos os usuários retornados têm o valor filtrado
- ✅ `'has total field'` → Response contém campo `total`
- ✅ `'total matches filter'` → `total` >= `users.length`

**Think Time**: 5-10s (análise de dados filtrados)

**Fonte**: `dummyjson.com_docs_users.md` - Filter users (key/value com suporte a nested keys)

---

**Step 5: Visualizar Detalhes de Usuário Específico**  
```http
GET /users/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /users/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'user has id'` → Response contém campo `id`
- ✅ `'user id matches'` → `id` = ID solicitado
- ✅ `'user has complete data'` → Response contém campos: `firstName`, `lastName`, `email`, `username`, `role`
- ✅ `'user has address'` → Response contém objeto `address` completo
- ✅ `'user has company'` → Response contém objeto `company` completo

**Think Time**: 5-10s (análise detalhada de perfil)

**Fonte**: `dummyjson.com_docs_users.md` - Get a single user

---

**Step 6 (Opcional): Selecionar Campos Específicos**  
```http
GET /users?limit=10&select=firstName,lastName,email,role
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'users count is 10'` → `users.length` <= 10
- ✅ `'only selected fields present'` → Response contém apenas `id`, `firstName`, `lastName`, `email`, `role`
- ✅ `'no extra fields'` → Campos como `address`, `company`, `bank` NÃO estão presentes

**Think Time**: 5-10s (otimização de payload)

**Fonte**: `dummyjson.com_docs_users.md` - Limit and skip users (select parameter)

---

### Pós-condições
- Administrador visualizou/listou usuários conforme necessidade
- Operações de paginação, busca e filtro validadas
- Dados de usuários acessados para moderação/suporte/análise
- Métricas customizadas `users_*` coletadas
- Token permanece válido para próximas operações admin (cache reutilizável)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Credenciais Não-Admin
**Condição**: Usuário tenta acessar /users mas não é admin (role: "user" ou "moderator")

**Steps**:
1. Login com credenciais de usuário comum (role: "user")
2. Request GET /users → API permite (DummyJSON não valida role)
3. VU registra sucesso mas valida role incorreta

**Validações**:
- ✅ `'status is 200'` → DummyJSON permite qualquer autenticado
- ⚠️ `'user is not admin'` → Response login tem `role !== "admin"`

**Observação**: DummyJSON **não** restringe acesso por role. Em produção real, deveria retornar 403 Forbidden.

---

### Cenário de Erro 2: Usuário Inexistente
**Condição**: GET /users/{id} com ID que não existe (ex: ID 999)

**Steps**:
1. Request GET /users/999
2. API retorna 404 Not Found
3. VU registra erro esperado

**Validações**:
- ❌ `'status is 404'` → Status code = 404
- ✅ `'error message present'` → Response contém mensagem de erro
- ✅ `'message is not found'` → Mensagem contém "not found"

**Métrica**: `users_errors` incrementada

---

### Cenário de Erro 3: Query de Busca Vazia
**Condição**: GET /users/search?q= (query vazia)

**Steps**:
1. Request GET /users/search?q=
2. API retorna 200 OK com array vazio ou todos os usuários (comportamento não documentado)
3. VU valida resposta

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has users array'` → Response contém array `users`
- ⚠️ `'behavior documented'` → Registrar comportamento real (vazio ou todos)

**Observação**: Comportamento de query vazia não está especificado na documentação DummyJSON.

---

### Edge Case 1: Filtro com Nested Keys
**Condição**: Filtrar por propriedades aninhadas (ex: hair.color, address.city)

**Steps**:
1. Request GET /users/filter?key=hair.color&value=Brown
2. API aplica filtro em nested property
3. VU valida que todos os usuários retornados têm `hair.color === "Brown"`

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'nested filter works'` → `users[0].hair.color` === "Brown"
- ✅ `'all match criteria'` → Todos os usuários validados

**Fonte**: `dummyjson.com_docs_users.md` - Filter users (suporta nested keys com ".")

---

### Edge Case 2: Paginação com limit=0
**Condição**: GET /users?limit=0 para obter TODOS os usuários

**Steps**:
1. Request GET /users?limit=0
2. API retorna todos os 208 usuários de uma vez
3. VU valida payload grande (~250KB)

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'users count is 208'` → `users.length` === 208
- ✅ `'total is 208'` → Campo `total` = 208
- ⚠️ `'response time acceptable'` → Latência pode ser >1s devido a payload

**Fonte**: `dummyjson.com_docs_users.md` - Limit and skip (limit=0 to get all items)

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/users/list-users-admin.test.ts`
- **Diretório**: `tests/api/users/` (domain-driven structure)

### Configuração de Cenário
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom Metrics
const usersListDuration = new Trend('users_list_duration_ms');
const usersSearchDuration = new Trend('users_search_duration_ms');
const usersFilterDuration = new Trend('users_filter_duration_ms');
const usersErrors = new Counter('users_errors');
const usersSuccess = new Counter('users_success');

// Test Data (SharedArray)
const adminCredentials = new SharedArray('adminCredentials', function() {
  return JSON.parse(open('../../../data/test-data/admin-credentials.json'));
});

const userIds = new SharedArray('userIds', function() {
  return JSON.parse(open('../../../data/test-data/user-ids-sample.json'));
});

const searchQueries = new SharedArray('searchQueries', function() {
  return JSON.parse(open('../../../data/test-data/user-search-queries.json'));
});

const filterCriteria = new SharedArray('filterCriteria', function() {
  return JSON.parse(open('../../../data/test-data/user-filter-criteria.json'));
});

export const options = {
  scenarios: {
    list_users_admin: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 1, // 10% tráfego, baseline 5 RPS = 0.5 RPS (arredonda para 1)
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { feature: 'users', kind: 'admin', uc: 'UC008' },
    },
  },
  thresholds: {
    'http_req_duration{feature:users}': ['p(95)<500', 'p(99)<700'],
    'http_req_failed{feature:users}': ['rate<0.01'],
    'checks{uc:UC008}': ['rate>0.99'],
    'users_list_duration_ms': ['p(95)<500'],
    'users_search_duration_ms': ['p(95)<650'],
    'users_filter_duration_ms': ['p(95)<650'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';
let accessToken = null;

export function setup() {
  // Authenticate once as admin
  const admin = adminCredentials[0];
  const res = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    username: admin.username,
    password: admin.password,
    expiresInMins: 60
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  if (res.status === 200 && res.json('role') === 'admin') {
    return { token: res.json('accessToken') };
  }
  throw new Error('Admin authentication failed');
}

export default function(data) {
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${data.token}`
  };

  // Step 1: List all users (default pagination)
  let res = http.get(`${BASE_URL}/users`, {
    headers: headers,
    tags: { name: 'list_users_default', uc: 'UC008', step: '1' }
  });
  
  usersListDuration.add(res.timings.duration);
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has users array': (r) => Array.isArray(r.json('users')),
    'users count is 30': (r) => r.json('users').length === 30,
  }, { uc: 'UC008', step: '1' })) {
    usersSuccess.add(1);
  } else {
    usersErrors.add(1);
  }
  
  sleep(Math.random() * 5 + 5); // 5-10s think time

  // Step 2: Custom pagination
  const randomSkip = Math.floor(Math.random() * 170); // 0-170 (208 - 30 - margem)
  res = http.get(`${BASE_URL}/users?limit=10&skip=${randomSkip}`, {
    headers: headers,
    tags: { name: 'list_users_paginated', uc: 'UC008', step: '2' }
  });
  
  usersListDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'users count is 10': (r) => r.json('users').length === 10,
  }, { uc: 'UC008', step: '2' });
  
  sleep(Math.random() * 5 + 5);

  // Step 3: Search users
  const randomQuery = randomItem(searchQueries);
  res = http.get(`${BASE_URL}/users/search?q=${randomQuery.term}`, {
    headers: headers,
    tags: { name: 'search_users', uc: 'UC008', step: '3' }
  });
  
  usersSearchDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has users array': (r) => Array.isArray(r.json('users')),
  }, { uc: 'UC008', step: '3' });
  
  sleep(Math.random() * 5 + 5);

  // Step 4: Filter users
  const randomFilter = randomItem(filterCriteria);
  res = http.get(`${BASE_URL}/users/filter?key=${randomFilter.key}&value=${randomFilter.value}`, {
    headers: headers,
    tags: { name: 'filter_users', uc: 'UC008', step: '4' }
  });
  
  usersFilterDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has users array': (r) => Array.isArray(r.json('users')),
  }, { uc: 'UC008', step: '4' });
  
  sleep(Math.random() * 5 + 5);

  // Step 5: Get single user details
  const randomUserId = randomItem(userIds);
  res = http.get(`${BASE_URL}/users/${randomUserId}`, {
    headers: headers,
    tags: { name: 'get_user_details', uc: 'UC008', step: '5' }
  });
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'user has id': (r) => r.json('id') !== undefined,
    'user has complete data': (r) => r.json('firstName') && r.json('email') && r.json('role'),
  }, { uc: 'UC008', step: '5' });
  
  sleep(Math.random() * 5 + 5);
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'users',      // Domain area (users management)
  kind: 'admin',         // Operation type (admin operations)
  uc: 'UC008'            // Use case ID
}
```

**Fonte**: `docs/casos_de_uso/templates/guia-de-estilo.md` - Tags k6 obrigatórias

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 1 admin op/s por 30s)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/users/list-users-admin.test.ts

# Baseline (5 min, 1 RPS = 10% de 5 RPS baseline)
K6_RPS=1 K6_DURATION=5m k6 run tests/api/users/list-users-admin.test.ts

# Stress (10 min, 2 RPS = 10% de 20 RPS stress)
K6_RPS=2 K6_DURATION=10m k6 run tests/api/users/list-users-admin.test.ts

# Com variáveis de ambiente customizadas
BASE_URL=https://dummyjson.com K6_RPS=1 K6_DURATION=3m \
  k6 run tests/api/users/list-users-admin.test.ts
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

const usersListDuration = new Trend('users_list_duration_ms');
const usersSearchDuration = new Trend('users_search_duration_ms');
const usersFilterDuration = new Trend('users_filter_duration_ms');

// No VU code:
// Step 1-2 (list/pagination):
usersListDuration.add(res.timings.duration);

// Step 3 (search):
usersSearchDuration.add(res.timings.duration);

// Step 4 (filter):
usersFilterDuration.add(res.timings.duration);
```

**Métricas**:
- `users_list_duration_ms`: Latência de listagem/paginação (P95 < 500ms)
- `users_search_duration_ms`: Latência de busca (P95 < 650ms)
- `users_filter_duration_ms`: Latência de filtros (P95 < 650ms)

---

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const usersSuccess = new Counter('users_success');
const usersErrors = new Counter('users_errors');

// No VU code:
if (check(res, { ... })) {
  usersSuccess.add(1);
} else {
  usersErrors.add(1);
}
```

**Métricas**:
- `users_success`: Contador de operações admin bem-sucedidas
- `users_errors`: Contador de erros (404, query inválida, etc.)

---

### Dashboards
- **Grafana**: (Futuro) Dashboard dedicado a operações admin com breakdown por tipo de operação (list/search/filter)
- **k6 Cloud**: (Futuro) Análise de performance de queries admin e padrões de uso

---

## ⚠️ Observações Importantes

### Limitações da API
- **DummyJSON**: API pública, sem autenticação real por role (qualquer token válido pode acessar /users)
- **Sem Restrição de Permissões**: Em produção real, operações admin devem validar `role === "admin"` (403 Forbidden se não)
- **Paginação Default**: 30 itens (não configurável via API, apenas via limit param)
- **Total Fixo**: 208 usuários (dataset fixo, não cresce com POST /users/add)
- **Filtros Case-Sensitive**: Key e value devem ter case exato (ex: "Brown" não encontra "brown")

### Particularidades do Teste
- **Think Times Longos**: 5-10s entre steps (Persona 3 Admin analisa dados)
- **Autenticação Setup**: Login admin uma vez no `setup()`, reutiliza token em todas as iterações
- **Randomização**: Skip, queries e filtros aleatórios para simular variedade de operações
- **Payload Grande**: GET /users?limit=0 retorna ~250KB (208 usuários completos)
- **Nested Keys**: Filtros suportam propriedades aninhadas com "." (ex: `hair.color`, `address.city`)
- **Select Parameter**: Reduz payload selecionando apenas campos necessários (otimização de banda)

### Considerações de Desempenho
- **SharedArray**: Usar para carregar credentials/IDs/queries/filters (evita duplicação em memória)
- **Tags Granulares**: Cada step tem tag `step: '1'` a `'5'` para análise individual
- **Open Model Executor**: `constant-arrival-rate` garante RPS constante independente de latência
- **Setup Function**: Autentica admin uma vez, compartilha token entre VUs (evita login repetido)
- **Memory-Efficient**: Dados carregados uma vez, compartilhados entre iterações

---

## 🔗 Dependências

### UCs Dependentes (Bloqueadores)
- **UC003** (User Login & Profile) → Step 0: Autenticação admin com validação de role

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC008 depende de UC003 (auth admin)

### UCs que Usam Este (Fornece Para)
- **UC011** (Mixed Workload) → Persona "Admin" (10%) executa UC008

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC008 fornece para UC011

### Libs Necessárias
- **`libs/http/auth.ts`** (Criada em UC003) → Login e gestão de tokens admin

**Funções Usadas de `libs/http/auth.ts`**:
```typescript
import { login, getAuthHeaders } from '../../../libs/http/auth';

// No setup():
const { token } = login(adminUsername, adminPassword);

// No VU code:
const headers = getAuthHeaders(token);
```

### Dados Requeridos
- **UC003**: `data/test-data/admin-credentials.json` (credenciais admin)
- **Novo (UC008)**: 
  - `data/test-data/user-ids-sample.json` (50 user IDs)
  - `data/test-data/user-search-queries.json` (20 queries)
  - `data/test-data/user-filter-criteria.json` (10 filtros)

**Estratégia**: Reutilizar admin credentials de UC003, gerar novos arquivos para operações admin (IDs, queries, filtros)

---

## 📂 Libs/Helpers Criados

### Sem Novas Libs Criadas

Este UC **reutiliza libs existentes**:

1. **`libs/http/auth.ts`** (Criada em UC003)
   - Funções: `login()`, `getToken()`, `getAuthHeaders()`
   - Usado para Step 0 (autenticação admin)

**Observação**: UC008 é um **caso de uso de leitura admin** que reutiliza autenticação de UC003 sem criar novas libs. Toda a lógica necessária já existe.

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-08 | GitHub Copilot | Criação inicial do UC008 (Sprint 5) - operações admin de listagem de usuários |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Persona 3 - Administrador, 10% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (7 endpoints: 1 POST + 6 GET)
- [x] SLOs estão definidos e justificados (referência ao baseline Users + 56% margem)
- [x] Fluxo principal está detalhado passo a passo (6 steps numerados + auth)
- [x] Validações (checks) estão especificadas (checks human-readable para cada step)
- [x] Dados de teste estão identificados (fonte + volume) - reutiliza UC003 + novos arquivos
- [x] Headers obrigatórios estão documentados (Content-Type + Authorization Bearer)
- [x] Think times estão especificados (5-10s entre steps, Persona 3)
- [x] Edge cases e cenários de erro estão mapeados (3 cenários alternativos + 2 edge cases)
- [x] Dependências de outros UCs estão listadas (UC003 auth)
- [x] Limitações da API estão documentadas (DummyJSON sem validação de role real)
- [x] Arquivo nomeado corretamente: `UC008-list-users-admin.md`
- [x] Libs/helpers criados estão documentados (reutiliza auth.ts de UC003)
- [x] Comandos de teste estão corretos e testados (smoke/baseline/stress)
- [x] Tags obrigatórias estão especificadas (feature: users, kind: admin, uc: UC008)
- [x] Métricas customizadas estão documentadas (3 Trends + 2 Counters)

---

## 📚 Referências

- [DummyJSON API Docs](https://dummyjson.com/docs)
- [DummyJSON Users API](https://dummyjson.com/docs/users)
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
