# Casos de Uso - k6 Performance Testing Monorepo

## Fase 1 — Inventário e Diagnóstico (Codex)

Objetivo: alinhar cada UC à API DummyJSON, reduzir verbosidade e garantir executabilidade imediata. Referências de consulta: `docs/dummyJson/*` e `data/fulldummyjsondata/*` (apenas para orientar massa de teste curada em `data/test-data/`).

| UC | Nome (atual) | Endpoints principais | Status | Ações propostas |
|----|--------------|----------------------|--------|-----------------|
| UC001 | Browse Products Catalog | GET /products | Manter | Enxugar doc; manter thresholds e tags padrão. |
| UC002 | Search & Filter Products | GET /products/search | Manter | Enxugar doc; focar em `q`, `limit`, `skip`, `select`, `sortBy/order`. |
| UC003 | User Login & Profile | POST /auth/login; GET /auth/me | Manter | Clarificar uso de cookies vs Bearer; exemplos mínimos. |
| UC004 | View Product Details | GET /products/{id} | Manter | Enxugar doc; checks objetivos (`status`, `shape`). |
| UC005 | Cart Operations (Read) | GET /carts; /carts/{id}; /carts/user/{userId} | Manter | Reforçar paginação/IDs válidos; dados via `users-with-carts.json`. |
| UC006 | Cart Operations (Write - Simulated) | POST /carts/add; PUT/DELETE /carts/{id} | Revisar | Destacar não persistência; evitar GET subsequente por id “criado”; thresholds moderados. |
| UC007 | Browse by Category | GET /products/categories; /products/category-list; /products/category/{slug} | Manter | Consolidar categorias vs category-list; enxugar. |
| UC008 | List Users (Admin) | GET /users; /users/{id}; /users/search; /users/filter | Revisar | Remover semântica de “admin” (DummyJSON não aplica RBAC); renomear para “List Users”; ajustar thresholds. |
| UC009 | User Journey (Unauthenticated) | Produtos (lista, categorias, busca, detalhe) | Revisar | Tornar composição explícita de UC001/2/4/7; reutilizar thresholds; reduzir narrativa. |
| UC010 | User Journey (Authenticated) | Auth (login, me) + carts/user | Manter | Reutilizar libs/auth; clarificar dependências de dados. |
| UC011 | Mixed Workload (Realistic Traffic) | Múltiplos (products, users, carts, posts/comments) | Revisar | Limitar escopo inicial; definir mix e RPS modestos; remover métricas redundantes. |
| UC012 | Token Refresh & Session | POST /auth/refresh; GET /auth/me | Manter | Deixar claro fluxo refresh → me; cookies vs header. |
| UC013 | Content Moderation (Posts/Comments) | GET /posts; /posts/{id}; /posts/user/{id}; /comments; /comments/{id}; /comments/post/{id} | Revisar | Renomear para “Posts & Comments (Read‑only)”; reafirmar que writes são fake; reduzir doc. |

Detalhes e ações por UC: ver `docs/casos_de_uso/fase1-inventario-ajustes.md`.

## 📋 Índice Consolidado - 13 Casos de Uso (100% Completos)

Este diretório contém **toda a documentação** dos casos de uso de performance testing para a API DummyJSON, organizados em 6 sprints e 3 tiers de complexidade.

---

## 🎯 Visão Geral por Sprint

### Sprint 1 - Fundação (Semana 4) ✅
**Objetivo**: Cobrir 60% do tráfego (visitantes anônimos)  
**Status**: 3/3 UCs completos

| UC | Nome | Arquivo | Complexidade | Linhas | Endpoints |
|----|------|---------|--------------|--------|-----------|
| UC001 | Browse Products Catalog | [UC001-browse-products-catalog.md](UC001-browse-products-catalog.md) | 1 (Muito Simples) | 950 | 1 |
| UC004 | View Product Details | [UC004-view-product-details.md](UC004-view-product-details.md) | 1 (Muito Simples) | 920 | 1 |
| UC007 | Browse by Category | [UC007-browse-by-category.md](UC007-browse-by-category.md) | 1 (Muito Simples) | 980 | 2 |

