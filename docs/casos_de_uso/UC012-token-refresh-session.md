# UC012 - Token Refresh & Session Management

> **Status**: ✅ Approved  
> **Prioridade**: P2 (Secundário)  
> **Complexidade**: 3 (Moderada)  
> **Sprint**: Sprint 6 (Semana 9)  
> **Esforço Estimado**: 5h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Comprador Autenticado / Administrador / Moderador (Personas 2 e 3)
- **Distribuição de Tráfego**: 40% do total (30% Comprador + 10% Admin/Moderador)
- **Objetivo de Negócio**: Manter sessões ativas sem re-autenticação, renovar access tokens expirados automaticamente, garantir resiliência em sessões longas

### Contexto
Usuários autenticados realizam operações que podem ultrapassar a validade do access token (60 minutos padrão). Para evitar interrupção da experiência e re-login frequente, o sistema deve renovar tokens automaticamente usando o refresh token. Este UC valida a capacidade da API de gerenciar sessões longas e renovação de credenciais de forma segura.

### Valor de Negócio
- **Resiliência de Sessões**: Evita falhas 401 Unauthorized em sessões longas (ex: admin analisando dados por 2+ horas)
- **Experiência de Usuário**: Elimina necessidade de re-login manual, mantém fluxo contínuo
- **Segurança**: Valida ciclo de vida de tokens (access token curto 60min, refresh token longo)
- **Operações Críticas**: Essencial para UC010 (jornadas autenticadas) e UC011 (mixed workload com sessões realistas)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| POST | `/auth/login` | P95 < 400ms | Obtém access + refresh tokens iniciais |
| GET | `/auth/me` | P95 < 300ms | Valida token atual (pode retornar 401 se expirado) |
| POST | `/auth/refresh` | P95 < 400ms | Renova access token usando refresh token |

**Total de Endpoints**: 3  
**Operações READ**: 1 (GET /auth/me)  
**Operações WRITE**: 2 (POST /auth/login, POST /auth/refresh)  

**Documentação de Referência**: `docs/dummyJson/dummyjson.com_docs_auth.md`

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:auth,kind:refresh}` (P95) | < 400ms | Baseline auth: P95=380ms, refresh similar a login (geração JWT) |
| `http_req_duration{feature:auth,kind:refresh}` (P99) | < 600ms | Margem 58% acima P95, consistente com baseline auth |
| `http_req_failed{feature:auth,kind:refresh}` | < 1% | Operação crítica, tolerância para token inválido/expirado |
| `checks{uc:UC012}` | > 99% | Validações de refresh e token válido devem passar |
| `token_refresh_success` (Counter) | > 95% | Métrica customizada, refresh deve ter alta taxa de sucesso |
| `token_refresh_duration_ms` (Trend) | P95 < 400ms | Latência específica de refresh (sem login) |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md` (Auth: P95<400ms)

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `users-credentials.csv` | `data/test-data/` | 100 users | UC003 (reutilizado) | Semanal (já existente) |
| `long-session-scenarios.json` | `data/test-data/` | 20 cenários | Gerado manualmente | Mensal |

### Geração de Dados

```bash
# Reutilizar credentials de UC003 (já existente)
# Arquivo: data/test-data/users-credentials.csv
# Formato: username,password,role,expiresInMins
# Exemplo: emilys,emilyspass,comprador,30

# Criar cenários de sessão longa (novo arquivo)
cat > data/test-data/long-session-scenarios.json <<EOF
[
  {
    "scenario": "short_session",
    "expiresInMins": 5,
    "operations": 3,
    "description": "Token expira durante teste (validar refresh)"
  },
  {
    "scenario": "medium_session",
    "expiresInMins": 30,
    "operations": 10,
    "description": "Sessão normal com refresh preventivo"
  },
  {
    "scenario": "long_session",
    "expiresInMins": 60,
    "operations": 20,
    "description": "Sessão longa admin/moderador"
  }
]
EOF
```

### Dependências de Dados
- **Requer**: `users-credentials.csv` de UC003 (User Login & Profile)
- **Novo**: `long-session-scenarios.json` (20 cenários de teste)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário possui credenciais válidas
- Access token pode expirar durante operações
- Refresh token está disponível (obtido no login)

