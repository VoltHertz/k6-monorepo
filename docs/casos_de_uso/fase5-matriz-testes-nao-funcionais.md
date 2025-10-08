# Matriz de Testes Não Funcionais - Mapeamento de UCs

## 🎯 Objetivo

Este documento mapeia **quais casos de uso (UCs)** serão executados em cada **tipo de teste não funcional** (smoke, baseline, stress, soak), organizados por **domínio da API** (products, auth, carts, users, posts).

---

## 📊 Tipos de Teste Não Funcional

### Smoke Test (Validação Rápida)
**Objetivo**: Validar funcionamento básico antes de testes mais pesados  
**Duração**: 30-60 segundos  
**RPS**: 1-2 RPS (baixa carga)  
**Thresholds**: Relaxados (P95 < 500ms, error < 1%, checks > 95%)  
**Quando Executar**: PR checks, antes de merge, validação rápida

### Baseline Test (Linha de Base)
**Objetivo**: Estabelecer performance esperada em condições normais  
**Duração**: 5-10 minutos  
**RPS**: 5-10 RPS (carga normal)  
**Thresholds**: Estritos (conforme SLOs de cada UC - P95 < 300-600ms, error < 0.5-1%, checks > 99%)  
**Quando Executar**: Main branch, releases, validação de SLOs

### Stress Test (Teste de Carga)
**Objetivo**: Validar comportamento sob carga alta (picos de tráfego)  
**Duração**: 10-15 minutos  
**RPS**: 20-50 RPS (ramping) - picos até 2-5x baseline  
**Thresholds**: Moderados (P95 < 800ms aceitável, error < 5%, checks > 90%)  
**Quando Executar**: Pre-release, validação de escalabilidade, on-demand

### Soak Test (Teste de Resistência)
**Objetivo**: Validar estabilidade em execução prolongada (memory leaks, degradação)  
**Duração**: 60-120 minutos  
**RPS**: 10 RPS (carga sustentada)  
**Thresholds**: Baseline + monitoramento de tendência (P95 não deve crescer > 20%)  
**Quando Executar**: Pre-release major, validação de resiliência, on-demand

---

## 🗂️ Matriz por Domínio e Tipo de Teste

### 1. Products API (6 UCs)

#### Smoke Test - Products (30-60s, 1-2 RPS)
**Objetivo**: Validar endpoints básicos de produtos funcionam

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC001 | Browse Products Catalog | GET /products | Endpoint mais usado (60% tráfego) |
| UC004 | View Product Details | GET /products/{id} | Crítico para conversão |

**Comandos**:
```bash
# Smoke - Browse Catalog
K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/browse-catalog.test.ts

# Smoke - View Details
K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/view-details.test.ts
```

**Thresholds**: P95 < 500ms, error < 1%, checks > 95%

---

#### Baseline Test - Products (5-10min, 5-10 RPS)
**Objetivo**: Validar SLOs de produtos em carga normal

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC001 | Browse Products Catalog | GET /products | 60% tráfego, SLO P95 < 300ms |
| UC002 | Search & Filter Products | GET /products/search | 30% tráfego browse, SLO P95 < 600ms |
| UC004 | View Product Details | GET /products/{id} | Decisão de compra, SLO P95 < 300ms |
| UC007 | Browse by Category | GET /products/categories, GET /products/category/{slug} | Navegação estruturada, SLO P95 < 300ms |

**Comandos**:
```bash
# Baseline - Browse Catalog
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/browse-catalog.test.ts

# Baseline - Search Products
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/search-products.test.ts

# Baseline - View Details
K6_RPS=5 K6_DURATION=5m k6 run tests/api/products/view-details.test.ts
```

**Thresholds**: Conforme SLOs individuais (P95 < 300-600ms, error < 0.5%, checks > 99.5%)

---

#### Stress Test - Products (10-15min, 20-50 RPS ramping)
**Objetivo**: Validar degradação em picos de tráfego (Black Friday, promoções)

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC001 | Browse Products Catalog | GET /products | Pico de navegação em promoções |
| UC002 | Search & Filter Products | GET /products/search | Pico de buscas por desconto |

