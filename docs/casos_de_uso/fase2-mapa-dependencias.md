# Mapa de Dependências entre Casos de Uso

## 🔗 Visão Geral

Este documento mapeia todas as **dependências técnicas e de negócio** entre os casos de uso identificados. Compreender essas relações é crítico para definir a ordem de implementação e evitar bloqueios.

---

## 📊 Grafo de Dependências

### Notação
- **→** : Depende de (requer implementação prévia)
- **⇢** : Usa opcionalmente (pode reutilizar mas não é obrigatório)
- **[D]** : Dependência de dados (massa de teste compartilhada)
- **[T]** : Dependência técnica (lib, helper, config)

---

## 🎯 Casos de Uso Independentes (Tier 0)

Estes UCs **não possuem dependências** e podem ser implementados primeiro:

### UC001 - Browse Products Catalog
- **Dependências**: Nenhuma ✅
- **Fornece para**:
  - UC009 (User Journey Unauthenticated)
  - UC010 (User Journey Authenticated)
  - UC011 (Mixed Workload)
- **Dados**: `data/test-data/products-sample.json` [D]
- **Libs**: Nenhuma necessária

### UC002 - Search & Filter Products
- **Dependências**: Nenhuma ✅
- **Fornece para**:
  - UC009 (User Journey Unauthenticated)
  - UC010 (User Journey Authenticated)
  - UC011 (Mixed Workload)
- **Dados**: `data/test-data/search-queries.json` [D]
- **Libs**: Nenhuma necessária

### UC004 - View Product Details
- **Dependências**: Nenhuma ✅
- **Fornece para**:
  - UC009 (User Journey Unauthenticated)
  - UC010 (User Journey Authenticated)
  - UC011 (Mixed Workload)
- **Dados**: `data/test-data/product-ids.json` [D]
- **Libs**: Nenhuma necessária

### UC007 - Browse by Category
- **Dependências**: Nenhuma ✅
- **Fornece para**:
  - UC009 (User Journey Unauthenticated)
  - UC010 (User Journey Authenticated)
  - UC011 (Mixed Workload)
- **Dados**: `data/test-data/categories.json` [D]
- **Libs**: Nenhuma necessária

---

## 🔐 Casos de Uso com Dependência em Auth (Tier 1)

Estes UCs **requerem autenticação** implementada (UC003):

### UC003 - User Login & Profile
- **Dependências**: Nenhuma ✅ (implementar primeiro no Tier 1)
- **Fornece para**:
  - UC005 (Cart Read) → [T] `libs/http/auth.ts`
  - UC006 (Cart Write) → [T] `libs/http/auth.ts`
  - UC008 (List Users Admin) → [T] `libs/http/auth.ts`
  - UC010 (User Journey Auth) → [T] `libs/http/auth.ts`
  - UC012 (Token Refresh) → [T] `libs/http/auth.ts`
  - UC013 (Content Moderation) → [T] `libs/http/auth.ts`
  - UC011 (Mixed Workload) → [T] `libs/http/auth.ts`
- **Dados**: `data/test-data/users-credentials.csv` [D]
- **Libs Criadas**: 
  - `libs/http/auth.ts` [T] (login, getToken, refreshToken)
  - `libs/data/user-loader.ts` [D] (SharedArray de usuários)

### UC005 - Cart Operations (Read)
- **Dependências**:
  - UC003 (User Login & Profile) → [T] auth helper
- **Fornece para**:
  - UC006 (Cart Write) → [D] cart IDs existentes
  - UC010 (User Journey Auth) → reutiliza fluxo
  - UC011 (Mixed Workload) → reutiliza fluxo
- **Dados**: 
  - `data/test-data/cart-ids.json` [D]
  - `data/test-data/users-with-carts.json` [D]
- **Libs Usadas**: `libs/http/auth.ts` [T]

### UC006 - Cart Operations (Write - Simulated)
- **Dependências**:
  - UC003 (User Login & Profile) → [T] auth helper
  - UC005 (Cart Read) → [D] cart IDs para update/delete
- **Fornece para**:
  - UC010 (User Journey Auth) ⇢ pode incluir add-to-cart
  - UC011 (Mixed Workload) ⇢ pode incluir write operations
