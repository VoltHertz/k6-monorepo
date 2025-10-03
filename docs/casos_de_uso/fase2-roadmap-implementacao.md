# Roadmap de Implementação - Casos de Uso k6

## 🗓️ Visão Geral

**Duração Total**: 6 sprints (6 semanas)  
**UCs Planejados**: 13 casos de uso  
**Cobertura**: 100% do tráfego esperado, 63% dos endpoints  

---

## 📅 Sprint 1 - Fundação (Semana 1)

### Objetivo
Implementar casos de uso fundamentais para cobrir **60% do tráfego** (visitantes não autenticados)

### Casos de Uso

#### UC001 - Browse Products Catalog ⭐ P0
- **Prioridade**: Crítica (5,1)
- **Endpoints**: GET /products
- **Complexidade**: Muito Simples
- **Esforço**: 4h
- **SLO**: P95 < 300ms, Error < 0.5%
- **Dependências**: Nenhuma
- **Entregáveis**:
  - Teste k6 em `tests/api/products/browse-catalog.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC001-browse-products-catalog.md`
  - Dados de teste: 100 produtos sample

#### UC004 - View Product Details ⭐ P0
- **Prioridade**: Crítica (4,1)
- **Endpoints**: GET /products/{id}
- **Complexidade**: Muito Simples
- **Esforço**: 3h
- **SLO**: P95 < 300ms, Error < 0.5%
- **Dependências**: Nenhuma
- **Entregáveis**:
  - Teste k6 em `tests/api/products/view-product-details.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC004-view-product-details.md`
  - Dados de teste: IDs válidos (1-100)

#### UC007 - Browse by Category ⭐ P0
- **Prioridade**: Crítica (4,1)
- **Endpoints**: GET /products/categories, GET /products/category/{slug}
- **Complexidade**: Muito Simples
- **Esforço**: 4h
- **SLO**: P95 < 300ms, Error < 0.5%
- **Dependências**: Nenhuma
- **Entregáveis**:
  - Teste k6 em `tests/api/products/browse-by-category.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC007-browse-by-category.md`
  - Dados de teste: slugs de categorias

### Métricas de Sucesso Sprint 1
- ✅ 3 UCs implementados
- ✅ 60% tráfego coberto
- ✅ 8 endpoints testados
- ✅ SLOs validados (P95 < 300ms)
- ✅ CI smoke test passando

**Duração**: 5 dias úteis  
**Esforço Total**: 11h  

---

## 📅 Sprint 2 - Busca e Autenticação (Semana 2)

### Objetivo
Adicionar **descoberta de produtos** e **autenticação** (+30% tráfego)

### Casos de Uso

#### UC002 - Search & Filter Products ⭐ P0
- **Prioridade**: Crítica (5,2)
- **Endpoints**: GET /products/search
- **Complexidade**: Simples
- **Esforço**: 6h
- **SLO**: P95 < 600ms, Error < 1%
- **Dependências**: Nenhuma
- **Entregáveis**:
  - Teste k6 em `tests/api/products/search-products.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC002-search-filter-products.md`
  - Dados de teste: 50 queries realistas

#### UC003 - User Login & Profile ⭐ P0
- **Prioridade**: Crítica (4,2)
- **Endpoints**: POST /auth/login, GET /auth/me
- **Complexidade**: Simples
- **Esforço**: 6h
- **SLO**: P95 < 400ms, Error < 1%
- **Dependências**: Nenhuma
- **Entregáveis**:
  - Teste k6 em `tests/api/auth/user-login-profile.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC003-user-login-profile.md`
  - Dados de teste: 30 usuários válidos (user/pass)
  - Helper: `libs/http/auth.ts` (token management)

### Métricas de Sucesso Sprint 2
- ✅ 5 UCs implementados (acumulado)
- ✅ 90% tráfego coberto
- ✅ 12 endpoints testados
- ✅ Auth helper reutilizável criado
- ✅ CI baseline test passando

**Duração**: 5 dias úteis  
**Esforço Total**: 12h  

---

