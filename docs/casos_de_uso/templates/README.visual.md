# Fase 3 - Resumo Visual dos Templates

## 📊 Estrutura do Template de UC

```
UC00X-nome-do-caso.md
│
├── 📋 METADADOS (Status, Prioridade, Complexidade, Sprint, Esforço)
│
├── 📋 DESCRIÇÃO
│   ├── Perfil de Usuário
│   ├── Contexto
│   └── Valor de Negócio
│
├── 🔗 ENDPOINTS ENVOLVIDOS
│   └── Tabela: Método | Endpoint | SLO | Observações
│
├── 📊 SLOs (Service Level Objectives)
│   └── Tabela: Métrica | Threshold | Rationale
│
├── 📦 DADOS DE TESTE
│   ├── Tabela: Arquivo | Localização | Volume | Fonte | Refresh
│   ├── Comando de Geração
│   └── Dependências de Dados
│
├── 🔄 FLUXO PRINCIPAL
│   ├── Pré-condições
│   ├── Step 1: [Nome]
│   │   ├── Request (HTTP)
│   │   ├── Validações (✅)
│   │   └── Think Time
│   ├── Step 2: [Nome]
│   │   └── [...]
│   └── Pós-condições
│
├── 🔀 FLUXOS ALTERNATIVOS
│   ├── Cenário de Erro 1
│   │   ├── Condição
│   │   ├── Steps
│   │   └── Validações (❌)
│   └── Edge Case 1
│       └── [...]
│
├── ⚙️ IMPLEMENTAÇÃO
│   ├── Localização do Teste
│   ├── Configuração de Cenário (k6 options)
│   └── Tags Obrigatórias
│
├── 🧪 COMANDOS DE TESTE
│   ├── Smoke Test (30-60s)
│   ├── Baseline Test (5min)
│   ├── Stress Test (10min+)
│   └── CI/CD Workflows
│
├── 📈 MÉTRICAS CUSTOMIZADAS
│   ├── Trends (Latência)
│   ├── Counters (Eventos)
│   └── Dashboards
│
├── ⚠️ OBSERVAÇÕES IMPORTANTES
│   ├── Limitações da API
│   ├── Particularidades do Teste
│   └── Considerações de Desempenho
│
├── 🔗 DEPENDÊNCIAS
│   ├── UCs Bloqueadores
│   ├── UCs que Usam Este
│   ├── Libs Necessárias
│   └── Dados Requeridos
│
├── 📂 LIBS/HELPERS CRIADOS (opcional)
│   ├── Localização
│   ├── Funções Exportadas
│   ├── Exemplo de Uso
│   └── Testes Unitários
│
├── 📝 HISTÓRICO DE MUDANÇAS
│   └── Tabela: Data | Autor | Mudança
│
├── ✅ CHECKLIST DE COMPLETUDE
│   └── 15 verificações inline
│
└── 📚 REFERÊNCIAS
    ├── DummyJSON API Docs
    ├── k6 Documentation
    └── Docs Fase 1/2
```

---

## 🎨 Convenções de Nomenclatura

### IDs de Casos de Uso
```
UC001, UC002, ..., UC013, UC014, ...
│   │   │
│   │   └── Dígito das unidades
│   └────── Dígito das dezenas
└────────── Prefixo fixo "UC"

✅ UC001 - Browse Products Catalog
✅ UC013 - Content Moderation
❌ UC1   - Falta zero-padding
❌ UC-001 - Hífen não permitido
```

### Arquivos de Documentação
```
UC00X-kebab-case-name.md
│    │
│    └── Nome descritivo em kebab-case (hífens)
└─────── ID do UC (3 dígitos)

✅ UC001-browse-products-catalog.md
✅ UC009-user-journey-unauthenticated.md
❌ UC001-Browse Products.md (espaços/maiúsculas)
❌ browse-products.md (falta ID)
```

