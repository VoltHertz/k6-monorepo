# Análise de Ajustes no Planejamento - Fases 3-6

## 🔍 Análise Realizada

Com base nos entregáveis das **Fase 1** e **Fase 2**, identifiquei **inconsistências críticas** entre o roadmap detalhado e o planejamento original das Fases 3-6.

---

## ⚠️ Inconsistências Identificadas

### 1. **Numeração de UCs Conflitante**

**Problema**: Há dois esquemas de numeração diferentes:

#### Roadmap Fase 2 (correto - baseado em priorização):
- UC001: Browse Products Catalog
- UC002: Search & Filter Products
- UC003: User Login & Profile
- UC004: View Product Details
- UC005: Cart Operations (Read)
- UC006: Cart Operations (Write)
- UC007: Browse by Category
- UC008: List Users (Admin)
- UC009: User Journey (Unauthenticated)
- UC010: User Journey (Authenticated)
- UC011: Mixed Workload
- UC012: Token Refresh
- UC013: Content Moderation

#### Fase 4 Original (DESATUALIZADO):
- UC001: Browse Products Catalog ✅
- UC002: Search & Filter Products ✅
- UC003: User Login & Profile ✅
- UC004: List Users (Admin) ❌ **CONFLITO** (agora é UC008)
- UC005: Cart Operations (Read) ✅
- UC006: Cart Operations (Write) ✅
- UC007: User Journey (não autenticado) ❌ **CONFLITO** (agora é UC009)
- UC008: User Journey (autenticado) ❌ **CONFLITO** (agora é UC010)
- UC009: Mixed Workload ❌ **CONFLITO** (agora é UC011)

**Impacto**: Documentação inconsistente, confusão na implementação

---

### 2. **Organização de Sprints na Fase 4**

**Problema**: A Fase 4 original tem 4 sprints, mas o Roadmap definiu **6 sprints de implementação**.

#### Fase 4 Original (4 sprints):
- Sprint 1: UC001, UC002
- Sprint 2: UC003, UC004 (antigo)
- Sprint 3: UC005, UC006
- Sprint 4: UC007, UC008, UC009 (antigos)

#### Roadmap Fase 2 (6 sprints - CORRETO):
- Sprint 1: UC001, UC004, UC007 (Fundação)
- Sprint 2: UC002, UC003 (Busca + Auth)
- Sprint 3: UC005 (Carrinho)
- Sprint 4: UC009, UC010 (Jornadas)
- Sprint 5: UC008, UC013 (Backoffice)
- Sprint 6: UC006, UC012, UC011 (Avançados)

**Impacto**: Cronograma desalinhado, distribuição de esforço incorreta

---

### 3. **UCs Ausentes na Fase 4 Original**

**Novos UCs identificados na Fase 2**:
- ✅ UC004: View Product Details (adicionado corretamente)
- ✅ UC007: Browse by Category (adicionado corretamente)
- ✅ UC012: Token Refresh (AUSENTE na Fase 4 original)
- ✅ UC013: Content Moderation (AUSENTE na Fase 4 original)

**Impacto**: 2 UCs não estavam planejados para documentação

---

### 4. **Distribuição de Esforço Desalinhada**

#### Fase 4 Original:
- Total: 9 UCs em 4 semanas
- Sem estimativa de horas

#### Roadmap Fase 2 (CORRETO):
- Total: 13 UCs em 6 sprints
- Esforço detalhado: 81 horas
- Distribuição: 11h, 12h, 8h, 18h, 9h, 23h

**Impacto**: Planejamento de recursos incorreto

---

## ✅ Ajustes Necessários

### Ajuste 1: Atualizar Numeração de UCs na Fase 4