- **Dados**: 
  - Reusa `data/test-data/product-ids.json` [D]
  - Reusa `data/test-data/cart-ids.json` [D]
- **Libs Usadas**: `libs/http/auth.ts` [T]
- **⚠️ Limitação**: Writes não persistem (DummyJSON fake)

### UC008 - List Users (Admin)
- **Dependências**:
  - UC003 (User Login & Profile) → [T] auth helper (admin role)
- **Fornece para**:
  - UC011 (Mixed Workload) ⇢ fluxo admin
- **Dados**: 
  - `data/test-data/admin-credentials.json` [D]
- **Libs Usadas**: `libs/http/auth.ts` [T]

### UC012 - Token Refresh & Session Management
- **Dependências**:
  - UC003 (User Login & Profile) → [T] auth helper (extend)
- **Fornece para**:
  - UC010 (User Journey Auth) ⇢ sessões longas
  - UC011 (Mixed Workload) ⇢ resiliência auth
- **Dados**: Reusa credentials de UC003
- **Libs Usadas**: 
  - `libs/http/auth.ts` [T] (extend com refresh logic)

### UC013 - Content Moderation (Posts/Comments)
- **Dependências**:
  - UC003 (User Login & Profile) → [T] auth helper (moderator role)
- **Fornece para**:
  - UC011 (Mixed Workload) ⇢ fluxo moderador
- **Dados**: 
  - `data/test-data/moderator-credentials.json` [D]
- **Libs Usadas**: `libs/http/auth.ts` [T]

---

## 🛤️ Casos de Uso Compostos (Tier 2)

Estes UCs **combinam múltiplos UCs anteriores** em jornadas:

### UC009 - User Journey (Unauthenticated)
- **Dependências**:
  - UC001 (Browse Products) → step 1: listar produtos
  - UC007 (Browse by Category) → step 2: filtrar categoria
  - UC002 (Search Products) → step 3: buscar
  - UC004 (View Details) → step 4: ver detalhes
- **Fornece para**:
  - UC010 (User Journey Auth) → fluxo base antes de auth
  - UC011 (Mixed Workload) → persona "Visitante" (60%)
- **Dados**: Combina dados dos UCs dependentes
- **Libs Criadas**: 
  - `libs/scenarios/journey-builder.ts` [T] (orquestração de steps)

### UC010 - User Journey (Authenticated)
- **Dependências**:
  - UC009 (User Journey Unauth) → fluxo base de navegação
  - UC003 (User Login & Profile) → step auth
  - UC005 (Cart Read) → step carrinho
  - UC006 (Cart Write) ⇢ opcional: add-to-cart
- **Fornece para**:
  - UC011 (Mixed Workload) → persona "Comprador" (30%)
- **Dados**: Combina dados dos UCs dependentes
- **Libs Usadas**: 
  - `libs/scenarios/journey-builder.ts` [T]
  - `libs/http/auth.ts` [T]

### UC011 - Mixed Workload (Realistic Traffic)
- **Dependências** (TODAS):
  - UC001, UC002, UC004, UC007 → fluxos visitante
  - UC003, UC005, UC006 → fluxos comprador
  - UC008, UC013 → fluxos admin/moderador
  - UC009 (User Journey Unauth) → persona visitante (60%)
  - UC010 (User Journey Auth) → persona comprador (30%)
  - UC012 (Token Refresh) ⇢ opcional: resiliência
- **Fornece para**: Nenhum (é o UC final)
- **Dados**: Combina TODOS os dados anteriores
- **Libs Usadas**: 
  - `libs/scenarios/journey-builder.ts` [T]
  - `libs/http/auth.ts` [T]
  - `libs/scenarios/workload-mixer.ts` [T] (distribuição 60/30/10)

---

## 📋 Tabela Resumida de Dependências