### Testes k6
```
<action>-<resource>.test.ts
│       │          │
│       │          └── Extensão TypeScript test
│       └──────────── Recurso/domínio
└──────────────────── Ação/verbo

✅ browse-catalog.test.ts (UC001)
✅ search-products.test.ts (UC002)
✅ user-login-profile.test.ts (UC003)
❌ test1.test.ts (não descritivo)
❌ browseCatalog.test.ts (camelCase não permitido)
```

### Tags k6
```javascript
tags: { 
  feature: 'products',  // Domínio (lowercase)
  kind: 'browse',       // Operação (lowercase)
  uc: 'UC001'           // ID do UC (uppercase UC + 3 dígitos)
}

// Valores permitidos:
feature: 'products' | 'auth' | 'users' | 'carts' | 'posts' | 'comments'
kind: 'browse' | 'search' | 'login' | 'checkout' | 'admin' | 'moderate'
uc: 'UC001' - 'UC013'
```

### Métricas Customizadas
```
<feature>_<action>_<unit>
│        │        │
│        │        └── Unidade (duration_ms, errors, count)
│        └─────────── Ação específica
└──────────────────── Feature/domínio

✅ product_list_duration_ms (Trend)
✅ auth_login_errors (Counter)
✅ cart_add_item_success (Counter)
❌ duration (muito genérico)
❌ productListDuration (camelCase)
```

---

## ✍️ Padrões de Escrita

### Checks (Validações)
```javascript
// ✅ Bom: Human-readable, afirmativo, conciso
check(res, {
  'status is 200': (r) => r.status === 200,
  'has products array': (r) => Array.isArray(r.json('products')),
  'response time < 300ms': (r) => r.timings.duration < 300,
}, { uc: 'UC001', step: 'list' });

// ❌ Ruim: Muito curto ou muito verboso
check(res, {
  '200': (r) => r.status === 200,  // Não descritivo
  'Status code should be 200 if request succeeds': ... // Verboso
});
```

### Think Times
```markdown
✅ Think Time: 2-5s (navegação casual)
✅ Think Time: 3-7s (decisão de compra)
✅ Think Time: 5-10s (análise de dados admin)
✅ Think Time: 1s (automação rápida - valor fixo)

❌ Wait 3 seconds (não especifica range)
❌ Think Time: 3000ms (usar segundos, não ms)
```

### SLOs com Rationale
```markdown
| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 300ms | Baseline Fase 1: P95 real = 250ms, margem 20% segurança |
| `http_req_failed{feature:products}` | < 0.5% | Operação crítica (60% tráfego), tolerância mínima |
| `checks{uc:UC001}` | > 99.5% | Validações core, permite 0.5% falhas temporárias |

✅ Sempre incluir justificativa
✅ Referenciar baseline
✅ Explicar margem de segurança
```

---

## 📐 Estrutura de Fluxos

### Numeração de Steps

#### Fluxo Simples (Linear)
```markdown
**Step 1: Login**
[Request, validações, think time]

**Step 2: Browse Products**
[Request, validações, think time]

**Step 3: View Details**
[Request, validações, think time]
```

#### Fluxo Complexo (Subpassos)
```markdown
**Step 1: Autenticação**

1.1. POST /auth/login
     - Validação: status 200
     - Validação: token presente

1.2. GET /auth/me (verificar sessão)
     - Validação: status 200
     - Validação: user.id > 0

**Step 2: Navegação**

2.1. GET /products?limit=20
     [...]

2.2. GET /products/category/beauty
     [...]
```

### Validações Inline
```markdown
**Validações**:
- ✅ Status code = 200
- ✅ Response contains `products` array
- ✅ `products.length` <= 20
- ✅ Each product has `id`, `title`, `price`
- ❌ Status code = 404 (edge case - produto inexistente)
```

---

## 🎨 Emojis Consistentes

