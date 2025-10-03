# Guia de Estilo - Escrita de Casos de Uso

## 🎯 Objetivo

Este guia estabelece **convenções de escrita, nomenclatura e estrutura** para garantir documentação consistente, clara e manutenível dos casos de uso k6.

---

## 📝 Convenções de Nomenclatura

### IDs de Casos de Uso

**Padrão**: `UC00X` (3 dígitos, zero-padded)

**Exemplos**:
- ✅ `UC001` - Browse Products Catalog
- ✅ `UC013` - Content Moderation
- ❌ `UC1` - Falta zero-padding
- ❌ `UC-001` - Não usar hífen

**Regras**:
- IDs são sequenciais e imutáveis (não renumerar após criação)
- UC001-UC099: Casos de uso principais
- UC100+: Extensões futuras (se necessário)

---

### Nomes de Arquivo

**Padrão**: `UC00X-kebab-case-name.md`

**Exemplos**:
- ✅ `UC001-browse-products-catalog.md`
- ✅ `UC003-user-login-profile.md`
- ✅ `UC009-user-journey-unauthenticated.md`
- ❌ `UC001-Browse Products Catalog.md` (sem espaços)
- ❌ `UC001_browse_products.md` (usar hífen, não underscore)
- ❌ `browse-products.md` (falta ID do UC)

**Regras**:
- Sempre começar com `UC00X-`
- Usar kebab-case (hífens entre palavras)
- Máximo 50 caracteres no nome total
- Extensão `.md` (Markdown)

---

### Nomes de Testes k6

**Padrão**: `<action>-<resource>.test.ts`

**Exemplos**:
- ✅ `browse-catalog.test.ts` (UC001)
- ✅ `search-products.test.ts` (UC002)
- ✅ `user-login-profile.test.ts` (UC003)
- ✅ `cart-operations-read.test.ts` (UC005)
- ❌ `test1.test.ts` (sem contexto)
- ❌ `browseCatalog.test.ts` (não usar camelCase)

**Regras**:
- Ação primeiro, depois recurso
- Máximo 40 caracteres
- Extensão `.test.ts` (TypeScript test)

---

### Tags k6

**Tags Obrigatórias**:

```javascript
tags: { 
  feature: 'products',  // Domain area
  kind: 'browse',       // Operation type
  uc: 'UC001'           // Use case ID
}
```

**Valores Permitidos**:

| Tag | Valores | Descrição |
|-----|---------|-----------|
| `feature` | `products`, `auth`, `users`, `carts`, `posts`, `comments` | Domínio funcional |
| `kind` | `browse`, `search`, `login`, `checkout`, `admin`, `moderate` | Tipo de operação |
| `uc` | `UC001` - `UC013` | ID do caso de uso |

**Regras**:
- Sempre usar lowercase (sem maiúsculas)
- feature = domínio da API (alinhado com endpoints)
- kind = verbo/ação do usuário
- uc = ID exato do UC (com zero-padding)

---

### Métricas Customizadas

**Padrão**: `<feature>_<action>_<unit>`

**Exemplos**:
- ✅ `product_list_duration_ms` (Trend)
- ✅ `product_list_errors` (Counter)
- ✅ `auth_login_success` (Counter)
- ✅ `cart_add_item_duration_ms` (Trend)
- ❌ `duration` (muito genérico)
- ❌ `productListDuration` (não usar camelCase)

**Regras**:
- Snake_case (underscores)
- Trends: sufixo `_duration_ms`, `_latency_ms`, `_time_ms`
- Counters: sufixo `_errors`, `_success`, `_count`
- Prefixo com feature (ex: `product_`, `auth_`, `cart_`)

---

## ✍️ Convenções de Escrita

### Tom e Voz

- **Imperativo**: "Execute o request", "Valide a resposta" (não "Executar", "Validar")
- **Técnico**: Termos precisos (não ambíguos)
- **Conciso**: Evitar prolixidade, ir direto ao ponto
- **Objetivo**: Baseado em fatos, não opiniões

**Exemplo Bom ✅**:
> Execute `GET /products?limit=20` e valide que `status === 200` e `products.length <= 20`.

**Exemplo Ruim ❌**:
> O usuário pode executar uma requisição GET no endpoint de produtos com limite de 20 itens e depois verificar se a resposta está ok.