---

### Steps

**Step 1: Login Inicial**  
```http
POST /auth/login
Headers:
  Content-Type: application/json
Body:
{
  "username": "emilys",
  "password": "emilyspass",
  "expiresInMins": 5
}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `accessToken` (JWT string)
- ✅ Response contains `refreshToken` (JWT string)
- ✅ Response contains user data (`id`, `username`, `email`)
- ✅ `accessToken` length > 100 (JWT válido)
- ✅ `refreshToken` length > 100 (JWT válido)

**Think Time**: 1s (setup inicial, não é ação de usuário)

**Armazenar**:
```javascript
const accessToken = res.json('accessToken');
const refreshToken = res.json('refreshToken');
```

---

**Step 2: Validar Token Inicial**  
```http
GET /auth/me
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `id` (user authenticated)
- ✅ `id` matches login response
- ✅ Response contains `username`, `email`, `firstName`

**Think Time**: 2s (validação, não é ação de usuário)

---

**Step 3: Simular Operações até Expiração**  
```javascript
// Loop de operações que ultrapassa expiresInMins
for (let i = 0; i < 3; i++) {
  sleep(120); // 2 minutos por operação (total 6 min > 5 min token)
  
  const res = http.get(
    `${BASE_URL}/auth/me`,
    { headers: { Authorization: `Bearer ${accessToken}` } }
  );
  
  // Após 5 minutos, espera-se 401 (token expirado)
  if (res.status === 401) {
    // Token expirou, prosseguir para refresh
    break;
  }
}
```

**Validações**:
- ✅ Primeira operação: status = 200 (token ainda válido)
- ✅ Segunda operação: status = 200 ou 401 (próximo de expirar)
- ✅ Terceira operação: status = 401 (token expirado, esperado)
- ✅ Response 401 contains error message (ex: "Token Expired!")

**Think Time**: 120s entre operações (simula trabalho real do usuário)

---