| Emoji | Seção | Quando Usar |
|-------|-------|-------------|
| 📋 | Descrição | Overview, contexto de negócio |
| 🔗 | Endpoints | Lista de APIs, links |
| 📊 | SLOs | Métricas, thresholds |
| 📦 | Dados | Massa de teste, arquivos |
| 🔄 | Fluxo Principal | Happy path, caminho principal |
| 🔀 | Fluxos Alternativos | Erros, edge cases |
| ⚙️ | Implementação | Config, localização código |
| 🧪 | Testes | Comandos, execução |
| 📈 | Métricas | Trends, Counters customizados |
| ⚠️ | Observações | Avisos, limitações |
| 🔗 | Dependências | UCs, libs, dados externos |
| 📂 | Libs/Helpers | Código criado, funções |
| 📝 | Histórico | Mudanças, versionamento |
| ✅ | Checklist | Items de validação |
| 📚 | Referências | Links externos, docs |

---

## 🔍 Checklist Visual Simplificado

### Validação Essencial (Bloqueia Aprovação)
```
┌─────────────────────────────────────┐
│  ✅ ESSENCIAL (10 itens)           │
├─────────────────────────────────────┤
│  [ ] ID e Nome corretos             │
│  [ ] Perfil de usuário claro        │
│  [ ] Endpoints documentados         │
│  [ ] SLOs definidos com rationale   │
│  [ ] Fluxo principal detalhado      │
│  [ ] Validações especificadas       │
│  [ ] Dados de teste identificados   │
│  [ ] Dependências mapeadas          │
│  [ ] Limitações documentadas        │
│  [ ] Libs/helpers (se criar)        │
└─────────────────────────────────────┘
```

### Validação Importante (Deve Ter)
```
┌─────────────────────────────────────┐
│  ⚠️ IMPORTANTE (5 itens)            │
├─────────────────────────────────────┤
│  [ ] Think times especificados      │
│  [ ] Cenários de erro documentados  │
│  [ ] Comandos de teste corretos     │
└─────────────────────────────────────┘
```

### Validação Desejável (Nice-to-have)
```
┌─────────────────────────────────────┐
│  💡 DESEJÁVEL (3 itens)             │
├─────────────────────────────────────┤
│  [ ] Métricas customizadas          │
│  [ ] Histórico de mudanças          │
└─────────────────────────────────────┘
```

---

## 🚦 Fluxo de Aprovação Visual

```
🚧 DRAFT
   │
   │ ✅ Seções essenciais completas
   │ ✅ Fluxo principal completo
   │ ✅ SLOs definidos
   │
   ▼
🔄 IN REVIEW
   │
   │ ✅ Revisor valida checklist (78 itens)
   │ ✅ 100% Essenciais OK
   │ ✅ 80% Importantes OK
   │ ✅ Aderência ao guia de estilo
   │
   ▼
✅ APPROVED
   │
   │ ⏰ Cool-off 24h
   │ ✅ Dados de teste disponíveis
   │ ✅ Libs dependentes prontas
   │ ✅ UCs bloqueadores completos
   │
   ▼
🚀 IMPLEMENTAÇÃO
```

---

## 📊 Comparação: Bom vs Ruim

### ❌ UC Mal Documentado
```markdown
# Browse Products

Status: draft

## Description
User goes to website and looks at products.

## Flow
1. GET /products
   - Check status

## SLOs
P95 < 300ms
```

**Problemas**:
- ❌ Falta ID do UC
- ❌ Status sem emoji/badge
- ❌ Inglês misturado com português
- ❌ Tom casual ("goes to")
- ❌ Sem emojis nas seções
- ❌ Validações não especificadas
- ❌ Sem think time
- ❌ SLO sem rationale
- ❌ Sem dependências
- ❌ Sem dados de teste

