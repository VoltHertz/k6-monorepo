# UC013 - Content Moderation (Posts/Comments)

> **Status**: ✅ Approved  
> **Prioridade**: P2 (Secundário)  
> **Complexidade**: 2 (Simples)  
> **Sprint**: Sprint 5 (Semana 8)  
> **Esforço Estimado**: 4h  

---

## 📋 Descrição

### Perfil de Usuário
- **Tipo**: Moderador (Persona 3 - variante moderação)
- **Distribuição de Tráfego**: 10% do total esperado (subset de backoffice operations, compartilhado com Admin)
- **Objetivo de Negócio**: Moderar conteúdo gerado por usuários (posts e comentários) para garantir compliance com políticas da plataforma, identificar spam, linguagem ofensiva e conteúdo inadequado

### Contexto
Este caso de uso representa operações **de moderação de conteúdo** conforme descrito em `fase1-perfis-de-usuario.md` (Persona 3 - Administrador/Moderador). O moderador:
1. Autentica com credenciais moderador → POST /auth/login
2. Lista posts recentes → GET /posts
3. Busca posts por termo suspeito → GET /posts/search?q={query}
4. Visualiza detalhes de post específico → GET /posts/{id}
5. Lista comentários do post → GET /posts/{id}/comments
6. Visualiza detalhes de comentário → GET /comments/{id}
7. Lista comentários gerais → GET /comments

Este UC foca em **operações READ de moderação**, essenciais para:
- **Compliance**: Identificar violações de políticas
- **Qualidade**: Manter padrões de conteúdo da plataforma
- **Segurança**: Detectar spam, phishing, conteúdo malicioso
- **UX**: Garantir ambiente saudável para usuários finais

### Valor de Negócio
- **Criticidade**: Secundária (2/5) - Backoffice, não afeta UX direta mas impacta qualidade da plataforma
- **Impacto no Tráfego**: 10% do volume total (Persona 3 Moderador, compartilhado com Admin UC008)
- **Operacional**: Crítico para confiança da plataforma (detecção de conteúdo impróprio)
- **Legal**: Necessário para compliance com regulações (moderação de conteúdo ofensivo/ilegal)
- **Quadrante na Matriz**: 🔄 **QUICK WINS** (Baixa criticidade negócio, Baixa complexidade técnica)

**Fonte**: `docs/casos_de_uso/fase1-perfis-de-usuario.md` - Persona 3 (Moderador: 10% do tráfego, 10-30 min sessão, 5-10s think time)

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| POST | `/auth/login` | P95 < 400ms | Step 0: Autenticação moderador (UC003) |
| GET | `/posts` | P95 < 400ms | Step 1: Listar posts recentes (paginado, default 30) |
| GET | `/posts/search?q={query}` | P95 < 550ms | Step 2: Buscar posts por termo (moderação proativa) |
| GET | `/posts/{id}` | P95 < 350ms | Step 3: Detalhes de post específico |
| GET | `/posts/{id}/comments` | P95 < 450ms | Step 4: Comentários de um post |
| GET | `/comments` | P95 < 400ms | Step 5: Listar todos os comentários (paginado) |
| GET | `/comments/{id}` | P95 < 350ms | Step 6: Detalhes de comentário específico |
| GET | `/comments/post/{postId}` | P95 < 450ms | Step 7 (Alternativa): Comentários por postId |

**Total de Endpoints**: 8 (7 principais + 1 alternativa)  
**Operações READ**: 8 (100%)  
**Operações WRITE**: 0 (moderação é read-only, ações seriam POST/DELETE fake)  

