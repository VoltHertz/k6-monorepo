# Guia de Implementação - k6 Performance Testing

## 🎯 Objetivo

Este guia orienta desenvolvedores na **implementação dos testes k6** baseados nos 13 casos de uso documentados (UC001-UC013).

---

## 📋 Pré-Requisitos

### Ferramentas Necessárias

```bash
# k6 (performance testing)
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg \
  --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | \
  sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Node.js (for TypeScript compilation check)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# TypeScript (optional, for type checking only)
npm install --save-dev typescript @types/k6
```

### Estrutura do Projeto

```
k6-monorepo/
├── tests/
│   ├── api/
│   │   ├── products/
│   │   │   ├── browse-catalog.test.ts      # UC001 + UC007
│   │   │   ├── search-products.test.ts     # UC002
│   │   │   └── view-details.test.ts        # UC004
│   │   ├── auth/
│   │   │   ├── user-login-profile.test.ts  # UC003
│   │   │   └── token-refresh.test.ts       # UC012
│   │   ├── carts/
│   │   │   ├── cart-operations-read.test.ts  # UC005
│   │   │   └── cart-operations-write.test.ts # UC006
│   │   ├── users/
│   │   │   └── list-users-admin.test.ts    # UC008
│   │   └── posts/
│   │       └── content-moderation.test.ts  # UC013
│   └── scenarios/
│       ├── user-journey-unauthenticated.test.ts  # UC009
│       ├── user-journey-authenticated.test.ts    # UC010
│       └── mixed-workload.test.ts                # UC011
├── libs/
│   ├── http/
│   │   ├── auth.ts                # UC003 + UC012
│   │   └── interceptors.ts        # baseHeaders, errorHandler
│   ├── data/
│   │   ├── user-loader.ts         # UC003
│   │   ├── product-loader.ts      # UC001
│   │   └── cart-loader.ts         # UC005
│   ├── scenarios/
│   │   ├── journey-builder.ts     # UC009
│   │   └── workload-mixer.ts      # UC011
│   ├── metrics/
│   │   └── custom-metrics.ts      # Shared Trends/Counters
│   └── reporting/
│       └── summary-handler.ts     # handleSummary
├── data/
│   └── test-data/                 # Massa de teste (gerada na Fase 6)
├── scripts/
│   ├── smoke.sh                   # Smoke tests
│   ├── baseline.sh                # Baseline tests
│   ├── stress.sh                  # Stress tests
│   └── soak.sh                    # Soak tests
└── docs/
    └── casos_de_uso/              # 13 UCs documentados
```

**Total**: ~20 arquivos TypeScript (11 tests + 9 libs)

---

## 🚀 Processo de Implementação

### Fase 1: Libs Base (Semana 1)

#### 1.1. Implementar `libs/http/auth.ts` (UC003)

**Referência**: `docs/casos_de_uso/UC003-user-login-profile.md`

```typescript
// libs/http/auth.ts
import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

// Token cache (per-VU)
let cachedToken: string | null = null;
let cachedRefreshToken: string | null = null;

/**
 * Login and return access token
 * @param username - DummyJSON username
 * @param password - DummyJSON password
 * @param expiresInMins - Token expiration (default 60)
 * @returns Access token string
 */
export function login(username: string, password: string, expiresInMins = 60): string {
  const res = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    username,
    password,
    expiresInMins,
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { feature: 'auth', kind: 'login', uc: 'UC003' },
  });

  check(res, {
    'login status is 200': (r) => r.status === 200,
    'login has accessToken': (r) => r.json('accessToken') !== undefined,
  }, { uc: 'UC003', step: 'login' });

  const body = res.json() as { accessToken: string; refreshToken: string };
  cachedToken = body.accessToken;
  cachedRefreshToken = body.refreshToken;
  
  return body.accessToken;
}

/**
 * Get current valid token (with cache)
 * @returns Access token string
 */
export function getToken(): string {
  if (!cachedToken) {
    throw new Error('No token available. Call login() first.');
  }
  return cachedToken;
}

/**
 * Get auth headers with Bearer token
 * @returns Headers object
 */
export function getAuthHeaders(): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${getToken()}`,
  };
}