**Comandos**:
```bash
# Stress - Browse Catalog (ramping 5→20→50 RPS)
K6_RPS_START=5 K6_RPS_PEAK=50 K6_DURATION=15m k6 run tests/api/products/browse-catalog.test.ts

# Stress - Search Products (ramping 5→35 RPS)
K6_RPS_START=5 K6_RPS_PEAK=35 K6_DURATION=15m k6 run tests/api/products/search-products.test.ts
```

**Thresholds**: P95 < 800ms (degradação aceitável), error < 5%, checks > 90%

---

#### Soak Test - Products (60-120min, 10 RPS sustentado)
**Objetivo**: Validar estabilidade em navegação prolongada (sem memory leaks)

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC001 | Browse Products Catalog | GET /products | Navegação contínua, detecta memory leaks |

**Comandos**:
```bash
# Soak - Browse Catalog (60 min sustentado)
K6_RPS=10 K6_DURATION=60m k6 run tests/api/products/browse-catalog.test.ts
```

**Thresholds**: P95 < 300ms (não deve crescer > 20% ao longo do tempo), error < 0.5%

---

### 2. Auth API (2 UCs)

#### Smoke Test - Auth (30-60s, 1-2 RPS)
**Objetivo**: Validar autenticação básica funciona

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC003 | User Login & Profile | POST /auth/login, GET /auth/me | Gateway para todos fluxos autenticados |

**Comandos**:
```bash
# Smoke - Login & Profile
K6_RPS=1 K6_DURATION=30s k6 run tests/api/auth/user-login-profile.test.ts
```

**Thresholds**: P95 < 600ms, error < 1%, checks > 95%

---

#### Baseline Test - Auth (5-10min, 5-10 RPS)
**Objetivo**: Validar SLOs de autenticação em carga normal

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC003 | User Login & Profile | POST /auth/login, GET /auth/me | 40% tráfego autenticado, SLO P95 < 400ms |
| UC012 | Token Refresh & Session Management | POST /auth/refresh | Sessões longas, SLO P95 < 400ms |

**Comandos**:
```bash
# Baseline - Login & Profile
K6_RPS=5 K6_DURATION=5m k6 run tests/api/auth/user-login-profile.test.ts

# Baseline - Token Refresh
K6_RPS=3 K6_DURATION=5m k6 run tests/api/auth/token-refresh.test.ts
```

**Thresholds**: P95 < 400ms, error < 1%, checks > 99%, token_refresh_success > 95%

---

#### Stress Test - Auth (10-15min, 20-50 RPS ramping)
**Objetivo**: Validar login em pico de acessos simultâneos

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC003 | User Login & Profile | POST /auth/login | Pico de logins simultâneos (lançamento produto) |

**Comandos**:
```bash
# Stress - Login (ramping 5→30 RPS)
K6_RPS_START=5 K6_RPS_PEAK=30 K6_DURATION=15m k6 run tests/api/auth/user-login-profile.test.ts
```

**Thresholds**: P95 < 800ms, error < 5%, checks > 90%

---

#### Soak Test - Auth (60-120min, 10 RPS sustentado)
**Objetivo**: Validar token refresh em sessões prolongadas (admin, moderador)

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC012 | Token Refresh & Session Management | POST /auth/refresh | Sessões admin de 60+ min, detecta token leaks |

**Comandos**:
```bash
# Soak - Token Refresh (60 min sustentado)
K6_RPS=5 K6_DURATION=60m k6 run tests/api/auth/token-refresh.test.ts
```

**Thresholds**: P95 < 400ms (não deve crescer), token_refresh_success > 95%, sem memory leaks

---

### 3. Carts API (2 UCs)

#### Smoke Test - Carts (30-60s, 1-2 RPS)
**Objetivo**: Validar leitura de carrinho funciona

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC005 | Cart Operations (Read) | GET /carts/user/{userId} | Visualização pré-checkout |