---

### Descrições de Checks

**Padrão**: Sentenças human-readable, afirmativas

**Exemplos**:
- ✅ `'status is 200'`
- ✅ `'has products array'`
- ✅ `'response time < 300ms'`
- ✅ `'user is authenticated'`
- ❌ `'200'` (muito curto)
- ❌ `'check_status'` (não descritivo)
- ❌ `'Status code should be 200 if request succeeds'` (muito verboso)

**Regras**:
- Começar com verbo no presente (is, has, contains)
- Máximo 50 caracteres
- Sem pontuação final
- Usar aspas simples em JavaScript

---

### Formatação de Código

**Headers HTTP**:
```http
GET /products?limit=20&skip=0
Headers:
  Content-Type: application/json
  Authorization: Bearer ${token}
```

**Request Bodies**:
```json
{
  "username": "emilys",
  "password": "emilyspass",
  "expiresInMins": 60
}
```

**k6 Code Blocks**:
```javascript
const res = http.get(`${BASE_URL}/products`, {
  headers: baseHeaders(),
  tags: { feature: 'products', kind: 'browse', uc: 'UC001' }
});
```

**Regras**:
- Usar syntax highlighting (http, json, javascript, typescript, bash)
- Indentar 2 espaços (não tabs)
- Variáveis de ambiente: `${VAR_NAME}` ou `__ENV.VAR_NAME`

---

### Think Times

**Notação**: `Think Time: X-Ys (contexto)`

**Exemplos**:
- ✅ `Think Time: 2-5s (navegação casual)`
- ✅ `Think Time: 3-7s (decisão de compra)`
- ✅ `Think Time: 5-10s (análise de dados admin)`
- ✅ `Think Time: 1s (automação rápida)`
- ❌ `Wait 3 seconds` (não especifica range)
- ❌ `Think Time: 3000ms` (usar segundos, não ms)

**Regras**:
- Sempre usar range (min-max) exceto para valores fixos
- Unidade: segundos (s)
- Incluir contexto entre parênteses
- Baseado em perfis de usuário (Fase 1)

---

### Documentação de SLOs

**Formato de Tabela**:

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 300ms | Baseline Fase 1: P95 real = 250ms, margem 20% |
| `http_req_failed{feature:products}` | < 0.5% | Operação crítica, tolerância mínima |
| `checks{uc:UC001}` | > 99.5% | Validações devem passar, permite 0.5% falhas temporárias |

**Regras**:
- Sempre incluir rationale (justificativa)
- Referenciar baseline: `docs/casos_de_uso/fase1-baseline-slos.md`
- Percentis: P95, P99 (não P50 para thresholds)
- Error rate: < X% (não > X%)
- Checks: > X% (não < X%)

---

## 📐 Estrutura de Fluxos

### Numeração de Steps

**Padrão Simples** (fluxo linear):
```markdown
**Step 1: Login**
[Request, validações, think time]

**Step 2: Browse Products**
[Request, validações, think time]

**Step 3: View Details**
[Request, validações, think time]
```

**Padrão Complexo** (subpassos):
```markdown
**Step 1: Autenticação**

1.1. POST /auth/login
     - Validação: status 200
     - Validação: token presente

1.2. GET /auth/me (verificar sessão)
     - Validação: status 200
     - Validação: user.id > 0

**Step 2: Navegação**
[...]
```

**Regras**:
- Steps principais: numeração sequencial (1, 2, 3...)
- Subpassos: notação decimal (1.1, 1.2, 2.1...)
- Máximo 10 steps principais por UC
- Máximo 5 subpassos por step principal

---

### Documentação de Validações

**Padrão Inline** (durante step):
```markdown
**Validações**:
- ✅ Status code = 200
- ✅ Response contains `products` array
- ✅ `products.length` <= 20
- ✅ Each product has `id`, `title`, `price`
```

**Padrão Code Block** (k6 code):
```javascript
check(res, {
  'status is 200': (r) => r.status === 200,
  'has products array': (r) => Array.isArray(r.json('products')),
  'products count valid': (r) => r.json('products').length <= 20,
}, { uc: 'UC001', step: 'list' });
```