/**
 * Refresh access token (UC012)
 * @param refreshToken - Refresh token from login
 * @returns New access token
 */
export function refreshToken(refreshToken: string): string {
  const res = http.post(`${BASE_URL}/auth/refresh`, JSON.stringify({
    refreshToken,
    expiresInMins: 60,
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { feature: 'auth', kind: 'refresh', uc: 'UC012' },
  });

  check(res, {
    'refresh status is 200': (r) => r.status === 200,
    'refresh has accessToken': (r) => r.json('accessToken') !== undefined,
  }, { uc: 'UC012', step: 'refresh' });

  const body = res.json() as { accessToken: string; refreshToken: string };
  cachedToken = body.accessToken;
  cachedRefreshToken = body.refreshToken;
  
  return body.accessToken;
}

/**
 * Get current refresh token
 * @returns Refresh token string
 */
export function getCurrentRefreshToken(): string {
  if (!cachedRefreshToken) {
    throw new Error('No refresh token available. Call login() first.');
  }
  return cachedRefreshToken;
}

/**
 * Clear token cache (for testing scenarios)
 */
export function clearTokens(): void {
  cachedToken = null;
  cachedRefreshToken = null;
}
```

**Teste Manual**:
```bash
# Criar teste simples para validar auth.ts
cat > tests/unit/auth.test.ts << 'EOF'
import { login, getToken, getAuthHeaders } from '../../libs/http/auth';

export default function() {
  const token = login('emilys', 'emilyspass');
  console.log('Token:', token);
  console.log('Headers:', JSON.stringify(getAuthHeaders()));
}
EOF

# Executar
k6 run tests/unit/auth.test.ts
```

---

#### 1.2. Implementar `libs/http/interceptors.ts`

```typescript
// libs/http/interceptors.ts
import { check, sleep } from 'k6';
import type { RefinedResponse, ResponseType } from 'k6/http';

/**
 * Get base headers for all requests
 * @returns Headers object
 */
export function baseHeaders(): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    'User-Agent': 'k6-performance-test/1.0',
  };
}

/**
 * Generic error handler for responses
 * @param res - k6 HTTP response
 * @param context - Context for logging (UC ID, step name)
 */
export function handleErrors(res: RefinedResponse<ResponseType | undefined>, context: string): void {
  if (res.status >= 400) {
    console.error(`[${context}] HTTP ${res.status}: ${res.body}`);
  }
}

/**
 * Add random jitter to think time
 * @param min - Minimum seconds
 * @param max - Maximum seconds
 */
export function thinkTime(min: number, max: number): void {
  const delay = min + Math.random() * (max - min);
  sleep(delay);
}
```

---

#### 1.3. Implementar `libs/data/user-loader.ts` (UC003)

**Referência**: `docs/casos_de_uso/UC003-user-login-profile.md`

```typescript
// libs/data/user-loader.ts
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

// Load users from CSV (generated in Phase 6)
const users = new SharedArray('users', function() {
  const csvData = open('../../data/test-data/users-credentials.csv');
  const parsed = papaparse.parse(csvData, { header: true });
  return parsed.data as Array<{ id: string; username: string; password: string; role: string }>;
});

/**
 * Get random user from dataset
 * @param role - Optional role filter (admin, moderator, user)
 * @returns User object
 */
export function getRandomUser(role?: string): { id: string; username: string; password: string; role: string } {
  const filtered = role 
    ? users.filter(u => u.role === role)
    : users;
  
  if (filtered.length === 0) {
    throw new Error(`No users found with role: ${role}`);
  }
  
  const randomIndex = Math.floor(Math.random() * filtered.length);
  return filtered[randomIndex];
}

/**
 * Get user by ID
 * @param id - User ID
 * @returns User object or undefined
 */
export function getUserById(id: string): { id: string; username: string; password: string; role: string } | undefined {
  return users.find(u => u.id === id);
}

/**
 * Get total users count
 * @returns Number of users
 */