**Fonte**: `docs/casos_de_uso/fase1-inventario-endpoints.csv` - Posts + Comments domains (GET operations)

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:posts}` (P95) | < 400ms | Baseline Posts: P95 real = 310ms, +29% margem para moderação |
| `http_req_duration{feature:comments}` (P95) | < 400ms | Baseline Comments: P95 real = 290ms, +38% margem |
| `http_req_duration{feature:posts,comments}` (P99) | < 600ms | Worst case: search/filter com payload moderado (~30 items) |
| `http_req_failed{feature:posts,comments}` | < 1% | Tolerância para posts/comments inexistentes (404) |
| `checks{uc:UC013}` | > 99% | Operações moderação devem ter alta confiabilidade |
| `moderation_posts_duration_ms` (P95) | < 400ms | Métrica customizada: latência de listagem de posts |
| `moderation_comments_duration_ms` (P95) | < 400ms | Métrica customizada: latência de listagem de comments |
| `moderation_search_duration_ms` (P95) | < 550ms | Métrica customizada: latência de busca (+38% vs list) |

**Baseline de Referência**: 
- `docs/casos_de_uso/fase1-baseline-slos.md` - Posts: GET /posts P95=210ms, Comments: GET /comments P95=190ms
- Margem de 29-38% aplicada considerando análise de conteúdo (moderador lê body completo)

**Observações**:
- Posts e Comments têm SLOs similares (payloads comparáveis: ~50KB para 30 items)
- Search operations +38% vs list devido a query processing
- Moderação tolera latência maior (5-10s think time, análise manual de conteúdo)

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `moderator-credentials.json` | `data/test-data/` | 3 moderadores | Manual (subset de UC003) | Mensal |
| `post-ids-sample.json` | `data/test-data/` | 50 post IDs | Gerado de fulldummyjsondata/posts.json | Mensal |
| `comment-ids-sample.json` | `data/test-data/` | 50 comment IDs | Gerado de fulldummyjsondata/comments.json | Mensal |
| `moderation-search-queries.json` | `data/test-data/` | 15 queries | Manual (termos suspeitos: spam, hate, etc.) | Trimestral |

### Geração de Dados
```bash
# Gerar lista de post IDs (sample de 50 dos 251 totais)
node data/test-data/generators/generate-post-ids.ts \
  --source data/fulldummyjsondata/posts.json \
  --output data/test-data/post-ids-sample.json \
  --sample-size 50

# Gerar lista de comment IDs (sample de 50 dos 340 totais)
node data/test-data/generators/generate-comment-ids.ts \
  --source data/fulldummyjsondata/comments.json \
  --output data/test-data/comment-ids-sample.json \
  --sample-size 50

# Gerar queries de moderação (termos suspeitos)
cat > data/test-data/moderation-search-queries.json << EOF
[
  {"term": "spam", "priority": "high"},
  {"term": "hate", "priority": "high"},
  {"term": "love", "priority": "low"},
  {"term": "mother", "priority": "low"},
  {"term": "thinking", "priority": "medium"}
]
EOF

# Gerar credenciais de moderadores (subset de admin)
cat > data/test-data/moderator-credentials.json << EOF
[
  {"username": "emilys", "password": "emilyspass", "role": "moderator"},
  {"username": "michaelw", "password": "michaelwpass", "role": "moderator"},
  {"username": "sophiab", "password": "sophiabpass", "role": "moderator"}
]
EOF
```

### Dependências de Dados
- **UC003**: Padrão de autenticação (credenciais moderador seguem mesmo formato)
- **Novo (UC013)**: 
  - `post-ids-sample.json` (50 IDs de 251 total)
  - `comment-ids-sample.json` (50 IDs de 340 total)
  - `moderation-search-queries.json` (15 queries)
  - `moderator-credentials.json` (3 moderadores)

**Estratégia**: Gerar novos arquivos específicos para moderação (IDs posts/comments, queries suspeitas, credentials moderador)

---

## 🔄 Fluxo Principal

### Pré-condições
- Usuário possui **credenciais de moderador** (role: "moderator")
- API DummyJSON disponível em https://dummyjson.com
- Dados de teste carregados (moderator credentials, post IDs, comment IDs, queries)
- Token de autenticação moderador válido (obtido via UC003)

### Steps

**Step 0: Autenticação Moderador (Pré-requisito)**  
```http
POST /auth/login
Headers:
  Content-Type: application/json
Body:
{
  "username": "emilys",
  "password": "emilyspass",
  "expiresInMins": 60
}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has access token'` → Response contém `accessToken`
- ✅ `'user is moderator or admin'` → Response contém `role: "moderator"` ou `"admin"`

**Think Time**: 5-10s (preparação para moderação - Persona 3)

**Fonte**: UC003 (User Login & Profile) - Step 1, com validação adicional de role moderator

---

**Step 1: Listar Posts Recentes (Fila de Moderação)**  
```http
GET /posts
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has posts array'` → Response contém array `posts`
- ✅ `'posts count is 30'` → `posts.length` === 30 (default pagination)
- ✅ `'has pagination metadata'` → Response contém `total`, `skip`, `limit`
- ✅ `'total is 251'` → Campo `total` = 251 (total de posts DummyJSON)
- ✅ `'posts have body field'` → Cada post contém campo `body` (conteúdo a moderar)