**Comandos**:
```bash
# Smoke - Cart Read
K6_RPS=1 K6_DURATION=30s k6 run tests/api/carts/cart-operations-read.test.ts
```

**Thresholds**: P95 < 700ms, error < 1%, checks > 95%

---

#### Baseline Test - Carts (5-10min, 5-10 RPS)
**Objetivo**: Validar SLOs de carrinho em carga normal

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC005 | Cart Operations (Read) | GET /carts, GET /carts/{id}, GET /carts/user/{userId} | Pré-checkout, SLO P95 < 500ms |
| UC006 | Cart Operations (Write - Simulated) | POST /carts/add, PUT /carts/{id} | Adicionar/atualizar itens, SLO P95 < 550ms |

**Comandos**:
```bash
# Baseline - Cart Read
K6_RPS=5 K6_DURATION=5m k6 run tests/api/carts/cart-operations-read.test.ts

# Baseline - Cart Write
K6_RPS=3 K6_DURATION=5m k6 run tests/api/carts/cart-operations-write.test.ts
```

**Thresholds**: P95 < 500-550ms, error < 1%, checks > 99%

---

#### Stress Test - Carts (10-15min, 20-50 RPS ramping)
**Objetivo**: Validar adicionar ao carrinho em pico de compras

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC006 | Cart Operations (Write - Simulated) | POST /carts/add | Pico de add-to-cart em promoção flash |

**Comandos**:
```bash
# Stress - Cart Write (ramping 5→25 RPS)
K6_RPS_START=5 K6_RPS_PEAK=25 K6_DURATION=15m k6 run tests/api/carts/cart-operations-write.test.ts
```

**Thresholds**: P95 < 900ms, error < 5% (fake writes, não persiste), checks > 90%

---

#### Soak Test - Carts (60-120min, 10 RPS sustentado)
**NÃO APLICÁVEL** para Carts  
**Justificativa**: Writes não persistem (fake API), soak não detectaria degradação real. Focar em Products/Auth.

---

### 4. Users API (1 UC)

#### Smoke Test - Users (30-60s, 1-2 RPS)
**Objetivo**: Validar listagem de usuários funciona

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC008 | List Users (Admin) | GET /users | Backoffice, 10% tráfego |

**Comandos**:
```bash
# Smoke - List Users
K6_RPS=1 K6_DURATION=30s k6 run tests/api/users/list-users-admin.test.ts
```

**Thresholds**: P95 < 700ms, error < 1%, checks > 95%

---

#### Baseline Test - Users (5-10min, 5-10 RPS)
**Objetivo**: Validar SLOs de admin em carga normal

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC008 | List Users (Admin) | GET /users, GET /users/{id}, GET /users/search, GET /users/filter | Admin operations, SLO P95 < 600ms |

**Comandos**:
```bash
# Baseline - List Users
K6_RPS=2 K6_DURATION=5m k6 run tests/api/users/list-users-admin.test.ts
```

**Thresholds**: P95 < 600ms, error < 1%, checks > 99%

---

#### Stress Test - Users (10-15min, 20-50 RPS ramping)
**NÃO PRIORITÁRIO** para Users  
**Justificativa**: 10% tráfego admin, baixa prioridade. Focar em Products/Auth/Carts.

---

#### Soak Test - Users (60-120min, 10 RPS sustentado)
**NÃO APLICÁVEL** para Users  
**Justificativa**: Admin operations curtas (< 30 min), não requer soak. Focar em Auth refresh.

---

### 5. Posts/Comments API (1 UC)

#### Smoke Test - Posts/Comments (30-60s, 1-2 RPS)
**Objetivo**: Validar moderação básica funciona

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC013 | Content Moderation (Posts/Comments) | GET /posts, GET /comments | Moderação de conteúdo |

**Comandos**:
```bash
# Smoke - Content Moderation
K6_RPS=1 K6_DURATION=30s k6 run tests/api/posts/content-moderation.test.ts
```

