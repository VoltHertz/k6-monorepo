# GitHub Copilot Instructions - k6 Performance Testing Monorepo

## 🎯 Project Overview

This is an **enterprise-grade k6 performance testing monorepo** using TypeScript, designed for 10+ years of maintainability. We test DummyJSON API endpoints with automated quality gates, CI/CD integration, and comprehensive observability.

## 🏗️ Architecture Principles

### ADR-001: TypeScript-First
- k6 runs `.ts` files natively via esbuild (no build step needed: `k6 run test.ts`)
- Run `tsc --noEmit` in CI for type checking only
- Use `@types/k6` for autocomplete/type safety

### ADR-002: Open Model Executors (CRITICAL)
- **Always use `constant-arrival-rate` or `ramping-arrival-rate`** for API tests
- Never use `shared-iterations` or `per-vu-iterations` (closed model) - these don't reflect real user behavior
- Open model creates VUs on-demand to hit target RPS, avoiding VU bottlenecks

### ADR-003: Data Strategy (CRITICAL)
- `data/fulldummyjsondata/` = **READ-ONLY** application dumps (reference only)
- `data/test-data/` = curated test data (CSV/JSON) generated from dumps
- Use `SharedArray` with `open()` to load test data (memory-efficient, thread-safe)

## 📁 Directory Structure & Conventions

```
tests/api/<feature>/<test-name>.test.ts    # Domain-driven tests (products, users, auth, carts)
tests/scenarios/<journey>.test.ts          # Composite user journeys
libs/http/                                 # HTTP client, checks, interceptors
libs/data/                                 # SharedArray loaders, generators, parsers
libs/scenarios/                            # Executor factories, tag strategies
libs/metrics/                              # Custom Trends/Counters, SLO validators
libs/reporting/                            # handleSummary (JSON/JUnit/HTML)
configs/scenarios/<type>.yaml              # smoke/baseline/stress/soak configs
configs/envs/<env>.json                    # Environment configs (local/ci/prod-like)
docs/casos_de_uso/UC00X-<name>.md         # Use case documentation with SLOs
```

## ✅ Test File Template (MANDATORY STRUCTURE)

```typescript
// tests/api/products/browse-catalog.test.ts
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import { getConfig } from '../../../libs/scenarios/profiles';
import { baseHeaders } from '../../../libs/http/interceptors';

// 1. Custom Metrics (Trends for latency, Counters for business events)
const productListDuration = new Trend('product_list_duration_ms');
const productListErrors = new Counter('product_list_errors');

// 2. Test Data (SharedArray for memory efficiency)
const categories = new SharedArray('categories', function() {
  return JSON.parse(open('../../../data/test-data/categories.json'));
});

// 3. Scenario Config (use getConfig factory from libs/scenarios/profiles.ts)
export const options = getConfig('baseline', {
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
});

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

// 4. VU Code
export default function() {
  const res = http.get(
    `${BASE_URL}/products?limit=20&skip=${Math.floor(Math.random() * 80)}`,
    { headers: baseHeaders(), tags: { name: 'list_products' } }
  );
  
  productListDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has products array': (r) => Array.isArray(r.json('products')),
  }, { uc: 'UC001', step: 'list' });
  
  sleep(1);
}
```

## 🔑 Critical Patterns

### Tagging Strategy (MANDATORY)
```javascript
tags: { 
  feature: 'products',  // Domain area (products/users/auth/carts)
  kind: 'browse',       // Operation type (browse/search/login/checkout)
  uc: 'UC001'           // Use case ID from docs/casos_de_uso/
}
```

### Thresholds (Quality Gates)
```javascript
thresholds: {
  'http_req_duration{feature:products}': ['p(95)<300'],      // Feature-specific latency
  'http_req_failed{feature:products}': ['rate<0.005'],       // Feature-specific error rate
  'checks{uc:UC001}': ['rate>0.995'],                        // Use case check success
}
```

### Remote Modules (ALWAYS VERSION-PINNED)
```typescript
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';
```