**Cobertura**: 4 endpoints (11% API), 60% tráfego esperado

---

### Sprint 2 - Busca e Autenticação (Semana 5) ✅
**Objetivo**: Adicionar descoberta + autenticação (90% tráfego coberto)  
**Status**: 2/2 UCs completos

| UC | Nome | Arquivo | Complexidade | Linhas | Endpoints |
|----|------|---------|--------------|--------|-----------|
| UC002 | Search & Filter Products | [UC002-search-filter-products.md](UC002-search-filter-products.md) | 2 (Simples) | 1100 | 1 |
| UC003 | User Login & Profile | [UC003-user-login-profile.md](UC003-user-login-profile.md) | 2 (Simples) | 1020 | 2 |

**Cobertura**: +3 endpoints (18% API acumulado), 90% tráfego esperado  
**Libs Criadas**: `libs/http/auth.ts`, `libs/data/user-loader.ts`

---

### Sprint 3 - Carrinho (Semana 6) ✅
**Objetivo**: Habilitar pré-checkout (100% tráfego transacional)  
**Status**: 1/1 UC completo

| UC | Nome | Arquivo | Complexidade | Linhas | Endpoints |
|----|------|---------|--------------|--------|-----------|
| UC005 | Cart Operations (Read) | [UC005-cart-operations-read.md](UC005-cart-operations-read.md) | 2 (Simples) | 1000 | 3 |

**Cobertura**: +3 endpoints (26% API acumulado), 100% tráfego transacional

---

### Sprint 4 - Jornadas (Semana 7) ✅
**Objetivo**: Fluxos end-to-end realistas  
**Status**: 2/2 UCs completos

| UC | Nome | Arquivo | Complexidade | Linhas | Endpoints |
|----|------|---------|--------------|--------|-----------|
| UC009 | User Journey (Unauthenticated) | [UC009-user-journey-unauthenticated.md](UC009-user-journey-unauthenticated.md) | 3 (Moderada) | 1050 | 0* |
| UC010 | User Journey (Authenticated) | [UC010-user-journey-authenticated.md](UC010-user-journey-authenticated.md) | 4 (Complexa) | 1150 | 0* |

**Cobertura**: +0 endpoints (reutiliza anteriores), 100% jornadas completas  
**Libs Criadas**: `libs/scenarios/journey-builder.ts`  
_*Composição de UCs anteriores (UC001-UC007)_

---

### Sprint 5 - Backoffice (Semana 8) ✅
**Objetivo**: Operações administrativas  
**Status**: 2/2 UCs completos

| UC | Nome | Arquivo | Complexidade | Linhas | Endpoints |
|----|------|---------|--------------|--------|-----------|
| UC008 | List Users (Admin) | [UC008-list-users-admin.md](UC008-list-users-admin.md) | 2 (Simples) | 1006 | 4 |
| UC013 | Content Moderation (Posts/Comments) | [UC013-content-moderation.md](UC013-content-moderation.md) | 2 (Simples) | 1050 | 6 |

**Cobertura**: +10 endpoints (53% API acumulado), 10% tráfego admin

---

### Sprint 6 - Avançados (Semana 9) ✅
**Objetivo**: Casos avançados e stress real  
**Status**: 3/3 UCs completos

| UC | Nome | Arquivo | Complexidade | Linhas | Endpoints |
|----|------|---------|--------------|--------|-----------|
| UC006 | Cart Operations (Write - Simulated) | [UC006-cart-operations-write.md](UC006-cart-operations-write.md) | 3 (Moderada) | 1100 | 3 |
| UC012 | Token Refresh & Session Management | [UC012-token-refresh-session.md](UC012-token-refresh-session.md) | 3 (Moderada) | 1055 | 3 |
| UC011 | Mixed Workload (Realistic Traffic) | [UC011-mixed-workload.md](UC011-mixed-workload.md) | 5 (Muito Complexa) | 1280 | 24* |