| UC | Nome | Tier | Depende de | Fornece para | Libs Criadas/Usadas |
|----|------|------|------------|--------------|---------------------|
| UC001 | Browse Products | 0 | - | UC009, UC010, UC011 | - |
| UC002 | Search Products | 0 | - | UC009, UC010, UC011 | - |
| UC004 | View Details | 0 | - | UC009, UC010, UC011 | - |
| UC007 | Browse Category | 0 | - | UC009, UC010, UC011 | - |
| UC003 | Login & Profile | 1 | - | UC005-UC013, UC010, UC011 | `auth.ts`, `user-loader.ts` |
| UC005 | Cart Read | 1 | UC003 | UC006, UC010, UC011 | (usa `auth.ts`) |
| UC006 | Cart Write | 1 | UC003, UC005 | UC010, UC011 | (usa `auth.ts`) |
| UC008 | List Users Admin | 1 | UC003 | UC011 | (usa `auth.ts`) |
| UC012 | Token Refresh | 1 | UC003 | UC010, UC011 | (estende `auth.ts`) |
| UC013 | Content Mod | 1 | UC003 | UC011 | (usa `auth.ts`) |
| UC009 | Journey Unauth | 2 | UC001, UC002, UC004, UC007 | UC010, UC011 | `journey-builder.ts` |
| UC010 | Journey Auth | 2 | UC003, UC005, UC009 | UC011 | (usa `journey-builder.ts`, `auth.ts`) |
| UC011 | Mixed Workload | 2 | TODOS anteriores | - | `workload-mixer.ts` |

---

## 🔧 Dependências de Libs e Helpers

### `libs/http/auth.ts` (Criada em UC003)
**Usado por**: UC005, UC006, UC008, UC010, UC012, UC013, UC011

**Funções**:
- `login(username, password)` → retorna token
- `getToken()` → retorna token válido (com cache)
- `refreshToken(refreshToken)` → renova token
- `getAuthHeaders()` → retorna headers com Bearer token

**Dependências**:
- k6 `http`
- `libs/data/user-loader.ts`

### `libs/data/user-loader.ts` (Criada em UC003)
**Usado por**: UC003, UC005, UC006, UC008, UC010, UC011

**Funções**:
- `loadUsers()` → SharedArray de usuários
- `getRandomUser(role?)` → retorna user aleatório
- `getUserById(id)` → retorna user específico

**Dependências**:
- k6 `data` (SharedArray)
- `data/test-data/users-credentials.csv`

### `libs/scenarios/journey-builder.ts` (Criada em UC009)
**Usado por**: UC009, UC010, UC011

**Funções**:
- `createJourney(steps)` → orquestra sequência de steps
- `addThinkTime(min, max)` → adiciona sleep aleatório
- `validateStep(response, checks)` → valida cada step
- `trackJourneyMetrics()` → custom metrics de jornada

**Dependências**:
- k6 `http`, `check`, `sleep`
- k6 `metrics` (Trend, Counter)

### `libs/scenarios/workload-mixer.ts` (Criada em UC011)
**Usado por**: UC011

**Funções**:
- `selectPersona()` → retorna 'visitante' (60%), 'comprador' (30%), 'admin' (10%)
- `executePersonaFlow(persona)` → executa fluxo da persona
- `getPersonaThinkTime(persona)` → retorna think time adequado

**Dependências**:
- Todos os UCs anteriores
- `libs/scenarios/journey-builder.ts`
- `libs/http/auth.ts`

---

## 📦 Dependências de Dados de Teste

### Tier 0 - Dados Base (Criados na Fase 1)
- `data/test-data/products-sample.json` [UC001]
- `data/test-data/product-ids.json` [UC004]
- `data/test-data/categories.json` [UC007]
- `data/test-data/search-queries.json` [UC002]

### Tier 1 - Dados de Auth (Criados em UC003)
- `data/test-data/users-credentials.csv` [UC003, UC005, UC006, UC010, UC011]
- `data/test-data/admin-credentials.json` [UC008]
- `data/test-data/moderator-credentials.json` [UC013]

### Tier 1 - Dados de Carrinho (Criados em UC005)
- `data/test-data/cart-ids.json` [UC005, UC006]
- `data/test-data/users-with-carts.json` [UC005, UC010]

### Tier 2 - Dados Compostos (Gerados em UC009/UC010)
- `data/test-data/journey-scenarios.json` [UC009, UC010]
- `data/test-data/persona-profiles.json` [UC011]

