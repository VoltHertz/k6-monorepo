# Matriz de Priorização de Casos de Uso

## 📊 Metodologia

### Eixos de Avaliação

**Eixo X - Criticidade de Negócio** (1-5):
- **1**: Nice to have (não afeta operação)
- **2**: Secundário (funcionalidade adicional)
- **3**: Importante (melhora experiência)
- **4**: Crítico (afeta conversão)
- **5**: Essencial (core business)

**Eixo Y - Complexidade Técnica** (1-5):
- **1**: Muito simples (1 endpoint GET, sem auth)
- **2**: Simples (poucos endpoints, validações básicas)
- **3**: Moderado (múltiplos endpoints, auth necessária)
- **4**: Complexo (jornada completa, múltiplas validações)
- **5**: Muito complexo (cenários avançados, resiliência)

### Quadrantes

```
Complexidade
    5 │                        │ 
      │   DESENVOLVER          │   PLANEJAR
      │   DEPOIS               │   CUIDADOSAMENTE
    4 │   (Baixa prioridade)   │   (Alta complexidade)
      │                        │
    3 │━━━━━━━━━━━━━━━━━━━━━━━━│━━━━━━━━━━━━━━━━━━━━━━
      │                        │
    2 │   QUICK WINS           │   PRIORIDADE MÁXIMA
      │   (Implementar logo)   │   (Começar aqui!)
    1 │                        │
      └────────────────────────┴─────────────────────→
      1         2         3    4              5    Criticidade
```

---

## 🎯 Casos de Uso Mapeados

### UC001 - Browse Products Catalog
- **Criticidade**: 5 (Essencial - 60% do tráfego, core browsing)
- **Complexidade**: 1 (Muito simples - GET /products, sem auth)
- **Quadrante**: ✅ **PRIORIDADE MÁXIMA**
- **Justificativa**: Endpoint mais usado, fundação para todo e-commerce
- **Dependências**: Nenhuma

### UC002 - Search & Filter Products
- **Criticidade**: 5 (Essencial - 30% do tráfego browse, descoberta)
- **Complexidade**: 2 (Simples - GET /products/search + filtros)
- **Quadrante**: ✅ **PRIORIDADE MÁXIMA**
- **Justificativa**: Segundo fluxo mais importante, UX crítica
- **Dependências**: Nenhuma

### UC003 - User Login & Profile
- **Criticidade**: 4 (Crítico - gateway para compras autenticadas)
- **Complexidade**: 2 (Simples - POST /auth/login + GET /auth/me)
- **Quadrante**: ✅ **PRIORIDADE MÁXIMA**
- **Justificativa**: Base para todos fluxos autenticados
- **Dependências**: Nenhuma

### UC004 - View Product Details
- **Criticidade**: 4 (Crítico - decisão de compra)
- **Complexidade**: 1 (Muito simples - GET /products/{id})
- **Quadrante**: ✅ **PRIORIDADE MÁXIMA**
- **Justificativa**: Conversão depende de detalhes claros
- **Dependências**: Nenhuma

### UC005 - Cart Operations (Read)
- **Criticidade**: 4 (Crítico - visualização pré-checkout)
- **Complexidade**: 2 (Simples - GET /carts, GET /carts/user/{id})
- **Quadrante**: ✅ **PRIORIDADE MÁXIMA**
- **Justificativa**: Essencial para checkout
- **Dependências**: UC003 (Auth)

### UC006 - Cart Operations (Write - Simulated)
- **Criticidade**: 3 (Importante - ação de compra, mas fake)
- **Complexidade**: 3 (Moderado - POST/PUT/DELETE, validações)
- **Quadrante**: ⚠️ **DESENVOLVER DEPOIS**
- **Justificativa**: Importante mas não persiste (fake API)
- **Dependências**: UC003 (Auth), UC005 (Cart Read)

### UC007 - Browse by Category
- **Criticidade**: 4 (Crítico - navegação estruturada)
- **Complexidade**: 1 (Muito simples - GET /products/category/{slug})
- **Quadrante**: ✅ **PRIORIDADE MÁXIMA**
- **Justificativa**: Padrão comum de navegação
- **Dependências**: Nenhuma

### UC008 - List Users (Admin)
- **Criticidade**: 2 (Secundário - backoffice, 10% tráfego)
- **Complexidade**: 2 (Simples - GET /users com paginação)
- **Quadrante**: 🔄 **QUICK WINS**
- **Justificativa**: Fácil implementar, menor impacto
- **Dependências**: UC003 (Auth admin)

### UC009 - User Journey (Unauthenticated)
- **Criticidade**: 5 (Essencial - fluxo 60% dos usuários)
- **Complexidade**: 3 (Moderado - combina UC001+UC002+UC004+UC007)
- **Quadrante**: 📋 **PLANEJAR CUIDADOSAMENTE**
- **Justificativa**: Jornada completa, múltiplos passos
- **Dependências**: UC001, UC002, UC004, UC007

### UC010 - User Journey (Authenticated)
- **Criticidade**: 4 (Crítico - fluxo 30% usuários compradores)
- **Complexidade**: 4 (Complexo - UC009 + UC003 + UC005)
- **Quadrante**: 📋 **PLANEJAR CUIDADOSAMENTE**
- **Justificativa**: Jornada end-to-end com auth
- **Dependências**: UC003, UC005, UC009

### UC011 - Mixed Workload (Realistic Traffic)
- **Criticidade**: 3 (Importante - simula produção real)
- **Complexidade**: 5 (Muito complexo - mix 60/30/10, think times)
- **Quadrante**: ⏸️ **DESENVOLVER DEPOIS**
- **Justificativa**: Valioso mas requer todos UCs anteriores
- **Dependências**: UC001-UC010