**Regras**:
- Usar ✅ para validações esperadas
- Usar ❌ para validações de erro (fluxos alternativos)
- Sempre incluir tags de check: `{ uc: 'UC00X', step: 'nome' }`

---

## 🎨 Convenções Visuais

### Emojis (Uso Consistente)

| Emoji | Uso | Exemplo |
|-------|-----|---------|
| 📋 | Descrição, overview | `## 📋 Descrição` |
| 🔗 | Endpoints, links | `## 🔗 Endpoints Envolvidos` |
| 📊 | SLOs, métricas | `## 📊 SLOs` |
| 📦 | Dados, massa de teste | `## 📦 Dados de Teste` |
| 🔄 | Fluxo principal | `## 🔄 Fluxo Principal` |
| 🔀 | Fluxos alternativos | `## 🔀 Fluxos Alternativos` |
| ⚙️ | Implementação, config | `## ⚙️ Implementação` |
| 🧪 | Testes, comandos | `## 🧪 Comandos de Teste` |
| 📈 | Métricas customizadas | `## 📈 Métricas Customizadas` |
| ⚠️ | Avisos, limitações | `## ⚠️ Observações Importantes` |
| 🔒 | Dependências | `## 🔗 Dependências` |
| 📂 | Libs, helpers | `## 📂 Libs/Helpers Criados` |
| ✅ | Checklist, completo | `- ✅ Item completo` |
| 🚧 | Draft, em progresso | `**Status**: 🚧 Draft` |

**Regras**:
- Um emoji por seção de cabeçalho
- Não usar emojis no corpo do texto (exceto listas de status)
- Consistência entre todos os UCs

---

### Status Badges

**Padrão**:
```markdown
> **Status**: 🚧 Draft | ✅ Approved | 🔄 In Review  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 1 (Muito Simples)  
> **Sprint**: Sprint 1 (Semana 4)  
> **Esforço Estimado**: 4h  
```

**Valores Permitidos**:

- **Status**: `🚧 Draft`, `🔄 In Review`, `✅ Approved`
- **Prioridade**: `P0 (Crítico)`, `P1 (Importante)`, `P2 (Secundário)`, `P3 (Nice-to-have)`
- **Complexidade**: `1 (Muito Simples)` a `5 (Muito Complexa)`
- **Sprint**: `Sprint X (Semana Y)` (conforme roadmap)
- **Esforço**: `Xh` (horas estimadas)

---

### Tabelas

**Alinhamento**:
- Coluna 1 (nome): esquerda
- Colunas numéricas: direita
- Demais colunas: esquerda

**Exemplo**:
```markdown
| Endpoint | Método | P95 | Observações |
|----------|--------|----:|-------------|
| /products | GET | 250ms | Paginação padrão |
| /auth/login | POST | 380ms | Geração de JWT |
```

**Regras**:
- Sempre usar cabeçalho com `|---|---|---|`
- Padding interno: 1 espaço antes/depois de `|`
- Máximo 6 colunas por tabela

---

## 🔤 Glossário de Termos

### Termos Técnicos (Usar Consistentemente)

| Termo Correto ✅ | Evitar ❌ | Contexto |
|------------------|-----------|----------|
| Threshold | Limite, Boundary | SLOs k6 |
| Check | Validação, Assert | Validações k6 |
| Think time | Wait time, Delay | Tempo entre steps |
| VU (Virtual User) | User, Usuário | Executores k6 |
| Executor | Scenario type | Open/closed model |
| SharedArray | Array, Lista | Dados de teste |
| Trend | Metric, Latency | Métrica de latência |
| Counter | Metric, Count | Métrica de contagem |
| Rate | Taxa, Porcentagem | RPS ou error rate |
| P95, P99 | 95th percentile | Percentis de latência |
| Baseline | Base, Reference | SLOs de referência |
| Smoke test | Quick test | Teste rápido (30-60s) |
| Stress test | Load test | Teste de carga alta |
| Soak test | Endurance test | Teste de longa duração |

---

### Abreviações Permitidas