## 📅 Sprint 3 - Carrinho (Semana 3)

### Objetivo
Habilitar operações de **carrinho (read)** para pré-checkout

### Casos de Uso

#### UC005 - Cart Operations (Read) ⭐ P1
- **Prioridade**: Importante (4,2)
- **Endpoints**: GET /carts, GET /carts/{id}, GET /carts/user/{userId}
- **Complexidade**: Simples
- **Esforço**: 6h
- **SLO**: P95 < 500ms, Error < 1%
- **Dependências**: UC003 (auth required)
- **Entregáveis**:
  - Teste k6 em `tests/api/carts/cart-operations-read.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC005-cart-operations-read.md`
  - Dados de teste: cart IDs, user IDs

### Trabalho Adicional
- Refatorar auth helper para reutilização
- Criar `libs/data/cart-loader.ts` (SharedArray)
- Adicionar custom metric: `cart_load_duration_ms`

### Métricas de Sucesso Sprint 3
- ✅ 6 UCs implementados (acumulado)
- ✅ 100% tráfego transacional coberto
- ✅ 15 endpoints testados
- ✅ Cart metrics disponíveis
- ✅ Auth helper validado em produção

**Duração**: 5 dias úteis  
**Esforço Total**: 8h  

---

## 📅 Sprint 4 - Jornadas Compostas (Semana 4)

### Objetivo
Implementar **fluxos end-to-end** realistas (jornadas de usuário)

### Casos de Uso

#### UC009 - User Journey (Unauthenticated) ⭐ P0
- **Prioridade**: Crítica (5,3)
- **Endpoints**: Combina UC001 + UC002 + UC004 + UC007
- **Complexidade**: Moderada
- **Esforço**: 8h
- **SLO**: P95 < 400ms média, Error < 0.5%
- **Dependências**: UC001, UC002, UC004, UC007
- **Entregáveis**:
  - Teste k6 em `tests/scenarios/user-journey-unauthenticated.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC009-user-journey-unauthenticated.md`
  - Think times: 2-5s entre steps

#### UC010 - User Journey (Authenticated) ⭐ P1
- **Prioridade**: Importante (4,4)
- **Endpoints**: UC009 + UC003 + UC005
- **Complexidade**: Complexa
- **Esforço**: 10h
- **SLO**: P95 < 450ms média, Error < 1%
- **Dependências**: UC003, UC005, UC009
- **Entregáveis**:
  - Teste k6 em `tests/scenarios/user-journey-authenticated.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC010-user-journey-authenticated.md`
  - Think times: 3-7s entre steps
  - Session management completo

### Trabalho Adicional
- Criar `libs/scenarios/journey-builder.ts` (helper para jornadas)
- Custom metrics: `journey_duration_total_ms`, `journey_steps_completed`
- Validar distribuição think times (histograma)

### Métricas de Sucesso Sprint 4
- ✅ 8 UCs implementados (acumulado)
- ✅ Jornadas end-to-end validadas
- ✅ Think times realistas aplicados
- ✅ Session management testado
- ✅ CI stress test (1000 VUs) passando

**Duração**: 5 dias úteis  
**Esforço Total**: 18h  

---

## 📅 Sprint 5 - Operações Secundárias (Semana 5)

### Objetivo
Completar casos de **backoffice** (admin operations)

### Casos de Uso

#### UC008 - List Users (Admin) 🔄 P2
- **Prioridade**: Secundária (2,2)
- **Endpoints**: GET /users, GET /users/search, GET /users/filter
- **Complexidade**: Simples
- **Esforço**: 5h
- **SLO**: P95 < 500ms, Error < 1%
- **Dependências**: UC003 (auth admin)
- **Entregáveis**:
  - Teste k6 em `tests/api/users/list-users-admin.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC008-list-users-admin.md`
  - Dados de teste: admin credentials

#### UC013 - Content Moderation (Posts/Comments) 🔄 P3
- **Prioridade**: Nice-to-have (2,2)
- **Endpoints**: GET /posts, GET /comments
- **Complexidade**: Simples
- **Esforço**: 4h
- **SLO**: P95 < 400ms, Error < 1%
- **Dependências**: UC003 (auth moderator)
- **Entregáveis**:
  - Teste k6 em `tests/api/moderation/content-moderation.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC013-content-moderation.md`