**Thresholds**: P95 < 600ms, error < 1%, checks > 95%

---

#### Baseline Test - Posts/Comments (5-10min, 5-10 RPS)
**Objetivo**: Validar SLOs de moderação em carga normal

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC013 | Content Moderation (Posts/Comments) | GET /posts, GET /comments, GET /posts/user/{userId}, GET /comments/post/{postId} | Moderação contínua, SLO P95 < 400ms |

**Comandos**:
```bash
# Baseline - Content Moderation
K6_RPS=2 K6_DURATION=5m k6 run tests/api/posts/content-moderation.test.ts
```

**Thresholds**: P95 < 400ms, error < 1%, checks > 98%

---

#### Stress Test - Posts/Comments (10-15min, 20-50 RPS ramping)
**NÃO PRIORITÁRIO** para Posts/Comments  
**Justificativa**: Moderação não é core e-commerce, baixa prioridade. Focar em Products/Carts.

---

#### Soak Test - Posts/Comments (60-120min, 10 RPS sustentado)
**NÃO APLICÁVEL** para Posts/Comments  
**Justificativa**: Moderação não requer soak testing. Focar em Products/Auth.

---

### 6. Jornadas Compostas (3 UCs)

#### Smoke Test - Jornadas (30-60s, 1-2 RPS)
**Objetivo**: Validar jornada completa funciona (visitante)

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC009 | User Journey (Unauthenticated) | UC001+UC002+UC004+UC007 | Fluxo 60% usuários |

**Comandos**:
```bash
# Smoke - Journey Unauthenticated
K6_RPS=1 K6_DURATION=60s k6 run tests/scenarios/user-journey-unauthenticated.test.ts
```

**Thresholds**: P95 < 600ms (jornada completa), error < 1%, checks > 95%

---

#### Baseline Test - Jornadas (5-10min, 5-10 RPS)
**Objetivo**: Validar jornadas realistas em carga normal

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC009 | User Journey (Unauthenticated) | UC001+UC002+UC004+UC007 | 60% tráfego, SLO P95 < 500ms |
| UC010 | User Journey (Authenticated) | UC009+UC003+UC005 | 30% tráfego, SLO P95 < 550ms |

**Comandos**:
```bash
# Baseline - Journey Unauthenticated
K6_RPS=6 K6_DURATION=10m k6 run tests/scenarios/user-journey-unauthenticated.test.ts

# Baseline - Journey Authenticated
K6_RPS=3 K6_DURATION=10m k6 run tests/scenarios/user-journey-authenticated.test.ts
```

**Thresholds**: P95 < 500-550ms, error < 1%, checks > 99%

---

#### Stress Test - Jornadas (10-15min, 20-50 RPS ramping)
**Objetivo**: Validar jornada completa em pico de tráfego

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC011 | Mixed Workload (Realistic Traffic) | TODOS UC001-UC013 | Produção realista (60/30/10) |

**Comandos**:
```bash
# Stress - Mixed Workload (ramping 10→50 RPS, 3 personas)
K6_RPS_START=10 K6_RPS_PEAK=50 K6_DURATION=15m k6 run tests/scenarios/mixed-workload.test.ts
```

**Thresholds**: P95 < 800ms (degradação global aceitável), error < 5%, checks > 90%

---

#### Soak Test - Jornadas (60-120min, 10 RPS sustentado)
**Objetivo**: Validar estabilidade de tráfego misto prolongado

| UC | Nome | Endpoints | Justificativa |
|----|------|-----------|---------------|
| UC011 | Mixed Workload (Realistic Traffic) | TODOS UC001-UC013 | Produção 24/7, detecta memory leaks |

**Comandos**:
```bash
# Soak - Mixed Workload (60 min sustentado, 3 personas)
K6_RPS=10 K6_DURATION=60m k6 run tests/scenarios/mixed-workload.test.ts
```

**Thresholds**: P95 < 500ms (não deve crescer > 20%), error < 1%, distribuição 60/30/10 mantida