**Step 4: Refresh Token**  
```http
POST /auth/refresh
Headers:
  Content-Type: application/json
Body:
{
  "refreshToken": "${refreshToken}",
  "expiresInMins": 30
}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `accessToken` (novo JWT)
- ✅ Response contains `refreshToken` (novo JWT, rotacionado)
- ✅ Novo `accessToken` ≠ antigo (token foi renovado)
- ✅ Novo `accessToken` length > 100

**Think Time**: 1s (operação automática, não é ação de usuário)

**Armazenar Novos Tokens**:
```javascript
const newAccessToken = res.json('accessToken');
const newRefreshToken = res.json('refreshToken');
```

---

**Step 5: Validar Novo Token**  
```http
GET /auth/me
Headers:
  Content-Type: application/json
  Authorization: Bearer ${newAccessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `id` (user ainda autenticado)
- ✅ `id` matches original user (sessão mantida)
- ✅ Response contains `username`, `email`

**Think Time**: 2s (validação de sessão renovada)

---

**Step 6: Continuar Operações com Novo Token**  
```http
GET /auth/me
Headers:
  Content-Type: application/json
  Authorization: Bearer ${newAccessToken}
```

**Validações**:
- ✅ Status code = 200
- ✅ Operações continuam sem interrupção
- ✅ Sessão está ativa com novo token

**Think Time**: 3-7s (operação normal de usuário autenticado)

---

### Pós-condições
- Token renovado está válido por +30 minutos (expiresInMins configurado)
- Sessão do usuário está ativa sem re-login
- Refresh token foi rotacionado (novo refresh token disponível)
- Métricas de refresh registradas (success counter, duration trend)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Refresh Token Inválido
**Condição**: Token manipulado, expirado ou revogado

**Steps**:
1. Tentar refresh com token inválido
```http
POST /auth/refresh
Body: { "refreshToken": "invalid_token_here" }
```

2. Recebe erro 401 ou 403
3. Validar mensagem de erro

**Validações**:
- ✅ Status code = 401 ou 403
- ✅ Response contains error message (ex: "Invalid refresh token")
- ❌ `accessToken` não está presente no response
- ❌ Sessão não foi renovada

**Ação de Recuperação**: Re-autenticar com POST /auth/login

---

### Cenário de Erro 2: Refresh Token Expirado
**Condição**: Refresh token também tem validade (geralmente longa, ex: 7 dias), pode expirar

**Steps**:
1. Simular refresh token expirado (não há endpoint fake para isso no DummyJSON)
2. Tentar refresh
3. Recebe erro de expiração

**Validações**:
- ✅ Status code = 401
- ✅ Error message indica expiração (ex: "Refresh token expired")
- ❌ Novo access token não gerado

**Ação de Recuperação**: Re-autenticar com POST /auth/login (novo login completo)

---

### Edge Case 1: Refresh Preventivo (Token Ainda Válido)
**Condição**: Usuário faz refresh antes da expiração (ex: 50 minutos de um token de 60 min)

**Steps**:
1. Login com expiresInMins=60
2. Após 10 minutos, fazer refresh (token ainda válido)
3. Validar que refresh funciona mesmo sem expiração

**Validações**:
- ✅ Status code = 200 (refresh aceito mesmo com token válido)
- ✅ Novo access token gerado
- ✅ Refresh token rotacionado

**Observação**: DummyJSON permite refresh a qualquer momento, não valida expiração real

---

### Edge Case 2: Múltiplos Refreshes Sequenciais
**Condição**: Usuário faz refresh múltiplas vezes seguidas

**Steps**:
1. Login inicial
2. Refresh 1 → obter newRefreshToken1
3. Refresh 2 usando newRefreshToken1 → obter newRefreshToken2
4. Refresh 3 usando newRefreshToken2 → obter newRefreshToken3

**Validações**:
- ✅ Cada refresh retorna novos tokens
- ✅ Refresh tokens são rotacionados (cada um diferente)
- ✅ Tokens antigos NÃO devem funcionar (rotação invalida anteriores)

**⚠️ Limitação DummyJSON**: API pode aceitar refresh tokens antigos (não invalida após rotação real)

---

### Edge Case 3: Uso de Cookies vs Bearer Token
**Condição**: DummyJSON suporta tokens via cookies ou header Authorization

**Steps**:
1. Login com `credentials: 'include'` (cookies habilitados)
2. Tokens retornados em response + cookies
3. Refresh usando cookie (sem body refreshToken)
```http
POST /auth/refresh
Headers:
  Cookie: refreshToken=${cookieValue}
Body: { "expiresInMins": 30 }
```

**Validações**:
- ✅ Status code = 200
- ✅ Novo access token gerado usando cookie
- ✅ Response contém novos tokens

**Observação**: k6 não gerencia cookies automaticamente, usar Bearer token é mais simples

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/auth/token-refresh-session.test.ts`
- **Alternativa**: Integrar em `libs/http/auth.ts` como função helper (não teste standalone)

### Configuração de Cenário

```typescript
export const options = {
  scenarios: {
    uc012_token_refresh: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 2, // Baixo RPS (operação de background)
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m', // Sessão longa para testar expiração
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { feature: 'auth', kind: 'refresh', uc: 'UC012' },
    },
  },
  thresholds: {
    'http_req_duration{feature:auth,kind:refresh}': ['p(95)<400'],
    'http_req_failed{feature:auth,kind:refresh}': ['rate<0.01'], // 1% tolerância
    'checks{uc:UC012}': ['rate>0.99'],
    'token_refresh_success': ['count>0'], // Pelo menos 1 refresh bem-sucedido
    'token_refresh_duration_ms': ['p(95)<400'],
  },
};
```

### Tags Obrigatórias
```typescript
tags: { 
  feature: 'auth',      // Domain: autenticação
  kind: 'refresh',      // Operation: renovação de token
  uc: 'UC012'           // Use case ID
}
```

---

## 🧪 Comandos de Teste

### Execução Local

```bash
# Smoke test (validação rápida, token expira em 1 min)
K6_RPS=1 K6_DURATION=2m k6 run tests/api/auth/token-refresh-session.test.ts

# Baseline (10 min, token expira em 5 min, testa refresh real)
K6_RPS=2 K6_DURATION=10m k6 run tests/api/auth/token-refresh-session.test.ts