## 🚫 Common Pitfalls to Avoid

1. **DON'T load data from `data/fulldummyjsondata/`** in tests → use `data/test-data/` only
2. **DON'T use closed-model executors** (`shared-iterations`, `per-vu-iterations`)
3. **DON'T expect DummyJSON POST/PUT/DELETE to persist** → they return fake responses
4. **DON'T forget `sleep(1)` between iterations** → prevents unrealistic hammering
5. **DON'T use unversioned remote modules** → always pin versions in jslib.k6.io URLs

## 🔧 Development Workflow

### Local Testing
```bash
# Run single test
k6 run tests/api/products/browse-catalog.test.ts

# With custom RPS/duration
K6_RPS=10 K6_DURATION=2m k6 run tests/api/products/browse-catalog.test.ts

# Type check (no execution)
npm run typecheck  # runs: tsc --noEmit
```

### CI/CD Quality Gates (auto-run on PR/main)
- **PR Smoke**: 30-60s, 1-2 RPS, loose thresholds (`.github/workflows/k6-pr-smoke.yml`)
- **Main Baseline**: 5-10min, 5-10 RPS, strict SLOs (`.github/workflows/k6-main-baseline.yml`)
- **On-Demand**: Stress/soak via `workflow_dispatch` (`.github/workflows/k6-on-demand.yml`)

### Data Generation
```bash
# Generate test data from application dumps
node data/test-data/generators/generate-users.ts \
  --source data/fulldummyjsondata/users.json \
  --output data/test-data/users.csv \
  --sample-size 100
```

## 📊 Use Case Documentation

Every test MUST have a corresponding use case doc in `docs/casos_de_uso/UC00X-<name>.md`:

```markdown
# UC001 - Browse Products Catalog

## SLOs
| Metric | Threshold |
|--------|-----------|
| http_req_duration{p95} | < 300ms |
| http_req_failed | < 0.5% |
| checks | > 99.5% |

## Implementation
- File: `tests/api/products/browse-catalog.test.ts`
- Scenario: `configs/scenarios/baseline.yaml`
```

## 🎨 Code Style

- **File naming**: `<action>-<resource>.test.ts` (e.g., `browse-catalog.test.ts`, `search-products.test.ts`)
- **Imports order**: k6 built-ins → k6 metrics → k6 data → remote modules → local libs
- **Custom metrics naming**: `<feature>_<action>_<unit>` (e.g., `product_list_duration_ms`)
- **Check descriptions**: Human-readable strings (e.g., `'status is 200'` not `'200'`)

## 🚀 SLO Targets by Feature

| Feature | P95 Latency | Error Rate | Checks |
|---------|-------------|------------|--------|
| products | < 300ms | < 0.5% | > 99.5% |
| auth | < 400ms | < 1% | > 99% |
| search | < 600ms | < 1% | > 99% |
| carts | < 500ms | < 1% | > 99% |

## 📋 Plano de Escrita dos Casos de Uso

### Fase 1: Análise e Levantamento ✅ COMPLETA

**Objetivo**: Mapear todos os endpoints da API DummyJSON e categorizar por domínio

**Atividades**:
1. **Inventário de Endpoints** ✅
   - Ler toda documentação em `docs/dummyJson/`
   - Listar todos os endpoints disponíveis (GET, POST, PUT, DELETE)
   - Categorizar por domínio: Products, Auth, Users, Carts, Posts, Comments
   - Identificar dependências entre endpoints (ex: login antes de /auth/me)

2. **Análise de Perfis de Usuário** ✅
   - Identificar personas típicas de e-commerce (visitante, comprador, admin)
   - Mapear fluxos de negócio reais (navegação, compra, administração)
   - Definir distribuição de carga (% de cada perfil)

3. **Benchmarking de SLOs** ✅
   - Executar requests manuais para estabelecer baseline de latência
   - Documentar tempos médios por tipo de operação (read vs write)
   - Definir SLOs iniciais conservadores (refinar depois)

