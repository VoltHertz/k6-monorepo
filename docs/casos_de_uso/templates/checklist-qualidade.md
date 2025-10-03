# Checklist de Revisão de Qualidade - Casos de Uso

## 🎯 Objetivo

Este checklist garante que **todos os casos de uso** estejam completos, consistentes e prontos para implementação antes de serem aprovados.

---

## 📋 Checklist Completo

### ✅ Seção 1: Metadados e Identificação

- [ ] **ID do UC**: Segue padrão `UC00X` (3 dígitos, zero-padded)
- [ ] **Nome do Arquivo**: `UC00X-kebab-case-name.md` (máx 50 chars)
- [ ] **Status Badge**: Presente no topo (`🚧 Draft`, `🔄 In Review`, `✅ Approved`)
- [ ] **Prioridade**: Definida (P0, P1, P2, P3) e alinhada com matriz de priorização
- [ ] **Complexidade**: Definida (1-5) e alinhada com roadmap
- [ ] **Sprint**: Especificado (Sprint X, Semana Y) conforme roadmap
- [ ] **Esforço**: Estimado em horas e validado com roadmap

**Referências**:
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- Roadmap: `docs/casos_de_uso/fase2-roadmap-implementacao.md`

---

### ✅ Seção 2: Descrição e Contexto

- [ ] **Perfil de Usuário**: Claramente definido (Visitante, Comprador, Admin)
- [ ] **Distribuição de Tráfego**: Especificada (% do total) conforme perfis Fase 1
- [ ] **Objetivo de Negócio**: Descrito de forma concisa e realista
- [ ] **Contexto**: Quando e por que o UC ocorre está claro
- [ ] **Valor de Negócio**: Justificativa de importância está presente

**Referências**:
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md`

---

### ✅ Seção 3: Endpoints e API

- [ ] **Todos os Endpoints**: Listados com método HTTP (GET, POST, PUT, DELETE)
- [ ] **SLO Individual**: Cada endpoint tem threshold (P95 < Xms)
- [ ] **Observações**: Particularidades documentadas (ex: "FAKE: não persiste")
- [ ] **Total de Endpoints**: Contabilizado (READ vs WRITE)
- [ ] **Headers Obrigatórios**: Documentados (Content-Type, Authorization, etc.)
- [ ] **Query Params**: Especificados quando aplicável (limit, skip, q, etc.)
- [ ] **Request Body**: Formato JSON documentado (para POST/PUT)

**Referências**:
- Inventário de Endpoints: `docs/casos_de_uso/fase1-inventario-endpoints.csv`

---

### ✅ Seção 4: SLOs (Service Level Objectives)

- [ ] **P95 Latency**: Threshold definido e justificado
- [ ] **P99 Latency**: Threshold definido (margem de segurança)
- [ ] **Error Rate**: Threshold definido (< X%)
- [ ] **Checks**: Threshold definido (> X%)
- [ ] **Rationale**: Cada SLO tem justificativa (referência ao baseline)
- [ ] **Baseline**: Referenciado (`fase1-baseline-slos.md`)
- [ ] **Métrica Completa**: Tags incluídas (ex: `http_req_duration{feature:products}`)

**Referências**:
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md`

---

### ✅ Seção 5: Dados de Teste

- [ ] **Arquivos Necessários**: Listados com localização (`data/test-data/`)
- [ ] **Volume**: Especificado (ex: 100 items, 50 IDs)
- [ ] **Fonte**: Origem dos dados documentada (`fulldummyjsondata/` ou gerado)
- [ ] **Estratégia de Refresh**: Definida (semanal, mensal, on-demand)
- [ ] **Comando de Geração**: Incluído (se aplicável)
- [ ] **Dependências de Dados**: Identificadas (ex: requer dados de UC003)

**Notas**:
- Dados devem estar em `data/test-data/` (NÃO em `fulldummyjsondata/`)
- SharedArray deve ser usado para carregar dados (memory-efficient)