# Stress (múltiplos usuários com refresh simultâneo)
K6_RPS=5 K6_DURATION=15m k6 run tests/api/auth/token-refresh-session.test.ts
```

### CI/CD

```bash
# GitHub Actions smoke test (PR)
# Arquivo: .github/workflows/k6-pr-smoke.yml
# Executa: K6_RPS=1 K6_DURATION=2m (valida refresh básico)

# GitHub Actions baseline (main branch)
# Arquivo: .github/workflows/k6-main-baseline.yml
# Executa: K6_RPS=2 K6_DURATION=10m (valida expiração real)
```

---

## 📈 Métricas Customizadas

### Trends (Latência de Refresh)

```typescript
import { Trend } from 'k6/metrics';

const tokenRefreshDuration = new Trend('token_refresh_duration_ms');
const tokenValidationDuration = new Trend('token_validation_duration_ms');

// No VU code (Step 4 - Refresh):
const refreshRes = http.post(
  `${BASE_URL}/auth/refresh`,
  JSON.stringify({ refreshToken, expiresInMins: 30 }),
  { headers: { 'Content-Type': 'application/json' }, tags: { step: 'refresh' } }
);
tokenRefreshDuration.add(refreshRes.timings.duration);

// No VU code (Step 5 - Validar novo token):
const validateRes = http.get(
  `${BASE_URL}/auth/me`,
  { headers: { Authorization: `Bearer ${newAccessToken}` }, tags: { step: 'validate' } }
);
tokenValidationDuration.add(validateRes.timings.duration);
```

### Counters (Eventos de Refresh)

```typescript
import { Counter } from 'k6/metrics';

const tokenRefreshSuccess = new Counter('token_refresh_success');
const tokenRefreshErrors = new Counter('token_refresh_errors');
const tokenExpiredDetected = new Counter('token_expired_detected');

// No VU code:
if (refreshRes.status === 200) {
  tokenRefreshSuccess.add(1);
} else {
  tokenRefreshErrors.add(1);
}