export function getUsersCount(): number {
  return users.length;
}
```

**Nota**: Este arquivo requer `data/test-data/users-credentials.csv` (gerado na Fase 6).

---

### Fase 2: Testes Tier 0 (Semana 2)

#### 2.1. Implementar `tests/api/products/browse-catalog.test.ts` (UC001 + UC007)

**Referência**: 
- `docs/casos_de_uso/UC001-browse-products-catalog.md`
- `docs/casos_de_uso/UC007-browse-by-category.md`

```typescript
// tests/api/products/browse-catalog.test.ts
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import { baseHeaders, thinkTime } from '../../../libs/http/interceptors';

// Custom metrics
const productListDuration = new Trend('product_list_duration_ms');
const productListErrors = new Counter('product_list_errors');
const categoryListDuration = new Trend('category_list_duration_ms');

// Test data
const categories = new SharedArray('categories', function() {
  return JSON.parse(open('../../../data/test-data/categories.json'));
});

// Scenario config
export const options = {
  scenarios: {
    browse_catalog: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 5,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'products', kind: 'browse', uc: 'UC001' },
    },
  },
  thresholds: {
    'http_req_duration{feature:products}': ['p(95)<300'],
    'http_req_failed{feature:products}': ['rate<0.005'],
    'checks{uc:UC001}': ['rate>0.995'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  // UC001: Browse Products Catalog
  const limit = 20;
  const skip = Math.floor(Math.random() * 80);
  
  const res = http.get(
    `${BASE_URL}/products?limit=${limit}&skip=${skip}`,
    { 
      headers: baseHeaders(), 
      tags: { feature: 'products', kind: 'browse', uc: 'UC001', name: 'list_products' }
    }
  );
  
  productListDuration.add(res.timings.duration);
  
  const listChecks = check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
    'products count valid': (r) => {
      const products = r.json('products') as Array<any>;
      return products.length <= limit;
    },
  }, { uc: 'UC001', step: 'list' });
  
  if (!listChecks) {
    productListErrors.add(1);
  }
  
  thinkTime(2, 5);  // UC001: navegação casual
  
  // UC007: Browse by Category (30% das iterações)
  if (Math.random() < 0.3) {
    const category = randomItem(categories);
    
    const catRes = http.get(
      `${BASE_URL}/products/category/${category.slug}`,
      { 
        headers: baseHeaders(), 
        tags: { feature: 'products', kind: 'browse', uc: 'UC007', name: 'category_products' }
      }
    );
    
    categoryListDuration.add(catRes.timings.duration);
    
    check(catRes, {
      'category status is 200': (r) => r.status === 200,
      'category has products': (r) => Array.isArray(r.json('products')),
    }, { uc: 'UC007', step: 'category' });
    
    thinkTime(2, 5);
  }
}
```

**Teste Local**:
```bash
# Smoke test
K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/browse-catalog.test.ts

# Baseline test
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/browse-catalog.test.ts
```

---

#### 2.2. Implementar demais testes Tier 0

Seguir mesma estrutura para:
- `tests/api/products/search-products.test.ts` (UC002)
- `tests/api/products/view-details.test.ts` (UC004)

**Padrão**:
1. Importar `http`, `check`, `sleep`, `Trend`, `Counter`
2. Definir custom metrics
3. Carregar test data com `SharedArray`
4. Configurar `options` com executor `constant-arrival-rate`
5. Implementar VU code com checks e think times

---

### Fase 3: Testes Tier 1 (Semana 3)

#### 3.1. Implementar `tests/api/auth/user-login-profile.test.ts` (UC003)

**Referência**: `docs/casos_de_uso/UC003-user-login-profile.md`

```typescript
// tests/api/auth/user-login-profile.test.ts
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { login, getAuthHeaders } from '../../../libs/http/auth';
import { getRandomUser } from '../../../libs/data/user-loader';
import { thinkTime } from '../../../libs/http/interceptors';

// Custom metrics
const loginDuration = new Trend('auth_login_duration_ms');
const loginSuccess = new Counter('auth_login_success');
const loginErrors = new Counter('auth_login_errors');