---

### ✅ Seção 6: Fluxo Principal

- [ ] **Pré-condições**: Claramente definidas
- [ ] **Steps**: Numerados sequencialmente (1, 2, 3...)
- [ ] **Request Details**: HTTP method, endpoint, headers, body documentados
- [ ] **Validações**: Checks especificados com ✅
- [ ] **Checks Human-Readable**: `'status is 200'` (não `'200'`)
- [ ] **Think Times**: Especificados (ex: `2-5s (navegação casual)`)
- [ ] **Pós-condições**: Estado esperado após fluxo documentado
- [ ] **Máximo 10 Steps**: Fluxo não é excessivamente longo

**Regras**:
- Think times baseados em perfis de usuário (Fase 1)
- Validações devem ser testáveis com k6 `check()`

---

### ✅ Seção 7: Fluxos Alternativos

- [ ] **Cenários de Erro**: Identificados (ex: 401, 404, 500)
- [ ] **Edge Cases**: Documentados (ex: produto fora de estoque)
- [ ] **Ações de Recuperação**: Especificadas (ex: retry, refresh token)
- [ ] **Validações de Erro**: Checks com ❌ para falhas esperadas

**Notas**:
- Mínimo 1 cenário de erro documentado
- DummyJSON fake writes devem ter edge case documentado

---

### ✅ Seção 8: Implementação

- [ ] **Localização do Teste**: Arquivo especificado (`tests/api/<feature>/<name>.test.ts`)
- [ ] **Configuração de Cenário**: Executor definido (`constant-arrival-rate` ou `ramping-arrival-rate`)
- [ ] **Tags Obrigatórias**: `feature`, `kind`, `uc` especificadas
- [ ] **Thresholds**: Alinhados com SLOs (P95, error rate, checks)
- [ ] **VUs**: `preAllocatedVUs` e `maxVUs` definidos
- [ ] **Duration**: Definida (ou variável `__ENV.K6_DURATION`)
- [ ] **Rate/RPS**: Definida (ou variável `__ENV.K6_RPS`)

**Regras**:
- **SEMPRE** usar open model executors (constant-arrival-rate)
- **NUNCA** usar closed model (shared-iterations, per-vu-iterations)

---

### ✅ Seção 9: Comandos de Teste

- [ ] **Smoke Test**: Comando documentado (30-60s, 1-2 RPS)
- [ ] **Baseline Test**: Comando documentado (5min, 5-10 RPS)
- [ ] **Stress Test**: Comando documentado (10min+, 20+ RPS)
- [ ] **Variáveis de Ambiente**: `K6_RPS`, `K6_DURATION` utilizadas
- [ ] **CI/CD**: Workflows referenciados (`.github/workflows/`)

**Exemplo Mínimo**:
```bash
K6_RPS=1 K6_DURATION=30s k6 run tests/api/example/test.test.ts
```

---

### ✅ Seção 10: Métricas Customizadas

- [ ] **Trends**: Definidas (se aplicável) com nomenclatura correta (`feature_action_duration_ms`)
- [ ] **Counters**: Definidos (se aplicável) com nomenclatura correta (`feature_action_errors`)
- [ ] **Imports**: `import { Trend, Counter } from 'k6/metrics'` presente
- [ ] **Uso no VU Code**: `.add()` chamado corretamente
- [ ] **Dashboards**: Links incluídos (se disponível)

**Regras**:
- Snake_case: `product_list_duration_ms` (não camelCase)
- Trends para latência, Counters para eventos de negócio

---

### ✅ Seção 11: Observações Importantes

- [ ] **Limitações da API**: Documentadas (ex: "DummyJSON fake writes")
- [ ] **Particularidades do Teste**: Identificadas (ex: paginação usa limit/skip)
- [ ] **Considerações de Desempenho**: Incluídas (ex: usar SharedArray)
- [ ] **Warnings**: Avisos relevantes destacados com ⚠️