**De** (Fase 4 original):
```markdown
**Sprint 1 (Semana 4) - Casos Fundamentais**:
- UC001: Browse Products Catalog
- UC002: Search & Filter Products

**Sprint 2 (Semana 5) - Autenticação**:
- UC003: User Login & Profile
- UC004: List Users (Admin)  ❌ ERRADO

**Sprint 3 (Semana 6) - Operações Principais**:
- UC005: Cart Operations (Read)
- UC006: Cart Operations (Write - Simulated)

**Sprint 4 (Semana 7) - Jornadas**:
- UC007: User Journey (não autenticado)  ❌ ERRADO
- UC008: User Journey (autenticado)      ❌ ERRADO
- UC009: Mixed Workload                  ❌ ERRADO
```

**Para** (Alinhado com Roadmap):
```markdown
**Sprint 1 (Semana 4) - Fundação**:
- UC001: Browse Products Catalog
- UC004: View Product Details
- UC007: Browse by Category

**Sprint 2 (Semana 5) - Busca e Autenticação**:
- UC002: Search & Filter Products
- UC003: User Login & Profile

**Sprint 3 (Semana 6) - Carrinho**:
- UC005: Cart Operations (Read)

**Sprint 4 (Semana 7) - Jornadas**:
- UC009: User Journey (Unauthenticated)
- UC010: User Journey (Authenticated)

**Sprint 5 (Semana 8) - Backoffice**:
- UC008: List Users (Admin)
- UC013: Content Moderation

**Sprint 6 (Semana 9) - Avançados**:
- UC006: Cart Operations (Write - Simulated)
- UC012: Token Refresh & Session Management
- UC011: Mixed Workload (Realistic Traffic)
```

---

### Ajuste 2: Reorganizar Fases 4-6

**Problema**: Fases 4-6 planejadas para semanas 4-9, mas agora temos 6 sprints de implementação.

**Solução**: Redefinir escopo das fases:

#### Fase 3: Templates e Padrões (Semana 3) ✅ MANTÉM
- Criar templates de UC
- Definir convenções
- Estruturar guia de escrita

#### Fase 4: Escrita dos UCs (Semanas 4-9) ✅ AJUSTAR
- **6 sprints** ao invés de 4
- **13 UCs** ao invés de 9
- Adicionar UC012 e UC013

#### Fase 5: Validação e Refinamento (Semana 10) ✅ AJUSTAR
- Mover para semana 10 (era semana 8)
- Validar 13 UCs ao invés de 9

#### Fase 6: Handoff (Semana 11) ✅ AJUSTAR
- Mover para semana 11 (era semana 9)
- Gerar massa de teste para 13 UCs

---

### Ajuste 3: Adicionar Detalhamento de Esforço na Fase 4

Incluir estimativas de horas por UC (baseado no Roadmap):

- UC001: 4h
- UC004: 3h
- UC007: 4h
- UC002: 6h
- UC003: 6h (+ libs/http/auth.ts)
- UC005: 6h (+ libs/data/cart-loader.ts)
- UC009: 8h (+ libs/scenarios/journey-builder.ts)
- UC010: 10h
- UC008: 5h
- UC013: 4h
- UC006: 6h
- UC012: 5h
- UC011: 12h (+ libs/scenarios/workload-mixer.ts)

**Total**: 81 horas

---

### Ajuste 4: Atualizar Métricas de Progresso

**De**:
- Sprint 1: 2 UCs fundamentais (10% do total)
- Sprint 2: +2 UCs auth (30% do total)
- Sprint 3: +2 UCs CRUD (50% do total)
- Sprint 4: +3 UCs jornadas (80% do total)

**Para**:
- Sprint 1: 3 UCs fundação (23% - 3/13)
- Sprint 2: +2 UCs busca/auth (38% - 5/13)
- Sprint 3: +1 UC carrinho (46% - 6/13)
- Sprint 4: +2 UCs jornadas (62% - 8/13)
- Sprint 5: +2 UCs backoffice (77% - 10/13)
- Sprint 6: +3 UCs avançados (100% - 13/13)

---

### Ajuste 5: Atualizar Estrutura do Template de UC

Adicionar seções obrigatórias identificadas no Roadmap:

