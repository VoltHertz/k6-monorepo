# Análise de Perfis de Usuário - DummyJSON API

## 📊 Personas Identificadas

### Persona 1: Visitante Anônimo (60% do tráfego esperado)

**Características**:
- Usuário não autenticado
- Navega pelo catálogo de produtos
- Busca e filtra produtos
- Visualiza detalhes de produtos
- Não realiza compras

**Jornada Típica**:
1. Acessa página inicial → Lista produtos
2. Explora categorias → Navega por categoria específica
3. Busca termo específico → Visualiza resultados
4. Clica em produto → Vê detalhes completos
5. Pode voltar e repetir navegação

**Padrão de Carga**:
- Requests: GET /products, GET /products/search, GET /products/category/{slug}
- Think time: 2-5 segundos entre ações
- Duração de sessão: 3-8 minutos
- Taxa de conversão para login: ~15%

**Endpoints Utilizados**:
- `GET /products` (alta frequência)
- `GET /products/categories` (média frequência)
- `GET /products/category/{slug}` (média frequência)
- `GET /products/search` (média-alta frequência)
- `GET /products/{id}` (alta frequência)

---

### Persona 2: Comprador Autenticado (30% do tráfego esperado)

**Características**:
- Usuário com conta ativa
- Realiza login
- Navega produtos autenticado
- Adiciona itens ao carrinho
- Visualiza e gerencia carrinho

**Jornada Típica**:
1. Login → POST /auth/login
2. Verifica perfil → GET /auth/me
3. Navega produtos → GET /products
4. Adiciona ao carrinho → POST /carts/add
5. Visualiza carrinho → GET /carts/user/{userId}
6. Pode atualizar carrinho → PUT /carts/{id}

**Padrão de Carga**:
- Session duration: 5-15 minutos
- Think time: 3-7 segundos entre ações
- Token refresh: A cada 30-45 minutos
- Ações de escrita: 20% do total de requests

**Endpoints Utilizados**:
- `POST /auth/login` (início de sessão)
- `GET /auth/me` (verificação periódica)
- `GET /products/*` (navegação)
- `POST /carts/add` (adição ao carrinho)
- `GET /carts/user/{userId}` (visualização)
- `PUT /carts/{id}` (atualização - simulada)

---

### Persona 3: Administrador/Moderador (10% do tráfego esperado)

**Características**:
- Usuário com role admin/moderator
- Acessa dados de usuários
- Visualiza múltiplos carrinhos
- Pode realizar operações administrativas

**Jornada Típica**:
1. Login → POST /auth/login
2. Lista usuários → GET /users (com paginação)
3. Busca usuário específico → GET /users/search
4. Visualiza carrinhos → GET /carts
5. Consulta posts/comentários → GET /posts, GET /comments

**Padrão de Carga**:
- Session duration: 10-30 minutos
- Think time: 5-10 segundos (análise de dados)
- Requests mais complexos (filtros, buscas)
- Maior uso de paginação (limit/skip)

**Endpoints Utilizados**:
- `POST /auth/login`
- `GET /users` (paginação extensa)
- `GET /users/search`
- `GET /users/filter`
- `GET /carts` (visão geral)
- `GET /posts`, `GET /comments` (moderação)

---

## 📈 Distribuição de Carga Proposta

| Persona | % Tráfego | RPS Base | Endpoints Principais | Autenticação |
|---------|-----------|----------|----------------------|--------------|
| Visitante Anônimo | 60% | 6 rps | Products (browse, search) | Não |
| Comprador Autenticado | 30% | 3 rps | Products + Auth + Carts | Sim |
| Admin/Moderador | 10% | 1 rps | Users + Carts + Posts | Sim |

**Baseline Total**: 10 RPS (ajustável por ambiente)

---

## 🔄 Fluxos de Negócio por Persona

### Fluxo 1: Descoberta de Produto (Visitante)
```
1. GET /products?limit=20 (lista inicial)
2. GET /products/categories (explorar categorias)
3. GET /products/category/beauty (categoria específica)
4. GET /products/1 (detalhes do produto)
[Think time: 3s entre cada step]
```

### Fluxo 2: Compra Simulada (Comprador)
```
1. POST /auth/login (autenticação)
2. GET /auth/me (validar sessão)
3. GET /products/search?q=phone (busca)
4. GET /products/5 (detalhes)
5. POST /carts/add (adicionar ao carrinho)
6. GET /carts/user/1 (ver carrinho)
[Think time: 5s entre cada step]
```

### Fluxo 3: Administração (Admin)
```
1. POST /auth/login (autenticação)
2. GET /users?limit=30&skip=0 (listar usuários)
3. GET /users/search?q=emily (buscar usuário)
4. GET /carts (overview de carrinhos)
5. GET /posts (moderação de conteúdo)
[Think time: 7s entre cada step]
```

---

## 🎯 Implicações para Casos de Uso

### Casos de Uso Prioritários (baseado em personas):

**P0 - Críticos (Visitante Anônimo - 60% tráfego)**:
- UC001: Browse Products Catalog
- UC002: Search & Filter Products

**P1 - Importantes (Comprador Autenticado - 30% tráfego)**:
- UC003: User Login & Profile
- UC005: Cart Operations (Read)
- UC006: Cart Operations (Write)

**P2 - Secundários (Admin - 10% tráfego)**:
- UC004: List Users (Admin)
- UC010: Content Moderation (Posts/Comments)

---

## 📝 Observações Importantes

1. **DummyJSON Limitations**:
   - POST/PUT/DELETE não persistem dados (respostas simuladas)
   - Tokens JWT válidos por 60 min (default)
   - Rate limiting não documentado (assumir 100 rps seguro)

2. **Autenticação**:
   - 40% do tráfego (Comprador + Admin) requer auth
   - Refresh tokens devem ser testados
   - Cookie vs Bearer token (suporta ambos)

3. **Think Times Realistas**:
   - Visitante: 2-5s (navegação rápida)
   - Comprador: 3-7s (decisão de compra)
   - Admin: 5-10s (análise de dados)

4. **Session Duration**:
   - Visitante: 3-8 min (rápido)
   - Comprador: 5-15 min (médio)
   - Admin: 10-30 min (longo)