### Métricas de Sucesso Sprint 5
- ✅ 10 UCs implementados (acumulado)
- ✅ Admin operations testadas
- ✅ 21 endpoints testados (55%)
- ✅ Paginação validada (limit/skip)

**Duração**: 5 dias úteis  
**Esforço Total**: 9h  

---

## 📅 Sprint 6 - Casos Avançados (Semana 6)

### Objetivo
Implementar **cenários avançados** e **stress realista**

### Casos de Uso

#### UC006 - Cart Operations (Write - Simulated) ⏸️ P2
- **Prioridade**: Média (3,3)
- **Endpoints**: POST /carts/add, PUT /carts/{id}, DELETE /carts/{id}
- **Complexidade**: Moderada
- **Esforço**: 6h
- **SLO**: P95 < 500ms, Error < 1%
- **Dependências**: UC003, UC005
- **Entregáveis**:
  - Teste k6 em `tests/api/carts/cart-operations-write.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC006-cart-operations-write.md`
  - **Nota**: Fake writes, não persiste

#### UC012 - Token Refresh & Session Management ⏸️ P2
- **Prioridade**: Média (3,3)
- **Endpoints**: POST /auth/refresh
- **Complexidade**: Moderada
- **Esforço**: 5h
- **SLO**: P95 < 400ms, Error < 1%
- **Dependências**: UC003
- **Entregáveis**:
  - Teste k6 em `tests/api/auth/token-refresh.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC012-token-refresh.md`
  - Helper: token refresh logic

#### UC011 - Mixed Workload (Realistic Traffic) ⏸️ P3
- **Prioridade**: Baixa (3,5)
- **Endpoints**: Mix de todos anteriores
- **Complexidade**: Muito Complexa
- **Esforço**: 12h
- **SLO**: Validar SLOs de cada feature
- **Dependências**: UC001-UC010
- **Entregáveis**:
  - Teste k6 em `tests/scenarios/mixed-workload-realistic.test.ts`
  - Documentação UC em `docs/casos_de_uso/UC011-mixed-workload.md`
  - Config: 60% visitante, 30% comprador, 10% admin
  - Think times variados por persona

### Trabalho Adicional
- Criar `configs/scenarios/stress.yaml` (1000 VUs, 30min)
- Criar `configs/scenarios/soak.yaml` (100 VUs, 2h)
- Dashboard Grafana/k6 Cloud (opcional)

### Métricas de Sucesso Sprint 6
- ✅ 13 UCs implementados (100%)
- ✅ 24 endpoints testados (63%)
- ✅ Mixed workload validado (60/30/10)
- ✅ Stress test (1000 VUs) passando
- ✅ Soak test (2h) estável

**Duração**: 5 dias úteis  
**Esforço Total**: 23h  

---

## 📊 Resumo Executivo

### Timeline Completo

```
Semana 1: Fundação          [UC001, UC004, UC007]        → 60% tráfego
Semana 2: Busca + Auth      [UC002, UC003]               → 90% tráfego
Semana 3: Carrinho          [UC005]                      → 100% transacional
Semana 4: Jornadas          [UC009, UC010]               → End-to-end
Semana 5: Backoffice        [UC008, UC013]               → Admin ops
Semana 6: Avançados         [UC006, UC012, UC011]        → Stress/Soak
```

### Esforço Total por Sprint

| Sprint | UCs | Esforço (h) | Acumulado | Cobertura |
|--------|-----|-------------|-----------|-----------|
| 1 | 3 | 11h | 11h | 60% tráfego |
| 2 | 2 | 12h | 23h | 90% tráfego |
| 3 | 1 | 8h | 31h | 100% transacional |
| 4 | 2 | 18h | 49h | Jornadas completas |
| 5 | 2 | 9h | 58h | Admin completo |
| 6 | 3 | 23h | 81h | Stress/Soak |