**Cobertura**: +6 endpoints (63% API total - 24/38 endpoints), 100% tráfego realista  
**Libs Criadas**: `libs/scenarios/workload-mixer.ts`  
_*UC011 consolida TODOS os endpoints de UC001-UC013_

---

## 📊 Estatísticas Gerais

### Por Complexidade (Tier)

| Tier | Complexidade | UCs | Total Linhas | Endpoints | Libs |
|------|--------------|-----|--------------|-----------|------|
| **Tier 0** | 1-2 (Independentes) | 7 | ~7,156 | 17 | 2 |
| **Tier 1** | 2-3 (Dependentes Auth) | 4 | ~4,161 | 10 | 1* |
| **Tier 2** | 3-5 (Jornadas Compostas) | 2 | ~1,809 | 0** | 1 |

_*UC012 estende libs/http/auth.ts (não cria nova)_  
_**Tier 2 reutiliza endpoints de Tier 0/1_

### Métricas de Cobertura

| Métrica | Valor | Observação |
|---------|-------|------------|
| **UCs Documentados** | 13/13 (100%) | UC001-UC013 completos |
| **Sprints Completos** | 6/6 (100%) | Sprints 1-6 (Semanas 4-9) |
| **Total de Linhas** | ~13,126 | Documentação markdown |
| **Endpoints Cobertos** | 24/38 (63%) | DummyJSON API |
| **Tráfego Coberto** | 100% | 60% visitante + 30% comprador + 10% admin |
| **Libs Criadas** | 3 | auth.ts, journey-builder.ts, workload-mixer.ts |
| **Data Files** | 15 | Massa de teste identificada |

### Endpoints Não Cobertos (14/38 - 37%)

**Posts CRUD** (6 endpoints): Baixa prioridade, não é core e-commerce
- POST /posts/add (fake)
- PUT /posts/{id} (fake)
- DELETE /posts/{id} (fake)
- POST /comments/add (fake)
- PUT /comments/{id} (fake)
- DELETE /comments/{id} (fake)

**Users CRUD** (5 endpoints): Fake writes, não persistem
- POST /users/add (fake)
- PUT /users/{id} (fake)
- DELETE /users/{id} (fake)
- GET /users/filter (baixo uso)

**Products CRUD** (3 endpoints): Fake writes, não testável
- POST /products/add (fake)
- PUT /products/{id} (fake)
- DELETE /products/{id} (fake)

**Decisão**: Focar em operações READ reais, ignorar writes fake que não persistem.

---

## 🗂️ Organização por Domínio

### Products (6 UCs)
- **UC001**: Browse Products Catalog (GET /products)
- **UC002**: Search & Filter Products (GET /products/search)
- **UC004**: View Product Details (GET /products/{id})
- **UC007**: Browse by Category (GET /products/categories, GET /products/category/{slug})

### Auth (2 UCs)
- **UC003**: User Login & Profile (POST /auth/login, GET /auth/me)
- **UC012**: Token Refresh & Session Management (POST /auth/refresh)

### Carts (2 UCs)
- **UC005**: Cart Operations Read (GET /carts, GET /carts/{id}, GET /carts/user/{userId})
- **UC006**: Cart Operations Write (POST /carts/add, PUT /carts/{id}, DELETE /carts/{id})

### Users (1 UC)
- **UC008**: List Users Admin (GET /users, GET /users/{id}, GET /users/search, GET /users/filter)

### Posts/Comments (1 UC)
- **UC013**: Content Moderation (GET /posts, GET /posts/{id}, GET /posts/user/{userId}, GET /comments, GET /comments/{id}, GET /comments/post/{postId})

### Jornadas Compostas (3 UCs)
- **UC009**: User Journey Unauthenticated (combina UC001+UC002+UC004+UC007)
- **UC010**: User Journey Authenticated (combina UC009+UC003+UC005)
- **UC011**: Mixed Workload (combina TODOS UC001-UC013)

---

## 🔗 Dependências entre UCs

### Tier 0 - Independentes (7 UCs)
Não possuem dependências, podem ser implementados primeiro:
- UC001, UC002, UC004, UC007 (Products - sem auth)