| Abreviação | Significado | Uso |
|------------|-------------|-----|
| UC | Use Case | IDs de casos de uso |
| SLO | Service Level Objective | Metas de desempenho |
| RPS | Requests Per Second | Taxa de requisições |
| VU | Virtual User | Usuários virtuais k6 |
| CI/CD | Continuous Integration/Deployment | Pipelines |
| API | Application Programming Interface | Endpoints |
| JWT | JSON Web Token | Autenticação |
| P95, P99 | 95th/99th Percentile | Percentis de latência |

**Regras**:
- Expandir na primeira menção: "SLO (Service Level Objective)"
- Depois usar só abreviação
- Não criar novas abreviações (usar glossário)

---

## 📚 Referências Externas

### Links para Documentação

**Padrão**: `[Texto Descritivo](URL)`

**Exemplos**:
- ✅ `[DummyJSON Products API](https://dummyjson.com/docs/products)`
- ✅ `[k6 Executors](https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/)`
- ❌ `https://dummyjson.com/docs/products` (sem texto descritivo)
- ❌ `Click here` (texto genérico)

**Regras**:
- Sempre incluir texto descritivo
- URLs completas (não encurtar)
- Verificar links antes de commit

---

### Referências Internas

**Padrão Relativo**: `../path/to/file.md`

**Exemplos**:
- ✅ `docs/casos_de_uso/fase1-baseline-slos.md`
- ✅ `../fase2-roadmap-implementacao.md` (se no mesmo diretório)
- ❌ `/home/Volt/k6-monorepo/docs/...` (caminho absoluto local)

**Regras**:
- Usar caminhos relativos sempre que possível
- Referenciar arquivos .md, .csv, .json relevantes
- Incluir âncoras para seções: `file.md#section`

---

## ✅ Checklist de Estilo

Antes de marcar UC como ✅ Approved, verificar:

### Nomenclatura
- [ ] ID do UC segue padrão `UC00X` (3 dígitos)
- [ ] Arquivo nomeado: `UC00X-kebab-case-name.md`
- [ ] Tags k6: `feature`, `kind`, `uc` corretamente especificadas
- [ ] Métricas customizadas: `feature_action_unit` (snake_case)

### Escrita
- [ ] Tom imperativo e técnico
- [ ] Checks human-readable: `'status is 200'`
- [ ] Think times especificados: `2-5s (contexto)`
- [ ] SLOs com rationale (justificativa)

### Estrutura
- [ ] Steps numerados sequencialmente (1, 2, 3...)
- [ ] Validações com ✅ ou ❌
- [ ] Emojis consistentes nos cabeçalhos
- [ ] Status badge completo no topo

### Formatação
- [ ] Code blocks com syntax highlighting
- [ ] Tabelas com alinhamento correto
- [ ] Links com texto descritivo
- [ ] Máximo 80 caracteres por linha (quando possível)

### Referências
- [ ] Links externos válidos (testados)
- [ ] Referências internas com caminhos relativos
- [ ] Glossário usado consistentemente

---

## 🚀 Exemplos Práticos

### Bom Exemplo ✅

```markdown
# UC001 - Browse Products Catalog

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 1 (Muito Simples)  

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo
- **Distribuição de Tráfego**: 60% do total
- **Objetivo**: Explorar catálogo de produtos

## 🔄 Fluxo Principal

**Step 1: Listar Produtos**
```http
GET /products?limit=20&skip=0
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `products` array

**Think Time**: 2-5s (navegação casual)

## 📊 SLOs

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 300ms | Baseline: 250ms + 20% margem |
```

---

### Mau Exemplo ❌

```markdown
# Browse Products (sem ID)

Status: draft (sem emoji/badge)

## Description (inglês misturado)

User goes to website and looks at products. (tom casual)

## Flow (sem emoji)

1. GET /products (sem validações, sem think time)
   - Check status (sem especificar valor)
   
## SLOs (sem rationale)

P95 < 300ms (sem métrica completa, sem justificativa)
```

---

## 📝 Versionamento do Guia

| Versão | Data | Mudanças |
|--------|------|----------|
| 1.0 | 2025-10-03 | Criação inicial do guia de estilo |

---

## 🔗 Referências

- Template de UC: `docs/casos_de_uso/templates/use-case-template.md`
- Checklist de Qualidade: `docs/casos_de_uso/templates/checklist-qualidade.md`
- PRD: `docs/planejamento/PRD.md`
- Copilot Instructions: `.github/copilot-instructions.md`