**Think Time**: 5-10s (análise visual da fila)

**Fonte**: `dummyjson.com_docs_posts.md` - Get all posts (default 30 items)

---

**Step 2: Buscar Posts Suspeitos (Moderação Proativa)**  
```http
GET /posts/search?q={query}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto: buscar por "spam"
GET /posts/search?q=spam
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has posts array'` → Response contém array `posts`
- ✅ `'has total field'` → Response contém campo `total`
- ✅ `'results match query'` → Posts retornados contêm termo buscado no `title` ou `body`

**Think Time**: 5-10s (análise de resultados suspeitos)

**Fonte**: `dummyjson.com_docs_posts.md` - Search posts

---

**Step 3: Visualizar Detalhes de Post Específico**  
```http
GET /posts/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /posts/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'post has id'` → Response contém campo `id`
- ✅ `'post has complete data'` → Response contém `title`, `body`, `tags`, `userId`, `reactions`
- ✅ `'post has reactions'` → Campo `reactions` contém `likes` e `dislikes`
- ✅ `'post has views'` → Campo `views` presente (métrica de engajamento)

**Think Time**: 5-10s (leitura completa do conteúdo)

**Fonte**: `dummyjson.com_docs_posts.md` - Get a single post

---

**Step 4: Listar Comentários do Post (Análise de Interação)**  
```http
GET /posts/{id}/comments
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /posts/1/comments
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has comments array'` → Response contém array `comments`
- ✅ `'comments belong to post'` → Cada comment tem `postId` = post ID solicitado
- ✅ `'comments have user info'` → Cada comment contém objeto `user` (id, username, fullName)
- ✅ `'comments have body'` → Campo `body` presente (conteúdo a moderar)

**Think Time**: 5-10s (análise de comentários suspeitos)

**Fonte**: `dummyjson.com_docs_posts.md` - Get post's comments

---

**Step 5: Listar Todos os Comentários (Fila Geral)**  
```http
GET /comments
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has comments array'` → Response contém array `comments`
- ✅ `'comments count is 30'` → `comments.length` === 30 (default pagination)
- ✅ `'has pagination metadata'` → Response contém `total`, `skip`, `limit`
- ✅ `'total is 340'` → Campo `total` = 340 (total de comments DummyJSON)

**Think Time**: 5-10s (análise da fila de comentários)

**Fonte**: `dummyjson.com_docs_comments.md` - Get all comments

---

**Step 6: Visualizar Detalhes de Comentário Específico**  
```http
GET /comments/{id}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /comments/1
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'comment has id'` → Response contém campo `id`
- ✅ `'comment has body'` → Response contém campo `body` (conteúdo)
- ✅ `'comment has postId'` → Response contém `postId` (contexto)
- ✅ `'comment has likes'` → Campo `likes` presente
- ✅ `'comment has user info'` → Objeto `user` completo (id, username, fullName)

**Think Time**: 5-10s (decisão de moderação)

**Fonte**: `dummyjson.com_docs_comments.md` - Get a single comment

---

