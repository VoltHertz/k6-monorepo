# UC003 - User Login & Profile

> **Status**: ✅ Approved  
> **Prioridade**: P1 (Importante)  
> **Complexidade**: 2 (Simples)  
> **Sprint**: Sprint 2 (Semana 5)  
> **Esforço Estimado**: 6h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Comprador Autenticado (Persona 2: 30% do tráfego) + Administrador/Moderador (Persona 3: 10% do tráfego)
- **Distribuição de Tráfego**: 40% do total (30% Comprador + 10% Admin/Moderador)
- **Objetivo de Negócio**: Realizar login na plataforma e acessar recursos protegidos que requerem autenticação (carrinho, perfil, administração)

### Contexto
Usuário possui credenciais válidas (username/password) obtidas durante cadastro prévio e deseja se autenticar na API para acessar funcionalidades restritas. Este caso de uso é o **gateway obrigatório** para todos os fluxos autenticados da aplicação, sendo executado no início de cada sessão autenticada. Após login bem-sucedido, usuário recebe JWT token que será usado em todas as requisições subsequentes que requerem autenticação.

### Valor de Negócio
- **Criticidade**: Crítico (4/5) - Base para 40% do tráfego total (todas personas autenticadas)
- **Impacto**: Bloqueador para 8 casos de uso dependentes (UC005, UC006, UC008, UC010, UC012, UC013, UC011)
- **Segurança**: Implementa autenticação JWT para proteção de recursos sensíveis
- **Conversão**: Habilita ações de compra (carrinho), administração e moderação de conteúdo
- **Quadrante na Matriz**: ✅ **PRIORIDADE MÁXIMA** (Alta criticidade, Baixa complexidade)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 2 (Comprador: 30%) e Persona 3 (Admin: 10%)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| POST | `/auth/login` | P95 < 400ms | Gera JWT accessToken e refreshToken, credenciais de /users |
| GET | `/auth/me` | P95 < 300ms | Requer Bearer token no header Authorization |

**Total de Endpoints**: 2  
**Operações READ**: 1 (GET /auth/me)  
**Operações WRITE**: 1 (POST /auth/login)  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Linhas 11-12 (Auth/POST /auth/login, Auth/GET /auth/me)  

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:auth}` (P95) | < 400ms | Baseline Fase 1: POST /auth/login P95 real = 380ms. Margem conservadora para geração de JWT |
| `http_req_duration{feature:auth}` (P99) | < 600ms | Baseline Fase 1: P99 real = 480ms. Margem de segurança para operações de autenticação |
| `http_req_failed{feature:auth}` | < 1% | Tolerância para credenciais inválidas (401) esperados em cenários reais de teste |
| `checks{uc:UC003}` | > 99% | Validações críticas de token e perfil devem passar. Permite 1% falhas temporárias |
| `auth_login_duration_ms` (P95) | < 400ms | Métrica customizada específica da operação de login |
| `auth_login_success` (count) | > 0 | Garantir que logins bem-sucedidos ocorrem durante o teste |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (Auth Operations)  
**Medição Original**: POST /auth/login - P50=250ms, P95=380ms, P99=480ms, Max=650ms, Error Rate=0%  
**Medição Original**: GET /auth/me - P50=180ms, P95=280ms, P99=360ms, Max=450ms, Error Rate=0%

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `users-credentials.csv` | `data/test-data/` | 50 usuários (role: user) | Extração de `data/fulldummyjsondata/users.json` | Mensal ou quando DummyJSON atualizar |
| `admin-credentials.json` | `data/test-data/` | 5 admins (role: admin) | Filtrado de `fulldummyjsondata/users.json` por `role` | Mensal |
| `moderator-credentials.json` | `data/test-data/` | 3 moderadores (role: moderator) | Filtrado de `fulldummyjsondata/users.json` por `role` | Mensal |

### Estrutura de `users-credentials.csv`
```csv
id,username,password,email,firstName,lastName,role,gender,age
1,emilys,emilyspass,emily.johnson@x.dummyjson.com,Emily,Johnson,admin,female,28
2,michaelw,michaelwpass,michael.williams@x.dummyjson.com,Michael,Williams,user,male,35
3,sophiab,sophiabpass,sophia.brown@x.dummyjson.com,Sophia,Brown,user,female,42
```

### Estrutura de `admin-credentials.json`
```json
[
  {
    "id": 1,
    "username": "emilys",
    "password": "emilyspass",
    "email": "emily.johnson@x.dummyjson.com",
    "firstName": "Emily",
    "lastName": "Johnson",
    "role": "admin",
    "gender": "female",
    "age": 28
  }
]
```

### Estrutura de `moderator-credentials.json`
```json
[
  {
    "id": 10,
    "username": "moderator1",
    "password": "moderator1pass",
    "email": "moderator@x.dummyjson.com",
    "firstName": "Mod",
    "lastName": "Erator",
    "role": "moderator",
    "gender": "male",
    "age": 30
  }
]
```

### Geração de Dados
```bash
# Gerar arquivo CSV com credenciais de usuários comuns (role: user)
jq -r '.users[] | select(.role == "user" or .role == "admin") | [.id, .username, .password, .email, .firstName, .lastName, .role, .gender, .age] | @csv' \
  data/fulldummyjsondata/users.json | head -50 > data/test-data/users-credentials.csv

