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

### 📝 Fase 3: Template e Padrões (Semana 3) 🔄 PENDENTE

**Objetivo**: Criar templates reutilizáveis para documentação consistente

**Entregáveis Planejados**:
- [ ] Template markdown completo (`templates/use-case-template.md`)
- [ ] Guia de estilo para escrita de UCs
- [ ] Checklist de revisão de qualidade

---

### ✍️ Fase 4: Escrita dos Casos de Uso (Semanas 4-7) 🔄 PENDENTE

**Objetivo**: Documentar todos os casos de uso priorizados

**Sprint 1 - Casos Fundamentais** (Semana 4):
- [ ] UC001: Browse Products Catalog
- [ ] UC002: Search & Filter Products

**Sprint 2 - Autenticação** (Semana 5):
- [ ] UC003: User Login & Profile
- [ ] UC004: List Users (Admin)

**Sprint 3 - Operações Principais** (Semana 6):
- [ ] UC005: Cart Operations (Read)
- [ ] UC006: Cart Operations (Write - Simulated)

**Sprint 4 - Jornadas** (Semana 7):
- [ ] UC007: User Journey (não autenticado)
- [ ] UC008: User Journey (autenticado)
- [ ] UC009: Mixed Workload

---

### ✅ Fase 5: Validação e Refinamento (Semana 8) 🔄 PENDENTE

**Objetivo**: Revisar e ajustar casos de uso antes da implementação

**Entregáveis Planejados**:
- [ ] Todos os UCs revisados e aprovados
- [ ] Ata de validação com stakeholders
- [ ] Notas de viabilidade técnica

---

### 🚀 Fase 6: Handoff para Implementação (Semana 9) 🔄 PENDENTE

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
- 🔄 **Fase 3**: 0/3 entregáveis (0%)
- 🔄 **Fase 4**: 0/9 UCs (0%)
- 🔄 **Fase 5**: 0/3 entregáveis (0%)
- 🔄 **Fase 6**: 0/3 entregáveis (0%)

**Total**: 6/24 itens completos (25%)

---

_Última atualização: Fase 2 completa - Outubro 2025_