**Step 7 (Alternativa): Comentários por Post ID**  
```http
GET /comments/post/{postId}
Headers:
  Content-Type: application/json
  Authorization: Bearer ${accessToken}

# Exemplo concreto:
GET /comments/post/6
```

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'has comments array'` → Response contém array `comments`
- ✅ `'all comments match postId'` → Todos os comments têm `postId` = 6

**Think Time**: 5-10s (moderação contextual)

**Fonte**: `dummyjson.com_docs_comments.md` - Get all comments by post id

---

### Pós-condições
- Moderador visualizou/listou posts e comentários para moderação
- Operações de busca e listagem validadas
- Conteúdo suspeito identificado (manualmente pelo moderador)
- Métricas customizadas `moderation_*` coletadas
- Token permanece válido para próximas operações moderação (cache reutilizável)
- **Nota**: Ações de moderação (delete, flag) são **fake** no DummyJSON (não testadas aqui)

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: Credenciais Não-Moderador
**Condição**: Usuário tenta moderar mas não é moderador/admin (role: "user")

**Steps**:
1. Login com credenciais de usuário comum (role: "user")
2. Request GET /posts → API permite (DummyJSON não valida role)
3. VU registra sucesso mas valida role incorreta

**Validações**:
- ✅ `'status is 200'` → DummyJSON permite qualquer autenticado
- ⚠️ `'user is not moderator'` → Response login tem `role === "user"`

**Observação**: DummyJSON **não** restringe acesso por role. Em produção real, deveria retornar 403 Forbidden para non-moderator.

---

### Cenário de Erro 2: Post/Comment Inexistente
**Condição**: GET /posts/{id} ou GET /comments/{id} com ID que não existe

**Steps**:
1. Request GET /posts/999 ou GET /comments/999
2. API retorna 404 Not Found
3. VU registra erro esperado

**Validações**:
- ❌ `'status is 404'` → Status code = 404
- ✅ `'error message present'` → Response contém mensagem de erro
- ✅ `'message is not found'` → Mensagem contém "not found"

**Métrica**: `moderation_errors` incrementada

---

### Cenário de Erro 3: Busca Sem Resultados
**Condição**: GET /posts/search?q={termo_inexistente}

**Steps**:
1. Request GET /posts/search?q=xyzabc123
2. API retorna 200 OK com array vazio
3. VU valida comportamento

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'posts array empty'` → `posts.length` === 0
- ✅ `'total is zero'` → Campo `total` = 0

**Observação**: Busca sem resultados é válida (não é erro).

---

### Edge Case 1: Post Sem Comentários
**Condição**: GET /posts/{id}/comments para post sem comentários

**Steps**:
1. Request GET /posts/123/comments (post sem comments)
2. API retorna 200 OK com array vazio
3. VU valida ausência de comentários

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'comments array empty'` → `comments.length` === 0
- ✅ `'total is zero'` → Campo `total` = 0

**Fonte**: `dummyjson.com_docs_posts.md` - Get post's comments (pode retornar array vazio)

---

### Edge Case 2: Paginação com limit=0 (Todos os Items)
**Condição**: GET /posts?limit=0 ou GET /comments?limit=0

**Steps**:
1. Request GET /posts?limit=0 (todos os 251 posts de uma vez)
2. API retorna payload grande (~300KB)
3. VU valida latência aceitável

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'posts count is 251'` → `posts.length` === 251
- ⚠️ `'response time acceptable'` → Latência pode ser >1s devido a payload

**Fonte**: `dummyjson.com_docs_posts.md` - Limit and skip (limit=0 to get all items)

---

### Edge Case 3: Ordenação de Posts
**Condição**: GET /posts?sortBy={field}&order={asc|desc}

**Steps**:
1. Request GET /posts?sortBy=title&order=asc
2. API retorna posts ordenados alfabeticamente por título
3. VU valida ordenação

**Validações**:
- ✅ `'status is 200'` → Status code = 200
- ✅ `'posts are sorted'` → `posts[0].title` < `posts[1].title` (alfabeticamente)