**Entregáveis**:
- ✅ [`fase1-inventario-endpoints.csv`](../docs/casos_de_uso/fase1-inventario-endpoints.csv) - 38 endpoints catalogados
- ✅ [`fase1-perfis-de-usuario.md`](../docs/casos_de_uso/fase1-perfis-de-usuario.md) - 3 personas com distribuição 60/30/10
- ✅ [`fase1-baseline-slos.md`](../docs/casos_de_uso/fase1-baseline-slos.md) - SLOs por feature (P95 < 300-600ms)

---

### Fase 2: Priorização e Roadmap (Semana 2)

**Objetivo**: Definir ordem de implementação baseada em criticidade e complexidade

**Atividades**:
1. **Matriz de Priorização**
   - Eixo X: Criticidade de negócio (core vs secundário)
   - Eixo Y: Complexidade técnica (simples vs complexo)
   - Classificar cada caso de uso identificado

2. **Definição de Fases**
   - Fase 0: Casos fundamentais (smoke test viability)
   - Fase 1: Autenticação e controle de acesso
   - Fase 2: Operações CRUD principais
   - Fase 3: Jornadas compostas
   - Fase 4: Casos avançados (resiliência, consistência)

3. **Dependências e Pré-requisitos**
   - Mapear quais UCs dependem de outros (ex: Cart precisa de Auth)
   - Identificar dados de teste necessários por UC
   - Planejar geração de massa de teste

**Entregáveis**:
- Matriz de priorização visual
- Roadmap de implementação por sprint
- Mapa de dependências entre UCs

---

### Fase 3: Template e Padrões (Semana 3)

**Objetivo**: Criar templates reutilizáveis para documentação consistente

**Atividades**:
1. **Template de Caso de Uso**
   - Criar `docs/casos_de_uso/templates/use-case-template.md`
   - Definir seções obrigatórias vs opcionais
   - Incluir exemplos de preenchimento

2. **Convenções de Nomenclatura**
   - Padrão de IDs: UC001, UC002, etc.
   - Padrão de nomes de arquivo: `UC00X-kebab-case-name.md`
   - Tags obrigatórias: feature, uc, kind

3. **Estrutura de Fluxos**
   - Notação para descrever passos (numeração, indentação)
   - Como documentar validações (checks)
   - Como especificar think times

**Entregáveis**:
- Template markdown completo em `docs/casos_de_uso/templates/`
- Guia de estilo para escrita de UCs
- Checklist de revisão de qualidade

---

### Fase 4: Escrita dos Casos de Uso (Semanas 4-7)

**Objetivo**: Documentar todos os casos de uso priorizados

**Sprint 1 (Semana 4) - Casos Fundamentais**:
- UC001: Browse Products Catalog
- UC002: Search & Filter Products
- **Meta**: 2 UCs completos, validados, com massa de teste identificada

**Sprint 2 (Semana 5) - Autenticação**:
- UC003: User Login & Profile
- UC004: List Users (Admin)
- **Meta**: Fluxos de auth documentados, tokens mapeados

**Sprint 3 (Semana 6) - Operações Principais**:
- UC005: Cart Operations (Read)
- UC006: Cart Operations (Write - Simulated)
- **Meta**: CRUD completo, limitações de simulação documentadas

**Sprint 4 (Semana 7) - Jornadas**:
- UC007: User Journey (não autenticado)
- UC008: User Journey (autenticado)
- UC009: Mixed Workload
- **Meta**: Cenários compostos com think times realistas

**Atividades por UC**:
1. Descrever perfil de usuário e objetivo de negócio
2. Listar endpoints envolvidos com métodos HTTP
3. Definir SLOs específicos (baseado em baseline)
4. Detalhar fluxo passo a passo com validações
5. Especificar dados de teste necessários
6. Documentar headers, payloads, query params
7. Identificar edge cases e cenários de erro

**Entregáveis por Sprint**:
- X casos de uso documentados em markdown
- Massa de teste identificada (ainda não gerada)
- Review de qualidade com checklist

---