### UC012 - Token Refresh & Session Management
- **Criticidade**: 3 (Importante - resiliência auth)
- **Complexidade**: 3 (Moderado - POST /auth/refresh, validações)
- **Quadrante**: ⚠️ **DESENVOLVER DEPOIS**
- **Justificativa**: Nice-to-have, auth já funciona
- **Dependências**: UC003

### UC013 - Content Moderation (Posts/Comments)
- **Criticidade**: 2 (Secundário - não é e-commerce core)
- **Complexidade**: 2 (Simples - GET /posts, GET /comments)
- **Quadrante**: 🔄 **QUICK WINS**
- **Justificativa**: Fácil, mas baixo valor negócio
- **Dependências**: UC003 (Auth moderador)

---

## 📈 Visualização da Matriz

### Quadrante: PRIORIDADE MÁXIMA (Alta Criticidade + Baixa/Média Complexidade)
**Implementar PRIMEIRO** - Máximo valor, mínimo esforço

1. ✅ **UC001** - Browse Products Catalog (5,1)
2. ✅ **UC004** - View Product Details (4,1)
3. ✅ **UC007** - Browse by Category (4,1)
4. ✅ **UC002** - Search & Filter Products (5,2)
5. ✅ **UC003** - User Login & Profile (4,2)
6. ✅ **UC005** - Cart Operations Read (4,2)

### Quadrante: PLANEJAR CUIDADOSAMENTE (Alta Criticidade + Alta Complexidade)
**Implementar SEGUNDO** - Alto valor, requer planejamento

7. 📋 **UC009** - User Journey Unauthenticated (5,3)
8. 📋 **UC010** - User Journey Authenticated (4,4)

### Quadrante: QUICK WINS (Baixa Criticidade + Baixa Complexidade)
**Implementar TERCEIRO** - Fácil, menor impacto

9. 🔄 **UC008** - List Users Admin (2,2)
10. 🔄 **UC013** - Content Moderation (2,2)

### Quadrante: DESENVOLVER DEPOIS (Baixa Criticidade + Alta Complexidade)
**Implementar POR ÚLTIMO** - Muito esforço, baixo retorno

11. ⏸️ **UC006** - Cart Operations Write (3,3)
12. ⏸️ **UC012** - Token Refresh (3,3)
13. ⏸️ **UC011** - Mixed Workload (3,5)

---

## 🎯 Recomendação de Ordem de Implementação

### Sprint 1 - Fundação (Semana 1)
1. UC001 - Browse Products Catalog
2. UC004 - View Product Details
3. UC007 - Browse by Category

**Objetivo**: Cobrir 60% do tráfego (visitantes)

### Sprint 2 - Busca e Auth (Semana 2)
4. UC002 - Search & Filter Products
5. UC003 - User Login & Profile

**Objetivo**: Adicionar descoberta + autenticação

### Sprint 3 - Carrinho (Semana 3)
6. UC005 - Cart Operations (Read)

**Objetivo**: Habilitar pré-checkout

### Sprint 4 - Jornadas (Semana 4)
7. UC009 - User Journey (Unauthenticated)
8. UC010 - User Journey (Authenticated)

**Objetivo**: Fluxos end-to-end realistas

### Sprint 5 - Secundários (Semana 5)
9. UC008 - List Users (Admin)
10. UC013 - Content Moderation

**Objetivo**: Completar backoffice

### Sprint 6 - Avançados (Semana 6)
11. UC006 - Cart Operations (Write)
12. UC012 - Token Refresh
13. UC011 - Mixed Workload

**Objetivo**: Casos avançados e stress real

---

## 📊 Métricas de Cobertura por Sprint

| Sprint | UCs | Cobertura Tráfego | Cobertura Endpoints | Valor Negócio |
|--------|-----|-------------------|---------------------|---------------|
| 1 | 3 | 60% (visitantes) | 8/38 (21%) | Alto |
| 2 | +2 | +30% (auth) | +4/38 (10%) | Alto |
| 3 | +1 | +10% (carrinho) | +3/38 (8%) | Médio |
| 4 | +2 | 100% (jornadas) | +0/38 (0%) | Alto |
| 5 | +2 | - (admin) | +6/38 (16%) | Baixo |
| 6 | +3 | - (stress) | +3/38 (8%) | Médio |

**Total**: 13 UCs, 100% tráfego, 24/38 endpoints (63%)

---

## ⚠️ Observações Importantes

### Endpoints Não Cobertos (14/38)
- **Posts**: 6 endpoints (baixa prioridade, não é core e-commerce)
- **Users CRUD**: 5 endpoints (fake writes, baixo valor)
- **Products CRUD**: 3 endpoints (fake writes, não testável)

**Decisão**: Focar em operações READ reais, ignorar writes fake que não persistem

### Riscos Identificados

1. **UC011 (Mixed Workload)**: Complexidade 5, requer todos anteriores
   - Mitigação: Implementar por último, após validar UCs individuais

2. **Dependência Auth**: 6 UCs dependem de UC003
   - Mitigação: Priorizar UC003 no Sprint 2

3. **Fake Writes**: DummyJSON não persiste POST/PUT/DELETE
   - Mitigação: Documentar limitação, focar em validação response

### Critérios de Sucesso

- ✅ 60% tráfego coberto em Sprint 1 (visitantes)
- ✅ 90% tráfego coberto em Sprint 2 (+ auth)
- ✅ 100% tráfego em Sprint 4 (jornadas)
- ✅ 13 UCs implementados em 6 sprints
- ✅ SLOs validados para cada UC