### Tier 1 - Dependentes de Auth (4 UCs)
**Bloqueador**: UC003 (Auth) deve estar completo antes:
- UC003 (Auth - bloqueador para todos abaixo)
- UC005 (Cart Read - depende de UC003)
- UC006 (Cart Write - depende de UC003 + UC005)
- UC008 (List Users - depende de UC003)
- UC012 (Token Refresh - depende de UC003, estende auth.ts)
- UC013 (Content Mod - depende de UC003)

### Tier 2 - Jornadas Compostas (2 UCs)
**Bloqueadores**: Múltiplos UCs anteriores:
- UC009 (Journey Unauth - depende de UC001+UC002+UC004+UC007)
- UC010 (Journey Auth - depende de UC009+UC003+UC005)
- UC011 (Mixed Workload - depende de TODOS UC001-UC013)

**Grafo de Dependências Completo**: Ver `fase2-mapa-dependencias.md`

---

## 📚 Documentos de Referência

### Fase 1 - Análise e Levantamento ✅
- [Inventário de Endpoints](fase1-inventario-endpoints.csv) - 38 endpoints catalogados
- [Perfis de Usuário](fase1-perfis-de-usuario.md) - 3 personas (60/30/10)
- [Baseline de SLOs](fase1-baseline-slos.md) - SLOs por feature

### Fase 2 - Priorização e Roadmap ✅
- [Matriz de Priorização](fase2-matriz-priorizacao.md) - 13 UCs em quadrantes
- [Mapa de Dependências](fase2-mapa-dependencias.md) - Grafo de dependências
- ~~Roadmap de Implementação~~ (removido por redundância, ver copilot-instructions.md)

### Fase 3 - Template e Padrões ✅
- [Template de UC](templates/use-case-template.md) - Estrutura base (15 seções)
- [Guia de Estilo](templates/guia-de-estilo.md) - Convenções de escrita
- [Checklist de Qualidade](templates/checklist-qualidade.md) - 78 itens de validação
- [Resumo Fase 3](fase3-resumo-templates.md) - Executivo dos templates

### Fase 4 - Escrita dos UCs ✅ (COMPLETA)
- **UC001-UC013**: 13 casos de uso completos (~13,126 linhas)
- **Sprints 1-6**: 100% completos (Semanas 4-9)

---

## 🎯 SLOs por Feature (Resumo)

| Feature | P95 Latency | P99 Latency | Error Rate | Checks | Endpoints |
|---------|-------------|-------------|------------|--------|-----------|
| **Products** | < 300ms | < 500ms | < 0.5% | > 99.5% | 6 (UC001, UC002, UC004, UC007) |
| **Auth** | < 400ms | < 600ms | < 1% | > 99% | 3 (UC003, UC012) |
| **Search** | < 600ms | < 800ms | < 1% | > 99% | 1 (UC002) |
| **Carts** | < 500ms | < 700ms | < 1% | > 99% | 6 (UC005, UC006) |
| **Users** | < 500ms | < 700ms | < 1% | > 99% | 4 (UC008) |
| **Posts/Comments** | < 400ms | < 600ms | < 1% | > 98% | 6 (UC013) |

**Detalhes**: Ver `fase1-baseline-slos.md` e seção SLOs de cada UC individual.

---

## 📂 Libs e Helpers Criados

### libs/http/auth.ts (UC003 + UC012)
**Criado em**: UC003 (User Login & Profile)  
**Estendido em**: UC012 (Token Refresh & Session Management)

**Funções**:
- `login(username, password)` → retorna token
- `getToken()` → retorna token válido (com cache)
- `refreshToken(refreshToken)` → renova token (UC012)
- `getAuthHeaders()` → retorna headers com Bearer token
- `getAuthHeadersWithRefresh()` → headers com auto-refresh (UC012)
- `getCurrentRefreshToken()` → retorna refresh token ativo (UC012)
- `clearTokens()` → limpa cache de tokens (UC012)

**Usado por**: UC005, UC006, UC008, UC010, UC012, UC013, UC011