**Obrigatório**:
- Se UC usa POST/PUT/DELETE do DummyJSON, DEVE ter aviso "FAKE: não persiste dados"

---

### ✅ Seção 12: Dependências

- [ ] **UCs Bloqueadores**: Listados (ex: "UC003 (Auth) - requer token")
- [ ] **UCs Dependentes**: Identificados (quem usa este UC)
- [ ] **Libs Necessárias**: Especificadas (ex: `libs/http/auth.ts`)
- [ ] **Dados Requeridos**: Listados (ex: `users-credentials.csv` de UC003)
- [ ] **Validação de Dependências**: Confirmadas com mapa de dependências

**Referências**:
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md`

---

### ✅ Seção 13: Libs/Helpers Criados

- [ ] **Localização**: Path completo especificado (`libs/<categoria>/<nome>.ts`)
- [ ] **Funções Exportadas**: Assinatura TypeScript documentada
- [ ] **Exemplo de Uso**: Code snippet incluído
- [ ] **Testes Unitários**: Referenciados (se aplicável)
- [ ] **Dependências da Lib**: Identificadas (imports)

**Nota**:
- Seção opcional, OBRIGATÓRIA se UC criar nova lib
- Exemplos: `libs/http/auth.ts` (UC003), `libs/scenarios/journey-builder.ts` (UC009)

---

### ✅ Seção 14: Histórico e Checklist Interno

- [ ] **Histórico de Mudanças**: Tabela presente com data, autor, mudança
- [ ] **Checklist de Completude**: Incluído no final do UC
- [ ] **Referências**: Links para docs relevantes (DummyJSON, k6, fase1/2)

---

## 🔍 Revisão por Tipo de UC

### UCs Tier 0 (Independentes)

**Foco adicional**:
- [ ] Não tem dependências de auth
- [ ] Dados de teste autocontidos
- [ ] Endpoints READ apenas (GET)
- [ ] SLOs conservadores (primeiro baseline)

**Exemplos**: UC001, UC002, UC004, UC007

---

### UCs Tier 1 (Dependentes de Auth)

**Foco adicional**:
- [ ] Dependência de UC003 está documentada
- [ ] `libs/http/auth.ts` está referenciada
- [ ] Headers de autenticação especificados (`Authorization: Bearer ${token}`)
- [ ] Cenário de erro: token inválido/expirado documentado

**Exemplos**: UC005, UC006, UC008, UC012, UC013

---

### UCs Tier 2 (Jornadas Compostas)

**Foco adicional**:
- [ ] Múltiplos UCs dependentes listados
- [ ] `libs/scenarios/journey-builder.ts` referenciada (se aplicável)
- [ ] Think times entre steps especificados
- [ ] Métricas de jornada customizadas (`journey_duration_total_ms`)
- [ ] Session management documentado

**Exemplos**: UC009, UC010, UC011

---

## 📊 Matriz de Validação Rápida

| Critério | Essencial | Importante | Desejável |
|----------|-----------|------------|-----------|
| ID e Nome corretos | ✅ | | |
| Perfil de usuário claro | ✅ | | |
| Endpoints documentados | ✅ | | |
| SLOs definidos com rationale | ✅ | | |
| Fluxo principal detalhado | ✅ | | |
| Validações especificadas | ✅ | | |
| Think times especificados | | ✅ | |
| Dados de teste identificados | ✅ | | |
| Cenários de erro documentados | | ✅ | |
| Dependências mapeadas | ✅ | | |
| Limitações documentadas | ✅ | | |
| Comandos de teste corretos | | ✅ | |
| Métricas customizadas | | | ✅ |
| Libs/helpers documentados | ✅ (se criar) | | |
| Histórico de mudanças | | | ✅ |

**Legenda**:
- **Essencial**: Bloqueia aprovação se ausente
- **Importante**: Deve ter, mas pode ser adicionado em review
- **Desejável**: Nice-to-have, não bloqueia

---

## 🚦 Critérios de Aprovação

### 🚧 Draft → 🔄 In Review

**Requisitos**:
- [ ] Todas as seções essenciais preenchidas
- [ ] Fluxo principal completo
- [ ] SLOs definidos
- [ ] Dependências identificadas

**Ação**: Autor marca como `🔄 In Review` e solicita revisão

---

### 🔄 In Review → ✅ Approved

**Requisitos**:
- [ ] Revisor validou checklist completo
- [ ] Todos os itens "Essenciais" OK
- [ ] Pelo menos 80% dos "Importantes" OK
- [ ] Aderência ao guia de estilo validada
- [ ] Alinhamento com roadmap/matriz confirmado

**Ação**: Revisor marca como `✅ Approved` e comita

---

### ✅ Approved → Implementação

**Requisitos**:
- [ ] UC aprovado há pelo menos 24h (cool-off period)
- [ ] Dados de teste gerados/disponíveis
- [ ] Libs dependentes implementadas (se aplicável)
- [ ] UCs bloqueadores completos

**Ação**: Dev inicia implementação do teste k6

---

## 📝 Template de Comentário de Review

```markdown
## Review UC00X - [Nome]

