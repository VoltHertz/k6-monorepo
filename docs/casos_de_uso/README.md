# Casos de Uso - k6 Monorepo

## 📋 Índice de Navegação

### 🏗️ Fase 1: Análise e Levantamento ✅ COMPLETA

**Objetivo**: Mapear endpoints, personas e baseline de SLOs

| Entregável | Descrição | Status |
|------------|-----------|--------|
| [📊 Inventário de Endpoints](fase1-inventario-endpoints.csv) | 38 endpoints catalogados (Products, Auth, Users, Carts, Posts, Comments) | ✅ Completo |
| [👥 Perfis de Usuário](fase1-perfis-de-usuario.md) | 3 personas com distribuição 60/30/10 (Visitante, Comprador, Admin) | ✅ Completo |
| [⏱️ Baseline de SLOs](fase1-baseline-slos.md) | SLOs por feature (P95: 300-600ms, Error < 1%) | ✅ Completo |

**Insights da Fase 1**:
- **38 endpoints** identificados em 6 domínios
- **Distribuição de tráfego**: 60% navegação, 30% compras, 10% admin
- **SLOs iniciais**: Products P95 < 300ms, Auth P95 < 400ms, Search P95 < 600ms
- **Dependências críticas**: Auth login → operações autenticadas, Products → Carts

---

### 🎯 Fase 2: Priorização e Roadmap ✅ COMPLETA

**Objetivo**: Definir ordem de implementação baseada em criticidade e complexidade

| Entregável | Descrição | Status |
|------------|-----------|--------|
| [📊 Matriz de Priorização](fase2-matriz-priorizacao.md) | 13 UCs classificados em quadrantes (criticidade x complexidade) | ✅ Completo |
| [🗓️ Roadmap de Implementação](fase2-roadmap-implementacao.md) | 6 sprints detalhados com esforço (81h total) | ✅ Completo |
| [🔗 Mapa de Dependências](fase2-mapa-dependencias.md) | Grafo de dependências técnicas e de dados | ✅ Completo |

**Insights da Fase 2**:
- **13 UCs planejados** em 6 sprints (6 semanas)
- **Priorização**: 6 UCs P0 (prioridade máxima), 5 UCs P1-P2, 2 UCs P3
- **Dependência crítica**: UC003 (Auth) bloqueia 8 UCs (62% do total)
- **Cobertura**: 63% endpoints (24/38) - foco em reads reais, ignorando fake writes
- **Esforço total**: 81 horas (~2 semanas fulltime ou 6 semanas part-time)

---

### 📝 Fase 3: Template e Padrões ✅ COMPLETA

**Objetivo**: Criar templates reutilizáveis para documentação consistente

| Entregável | Descrição | Status |
|------------|-----------|--------|
| [📝 Template de UC](templates/use-case-template.md) | Template completo com 15 seções (~400 linhas) | ✅ Completo |
| [🎨 Guia de Estilo](templates/guia-de-estilo.md) | Convenções de nomenclatura, escrita e formatação (~600 linhas) | ✅ Completo |
| [✅ Checklist de Qualidade](templates/checklist-qualidade.md) | 78 itens de validação, critérios de aprovação (~500 linhas) | ✅ Completo |
| [📊 Guia Visual](templates/README.visual.md) | Diagramas ASCII, exemplos bons vs ruins (~500 linhas) | ✅ Completo |
| [📋 Resumo Executivo](fase3-resumo-templates.md) | Resumo da Fase 3 e próximos passos | ✅ Completo |

**Insights da Fase 3**:
- **Template UC**: 15 seções (Descrição, Endpoints, SLOs, Dados, Fluxo, Implementação, Métricas, Dependências, Libs)
- **Guia de Estilo**: Nomenclatura (UC00X, kebab-case), Escrita (imperativo, human-readable checks), Formatação (emojis, tabelas)
- **Checklist**: 78 itens em 14 grupos, validação por Tier (0/1/2), aprovação Draft→Review→Approved→Implementation
- **Qualidade**: Smoke review 5 min, critérios Essencial/Importante/Desejável
- **Total**: ~2000 linhas de padrões e exemplos

---

### ✍️ Fase 4: Escrita dos Casos de Uso (Semanas 4-9) 🔄 PENDENTE

**Objetivo**: Documentar todos os casos de uso priorizados

**Entradas prioritárias (Fases 1–3) a usar como input em todos os UCs:**
- Fase 1 — Base de requisitos e SLOs
  - [Inventário de Endpoints](fase1-inventario-endpoints.csv): fonte primária para "🔗 Endpoints Envolvidos" (método, path, domínio)
  - [Perfis de Usuário](fase1-perfis-de-usuario.md): define persona, distribuição de tráfego e orienta "📋 Descrição" e think times
  - [Baseline de SLOs](fase1-baseline-slos.md): thresholds padrão por feature para "📊 SLOs" (P95, erro, checks)