# Adicionar header ao CSV
sed -i '1i id,username,password,email,firstName,lastName,role,gender,age' data/test-data/users-credentials.csv

# Gerar arquivo JSON com admins (role === 'admin')
jq '[.users[] | select(.role == "admin")]' \
  data/fulldummyjsondata/users.json > data/test-data/admin-credentials.json

# Gerar arquivo JSON com moderadores (role === 'moderator')
jq '[.users[] | select(.role == "moderator")]' \
  data/fulldummyjsondata/users.json > data/test-data/moderator-credentials.json

# Validar estrutura dos arquivos gerados
wc -l data/test-data/users-credentials.csv
jq 'length' data/test-data/admin-credentials.json
jq 'length' data/test-data/moderator-credentials.json
```

### Dependências de Dados
- **Nenhuma** - UC Tier 1 independente (não requer dados de outros UCs)
- **Fornece para**: UC005, UC006, UC008, UC010, UC012, UC013, UC011 (todos UCs que requerem autenticação)
- Dados autocontidos extraídos de `fulldummyjsondata/users.json`

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC003 listado como Tier 1 (fornece auth para 8 UCs)

### Formato Esperado

**users-credentials.csv**: (header obrigatório)
```csv
id,username,password,email,firstName,lastName,role
1,emilys,emilyspass,emily.johnson@x.dummyjson.com,Emily,Johnson,admin
2,michaelw,michaelwpass,michael.williams@x.dummyjson.com,Michael,Williams,user
```

**admin-credentials.json**:
```json
[
  {
    "id": 1,
    "username": "emilys",
    "password": "emilyspass",
    "role": "admin",
    "email": "emily.johnson@x.dummyjson.com"
  }
]
```

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário possui credenciais válidas (username e password)
- API DummyJSON disponível e acessível
- Usuário ainda **não** está autenticado (sem token)

### Steps

**Step 1: Login (Autenticação)**  
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
- ✅ `'has access token'` → Response contains `accessToken` (JWT string)
- ✅ `'has refresh token'` → Response contains `refreshToken` (JWT string)
- ✅ `'has user data'` → Response contains `id`, `username`, `email`, `firstName`, `lastName`
- ✅ `'token is valid JWT'` → `accessToken` matches JWT format (3 partes separadas por ponto)

**Think Time**: 3-7s (transição pós-login conforme Persona 2)

**Fonte Think Time**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Fluxo 2 (Comprador): 3-7s entre ações

---

**Step 2: Verificar Perfil (Validação de Token)**  
```http
GET /auth/me
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'user id matches'` → Response contains `id` matching login response
- ✅ `'username matches'` → Response contains `username` matching login credentials
- ✅ `'has profile data'` → Response contains `email`, `firstName`, `lastName`, `gender`, `image`
- ✅ `'no password field'` → Response **does NOT** contain `password` (validação de segurança)

**Think Time**: 3-7s (decisão de ação - usuário procede com navegação ou gerenciamento de carrinho)

**Fonte Think Time**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Fluxo 2 (Comprador): 3-7s think time

---

### Pós-condições
- Usuário possui `accessToken` válido (JWT) armazenado em variável/contexto
- Usuário possui `refreshToken` para renovação de sessão (ver UC012)
- Token pode ser usado em requests subsequentes via header `Authorization: Bearer ${token}`
- Sessão ativa por 60 minutos (padrão DummyJSON - configurável via `expiresInMins`)
- Dados do perfil (id, username, email) disponíveis para uso em próximos steps

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Credenciais Inválidas
**Condição**: Username ou password incorretos

**Steps**:
1. POST /auth/login com credenciais inválidas
   ```json
   {
     "username": "invalid_user",
     "password": "wrong_pass"
   }
   ```
2. Recebe 400 Bad Request ou 401 Unauthorized
3. Response contém mensagem de erro

**Validações**:
- ✅ `'status is 400 or 401'` → Status code = 400 Bad Request ou 401 Unauthorized
- ✅ `'has error message'` → Response contains `message` field com descrição do erro

---

### Cenário de Erro 2: Token Inválido ou Expirado
**Condição**: GET /auth/me com token inválido/expirado

**Steps**:
1. GET /auth/me com `Authorization: Bearer invalid_or_expired_token`
2. Recebe 401 Unauthorized
3. Response contém erro de autenticação

**Validações**:
- ✅ `'status is 401'` → Status code = 401 Unauthorized
- ✅ `'token error message'` → Response contains error message sobre token inválido/expirado

**Ação de Recuperação**: 
- Usar UC012 (Token Refresh) para renovar token
- Ou realizar novo login (Step 1)

---

### Cenário de Erro 3: Missing Authorization Header
**Condição**: GET /auth/me sem header Authorization

**Steps**:
1. GET /auth/me **sem** header `Authorization`
2. Recebe 401 Unauthorized ou 403 Forbidden
3. Response indica falta de autenticação

**Validações**:
- ✅ `'status is 401 or 403'` → Status code = 401 Unauthorized ou 403 Forbidden
- ✅ `'missing auth message'` → Response indica "missing token" ou "unauthorized"

---

### Edge Case 1: Login com expiresInMins Customizado
**Condição**: Configurar tempo de expiração customizado (ex: 30 min ao invés de 60 min)

**Steps**:
1. POST /auth/login com `"expiresInMins": 30`
2. Validar que token expira em ~30 minutos
3. (Opcional) Decodificar JWT e verificar claim `exp`

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'token returned'` → Token retornado válido
- ✅ `'jwt exp claim correct'` → (Opcional) JWT claim `exp` está correto (decodificar token)

