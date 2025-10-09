# Fase 1 — Inventário e Ajustes por UC (Codex)

Referências de consulta: `docs/dummyJson/*` e `data/fulldummyjsondata/*`. Testes devem consumir apenas `data/test-data/*`.

Legenda de status: Manter | Revisar | Descartar

## UC001 — Browse Products Catalog — Status: Manter
- Endpoints: GET `/products` (limit/skip/select/sortBy/order)
- Ajustes:
  - Enxugar seções descritivas; manter checks objetivos (status 200, array não vazio, campos essenciais).
  - Manter thresholds por feature `products` (P95 300ms) e `checks{uc:UC001}>0.995`.
  - Dados: `products-sample.json` (100 itens), derivado de `fulldummyjsondata/products.json`.

## UC002 — Search & Filter Products — Status: Manter
- Endpoints: GET `/products/search?q=...` (+ select/limit/skip/sortBy/order)
- Ajustes:
  - Focar em `q` e ordenação; remover variações redundantes.
  - Consolidar queries em `search-queries.json` (50 termos).
  - Thresholds: `http_req_duration{feature:search} p95<600ms`; checks mínimos.

## UC003 — User Login & Profile — Status: Manter
- Endpoints: POST `/auth/login`, GET `/auth/me`, (cookies + Authorization: Bearer).
- Ajustes:
  - Exemplos mínimos para cookie ou header; evitar duplicações.
  - Dados: `users-credentials.csv` (50 credenciais reais do dump de users).
  - Thresholds: auth p95<400ms; checks > 0.995.

## UC004 — View Product Details — Status: Manter
- Endpoints: GET `/products/{id}`
- Ajustes:
  - Checks: status 200, campos `id`, `title`, `price`; 404 esperado para inválidos.
  - Dados: `product-ids.json` (100 ids válidos).

## UC005 — Cart Operations (Read) — Status: Manter
- Endpoints: GET `/carts`, `/carts/{id}`, `/carts/user/{userId}`
- Ajustes:
  - Priorizar `/carts/user/{userId}` (principal); manter exemplos dos demais.
  - Dados: `users-with-carts.json` (amostra de userIds com carrinhos), `cart-ids.json`.

## UC006 — Cart Operations (Write - Simulated) — Status: Revisar
- Endpoints: POST `/carts/add`, PUT `/carts/{id}`, DELETE `/carts/{id}` (writes fake)
- Ajustes:
  - Deixar explícito que não há persistência; remover follow-up GET por id “criado”.
  - Checks: apenas status/shape da resposta simulada; tolerância a inconsistências.
  - Thresholds mais folgados; rate baixo em CI.

## UC007 — Browse by Category — Status: Manter
- Endpoints: GET `/products/categories`, `/products/category-list`, `/products/category/{slug}`
- Ajustes:
  - Unificar narrativa; `categories` vs `category-list` servem a propósitos distintos (slugs vs nomes).
  - Dados: `category-slugs.json`.

## UC008 — List Users (Admin) — Status: Revisar
- Endpoints: GET `/users`, `/users/{id}`, `/users/search`, `/users/filter`
- Ajustes:
  - Remover semântica “admin”: DummyJSON não aplica RBAC; basta token válido.
  - Renomear UC para “List Users”.
  - Dados: `user-ids-sample.json`, `users-search-queries.json`.

## UC009 — User Journey (Unauthenticated) — Status: Revisar
- Endpoints: composição de UC001 + UC002 + UC004 + UC007
- Ajustes:
  - Reutilizar thresholds/tags dos UCs base; reduzir seções duplicadas.
  - Sequências claras, 1–2 variações; evitar “mix” extensos.

## UC010 — User Journey (Authenticated) — Status: Manter
- Endpoints: POST `/auth/login`, GET `/auth/me`, GET `/carts/user/{userId}`
- Ajustes:
  - Referenciar `libs/http/auth` (login + headers) e dados compartilhados de UC003/UC005.
  - Tornar o “como rodar” objetivo (envs + baseURL + comando).

## UC011 — Mixed Workload (Realistic Traffic) — Status: Revisar
- Endpoints: múltiplos (products, users, carts, posts/comments)
- Ajustes:
  - Definir mix percentual simples (ex.: 50% products, 25% search, 15% users, 10% carts); reduzir escopo inicial.
  - Garantir executores open‑model e RPS modestos; remover métricas redundantes.

## UC012 — Token Refresh & Session — Status: Manter
- Endpoints: POST `/auth/refresh`, GET `/auth/me`
- Ajustes:
  - Explicitar fluxo refresh → me, token de cookies vs body.
  - Dados: credenciais + refreshToken quando aplicável.

## UC013 — Content Moderation (Posts/Comments) — Status: Revisar
- Endpoints: GET `/posts`, `/posts/{id}`, `/posts/user/{id}`, `/comments`, `/comments/{id}`, `/comments/post/{id}`
- Ajustes:
  - Renomear para “Posts & Comments (Read‑only)”; remover menções a moderação/roles.
  - Focar em navegação/busca/leitura; registrar que writes são fake e fora de escopo.

---

Próximos passos da Fase 1
- Atualizar títulos e seções dos UCs marcados como Revisar, seguindo o template mínimo (AGENTS.md).
- Conferir que todos os arquivos de `data/test-data/*` referenciados existem (ou estão planejados) e são pequenos.
- Submeter commit incremental por UC revisado; push ao final do bloco UC001–UC003.