- Fase 2 — Ordem e dependências
  - [Matriz de Priorização](fase2-matriz-priorizacao.md): determina sequência/sprint de escrita e foco por criticidade
  - [Roadmap de Implementação](fase2-roadmap-implementacao.md): esforço estimado por UC; usar como referência de planejamento
  - [Mapa de Dependências](fase2-mapa-dependencias.md): preencher "🔗 Dependências" e pré-requisitos (ex.: Auth → Carts)
- Fase 3 — Padrões e qualidade (MANDATÓRIO)
  - [Template de UC](templates/use-case-template.md): seguir todas as seções obrigatórias
  - [Guia de Estilo](templates/guia-de-estilo.md): nomenclatura (UC00X, kebab-case), tags k6, métricas snake_case, formatação
  - [Checklist de Qualidade](templates/checklist-qualidade.md): validar antes de marcar como ✅ Approved
  - [Guia Visual](templates/README.visual.md): exemplos de formatação e estrutura

**Sprint 1 - Fundação** (Semana 4):
- [ ] UC001: Browse Products Catalog (4h)
- [ ] UC004: View Product Details (3h)
- [ ] UC007: Browse by Category (4h)

**Sprint 2 - Busca e Autenticação** (Semana 5):
- [ ] UC002: Search & Filter Products (6h)
- [ ] UC003: User Login & Profile (6h + `libs/http/auth.ts`)

**Sprint 3 - Carrinho** (Semana 6):
- [ ] UC005: Cart Operations (Read) (6h + `libs/data/cart-loader.ts`)

**Sprint 4 - Jornadas** (Semana 7):
- [ ] UC009: User Journey (Unauthenticated) (8h + `libs/scenarios/journey-builder.ts`)
- [ ] UC010: User Journey (Authenticated) (10h)

**Sprint 5 - Backoffice** (Semana 8):
- [ ] UC008: List Users (Admin) (5h)
- [ ] UC013: Content Moderation (Posts/Comments) (4h)

**Sprint 6 - Avançados** (Semana 9):
- [ ] UC006: Cart Operations (Write - Simulated) (6h)
- [ ] UC012: Token Refresh & Session Management (5h)
- [ ] UC011: Mixed Workload (Realistic Traffic) (12h + `libs/scenarios/workload-mixer.ts`)

**Esforço Total**: 81 horas, 13 UCs

---

### ✅ Fase 5: Validação e Refinamento (Semana 10) 🔄 PENDENTE

**Objetivo**: Revisar e ajustar casos de uso antes da implementação

**Entregáveis Planejados**:
- [ ] Todos os 13 UCs revisados e aprovados
- [ ] Ata de validação com stakeholders
- [ ] Notas de viabilidade técnica

---

### 🚀 Fase 6: Handoff para Implementação (Semana 11) 🔄 PENDENTE

**Objetivo**: Preparar documentação para time de implementação

**Entregáveis Planejados**:
- [ ] README navegável de casos de uso (este arquivo)
- [ ] Massa de teste gerada e versionada
- [ ] Guia de implementação para devs

---

## 📊 Visão Geral dos Domínios

### Produtos (Products)
- **9 endpoints** (browse, search, categorias, CRUD)
- **Prioridade**: P0 (crítico - 60% tráfego)
- **SLO**: P95 < 300ms

### Autenticação (Auth)
- **3 endpoints** (login, profile, refresh)
- **Prioridade**: P1 (importante - gate para compras)
- **SLO**: P95 < 400ms

### Usuários (Users)
- **7 endpoints** (list, search, filter, CRUD)
- **Prioridade**: P2 (secundário - 10% tráfego admin)
- **SLO**: P95 < 500ms

### Carrinhos (Carts)
- **6 endpoints** (list, read, write - simulado)
- **Prioridade**: P1 (importante - checkout)
- **SLO**: P95 < 500ms

### Posts & Comments
- **12 endpoints** (moderação de conteúdo)
- **Prioridade**: P3 (nice-to-have)
- **SLO**: P95 < 400ms

---

## 🔗 Referências

- [PRD Completo](../planejamento/PRD.md)
- [GitHub Copilot Instructions](../../.github/copilot-instructions.md)
- [DummyJSON API Docs](https://dummyjson.com/docs)
- [Plano de 6 Fases (copilot-instructions)](../../.github/copilot-instructions.md#-plano-de-escrita-dos-casos-de-uso)

---

## 📈 Progresso Geral

- ✅ **Fase 1**: 3/3 entregáveis completos (100%)
- ✅ **Fase 2**: 3/3 entregáveis completos (100%)
- ✅ **Fase 3**: 5/5 entregáveis completos (100%)
- 🔄 **Fase 4**: 0/13 UCs (0%)
- 🔄 **Fase 5**: 0/3 entregáveis (0%)
- 🔄 **Fase 6**: 0/3 entregáveis (0%)

**Total**: 11/27 itens completos (41%)  
**Fases Completas**: 3/6 (50%)  
**Timeline**: 11 semanas (3 completas, 8 pendentes)

---

_Última atualização: Fase 3 completa - Outubro 2025_