---

### Edge Case 2: Múltiplos Logins Sequenciais
**Condição**: Mesmo usuário faz login múltiplas vezes

**Steps**:
1. Login #1 → recebe accessToken1
2. Login #2 (mesmo user) → recebe accessToken2
3. Validar que ambos tokens funcionam (se dentro do prazo)

**Validações**:
- ✅ `'both logins succeed'` → Ambos logins retornam status 200
- ✅ `'tokens are different'` → Tokens diferentes gerados (novos JWTs)
- ✅ `'both tokens valid'` → Ambos tokens funcionam em GET /auth/me (se não expirados)

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/auth/user-login-profile.test.ts`
- **Libs Criadas**: 
  - `libs/http/auth.ts` (funções de autenticação reutilizáveis)
  - `libs/data/user-loader.ts` (carrega credenciais via SharedArray)

### Configuração de Cenário
```javascript
export const options = {
  scenarios: {
    user_login_profile: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 3,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { feature: 'auth', kind: 'login', uc: 'UC003' },
    },
  },
  thresholds: {
    'http_req_duration{feature:auth}': ['p(95)<400', 'p(99)<600'],
    'http_req_failed{feature:auth}': ['rate<0.01'],
    'checks{uc:UC003}': ['rate>0.99'],
    'auth_login_duration_ms': ['p(95)<400'],
    'auth_login_success': ['count>0'],
  },
};
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'auth',    // Domain area
  kind: 'login',      // Operation type
  uc: 'UC003'         // Use case ID
}
```

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida, 30s, 1 RPS)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/auth/user-login-profile.test.ts

# Baseline (5 min, 3 RPS - 30% do tráfego auth)
K6_RPS=3 K6_DURATION=5m k6 run tests/api/auth/user-login-profile.test.ts

# Stress (10 min, 10 RPS - pico de login)
K6_RPS=10 K6_DURATION=10m k6 run tests/api/auth/user-login-profile.test.ts

# Com variáveis de ambiente customizadas
BASE_URL=https://dummyjson.com K6_RPS=5 k6 run tests/api/auth/user-login-profile.test.ts
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

const authLoginDuration = new Trend('auth_login_duration_ms');
const authProfileDuration = new Trend('auth_profile_duration_ms');

// No VU code:
// Step 1: Login
const loginRes = http.post(/* ... */);
authLoginDuration.add(loginRes.timings.duration);

// Step 2: Profile
const profileRes = http.get(/* ... */);
authProfileDuration.add(profileRes.timings.duration);
```

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const authLoginSuccess = new Counter('auth_login_success');
const authLoginErrors = new Counter('auth_login_errors');
const authProfileSuccess = new Counter('auth_profile_success');
const authTokenInvalid = new Counter('auth_token_invalid');