### ✅ UC Bem Documentado
```markdown
# UC001 - Browse Products Catalog

> **Status**: ✅ Approved  
> **Prioridade**: P0 (Crítico)  
> **Complexidade**: 1 (Muito Simples)  

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Visitante Anônimo
- **Distribuição**: 60% do tráfego total
- **Objetivo**: Explorar catálogo de produtos

## 🔄 Fluxo Principal

**Step 1: Listar Produtos**
```http
GET /products?limit=20&skip=0
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `products` array
- ✅ `products.length` <= 20

**Think Time**: 2-5s (navegação casual)

## 📊 SLOs

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:products}` (P95) | < 300ms | Baseline: 250ms + 20% margem |

## 🔗 Dependências

**UCs Bloqueadores**: Nenhum ✅
```

**Acertos**:
- ✅ ID correto (UC001)
- ✅ Status badge completo
- ✅ Português técnico consistente
- ✅ Tom imperativo
- ✅ Emojis nas seções
- ✅ Validações detalhadas
- ✅ Think time especificado
- ✅ SLO com justificativa
- ✅ Dependências mapeadas

---

## 📈 Estatísticas Finais - Fase 3

```
┌──────────────────────────────────────────────┐
│  FASE 3 - TEMPLATES E PADRÕES               │
├──────────────────────────────────────────────┤
│  📄 Arquivos Criados: 4                     │
│  📝 Linhas Totais: ~1500                    │
│  📑 Seções Totais: 39                       │
│  💡 Exemplos: 35+                           │
│  🔗 Referências: 16                         │
│                                              │
│  TEMPLATE UC                                 │
│  ├── Linhas: ~400                           │
│  ├── Seções: 15                             │
│  └── Exemplos: 10+                          │
│                                              │
│  GUIA DE ESTILO                             │
│  ├── Linhas: ~600                           │
│  ├── Seções: 10                             │
│  └── Exemplos: 20+                          │
│                                              │
│  CHECKLIST QUALIDADE                        │
│  ├── Linhas: ~500                           │
│  ├── Seções: 14                             │
│  ├── Itens: 78                              │
│  └── Exemplos: 5+                           │
│                                              │
│  STATUS: ✅ COMPLETA                        │
└──────────────────────────────────────────────┘
```

---

## 🎯 Próximos Passos

### Fase 4 - Sprint 1 (Semana 4)

**UCs a Documentar**:
1. **UC001** - Browse Products Catalog (4h)
   - Copiar `templates/use-case-template.md`
   - Renomear para `UC001-browse-products-catalog.md`
   - Preencher com base em `fase2-roadmap-implementacao.md`
   - Validar com `templates/checklist-qualidade.md`

2. **UC004** - View Product Details (3h)
   - Seguir mesmo processo

3. **UC007** - Browse by Category (4h)
   - Seguir mesmo processo

**Como Usar os Templates**:
```bash
# 1. Copiar template
cp docs/casos_de_uso/templates/use-case-template.md \
   docs/casos_de_uso/UC001-browse-products-catalog.md

# 2. Abrir e preencher seções
# 3. Consultar guia de estilo para dúvidas
# 4. Validar com checklist de qualidade
# 5. Marcar como 🔄 In Review
# 6. Após aprovação, marcar ✅ Approved
```

---

## 🔗 Arquivos de Referência

### Templates (Fase 3)
- `docs/casos_de_uso/templates/use-case-template.md`
- `docs/casos_de_uso/templates/guia-de-estilo.md`
- `docs/casos_de_uso/templates/checklist-qualidade.md`
- `docs/casos_de_uso/templates/README.visual.md` (este arquivo)

### Documentação Base (Fases 1-2)
- `docs/casos_de_uso/fase1-baseline-slos.md`
- `docs/casos_de_uso/fase1-perfis-de-usuario.md`
- `docs/casos_de_uso/fase2-roadmap-implementacao.md`
- `docs/casos_de_uso/fase2-mapa-dependencias.md`

### Planejamento
- `.github/copilot-instructions.md`
- `docs/planejamento/PRD.md`