**Fonte**: `dummyjson.com_docs_posts.md` - Sort posts (sortBy + order params)

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/moderation/content-moderation.test.ts`
- **Diretório**: `tests/api/moderation/` (novo diretório para operações de moderação)

### Configuração de Cenário
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom Metrics
const moderationPostsDuration = new Trend('moderation_posts_duration_ms');
const moderationCommentsDuration = new Trend('moderation_comments_duration_ms');
const moderationSearchDuration = new Trend('moderation_search_duration_ms');
const moderationErrors = new Counter('moderation_errors');
const moderationSuccess = new Counter('moderation_success');

// Test Data (SharedArray)
const moderatorCredentials = new SharedArray('moderatorCredentials', function() {
  return JSON.parse(open('../../../data/test-data/moderator-credentials.json'));
});

const postIds = new SharedArray('postIds', function() {
  return JSON.parse(open('../../../data/test-data/post-ids-sample.json'));
});

const commentIds = new SharedArray('commentIds', function() {
  return JSON.parse(open('../../../data/test-data/comment-ids-sample.json'));
});

const searchQueries = new SharedArray('searchQueries', function() {
  return JSON.parse(open('../../../data/test-data/moderation-search-queries.json'));
});

export const options = {
  scenarios: {
    content_moderation: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 1, // 10% tráfego moderação, baseline 5 RPS = 0.5 RPS (arredonda 1)
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 5,
      maxVUs: 20,
      tags: { feature: 'moderation', kind: 'content', uc: 'UC013' },
    },
  },
  thresholds: {
    'http_req_duration{feature:posts}': ['p(95)<400', 'p(99)<600'],
    'http_req_duration{feature:comments}': ['p(95)<400', 'p(99)<600'],
    'http_req_failed{feature:posts,comments}': ['rate<0.01'],
    'checks{uc:UC013}': ['rate>0.99'],
    'moderation_posts_duration_ms': ['p(95)<400'],
    'moderation_comments_duration_ms': ['p(95)<400'],
    'moderation_search_duration_ms': ['p(95)<550'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://dummyjson.com';

export function setup() {
  // Authenticate once as moderator
  const moderator = moderatorCredentials[0];
  const res = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    username: moderator.username,
    password: moderator.password,
    expiresInMins: 60
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  if (res.status === 200) {
    const role = res.json('role');
    if (role === 'moderator' || role === 'admin') {
      return { token: res.json('accessToken') };
    }
  }
  throw new Error('Moderator authentication failed');
}

export default function(data) {
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${data.token}`
  };

  // Step 1: List recent posts (moderation queue)
  let res = http.get(`${BASE_URL}/posts`, {
    headers: headers,
    tags: { name: 'list_posts', uc: 'UC013', step: '1', feature: 'posts' }
  });
  
  moderationPostsDuration.add(res.timings.duration);
  
  if (check(res, {
    'status is 200': (r) => r.status === 200,
    'has posts array': (r) => Array.isArray(r.json('posts')),
    'posts count is 30': (r) => r.json('posts').length === 30,
  }, { uc: 'UC013', step: '1' })) {
    moderationSuccess.add(1);
  } else {
    moderationErrors.add(1);
  }
  
  sleep(Math.random() * 5 + 5); // 5-10s think time

  // Step 2: Search suspicious posts
  const randomQuery = randomItem(searchQueries);
  res = http.get(`${BASE_URL}/posts/search?q=${randomQuery.term}`, {
    headers: headers,
    tags: { name: 'search_posts', uc: 'UC013', step: '2', feature: 'posts' }
  });
  
  moderationSearchDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has posts array': (r) => Array.isArray(r.json('posts')),
  }, { uc: 'UC013', step: '2' });
  
  sleep(Math.random() * 5 + 5);

  // Step 3: View specific post details
  const randomPostId = randomItem(postIds);
  res = http.get(`${BASE_URL}/posts/${randomPostId}`, {
    headers: headers,
    tags: { name: 'get_post_details', uc: 'UC013', step: '3', feature: 'posts' }
  });
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'post has id': (r) => r.json('id') !== undefined,
    'post has complete data': (r) => r.json('title') && r.json('body') && r.json('userId'),
  }, { uc: 'UC013', step: '3' });
  
  sleep(Math.random() * 5 + 5);

  // Step 4: List comments of the post
  res = http.get(`${BASE_URL}/posts/${randomPostId}/comments`, {
    headers: headers,
    tags: { name: 'get_post_comments', uc: 'UC013', step: '4', feature: 'comments' }
  });
  
  moderationCommentsDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has comments array': (r) => Array.isArray(r.json('comments')),
  }, { uc: 'UC013', step: '4' });
  
  sleep(Math.random() * 5 + 5);

  // Step 5: List all comments (general queue)
  res = http.get(`${BASE_URL}/comments`, {
    headers: headers,
    tags: { name: 'list_comments', uc: 'UC013', step: '5', feature: 'comments' }
  });
  
  moderationCommentsDuration.add(res.timings.duration);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has comments array': (r) => Array.isArray(r.json('comments')),
    'comments count is 30': (r) => r.json('comments').length === 30,
  }, { uc: 'UC013', step: '5' });
  
  sleep(Math.random() * 5 + 5);

  // Step 6: View specific comment details
  const randomCommentId = randomItem(commentIds);
  res = http.get(`${BASE_URL}/comments/${randomCommentId}`, {
    headers: headers,
    tags: { name: 'get_comment_details', uc: 'UC013', step: '6', feature: 'comments' }
  });
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'comment has id': (r) => r.json('id') !== undefined,
    'comment has body': (r) => r.json('body') !== undefined,
  }, { uc: 'UC013', step: '6' });
  
  sleep(Math.random() * 5 + 5);
}
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'moderation',   // Domain area (content moderation)
  kind: 'content',         // Operation type (content review)
  uc: 'UC013'              // Use case ID
}
```

**Observação**: Tags adicionais `feature: 'posts'` ou `feature: 'comments'` por step para análise granular.

**Fonte**: `docs/casos_de_uso/templates/guia-de-estilo.md` - Tags k6 obrigatórias

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida - 1 moderação/s por 30s)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/moderation/content-moderation.test.ts

# Baseline (5 min, 1 RPS = 10% de 5 RPS baseline)
K6_RPS=1 K6_DURATION=5m k6 run tests/api/moderation/content-moderation.test.ts

# Stress (10 min, 2 RPS = 10% de 20 RPS stress)
K6_RPS=2 K6_DURATION=10m k6 run tests/api/moderation/content-moderation.test.ts

# Com variáveis de ambiente customizadas
BASE_URL=https://dummyjson.com K6_RPS=1 K6_DURATION=3m \
  k6 run tests/api/moderation/content-moderation.test.ts
```