// No VU code:
if (loginRes.status === 200) {
  authLoginSuccess.add(1);
} else {
  authLoginErrors.add(1);
}

if (profileRes.status === 401) {
  authTokenInvalid.add(1);
}
```

### Dashboards
- **Grafana**: Dashboard "Auth Operations" com métricas de login/profile
- **k6 Cloud**: Projeto "DummyJSON Auth" (se disponível)

---

## ⚠️ Observações Importantes

### Limitações da API
- **JWT Tokens**: DummyJSON retorna JWTs válidos mas simplificados (não há backend real de auth)
- **Token Expiration**: `expiresInMins` é respeitado na geração do token, mas validação de expiração pode não ser rigorosa
- **Cookies**: DummyJSON retorna tokens em cookies (`credentials: 'include'`), mas k6 não suporta cookies por padrão - **usar apenas Bearer token no header**
- **Refresh Token**: POST /auth/refresh está documentado mas não será testado neste UC (ver UC012)

### Particularidades do Teste
- **Credenciais**: Usar apenas usuários do arquivo `users.json` (DummyJSON não persiste novos usuários)
- **Role-Based**: Alguns usuários têm `role: "admin"` ou `role: "moderator"` - importante para UC008 e UC013
- **SharedArray**: Carregar credenciais via `SharedArray` para evitar duplicação de dados em memória (múltiplos VUs)
- **Token Storage**: Não há estado persistente entre iterações - cada iteração deve fazer login novamente (ou reusar token da mesma iteração)

### Considerações de Desempenho
- **Think Time**: 1s entre login e profile é curto (automação), 3-7s após profile é realista (usuário navega)
- **RPS**: 3 RPS baseline reflete 30% do tráfego total (Persona 2: Comprador Autenticado)
- **VUs**: `preAllocatedVUs: 5` suficiente para 3 RPS, `maxVUs: 20` para picos de 10 RPS

---

## 🔗 Dependências

### UCs Bloqueadores (Dependências)
- **Nenhuma** ✅ - Este UC é Tier 1 e não depende de outros UCs
- UC independente, pode ser implementado sem pré-requisitos

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC003 listado como Tier 1 sem dependências

### UCs Dependentes (Fornece Para)
- **UC005** - Cart Operations (Read): Requer token para GET /carts/user/{userId}
- **UC006** - Cart Operations (Write): Requer token para POST/PUT/DELETE /carts
- **UC008** - List Users (Admin): Requer token de admin (role: admin)
- **UC010** - User Journey (Authenticated): Integra login no fluxo de jornada autenticada
- **UC012** - Token Refresh: Depende de refreshToken gerado neste UC
- **UC013** - Content Moderation: Requer token de moderador (role: moderator)
- **UC011** - Mixed Workload: Usa auth para 40% do tráfego (Comprador + Admin)

**Total**: 7 UCs dependentes diretos

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC003 fornece `libs/http/auth.ts` para todos UCs Tier 1+

### Libs Necessárias
- **k6 built-ins**: `http`, `check`, `sleep`
- **k6 metrics**: `Trend`, `Counter` (para métricas customizadas)
- **k6 data**: `SharedArray` (para carregar credenciais)

### Dados Requeridos
- **Nenhuma dependência externa** - dados gerados de `fulldummyjsondata/users.json`

---

## 📂 Libs/Helpers Criados

### `libs/http/auth.ts`
**Descrição**: Helper de autenticação reutilizável para todos os testes que requerem login

**Funções Exportadas**:
```typescript
import http from 'k6/http';

export interface LoginResponse {
  id: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  gender: string;
  image: string;
  accessToken: string;
  refreshToken: string;
}

/**
 * Realiza login e retorna tokens
 * @param username - Username do usuário
 * @param password - Senha do usuário
 * @param expiresInMins - Tempo de expiração do token (padrão: 60)
 * @returns LoginResponse com tokens e dados do usuário
 */
export function login(
  username: string, 
  password: string, 
  expiresInMins: number = 60
): LoginResponse {
  const baseUrl = __ENV.BASE_URL || 'https://dummyjson.com';
  const res = http.post(`${baseUrl}/auth/login`, JSON.stringify({
    username,
    password,
    expiresInMins,
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'auth_login' },
  });
  
  return res.json() as LoginResponse;
}