export const options = {
  scenarios: {
    user_login: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 5,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'auth', kind: 'login', uc: 'UC003' },
    },
  },
  thresholds: {
    'http_req_duration{feature:auth}': ['p(95)<400'],
    'http_req_failed{feature:auth}': ['rate<0.01'],
    'checks{uc:UC003}': ['rate>0.99'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  const user = getRandomUser();
  
  // Step 1: Login
  const startTime = Date.now();
  const token = login(user.username, user.password);
  const loginTime = Date.now() - startTime;
  
  loginDuration.add(loginTime);
  
  if (token) {
    loginSuccess.add(1);
  } else {
    loginErrors.add(1);
    return;  // Skip /auth/me if login failed
  }
  
  thinkTime(1, 2);
  
  // Step 2: Get authenticated user profile
  const meRes = http.get(`${BASE_URL}/auth/me`, {
    headers: getAuthHeaders(),
    tags: { feature: 'auth', kind: 'profile', uc: 'UC003', name: 'get_profile' },
  });
  
  check(meRes, {
    'profile status is 200': (r) => r.status === 200,
    'profile has id': (r) => r.json('id') !== undefined,
    'profile username matches': (r) => r.json('username') === user.username,
  }, { uc: 'UC003', step: 'profile' });
  
  thinkTime(2, 5);
}
```

---

#### 3.2. Implementar demais testes Tier 1

Seguir padrão para:
- `tests/api/carts/cart-operations-read.test.ts` (UC005)
- `tests/api/carts/cart-operations-write.test.ts` (UC006)
- `tests/api/users/list-users-admin.test.ts` (UC008)
- `tests/api/auth/token-refresh.test.ts` (UC012)
- `tests/api/posts/content-moderation.test.ts` (UC013)

**Importante**: Todos devem importar e usar `libs/http/auth.ts` para autenticação.

---

### Fase 4: Jornadas Compostas (Semana 4)

#### 4.1. Implementar `libs/scenarios/journey-builder.ts` (UC009)

**Referência**: `docs/casos_de_uso/UC009-user-journey-unauthenticated.md`

```typescript
// libs/scenarios/journey-builder.ts
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import type { RefinedResponse, ResponseType } from 'k6/http';

interface JourneyStep {
  name: string;
  execute: () => RefinedResponse<ResponseType | undefined>;
  checks: Record<string, (r: RefinedResponse<ResponseType | undefined>) => boolean>;
  thinkTime?: [number, number];
}

// Custom metrics
const journeyDuration = new Trend('journey_total_duration_ms');
const journeyStepDuration = new Trend('journey_step_duration_ms');
const journeySuccess = new Counter('journey_success');
const journeyErrors = new Counter('journey_errors');

/**
 * Execute a complete user journey with steps
 * @param steps - Array of journey steps
 * @param tags - Tags for metrics (uc, persona)
 */
export function executeJourney(steps: JourneyStep[], tags: Record<string, string>): void {
  const startTime = Date.now();
  let allPassed = true;
  
  for (const [index, step] of steps.entries()) {
    const stepStart = Date.now();
    
    const res = step.execute();
    const stepDuration = Date.now() - stepStart;
    journeyStepDuration.add(stepDuration, { ...tags, step: step.name });
    
    const passed = check(res, step.checks, { ...tags, step: step.name });
    if (!passed) {
      allPassed = false;
    }
    
    if (step.thinkTime) {
      const [min, max] = step.thinkTime;
      const delay = min + Math.random() * (max - min);
      sleep(delay);
    }
  }
  
  const totalDuration = Date.now() - startTime;
  journeyDuration.add(totalDuration, tags);
  
  if (allPassed) {
    journeySuccess.add(1, tags);
  } else {
    journeyErrors.add(1, tags);
  }
}
```

---

#### 4.2. Implementar `tests/scenarios/user-journey-unauthenticated.test.ts` (UC009)

**Referência**: `docs/casos_de_uso/UC009-user-journey-unauthenticated.md`

```typescript
// tests/scenarios/user-journey-unauthenticated.test.ts
import http from 'k6/http';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import { SharedArray } from 'k6/data';
import { baseHeaders } from '../../libs/http/interceptors';
import { executeJourney } from '../../libs/scenarios/journey-builder';

const categories = new SharedArray('categories', function() {
  return JSON.parse(open('../../data/test-data/categories.json'));
});

const searchQueries = new SharedArray('searches', function() {
  return JSON.parse(open('../../data/test-data/search-queries.json'));
});

export const options = {
  scenarios: {
    journey_unauthenticated: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 6,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m',
      preAllocatedVUs: 20,
      maxVUs: 100,
      tags: { persona: 'visitante', uc: 'UC009' },
    },
  },
  thresholds: {
    'journey_total_duration_ms{persona:visitante}': ['p(95)<3000'],
    'checks{uc:UC009}': ['rate>0.995'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export default function() {
  const category = randomItem(categories);
  const query = randomItem(searchQueries);
  let productId: number | null = null;
  
  executeJourney([
    {
      name: 'browse_products',
      execute: () => http.get(`${BASE_URL}/products?limit=20`, {
        headers: baseHeaders(),
        tags: { feature: 'products', kind: 'browse' },
      }),
      checks: {
        'status is 200': (r) => r.status === 200,
        'has products': (r) => Array.isArray(r.json('products')),
      },
      thinkTime: [2, 5],
    },
    {
      name: 'browse_category',
      execute: () => http.get(`${BASE_URL}/products/category/${category.slug}`, {
        headers: baseHeaders(),
        tags: { feature: 'products', kind: 'category' },
      }),
      checks: {
        'category status is 200': (r) => r.status === 200,
      },
      thinkTime: [2, 5],
    },
    {
      name: 'search_products',
      execute: () => {
        const res = http.get(`${BASE_URL}/products/search?q=${query}`, {
          headers: baseHeaders(),
          tags: { feature: 'products', kind: 'search' },
        });
        const products = res.json('products') as Array<{ id: number }>;
        if (products && products.length > 0) {
          productId = products[0].id;
        }
        return res;
      },
      checks: {
        'search status is 200': (r) => r.status === 200,
      },
      thinkTime: [2, 5],
    },
    {
      name: 'view_details',
      execute: () => http.get(`${BASE_URL}/products/${productId || 1}`, {
        headers: baseHeaders(),
        tags: { feature: 'products', kind: 'details' },
      }),
      checks: {
        'details status is 200': (r) => r.status === 200,
        'details has id': (r) => r.json('id') !== undefined,
      },
      thinkTime: [3, 7],
    },
  ], { persona: 'visitante', uc: 'UC009' });
}
```

---

### Fase 5: Testes Avançados (Semana 5)

#### 5.1. Implementar `libs/scenarios/workload-mixer.ts` (UC011)

**Referência**: `docs/casos_de_uso/UC011-mixed-workload.md`

```typescript
// libs/scenarios/workload-mixer.ts

export type Persona = 'visitante' | 'comprador' | 'admin';

/**
 * Select persona based on distribution (60/30/10)
 * @returns Persona name
 */
export function selectPersona(): Persona {
  const rand = Math.random();
  if (rand < 0.6) return 'visitante';
  if (rand < 0.9) return 'comprador';
  return 'admin';
}

/**
 * Get think time range for persona
 * @param persona - Persona name
 * @returns [min, max] seconds
 */
export function getPersonaThinkTime(persona: Persona): [number, number] {
  switch (persona) {
    case 'visitante': return [2, 5];
    case 'comprador': return [3, 7];
    case 'admin': return [5, 10];
  }
}

/**
 * Get RPS config for persona
 * @param persona - Persona name
 * @param totalRPS - Total RPS target
 * @returns RPS for persona
 */
export function getPersonaRPS(persona: Persona, totalRPS: number): number {
  switch (persona) {
    case 'visitante': return Math.floor(totalRPS * 0.6);
    case 'comprador': return Math.floor(totalRPS * 0.3);
    case 'admin': return Math.floor(totalRPS * 0.1);
  }
}
```

---

#### 5.2. Implementar `tests/scenarios/mixed-workload.test.ts` (UC011)

**Referência**: `docs/casos_de_uso/UC011-mixed-workload.md`

```typescript
// tests/scenarios/mixed-workload.test.ts
import { Trend, Counter, Rate } from 'k6/metrics';
import { selectPersona } from '../../libs/scenarios/workload-mixer';
// Import journey executors
import visitanteJourney from './user-journey-unauthenticated.test';
import compradorJourney from './user-journey-authenticated.test';
// Import admin functions (simplified)

const personaDistribution = new Rate('persona_distribution');
const visitanteExecutions = new Counter('visitante_executions');
const compradorExecutions = new Counter('comprador_executions');
const adminExecutions = new Counter('admin_executions');

export const options = {
  scenarios: {
    visitante_flow: {
      executor: 'constant-arrival-rate',
      exec: 'visitanteFlow',
      rate: Math.floor((Number(__ENV.K6_RPS) || 10) * 0.6),
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m',
      preAllocatedVUs: 20,
      maxVUs: 100,
      tags: { persona: 'visitante' },
    },
    comprador_flow: {
      executor: 'constant-arrival-rate',
      exec: 'compradorFlow',
      rate: Math.floor((Number(__ENV.K6_RPS) || 10) * 0.3),
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { persona: 'comprador' },
    },
    admin_flow: {
      executor: 'constant-arrival-rate',
      exec: 'adminFlow',
      rate: Math.floor((Number(__ENV.K6_RPS) || 10) * 0.1),
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '10m',
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { persona: 'admin' },
    },
  },
  thresholds: {
    'http_req_duration': ['p(95)<500'],
    'http_req_failed': ['rate<0.01'],
    'checks': ['rate>0.99'],
  },
};

export function visitanteFlow() {
  visitanteExecutions.add(1);
  visitanteJourney();
}

export function compradorFlow() {
  compradorExecutions.add(1);
  compradorJourney();
}

export function adminFlow() {
  adminExecutions.add(1);
  // Execute admin journey (UC008 + UC013)
}
```

---

## 📦 Geração de Dados de Teste (Fase 6 - Opcional)

### Criar Geradores

```bash
# Criar diretório de geradores
mkdir -p data/test-data/generators

# Gerar users-credentials.csv
cat > data/test-data/generators/generate-users.ts << 'EOF'
import fs from 'fs';
const users = JSON.parse(fs.readFileSync('../fulldummyjsondata/users.json', 'utf8'));

const csv = users.users.slice(0, 100).map((u: any) => 
  `${u.id},${u.username},${u.password},user`
).join('\n');

fs.writeFileSync('../users-credentials.csv', `id,username,password,role\n${csv}`);
console.log('Generated users-credentials.csv (100 users)');
EOF

# Executar gerador
node data/test-data/generators/generate-users.ts
```

---

## 🧪 Validação e Testes

### Executar Smoke Tests (5 min)

```bash
./scripts/smoke.sh all
```

**Espera-se**: 8 testes passando, duração ~5 min

---

### Executar Baseline Tests (60 min)

```bash
./scripts/baseline.sh all
```

**Espera-se**: 11 testes passando com SLOs validados

---

### Executar Stress Tests (80 min)

```bash
./scripts/stress.sh mixed
```

**Espera-se**: UC011 rodando com degradação aceitável (P95 < 800ms)

---

## 📊 Monitoramento e Resultados

### Output Local (Terminal)

k6 exibe resumo automático:
```
✓ status is 200
✓ has products array

checks.........................: 99.85% ✓ 5991  ✗ 9
data_received..................: 12 MB  40 kB/s
data_sent......................: 590 kB 2.0 kB/s
http_req_duration..............: avg=245ms min=102ms med=201ms max=1.2s p(90)=380ms p(95)=450ms
  { feature:products }.........: avg=220ms min=102ms med=190ms max=890ms p(95)=310ms
http_req_failed................: 0.15%  ✓ 9     ✗ 5991
http_reqs......................: 6000   20/s
```

---

### Output JSON (Análise Detalhada)

```bash
# Executar com output JSON
K6_RPS=5 K6_DURATION=5m k6 run \
  --out json=results/baseline_UC001.json \
  tests/api/products/browse-catalog.test.ts

# Analisar com jq
cat results/baseline_UC001.json | jq -r 'select(.type=="Point" and .metric=="http_req_duration") | .data.value' | \
  awk '{sum+=$1; count++} END {print "Avg latency:", sum/count, "ms"}'
```

---

### Integração CI/CD (GitHub Actions)

Ver workflows já criados:
- `.github/workflows/k6-pr-smoke.yml` (PR checks)
- `.github/workflows/k6-main-baseline.yml` (Main branch)
- `.github/workflows/k6-on-demand.yml` (Stress/Soak manual)

---

## ⚠️ Troubleshooting

### Erro: `open() file not found`

**Causa**: Caminho relativo incorreto para `data/test-data/`

**Solução**:
```typescript
// Correto
const data = new SharedArray('data', function() {
  return JSON.parse(open('../../../data/test-data/file.json'));
});
```

---

### Erro: `No token available`

**Causa**: `login()` não foi chamado antes de `getAuthHeaders()`

**Solução**:
```typescript
import { login, getAuthHeaders } from '../../../libs/http/auth';

export default function() {
  login('emilys', 'emilyspass');  // MUST call first
  const headers = getAuthHeaders();  // Now works
}
```

---

### Thresholds Failing

**Causa**: SLOs muito estritos para ambiente atual

**Solução**: Ajustar thresholds temporariamente:
```typescript
thresholds: {
  'http_req_duration{feature:products}': ['p(95)<500'],  // Era 300ms
}
```

---

## 📚 Referências

### Documentação de UCs
- **UC001-UC013**: `docs/casos_de_uso/UC00X-*.md`
- **Matriz de Testes**: `docs/casos_de_uso/fase5-matriz-testes-nao-funcionais.md`

### k6 Documentation
- [k6 TypeScript Support](https://grafana.com/docs/k6/latest/using-k6/javascript-typescript-compatibility-mode/)
- [k6 Executors](https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/)
- [k6 Metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)

### DummyJSON API
- [API Documentation](https://dummyjson.com/docs)
- [Products API](https://dummyjson.com/docs/products)
- [Auth API](https://dummyjson.com/docs/auth)

---

## ✅ Checklist de Implementação

### Libs Base
- [ ] `libs/http/auth.ts` implementado e testado
- [ ] `libs/http/interceptors.ts` implementado
- [ ] `libs/data/user-loader.ts` implementado
- [ ] `libs/data/product-loader.ts` implementado (opcional)
- [ ] `libs/data/cart-loader.ts` implementado (opcional)

### Testes Tier 0 (Independentes)
- [ ] `tests/api/products/browse-catalog.test.ts` (UC001 + UC007)
- [ ] `tests/api/products/search-products.test.ts` (UC002)
- [ ] `tests/api/products/view-details.test.ts` (UC004)

### Testes Tier 1 (Dependentes Auth)
- [ ] `tests/api/auth/user-login-profile.test.ts` (UC003)
- [ ] `tests/api/carts/cart-operations-read.test.ts` (UC005)
- [ ] `tests/api/carts/cart-operations-write.test.ts` (UC006)
- [ ] `tests/api/users/list-users-admin.test.ts` (UC008)
- [ ] `tests/api/auth/token-refresh.test.ts` (UC012)
- [ ] `tests/api/posts/content-moderation.test.ts` (UC013)

### Testes Tier 2 (Jornadas)
- [ ] `libs/scenarios/journey-builder.ts` implementado
- [ ] `tests/scenarios/user-journey-unauthenticated.test.ts` (UC009)
- [ ] `tests/scenarios/user-journey-authenticated.test.ts` (UC010)
- [ ] `libs/scenarios/workload-mixer.ts` implementado
- [ ] `tests/scenarios/mixed-workload.test.ts` (UC011)

### Validação
- [ ] Smoke tests passando (./scripts/smoke.sh all)
- [ ] Baseline tests passando (./scripts/baseline.sh all)
- [ ] Stress tests com degradação aceitável
- [ ] Soak tests estáveis (opcional)

### CI/CD
- [ ] Workflows GitHub Actions configurados
- [ ] PR checks automáticos funcionando
- [ ] Baseline automático no main
- [ ] On-demand stress/soak disponíveis

**🎯 FASE 5 (Entregável 4/4) - Guia de Implementação Completo**

---

## 📝 Histórico de Versões

| Versão | Data | Autor | Mudança |
|--------|------|-------|---------|
| 1.0 | 2025-10-08 | GitHub Copilot | Criação do guia de implementação (FASE 5) |