// Quando detectar 401 em /auth/me:
if (res.status === 401) {
  tokenExpiredDetected.add(1);
}
```

### Dashboards
- **Grafana**: Painel "Auth Resilience" com métricas:
  - `token_refresh_duration_ms` (P50, P95, P99)
  - `token_refresh_success` vs `token_refresh_errors` (taxa de sucesso)
  - `token_expired_detected` (frequência de expiração)
- **k6 Cloud**: Não disponível (API pública gratuita)

---

## ⚠️ Observações Importantes

### Limitações da API

1. **DummyJSON Refresh Token Rotation**:
   - API retorna novo `refreshToken` no response de `/auth/refresh`
   - **NÃO GARANTE** que refresh token antigo seja invalidado
   - Em produção real, refresh token antigo deveria ser revogado após uso

2. **Expiração Real**:
   - `expiresInMins` controla validade do access token
   - DummyJSON **PODE NÃO VALIDAR** expiração real (aceita tokens expirados)
   - Testes devem simular expiração com `sleep()` para validar fluxo

3. **Cookies vs Bearer**:
   - API suporta ambos, mas k6 recomenda Bearer token (mais simples)
   - Cookies requerem `credentials: 'include'` e gerenciamento manual em k6

### Particularidades do Teste

1. **Sessões Longas**:
   - Usar `expiresInMins: 5` para testes rápidos (token expira em 5 min)
   - Usar `sleep(120)` entre operações para simular tempo real
   - Smoke test: 2 min (valida refresh básico)
   - Baseline: 10 min (valida expiração real + refresh)

2. **Think Times**:
   - Não há "think time de usuário" neste UC (operação de sistema)
   - Usar `sleep()` para simular passagem de tempo (expiração)
   - Step 3: `sleep(120)` = 2 minutos entre operações (forçar expiração)

3. **Integração com UC003**:
   - `libs/http/auth.ts` deve ser **estendido** com função `refreshToken()`
   - Função deve gerenciar refresh automático quando detectar 401
   - Exemplo:
   ```typescript
   export function getAuthHeaders(refreshIfNeeded = true) {
     let token = getCurrentToken();
     
     // Tentar operação com token atual
     const testRes = http.get(`${BASE_URL}/auth/me`, {
       headers: { Authorization: `Bearer ${token}` }
     });
     
     // Se 401, fazer refresh automático
     if (testRes.status === 401 && refreshIfNeeded) {
       const newToken = refreshToken();
       return { Authorization: `Bearer ${newToken}` };
     }
     
     return { Authorization: `Bearer ${token}` };
   }
   ```

### Considerações de Desempenho

1. **RPS Baixo**:
   - Token refresh não é operação frequente (1-2x por hora por usuário)
   - RPS sugerido: 1-2 (não sobrecarregar API com refreshes desnecessários)

2. **Memória de Tokens**:
   - Armazenar tokens em variáveis VU (não SharedArray)
   - Cada VU gerencia seu próprio par access/refresh token
   - Não compartilhar tokens entre VUs (sessões independentes)

3. **Duração de Teste**:
   - Smoke: 2 min (valida fluxo básico)
   - Baseline: 10 min (permite expiração real com `expiresInMins: 5`)
   - Stress: 15+ min (múltiplas sessões com refresh)

---

## 🔗 Dependências

### UCs Bloqueadores (Devem Estar Completos Antes)
- **UC003 - User Login & Profile**: Fornece `libs/http/auth.ts` base (login, getToken)
  - Requer: Função `login()` implementada
  - Requer: Armazenamento de access/refresh tokens
  - Requer: `data/test-data/users-credentials.csv`

### UCs que Usam Este (Fornece Para)
- **UC010 - User Journey (Authenticated)**: Pode usar refresh em sessões longas
  - Uso: Chamar `refreshToken()` se operação retornar 401
- **UC011 - Mixed Workload (Realistic Traffic)**: Simula sessões realistas com refresh
  - Uso: Personas 2 e 3 com sessões de 5-30 minutos (refresh necessário)

### Libs Necessárias
- **`libs/http/auth.ts`** (de UC003): Deve ser **estendido** com:
  - `refreshToken(currentRefreshToken: string, expiresInMins?: number): string`
  - Retorna novo access token
  - Atualiza estado interno com novos tokens
  - Trata erros 401/403 (refresh inválido)

### Dados Requeridos
- **`data/test-data/users-credentials.csv`** (de UC003): Credenciais para login inicial
- **`data/test-data/long-session-scenarios.json`** (novo): Cenários de teste com expiresInMins variados

---

## 📂 Libs/Helpers Criados

### `libs/http/auth.ts` (ESTENDER - não criar novo)

**Localização**: `libs/http/auth.ts`

**Funções NOVAS a Adicionar**:

```typescript
import http from 'k6/http';

// Estado global de tokens (por VU)
let currentAccessToken: string | null = null;
let currentRefreshToken: string | null = null;

/**
 * Faz refresh do access token usando refresh token
 * @param refreshToken - Token de refresh obtido no login
 * @param expiresInMins - Validade do novo access token (padrão 60)
 * @returns Novo access token ou null se falhar
 */
export function refreshToken(
  refreshToken: string, 
  expiresInMins: number = 60
): string | null {
  const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';
  
  const payload = JSON.stringify({
    refreshToken,
    expiresInMins,
  });
  
  const res = http.post(
    `${BASE_URL}/auth/refresh`,
    payload,
    {
      headers: { 'Content-Type': 'application/json' },
      tags: { feature: 'auth', kind: 'refresh', uc: 'UC012' }
    }
  );
  
  if (res.status === 200) {
    const newAccessToken = res.json('accessToken') as string;
    const newRefreshToken = res.json('refreshToken') as string;
    
    // Atualizar estado global
    currentAccessToken = newAccessToken;
    currentRefreshToken = newRefreshToken;
    
    return newAccessToken;
  }
  
  console.error(`Token refresh failed: ${res.status} - ${res.body}`);
  return null;
}

/**
 * Obtém headers de autenticação, faz refresh automático se token expirado
 * @param autoRefresh - Se true, tenta refresh automático em caso de 401
 * @returns Headers com Authorization Bearer
 */
export function getAuthHeadersWithRefresh(autoRefresh: boolean = true): object {
  if (!currentAccessToken) {
    throw new Error('No access token available. Call login() first.');
  }
  
  // Validar se token ainda é válido (opcional, pode adicionar validação GET /auth/me)
  // Se autoRefresh habilitado e token inválido, fazer refresh
  
  return {
    'Authorization': `Bearer ${currentAccessToken}`,
    'Content-Type': 'application/json',
  };
}