**Total**: 81 horas (~2 semanas de trabalho fulltime ou 6 semanas part-time)

### Cobertura de Endpoints

- **Sprint 1**: 8/38 endpoints (21%)
- **Sprint 2**: 12/38 endpoints (32%)
- **Sprint 3**: 15/38 endpoints (39%)
- **Sprint 4**: 15/38 endpoints (39%) - jornadas reutilizam
- **Sprint 5**: 21/38 endpoints (55%)
- **Sprint 6**: 24/38 endpoints (63%)

**Endpoints Não Cobertos** (14/38 - 37%):
- Posts CRUD: 5 endpoints (fake writes)
- Users CRUD: 4 endpoints (fake writes)
- Products CRUD: 3 endpoints (fake writes)
- Comments CRUD: 2 endpoints (fake writes)

**Decisão**: Ignorar writes fake que não persistem

---

## 🎯 Marcos (Milestones)

### M1 - Fundação Completa (Final Sprint 1)
- ✅ 60% tráfego coberto
- ✅ CI smoke test configurado
- ✅ Baseline SLOs validados

### M2 - Auth Habilitado (Final Sprint 2)
- ✅ 90% tráfego coberto
- ✅ Auth helper reutilizável
- ✅ CI baseline test (5min, 10 RPS)

### M3 - Transações Completas (Final Sprint 3)
- ✅ 100% tráfego transacional
- ✅ Cart operations testadas
- ✅ Custom metrics implementadas

### M4 - Jornadas End-to-End (Final Sprint 4)
- ✅ Fluxos realistas validados
- ✅ Think times calibrados
- ✅ CI stress test (1000 VUs)

### M5 - Backoffice Completo (Final Sprint 5)
- ✅ Admin operations testadas
- ✅ 55% endpoints cobertos
- ✅ Paginação validada

### M6 - Produção-Ready (Final Sprint 6)
- ✅ 13 UCs completos
- ✅ Stress/Soak validados
- ✅ 63% endpoints (foco em reads reais)
- ✅ Projeto pronto para CI/CD

---

## ⚠️ Riscos e Mitigações

### Risco 1: Dependências Auth (UC003)
- **Impacto**: 6 UCs bloqueados
- **Probabilidade**: Baixa
- **Mitigação**: Priorizar UC003 no Sprint 2, validar antes de UC005

### Risco 2: DummyJSON Fake Writes
- **Impacto**: Não é possível testar persistência
- **Probabilidade**: Alta (by design)
- **Mitigação**: Documentar limitação, focar em response validation

### Risco 3: UC011 (Mixed Workload) Complexidade
- **Impacto**: Pode estourar esforço (12h estimado)
- **Probabilidade**: Média
- **Mitigação**: Implementar por último, buffer de 1 semana extra

### Risco 4: SLOs não atingidos
- **Impacto**: Thresholds falham, CI quebra
- **Probabilidade**: Baixa
- **Mitigação**: SLOs conservadores (baseado em baseline Fase 1)

---

## 📋 Checklist de Finalização

Ao final do roadmap (Sprint 6), validar:

- [ ] 13 UCs documentados e implementados
- [ ] 24 endpoints testados (63% cobertura)
- [ ] 100% tráfego realista coberto (60/30/10)
- [ ] SLOs validados para cada UC
- [ ] CI/CD completo (smoke/baseline/stress/soak)
- [ ] Massa de teste gerada e versionada
- [ ] Dashboards configurados (k6 Cloud ou Grafana)
- [ ] Documentação técnica completa
- [ ] README atualizado com status final
- [ ] Handoff para equipe de QA/Ops

---

## 🚀 Próximos Passos (Pós-Sprint 6)

1. **Monitoramento Contínuo**: Dashboard Grafana com métricas k6
2. **Alertas**: Notificações quando P95 > 120% baseline
3. **Otimização**: Refinar thresholds baseado em 30 dias de dados
4. **Expansão**: Adicionar novos endpoints (se API crescer)
5. **Integração**: k6 Cloud para execução distribuída (opcional)