### Fase 5: Validação e Refinamento (Semana 8)

**Objetivo**: Revisar e ajustar casos de uso antes da implementação

**Atividades**:
1. **Revisão por Pares**
   - Revisar cada UC com outro membro do time
   - Validar clareza e completude
   - Verificar aderência ao template

2. **Validação com Stakeholders**
   - Apresentar UCs para product owners
   - Confirmar que perfis de usuário estão corretos
   - Ajustar SLOs baseado em expectativas de negócio

3. **Testes de Viabilidade**
   - Executar requests manuais para cada UC
   - Confirmar que endpoints existem e funcionam
   - Documentar particularidades descobertas

4. **Refinamento Final**
   - Ajustar SLOs baseado em testes manuais
   - Adicionar observações importantes
   - Atualizar dependências descobertas

**Entregáveis**:
- Todos os UCs revisados e aprovados
- Ata de validação com stakeholders
- Notas de viabilidade técnica

---

### Fase 6: Handoff para Implementação (Semana 9)

**Objetivo**: Preparar documentação para time de implementação

**Atividades**:
1. **Organização Final**
   - Numerar UCs em ordem de implementação
   - Criar índice em `docs/casos_de_uso/README.md`
   - Linkar UCs com endpoints da API docs

2. **Geração de Massa de Teste**
   - Criar geradores em `data/test-data/generators/`
   - Extrair amostras de `data/fulldummyjsondata/`
   - Versionar dados no Git

3. **Documentação de Suporte**
   - Criar guia de implementação
   - Documentar padrões de código esperados
   - Preparar exemplos de testes

**Entregáveis**:
- README navegável de casos de uso
- Massa de teste gerada e versionada
- Guia de implementação para devs

---

### 📝 Estrutura do Template de UC (Resumo)

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
```

---

### ✅ Checklist de Qualidade por UC

Antes de considerar um UC completo, verificar:

- [ ] Perfil de usuário está claro e realista
- [ ] Todos os endpoints estão documentados com método HTTP
- [ ] SLOs estão definidos e justificados
- [ ] Fluxo principal está detalhado passo a passo
- [ ] Validações (checks) estão especificadas
- [ ] Dados de teste estão identificados (fonte + volume)
- [ ] Headers obrigatórios estão documentados
- [ ] Think times estão especificados onde necessário
- [ ] Edge cases e cenários de erro estão mapeados
- [ ] Dependências de outros UCs estão listadas
- [ ] Limitações da API (ex: fake POST) estão documentadas
- [ ] Arquivo nomeado corretamente: `UC00X-kebab-case.md`

---

### 🎯 Ordem de Escrita Recomendada

1. **Começar pelos mais simples**: Browse, Search (sem auth)
2. **Depois auth**: Login, Profile (fundação para outros)
3. **CRUD principais**: Carts, Users (operações isoladas)
4. **Jornadas simples**: Combinar 2-3 UCs
5. **Jornadas complexas**: Autenticação + múltiplas operações
6. **Casos avançados**: Resiliência, validações complexas

### 📊 Métricas de Progresso

- **Sprint 1**: 2 UCs fundamentais (10% do total)
- **Sprint 2**: +2 UCs auth (30% do total)
- **Sprint 3**: +2 UCs CRUD (50% do total)
- **Sprint 4**: +3 UCs jornadas (80% do total)
- **Refinamento**: +2 UCs avançados (100%)

---

## 📚 Key References

- [k6 TypeScript Support](https://grafana.com/docs/k6/latest/using-k6/javascript-typescript-compatibility-mode/)
- [k6 Executors](https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/)
- [DummyJSON API Docs](https://dummyjson.com/docs)
- [DummyJSON Products API](https://dummyjson.com/docs/products)
- [DummyJSON Auth API](https://dummyjson.com/docs/auth)
- [DummyJSON Carts API](https://dummyjson.com/docs/carts)
- [jslib.k6.io](https://jslib.k6.io/)
- Full PRD: `docs/planejamento/PRD.md`