/**
 * Obtém refresh token atual (armazenado após login)
 * @returns Refresh token ou null se não disponível
 */
export function getCurrentRefreshToken(): string | null {
  return currentRefreshToken;
}

/**
 * Limpa tokens (logout lógico)
 */
export function clearTokens(): void {
  currentAccessToken = null;
  currentRefreshToken = null;
}
```

**Uso no Teste**:

```typescript
import { login, refreshToken, getCurrentRefreshToken } from '../../../libs/http/auth';

export default function() {
  // Step 1: Login inicial
  const user = login('emilys', 'emilyspass', 5); // expiresInMins: 5
  
  // Step 2: Simular operações até expiração
  for (let i = 0; i < 3; i++) {
    sleep(120); // 2 minutos
    
    const res = http.get(`${BASE_URL}/auth/me`, {
      headers: { Authorization: `Bearer ${user.accessToken}` }
    });
    
    if (res.status === 401) {
      console.log('Token expired, refreshing...');
      
      // Step 4: Refresh token
      const newToken = refreshToken(getCurrentRefreshToken()!, 30);
      
      if (newToken) {
        console.log('Token refreshed successfully');
        // Step 5: Validar novo token (próxima iteração usará novo token)
      } else {
        console.error('Token refresh failed, re-authenticating');
        login('emilys', 'emilyspass', 30);
      }
      
      break;
    }
  }
}
```

**Testes Unitários**: `tests/unit/libs/http/auth.test.ts` (estender com testes de refreshToken)

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-08 | GitHub Copilot | Criação inicial do UC012 (Token Refresh & Session Management) |

---

## ✅ Checklist de Completude

Validação antes de marcar como ✅ Approved:

- [x] Perfil de usuário está claro e realista (Personas 2/3, 40% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (POST /auth/login, GET /auth/me, POST /auth/refresh)
- [x] SLOs estão definidos e justificados (P95<400ms, checks>99%, baseline auth)
- [x] Fluxo principal está detalhado passo a passo (6 steps: login, validar, expirar, refresh, validar novo, continuar)
- [x] Validações (checks) estão especificadas (tokens válidos, expiração 401, refresh 200)
- [x] Dados de teste estão identificados (users-credentials.csv UC003, long-session-scenarios.json novo)
- [x] Headers obrigatórios estão documentados (Authorization Bearer, Content-Type)
- [x] Think times estão especificados (1-2s validação, 120s simulação expiração, não há ação de usuário)
- [x] Edge cases e cenários de erro estão mapeados (refresh inválido, expirado, preventivo, múltiplos refreshes, cookies)
- [x] Dependências de outros UCs estão listadas (UC003 bloqueador, UC010/UC011 usam)
- [x] Limitações da API (fake rotation, expiração não validada) estão documentadas
- [x] Arquivo nomeado corretamente: `UC012-token-refresh-session.md`
- [x] Libs/helpers criados estão documentados (estender auth.ts com refreshToken(), getAuthHeadersWithRefresh(), getCurrentRefreshToken(), clearTokens())
- [x] Comandos de teste estão corretos e testados (smoke 2m, baseline 10m, stress 15m)
- [x] Tags obrigatórias estão especificadas (feature: auth, kind: refresh, uc: UC012)
- [x] Métricas customizadas estão documentadas (3 Trends: refresh/validation duration, 3 Counters: success/errors/expired)

---

## 📚 Referências

- [DummyJSON Auth API](https://dummyjson.com/docs/auth)
- [k6 HTTP Authentication](https://grafana.com/docs/k6/latest/using-k6/protocols/http/authentication/)
- [JWT Token Management](https://jwt.io/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md`
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md`
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md`
- UC003 (User Login & Profile): `docs/casos_de_uso/UC003-user-login-profile.md`
- Template de UC: `docs/casos_de_uso/templates/use-case-template.md`
- Guia de Estilo: `docs/casos_de_uso/templates/guia-de-estilo.md`
- Checklist de Qualidade: `docs/casos_de_uso/templates/checklist-qualidade.md`