---

## 📊 Resumo da Matriz

### Smoke Test (30-60s, 1-2 RPS)
**Total**: 8 UCs executados

| Domínio | UCs | Endpoints | Justificativa |
|---------|-----|-----------|---------------|
| Products | UC001, UC004 | 2 | Endpoints mais usados |
| Auth | UC003 | 2 | Gateway autenticação |
| Carts | UC005 | 1 | Pré-checkout |
| Users | UC008 | 1 | Admin backoffice |
| Posts | UC013 | 2 | Moderação |
| Jornadas | UC009 | 0* | Fluxo visitante |

**Duração Estimada**: ~5 minutos (8 testes x 30-60s)

---

### Baseline Test (5-10min, 5-10 RPS)
**Total**: 11 UCs executados

| Domínio | UCs | Endpoints | Justificativa |
|---------|-----|-----------|---------------|
| Products | UC001, UC002, UC004, UC007 | 6 | SLOs de produtos |
| Auth | UC003, UC012 | 3 | SLOs de autenticação |
| Carts | UC005, UC006 | 6 | SLOs de carrinho |
| Users | UC008 | 4 | SLOs de admin |
| Posts | UC013 | 6 | SLOs de moderação |
| Jornadas | UC009, UC010 | 0* | Jornadas realistas |

**Duração Estimada**: ~60 minutos (11 testes x 5-10min)

---

### Stress Test (10-15min, 20-50 RPS ramping)
**Total**: 6 UCs executados (PRIORITÁRIOS)

| Domínio | UCs | Endpoints | Justificativa |
|---------|-----|-----------|---------------|
| Products | UC001, UC002 | 2 | Pico de navegação/busca |
| Auth | UC003 | 1 | Pico de logins |
| Carts | UC006 | 1 | Pico de add-to-cart |
| Jornadas | UC011 | 24* | Tráfego misto realista |

**Duração Estimada**: ~80 minutos (6 testes x 10-15min)

---

### Soak Test (60-120min, 10 RPS sustentado)
**Total**: 4 UCs executados (CRÍTICOS)

| Domínio | UCs | Endpoints | Justificativa |
|---------|-----|-----------|---------------|
| Products | UC001 | 1 | Detecta memory leaks navegação |
| Auth | UC012 | 1 | Sessões longas, token refresh |
| Jornadas | UC011 | 24* | Produção 24/7, estabilidade |

**Duração Estimada**: ~240 minutos (4 testes x 60min)

---

## 🚀 Estratégia de Execução

### CI/CD Pipeline (Automático)

#### PR Smoke Test (Trigger: Pull Request)
**Objetivo**: Validação rápida antes de merge  
**Duração Total**: ~5 minutos  
**UCs Executados**: 8 (UC001, UC003, UC004, UC005, UC008, UC009, UC013)

**Workflow**: `.github/workflows/k6-pr-smoke.yml`
```yaml
name: k6 PR Smoke Test
on: pull_request
jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - name: Smoke - Browse Catalog
        run: K6_RPS=1 K6_DURATION=30s k6 run tests/api/products/browse-catalog.test.ts
      - name: Smoke - Login
        run: K6_RPS=1 K6_DURATION=30s k6 run tests/api/auth/user-login-profile.test.ts
      # ... (outros 6 testes)
```

---

#### Main Baseline Test (Trigger: Push to main)
**Objetivo**: Validar SLOs em produção  
**Duração Total**: ~60 minutos  
**UCs Executados**: 11 (todos baseline)

**Workflow**: `.github/workflows/k6-main-baseline.yml`
```yaml
name: k6 Main Baseline Test
on:
  push:
    branches: [main]
jobs:
  baseline:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test:
          - tests/api/products/browse-catalog.test.ts
          - tests/api/products/search-products.test.ts
          - tests/api/auth/user-login-profile.test.ts
          # ... (outros 8 testes)
    steps:
      - name: Baseline Test
        run: K6_RPS=5 K6_DURATION=5m k6 run ${{ matrix.test }}
```