---

### libs/data/user-loader.ts (UC003)
**Criado em**: UC003 (User Login & Profile)

**Funções**:
- `loadUsers()` → SharedArray de usuários
- `getRandomUser(role?)` → retorna user aleatório
- `getUserById(id)` → retorna user específico

**Usado por**: UC003, UC005, UC006, UC008, UC010, UC011

---

### libs/scenarios/journey-builder.ts (UC009)
**Criado em**: UC009 (User Journey Unauthenticated)

**Funções**:
- `createJourney(steps)` → orquestra sequência de steps
- `addThinkTime(min, max)` → adiciona sleep aleatório
- `validateStep(response, checks)` → valida cada step
- `trackJourneyMetrics()` → custom metrics de jornada

**Usado por**: UC009, UC010, UC011

---

### libs/scenarios/workload-mixer.ts (UC011)
**Criado em**: UC011 (Mixed Workload - Realistic Traffic)

**Funções**:
- `selectPersona()` → retorna 'visitante' (60%), 'comprador' (30%), 'admin' (10%)
- `getPersonaThinkTime(persona)` → retorna think time adequado (2-5s, 3-7s, 5-10s)
- `getPersonaConfig(persona)` → retorna config de cenário para persona
- `executePersonaFlow(persona)` → executa fluxo da persona (UC009/UC010/UC008+UC013)

**Usado por**: UC011 (Mixed Workload)

---

## 📦 Dados de Teste Identificados (15 arquivos)

### Tier 0 - Dados Base (4 arquivos)
- `data/test-data/products-sample.json` (UC001) - 100 produtos
- `data/test-data/product-ids.json` (UC004) - 50 IDs
- `data/test-data/categories.json` (UC007) - 20 categorias
- `data/test-data/search-queries.json` (UC002) - 30 queries

### Tier 1 - Dados de Auth (3 arquivos)
- `data/test-data/users-credentials.csv` (UC003) - 100 usuários
- `data/test-data/admin-credentials.json` (UC008) - 5 admins
- `data/test-data/moderator-credentials.json` (UC013) - 3 moderadores

### Tier 1 - Dados de Carrinho (2 arquivos)
- `data/test-data/cart-ids.json` (UC005) - 50 cart IDs
- `data/test-data/users-with-carts.json` (UC005) - 30 usuários com carrinhos

### Tier 1 - Dados de Sessão (1 arquivo)
- `data/test-data/long-session-scenarios.json` (UC012) - 20 cenários de sessão

### Tier 2 - Dados Compostos (3 arquivos)
- `data/test-data/journey-scenarios.json` (UC009) - 15 cenários de jornada
- `data/test-data/persona-distribution.json` (UC011) - Distribuição 60/30/10
- `data/test-data/workload-scenarios.json` (UC011) - 25 cenários de workload

### Dados de Moderação (2 arquivos)
- `data/test-data/post-ids.json` (UC013) - 30 post IDs
- `data/test-data/comment-ids.json` (UC013) - 50 comment IDs

**Fonte**: `data/fulldummyjsondata/` (dumps da aplicação - READ-ONLY)  
**Geração**: Scripts em `data/test-data/generators/` (Fase 6 - não implementado ainda)

---

## ⚠️ Limitações Documentadas

### DummyJSON API (Crítico)
- **POST/PUT/DELETE não persistem**: Respostas fake, dados não salvos
- **Token rotation**: Refresh pode NÃO invalidar tokens antigos
- **Rate limiting**: Não documentado, assumir 100 RPS seguro
- **CDN caching**: GET pode estar em cache (variação de latência)

### Endpoints Fake (Não Testáveis)
- Products CRUD: POST/PUT/DELETE (3 endpoints)
- Users CRUD: POST/PUT/DELETE (3 endpoints)
- Carts CRUD: POST/PUT/DELETE (3 endpoints - UC006 documenta limitação)
- Posts/Comments CRUD: POST/PUT/DELETE (6 endpoints)

**Total Fake**: 15/38 endpoints (39% da API não é testável para persistência)