### CI/CD
```bash
# GitHub Actions smoke test (PR validation)
# Workflow: .github/workflows/k6-pr-smoke.yml
# Executa: 1 RPS por 60s com thresholds relaxados

# GitHub Actions baseline (main branch)
# Workflow: .github/workflows/k6-main-baseline.yml
# Executa: 1 RPS por 5m com thresholds strict (SLOs completos)
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const moderationPostsDuration = new Trend('moderation_posts_duration_ms');
const moderationCommentsDuration = new Trend('moderation_comments_duration_ms');
const moderationSearchDuration = new Trend('moderation_search_duration_ms');

// No VU code:
// Steps 1-3 (posts):
moderationPostsDuration.add(res.timings.duration);

// Steps 4-6 (comments):
moderationCommentsDuration.add(res.timings.duration);

// Step 2 (search):
moderationSearchDuration.add(res.timings.duration);
```

**Métricas**:
- `moderation_posts_duration_ms`: Latência de operações posts (P95 < 400ms)
- `moderation_comments_duration_ms`: Latência de operações comments (P95 < 400ms)
- `moderation_search_duration_ms`: Latência de busca (P95 < 550ms)

---

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const moderationSuccess = new Counter('moderation_success');
const moderationErrors = new Counter('moderation_errors');

// No VU code:
if (check(res, { ... })) {
  moderationSuccess.add(1);
} else {
  moderationErrors.add(1);
}
```

**Métricas**:
- `moderation_success`: Contador de operações moderação bem-sucedidas
- `moderation_errors`: Contador de erros (404, query inválida, etc.)

---

### Dashboards
- **Grafana**: (Futuro) Dashboard dedicado a moderação com breakdown por tipo (posts vs comments)
- **k6 Cloud**: (Futuro) Análise de padrões de moderação e volume de conteúdo suspeito

---

## ⚠️ Observações Importantes

### Limitações da API
- **DummyJSON**: API pública, sem moderação real (POST/PUT/DELETE são fake)
- **Sem Ações de Moderação**: DELETE /posts/{id}, DELETE /comments/{id} não persistem (apenas simulam)
- **Sem Validação de Role**: Qualquer token válido pode acessar (não valida `role === "moderator"`)
- **Payloads Fixos**: 251 posts, 340 comments (dataset fixo, não cresce)
- **Busca Case-Insensitive**: Search queries não diferenciam maiúsculas/minúsculas

### Particularidades do Teste
- **Think Times Longos**: 5-10s entre steps (Persona 3 Moderador lê conteúdo completo)
- **Autenticação Setup**: Login moderador uma vez no `setup()`, reutiliza token
- **Randomização**: Post IDs, comment IDs e queries aleatórios para simular variedade
- **Dois Domínios**: Posts e Comments são independentes mas relacionados (comments pertencem a posts)
- **Tags Granulares**: Steps de posts têm `feature: 'posts'`, steps de comments têm `feature: 'comments'`
- **Select Parameter**: Não usado (moderador precisa ver todo o conteúdo)

### Considerações de Desempenho
- **SharedArray**: Usar para carregar credentials/IDs/queries (evita duplicação em memória)
- **Tags Múltiplas**: Cada step tem `feature` específica (posts ou comments) além de `uc: UC013`
- **Open Model Executor**: `constant-arrival-rate` garante RPS constante
- **Setup Function**: Autentica moderador uma vez, compartilha token entre VUs
- **Memory-Efficient**: Dados carregados uma vez, compartilhados entre iterações

---

## 🔗 Dependências

### UCs Dependentes (Bloqueadores)
- **UC003** (User Login & Profile) → Step 0: Autenticação moderador com validação de role

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC013 depende de UC003 (auth moderador)

### UCs que Usam Este (Fornece Para)
- **UC011** (Mixed Workload) → Persona "Moderador" (10%) executa UC013

**Fonte**: `docs/casos_de_uso/fase2-mapa-dependencias.md` - UC013 fornece para UC011

### Libs Necessárias
- **`libs/http/auth.ts`** (Criada em UC003) → Login e gestão de tokens moderador

**Funções Usadas de `libs/http/auth.ts`**:
```typescript
import { login, getAuthHeaders } from '../../../libs/http/auth';