---

## 🚦 Ordem de Implementação Recomendada

### Fase 1 - Independentes (Tier 0)
**Ordem**: Qualquer (paralelo possível)
1. UC001 - Browse Products
2. UC004 - View Details
3. UC007 - Browse Category
4. UC002 - Search Products

**Bloqueios**: Nenhum ✅

### Fase 2 - Dependentes de Auth (Tier 1)
**Ordem**: UC003 PRIMEIRO, depois paralelo
5. UC003 - Login & Profile ⚠️ **BLOQUEADOR**
6. UC005 - Cart Read (após UC003)
7. UC008 - List Users Admin (após UC003, paralelo com UC005)
8. UC013 - Content Moderation (após UC003, paralelo)
9. UC006 - Cart Write (após UC003 + UC005)
10. UC012 - Token Refresh (após UC003, paralelo)

**Bloqueios**: UC003 bloqueia todos os demais

### Fase 3 - Jornadas Compostas (Tier 2)
**Ordem**: Sequencial (dependências em cadeia)
11. UC009 - Journey Unauthenticated (após UC001, UC002, UC004, UC007)
12. UC010 - Journey Authenticated (após UC009 + UC003 + UC005)
13. UC011 - Mixed Workload (após TODOS)

**Bloqueios**: UC009 bloqueia UC010, que bloqueia UC011

---

## ⚠️ Bloqueadores Críticos

### Bloqueador 1: UC003 (Auth) ⛔
**Impacto**: 8 UCs bloqueados (UC005, UC006, UC008, UC010, UC012, UC013, UC011)  
**Mitigação**: 
- Priorizar UC003 no Sprint 2 (antes de qualquer UC Tier 1)
- Validar `libs/http/auth.ts` antes de prosseguir
- Criar massa de teste (users-credentials.csv) junto

### Bloqueador 2: UC009 (Journey Unauth) ⛔
**Impacto**: 2 UCs bloqueados (UC010, UC011)  
**Mitigação**:
- Implementar após todos UCs Tier 0 completos
- Validar `libs/scenarios/journey-builder.ts` antes de UC010
- Think times devem estar calibrados

### Bloqueador 3: Massa de Teste ⚠️
**Impacto**: UCs não podem executar sem dados
**Mitigação**:
- Gerar dados junto com implementação do UC
- Versionar em Git (para reprodutibilidade)
- Criar geradores em `data/test-data/generators/` (Fase 6)

---

## 📊 Análise de Impacto (Caso UC Falhe)

### Se UC003 (Auth) falhar:
- ❌ 8 UCs bloqueados (62% do total)
- ❌ Impossível testar fluxos autenticados
- ⚠️ **Ação**: Revalidar baseline SLOs de auth, simplificar se necessário

### Se UC009 (Journey Unauth) falhar:
- ❌ 2 UCs bloqueados (UC010, UC011)
- ⚠️ Jornadas compostas não validadas
- ✅ UCs individuais (Tier 0 e Tier 1) não afetados
- **Ação**: Dividir UC009 em mini-jornadas menores

### Se UC011 (Mixed Workload) falhar:
- ✅ Nenhum UC bloqueado (é o último)
- ⚠️ Teste realista de produção não validado
- **Ação**: Simplificar distribuição (ex: 50/50 ao invés de 60/30/10)

---

## ✅ Checklist de Validação de Dependências

Antes de implementar um UC, verificar:

- [ ] Todos os UCs dependentes estão completos?
- [ ] Libs necessárias foram criadas/testadas?
- [ ] Dados de teste estão disponíveis?
- [ ] Helpers de autenticação funcionam?
- [ ] SLOs dos UCs dependentes estão validados?
- [ ] Não há bloqueadores técnicos (API down, bugs)?

---

## 🔗 Referências Cruzadas

- **Matriz de Priorização**: `fase2-matriz-priorizacao.md`
- **Roadmap**: `fase2-roadmap-implementacao.md`
- **Inventário de Endpoints**: `fase1-inventario-endpoints.csv`
- **SLOs Baseline**: `fase1-baseline-slos.md`