/**
 * Retorna headers de autenticação com Bearer token
 * @param token - JWT accessToken
 * @returns Object com header Authorization
 */
export function getAuthHeaders(token: string): { [key: string]: string } {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  };
}

/**
 * Valida se token está no formato JWT (3 partes separadas por ponto)
 * @param token - Token a validar
 * @returns true se formato válido
 */
export function isValidJWT(token: string): boolean {
  return typeof token === 'string' && token.split('.').length === 3;
}
```

**Uso**:
```typescript
import { login, getAuthHeaders } from '../../../libs/http/auth';

// No VU code:
const loginData = login('emilys', 'emilyspass');
const headers = getAuthHeaders(loginData.accessToken);

const profileRes = http.get(`${BASE_URL}/auth/me`, { headers });
```

---

### `libs/data/user-loader.ts`
**Descrição**: Carrega credenciais de usuários via SharedArray (memory-efficient)

**Funções Exportadas**:
```typescript
import { SharedArray } from 'k6/data';

export interface UserCredentials {
  id: number;
  username: string;
  password: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

/**
 * SharedArray de credenciais de usuários
 */
export const users = new SharedArray('users', function() {
  const data = open('../../../data/test-data/users-credentials.csv');
  return papaparse.parse(data, { header: true }).data as UserCredentials[];
});

/**
 * Retorna um usuário aleatório
 * @param role - Filtrar por role (opcional: 'admin', 'moderator', 'user')
 * @returns UserCredentials aleatório
 */
export function getRandomUser(role?: string): UserCredentials {
  const filtered = role 
    ? users.filter(u => u.role === role)
    : users;
  
  return filtered[Math.floor(Math.random() * filtered.length)];
}

/**
 * Retorna usuário por ID
 * @param id - ID do usuário
 * @returns UserCredentials ou undefined
 */
export function getUserById(id: number): UserCredentials | undefined {
  return users.find(u => u.id === id);
}
```

**Uso**:
```typescript
import { getRandomUser } from '../../../libs/data/user-loader';
import { login } from '../../../libs/http/auth';

// No VU code:
const user = getRandomUser(); // ou getRandomUser('admin')
const loginData = login(user.username, user.password);
```

**Dependências**:
- `papaparse` (remote module): `https://jslib.k6.io/papaparse/5.1.1/index.js`

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-03 | GitHub Copilot | Criação inicial do UC003 (Sprint 2) |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Comprador/Admin, 40% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (POST /auth/login, GET /auth/me)
- [x] SLOs estão definidos e justificados (P95 < 400ms baseado em baseline)
- [x] Fluxo principal está detalhado passo a passo (Login → Verificar Perfil)
- [x] Validações (checks) estão especificadas (status, tokens, campos)
- [x] Dados de teste estão identificados (users-credentials.csv, admin/moderator JSONs)
- [x] Headers obrigatórios estão documentados (Content-Type, Authorization)
- [x] Think times estão especificados (1s, 3-7s conforme perfil)
- [x] Edge cases e cenários de erro estão mapeados (credenciais inválidas, token expirado, missing header)
- [x] Dependências de outros UCs estão listadas (Nenhuma, mas fornece para 8 UCs)
- [x] Limitações da API (JWT simplificado, cookies não suportados em k6) estão documentadas
- [x] Arquivo nomeado corretamente: `UC003-user-login-profile.md`
- [x] Libs/helpers criados estão documentados (`auth.ts`, `user-loader.ts`)
- [x] Comandos de teste estão corretos e testados (smoke, baseline, stress)
- [x] Tags obrigatórias estão especificadas (feature: auth, kind: login, uc: UC003)
- [x] Métricas customizadas estão documentadas (auth_login_duration_ms, auth_login_success, etc.)

---

## 📚 Referências

- [DummyJSON Auth API](https://dummyjson.com/docs/auth)
- [DummyJSON Users API](https://dummyjson.com/docs/users)
- [k6 HTTP Module](https://grafana.com/docs/k6/latest/javascript-api/k6-http/)
- [k6 Checks](https://grafana.com/docs/k6/latest/using-k6/checks/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md` (Auth Operations)
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md` (Persona 2: Comprador Autenticado)
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md` (UC003 - P1, Complexidade 2)
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md` (UC003 - Tier 1, bloqueador de 8 UCs)
- Template de UC: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`
- Checklist de Qualidade: `docs/casos_de_uso/templates/checklist-qualidade.md`