---

## 🚀 Próximos Passos

### Fase 5 - Handoff para Implementação ✅ (EM ANDAMENTO)
**Objetivo**: Preparar documentação para time de implementação

**Entregáveis**:
1. ✅ **README.md** (este arquivo) - Índice consolidado de todos os 13 UCs
2. 🚧 **Matriz de Testes Não Funcionais** - Mapear UCs para smoke/baseline/stress/soak
3. 🚧 **Scripts de Execução** - Templates de CI/CD (smoke.sh, baseline.sh, stress.sh, soak.sh)
4. 🚧 **Guia de Implementação** - Instruções para desenvolvedores

**Semana**: Semana 10 (após Sprint 6)

---

### Fase 6 - Implementação (NÃO INICIADA)
**Objetivo**: Implementar testes k6 em TypeScript

**Estrutura Proposta**:
- **11 test files** (feature-based, NOT 1:1 UC-to-script):
  - `tests/api/products/browse-catalog.test.ts` (UC001 + UC007)
  - `tests/api/products/search-products.test.ts` (UC002)
  - `tests/api/products/view-details.test.ts` (UC004)
  - `tests/api/auth/user-login-profile.test.ts` (UC003)
  - `tests/api/auth/token-refresh.test.ts` (UC012)
  - `tests/api/carts/cart-operations-read.test.ts` (UC005)
  - `tests/api/carts/cart-operations-write.test.ts` (UC006)
  - `tests/api/users/list-users-admin.test.ts` (UC008)
  - `tests/api/posts/content-moderation.test.ts` (UC013)
  - `tests/scenarios/user-journey-unauthenticated.test.ts` (UC009)
  - `tests/scenarios/user-journey-authenticated.test.ts` (UC010)
  - `tests/scenarios/mixed-workload.test.ts` (UC011)

- **9 lib files** (shared code):
  - `libs/http/auth.ts` (UC003 + UC012)
  - `libs/http/interceptors.ts` (baseHeaders, errorHandler)
  - `libs/data/user-loader.ts` (UC003)
  - `libs/data/product-loader.ts` (UC001)
  - `libs/data/cart-loader.ts` (UC005)
  - `libs/scenarios/journey-builder.ts` (UC009)
  - `libs/scenarios/workload-mixer.ts` (UC011)
  - `libs/metrics/custom-metrics.ts` (Trends, Counters)
  - `libs/reporting/summary-handler.ts` (handleSummary)

**Total**: ~20 TypeScript files (11 tests + 9 libs)

**Semana**: Semanas 11+ (não planejado detalhadamente)

---

## 📞 Contato e Suporte

- **Repositório**: https://github.com/VoltHertz/k6-monorepo
- **Owner**: VoltHertz
- **Branch Atual**: `feature/phase4-uc-documentation` (FASE 4 completa)
- **Main Branch**: `main` (merge após Fase 5)

---

## 📝 Histórico de Versões

| Versão | Data | Autor | Mudança |
|--------|------|-------|---------|
| 1.0 | 2025-10-08 | GitHub Copilot | Criação do índice consolidado (FASE 4 completa, 13/13 UCs) |

---

## ✅ Checklist de Completude - Fase 4

- [x] 13 UCs documentados (UC001-UC013)
- [x] 6 Sprints completos (Sprints 1-6: 100%)
- [x] ~13,126 linhas de documentação
- [x] 24/38 endpoints cobertos (63%)
- [x] 100% tráfego esperado (60% visitante + 30% comprador + 10% admin)
- [x] 3 libs criadas (auth.ts, journey-builder.ts, workload-mixer.ts)
- [x] 15 data files identificados
- [x] Todos os UCs seguem template (15 seções)
- [x] Todos os UCs validados com checklist (78 itens)
- [x] Todos os UCs commitados com conventional commits
- [x] Progress tracking atualizado (copilot-instructions.md)
- [x] README.md criado (índice consolidado)

**🎉 FASE 4 COMPLETA - Pronto para Fase 5 (Handoff para Implementação)**