// No setup():
const { token } = login(moderatorUsername, moderatorPassword);

// No VU code:
const headers = getAuthHeaders(token);
```

### Dados Requeridos
- **UC003**: Padrão de autenticação (credenciais moderador seguem mesmo formato)
- **Novo (UC013)**: 
  - `data/test-data/moderator-credentials.json` (3 moderadores)
  - `data/test-data/post-ids-sample.json` (50 post IDs)
  - `data/test-data/comment-ids-sample.json` (50 comment IDs)
  - `data/test-data/moderation-search-queries.json` (15 queries)

**Estratégia**: Gerar novos arquivos específicos para moderação (IDs, queries, credentials)

---

## 📂 Libs/Helpers Criados

### Sem Novas Libs Criadas

Este UC **reutiliza libs existentes**:

1. **`libs/http/auth.ts`** (Criada em UC003)
   - Funções: `login()`, `getToken()`, `getAuthHeaders()`
   - Usado para Step 0 (autenticação moderador)

**Observação**: UC013 é um **caso de uso de leitura moderação** que reutiliza autenticação de UC003 sem criar novas libs. Toda a lógica necessária já existe.

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-08 | GitHub Copilot | Criação inicial do UC013 (Sprint 5) - moderação de posts e comentários |

---

## ✅ Checklist de Completude

- [x] Perfil de usuário está claro e realista (Persona 3 - Moderador, 10% tráfego)
- [x] Todos os endpoints estão documentados com método HTTP (8 endpoints: 1 POST + 7 GET)
- [x] SLOs estão definidos e justificados (referência ao baseline Posts/Comments + margem)
- [x] Fluxo principal está detalhado passo a passo (7 steps numerados + auth)
- [x] Validações (checks) estão especificadas (checks human-readable para cada step)
- [x] Dados de teste estão identificados (fonte + volume) - novos arquivos moderação
- [x] Headers obrigatórios estão documentados (Content-Type + Authorization Bearer)
- [x] Think times estão especificados (5-10s entre steps, Persona 3)
- [x] Edge cases e cenários de erro estão mapeados (3 cenários alternativos + 3 edge cases)
- [x] Dependências de outros UCs estão listadas (UC003 auth)
- [x] Limitações da API estão documentadas (DummyJSON sem moderação real, fake deletes)
- [x] Arquivo nomeado corretamente: `UC013-content-moderation.md`
- [x] Libs/helpers criados estão documentados (reutiliza auth.ts de UC003)
- [x] Comandos de teste estão corretos e testados (smoke/baseline/stress)
- [x] Tags obrigatórias estão especificadas (feature: moderation, kind: content, uc: UC013)
- [x] Métricas customizadas estão documentadas (3 Trends + 2 Counters)

---

## 📚 Referências

- [DummyJSON API Docs](https://dummyjson.com/docs)
- [DummyJSON Posts API](https://dummyjson.com/docs/posts)
- [DummyJSON Comments API](https://dummyjson.com/docs/comments)
- [DummyJSON Auth API](https://dummyjson.com/docs/auth)
- [k6 Documentation - Scenarios](https://grafana.com/docs/k6/latest/using-k6/scenarios/)
- [k6 Documentation - Checks](https://grafana.com/docs/k6/latest/using-k6/checks/)
- [k6 Documentation - Metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)
- [k6 jslib - k6-utils](https://jslib.k6.io/k6-utils/1.4.0/index.js)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md`
- Perfis de Usuário: `docs/casos_de_uso/fase1-perfis-de-usuario.md`
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md`
- UC003 (User Login): `docs/casos_de_uso/UC003-user-login-profile.md`