---

#### On-Demand Tests (Trigger: Manual workflow_dispatch)
**Objetivo**: Stress/Soak sob demanda  
**Duração Total**: Variável (80-240 min)  
**UCs Executados**: 6 (stress) ou 4 (soak)

**Workflow**: `.github/workflows/k6-on-demand.yml`
```yaml
name: k6 On-Demand Test
on:
  workflow_dispatch:
    inputs:
      test_type:
        description: 'Test type (stress or soak)'
        required: true
        default: 'stress'
jobs:
  on-demand:
    runs-on: ubuntu-latest
    steps:
      - name: Run Test
        run: |
          if [ "${{ github.event.inputs.test_type }}" == "stress" ]; then
            ./scripts/run-stress-tests.sh
          else
            ./scripts/run-soak-tests.sh
          fi
```

---

### Execução Local (Manual)

#### Smoke Local (Desenvolvedor)
```bash
# Executar smoke de um UC específico
./scripts/smoke.sh UC001

# Executar smoke de todos os 8 UCs
./scripts/smoke.sh all
```

#### Baseline Local (QA)
```bash
# Executar baseline de um domínio
./scripts/baseline.sh products

# Executar baseline de todos os 11 UCs
./scripts/baseline.sh all
```

#### Stress Local (Pre-Release)
```bash
# Executar stress de produtos
./scripts/stress.sh products

# Executar stress completo (UC011 mixed)
./scripts/stress.sh mixed
```

#### Soak Local (Validação Resiliência)
```bash
# Executar soak de produtos (60 min)
./scripts/soak.sh products

# Executar soak completo (UC011 mixed, 60 min)
./scripts/soak.sh mixed
```

---

## ⚠️ Observações Importantes

### Limitações DummyJSON
- **Fake Writes**: POST/PUT/DELETE não persistem → Stress/Soak de Carts tem valor limitado
- **Rate Limiting**: API pública, assumir 100 RPS máximo seguro
- **CDN Caching**: GET pode estar em cache → variação de latência esperada

### Priorização de Testes
1. **CRÍTICO**: Smoke (PR) + Baseline (main) → sempre executar
2. **IMPORTANTE**: Stress (pre-release) → validar antes de deploy major
3. **OPCIONAL**: Soak (trimestral) → validar resiliência long-term

### Custos de Execução
- **Smoke**: ~5 min → executar em todo PR (baixo custo)
- **Baseline**: ~60 min → executar em todo merge main (custo médio)
- **Stress**: ~80 min → executar on-demand (custo alto)
- **Soak**: ~240 min → executar trimestral (custo muito alto)

---

## 📝 Histórico de Versões

| Versão | Data | Autor | Mudança |
|--------|------|-------|---------|
| 1.0 | 2025-10-08 | GitHub Copilot | Criação da matriz de testes não funcionais (FASE 5) |

---

## 📚 Referências

- **UCs Individuais**: `docs/casos_de_uso/UC00X-*.md`
- **Baseline SLOs**: `docs/casos_de_uso/fase1-baseline-slos.md`
- **Roadmap**: `.github/copilot-instructions.md` (Fase 4 completa)
- **k6 Executors**: https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/
- **DummyJSON API**: https://dummyjson.com/docs

---

## ✅ Checklist de Uso

- [ ] Smoke tests executados em todo PR
- [ ] Baseline tests executados em todo merge main
- [ ] Stress tests executados antes de release major
- [ ] Soak tests executados trimestralmente
- [ ] Thresholds ajustados conforme evolução da API
- [ ] Workflows CI/CD configurados (.github/workflows/)
- [ ] Scripts de execução criados (scripts/smoke.sh, baseline.sh, stress.sh, soak.sh)
- [ ] Resultados monitorados (Grafana, k6 Cloud, ou local HTML)

**🎯 FASE 5 (Entregável 2/4) - Matriz de Testes Não Funcionais Completa**