### ✅ Aprovado com ressalvas

**Pontos Fortes**:
- [Item bem feito 1]
- [Item bem feito 2]

**Melhorias Necessárias**:
- [ ] [Item a corrigir 1] - Criticidade: Alta/Média/Baixa
- [ ] [Item a corrigir 2] - Criticidade: Alta/Média/Baixa

**Sugestões (Opcional)**:
- [Melhoria nice-to-have 1]

**Decisão**: Aprovar após correções de criticidade Alta
**Próximo Passo**: Autor corrige e marca como ✅ Approved
```

---

## 🧪 Teste de Validação (Smoke Review)

Antes de aprovar, executar **smoke review** (5 minutos):

1. ✅ Abrir arquivo `UC00X-nome.md`
2. ✅ Verificar badge de status no topo
3. ✅ Ler seção "Descrição" - está claro?
4. ✅ Conferir tabela de endpoints - todos documentados?
5. ✅ Validar SLOs - tem rationale?
6. ✅ Ler fluxo principal - steps claros?
7. ✅ Verificar dependências - estão corretas?
8. ✅ Conferir comandos de teste - funcionam?

**Se TODOS ✅**: Aprovar  
**Se 1+ ❌**: Solicitar correções

---

## 📚 Referências

- **Template de UC**: `docs/casos_de_uso/templates/use-case-template.md`
- **Guia de Estilo**: `docs/casos_de_uso/templates/guia-de-estilo.md`
- **Fase 1 - Baseline SLOs**: `docs/casos_de_uso/fase1-baseline-slos.md`
- **Fase 2 - Matriz de Priorização**: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- **Fase 2 - Roadmap**: `docs/casos_de_uso/fase2-roadmap-implementacao.md`
- **Fase 2 - Mapa de Dependências**: `docs/casos_de_uso/fase2-mapa-dependencias.md`

---

## 🔄 Versionamento do Checklist

| Versão | Data | Mudanças |
|--------|------|----------|
| 1.0 | 2025-10-03 | Criação inicial do checklist de qualidade |

---

## ✅ Meta-Checklist (Validação do Próprio Checklist)

Este checklist está completo?

- [x] Cobre todas as seções do template de UC
- [x] Critérios de aprovação estão claros
- [x] Matriz de validação rápida incluída
- [x] Template de comentário de review fornecido
- [x] Referências a docs de fase 1/2 incluídas
- [x] Diferenciação entre Tier 0/1/2 documentada
- [x] Smoke review (5 min) descrito
- [x] Versionamento do checklist incluído