```markdown
# UC00X - [Nome do Caso de Uso]

## 📋 Descrição
[Perfil de usuário, objetivo, contexto de negócio]

## 🔗 Endpoints Envolvidos
[Lista de endpoints com método HTTP e SLO individual]

## 📊 SLOs
[Tabela com métricas, thresholds e rationale]

## 📦 Dados de Teste
[Arquivos necessários, volume, fonte, refresh strategy]

## 🔄 Fluxo Principal
[Passos numerados com requests, validações, think times]

## 🔀 Fluxos Alternativos
[Cenários de erro, edge cases]

## ⚙️ Implementação
[Onde será implementado, configs, tags]

## 🧪 Comandos de Teste
[Como executar localmente]

## 📈 Métricas Customizadas
[Trends e Counters específicos deste UC]

## ⚠️ Observações Importantes
[Limitações, dependências, particularidades]

## 🔗 Dependências  ← NOVA SEÇÃO
[UCs dependentes, libs necessárias, dados requeridos]

## 📂 Libs/Helpers Criados  ← NOVA SEÇÃO
[Se o UC criar novas libs, documentar aqui]
```

---

## 📋 Checklist de Ajustes

### Fase 3: Templates e Padrões
- [ ] Atualizar template com 13 UCs (não 9)
- [ ] Adicionar seções de Dependências e Libs
- [ ] Incluir nomenclatura UC001-UC013
- [ ] Documentar padrão de esforço (horas)

### Fase 4: Escrita dos Casos de Uso
- [ ] Reorganizar em 6 sprints (não 4)
- [ ] Renumerar UCs corretamente
- [ ] Adicionar UC012 e UC013
- [ ] Incluir estimativas de esforço
- [ ] Atualizar métricas de progresso
- [ ] Adicionar detalhamento de libs criadas

### Fase 5: Validação e Refinamento
- [ ] Mover para Semana 10 (não 8)
- [ ] Validar 13 UCs (não 9)
- [ ] Adicionar checklist de dependências

### Fase 6: Handoff para Implementação
- [ ] Mover para Semana 11 (não 9)
- [ ] Gerar dados para 13 UCs
- [ ] Incluir ordem de implementação (6 sprints)

---

## 🎯 Cronograma Atualizado

| Semana | Fase | Atividades | Entregáveis |
|--------|------|------------|-------------|
| 1 | Fase 1 ✅ | Análise e Levantamento | 3 docs (endpoints, personas, SLOs) |
| 2 | Fase 2 ✅ | Priorização e Roadmap | 3 docs (matriz, roadmap, dependências) |
| 3 | Fase 3 🔄 | Templates e Padrões | 3 docs (template, guia, checklist) |
| 4-9 | Fase 4 🔄 | Escrita dos 13 UCs | 13 UCs documentados (81h) |
| 10 | Fase 5 🔄 | Validação e Refinamento | UCs revisados, ata de validação |
| 11 | Fase 6 🔄 | Handoff para Implementação | Massa de teste, guia implementação |

**Duração Total**: 11 semanas (era 9 semanas)

---

## 🚀 Próxima Ação Recomendada

**CRÍTICO**: Atualizar `.github/copilot-instructions.md` com:

1. ✅ Numeração correta dos 13 UCs
2. ✅ 6 sprints na Fase 4 (não 4)
3. ✅ Adicionar UC012 e UC013
4. ✅ Ajustar cronograma (11 semanas, não 9)
5. ✅ Atualizar métricas de progresso
6. ✅ Adicionar detalhamento de libs criadas por UC

**Commits necessários**:
```bash
docs(planning): fix UC numbering and sprint organization
- Align Phase 4 with Phase 2 roadmap (6 sprints, not 4)
- Fix UC numbering conflicts (UC004, UC007-UC013)
- Add missing UC012 (Token Refresh) and UC013 (Content Moderation)
- Update timeline: 11 weeks total (was 9)
- Add effort estimates per UC (81h total)
```

---

## ✅ Recomendação Final

**EXECUTAR AGORA**:
1. Atualizar `copilot-instructions.md` com ajustes acima
2. Committar ajustes: `docs(planning): align phases with roadmap`
3. Prosseguir com Fase 3 usando planejamento correto
