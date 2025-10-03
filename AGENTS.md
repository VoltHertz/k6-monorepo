# Repository Guidelines

This guide sets conventions for contributing to the k6 + TypeScript performance‑testing monorepo. Keep changes small, documented, and aligned with the structure and quality gates below.

## Project Structure & Module Organization
- `docs/` — Source of truth for phases, use cases, SLOs, and templates.
- `data/` — `fulldummyjsondata/` (read‑only reference), `test-data/` (curated inputs).
- `.github/` — Automation and `.github/copilot-instructions.md` for agent guidance.
- Phase 4+ (planned): `tests/` (API + scenarios), `libs/` (http, data, metrics), `configs/` (scenarios, envs).
- Example test path: `tests/api/products/browse-catalog.test.ts`.

## Build, Test, and Development Commands
- Prereqs: k6 v0.57+, Node 20.x, TypeScript 5.x.
- Run single test: `k6 run tests/api/products/browse-catalog.test.ts`.
- Adjust load: `K6_RPS=10 K6_DURATION=2m k6 run tests/api/products/browse-catalog.test.ts`.
- Type check (Phase 4+): `npm run typecheck` (e.g., `tsc --noEmit`).

## Coding Style & Naming Conventions
- Language: TypeScript. Indentation: 2 spaces; prefer ≤80 cols where reasonable.
- Test files: `<action>-<resource>.test.ts` (e.g., `search-products.test.ts`).
- k6 tags (required): `feature`, `kind`, `uc`.
  - Example: `tags: { feature: 'products', kind: 'browse', uc: 'UC001' }`.
- Metrics: snake_case `<feature>_<action>_<unit>` (e.g., `product_list_duration_ms`).
- Pin remote module versions (e.g., `https://jslib.k6.io/.../1.4.0/index.js`).

## Testing Guidelines
- Prefer open‑model executors (e.g., `constant-arrival-rate`) for realistic RPS.
- Use clear checks: `'status is 200'`, `'has products array'`.
- Thresholds live in `options.thresholds`, e.g.:
  - `'http_req_duration{feature:products}': ['p(95)<300']`
  - `'checks{uc:UC001}': ['rate>0.995']`
- Test data: load from `data/test-data/`; do not read from `data/fulldummyjsondata/` in tests.

## Commit & Pull Request Guidelines
- Conventional Commits: `type(scope): summary`.
  - Examples: `docs(readme): update overview`, `docs(phase3): add templates`, `feat: initial setup`.
- PRs must include:
  - What/why, linked issues, and scope of impact.
  - How to run locally (exact `k6` command and env vars).
  - Expected thresholds/SLOs and a sample k6 summary.
  - Update docs/configs if scenarios, tags, or SLOs change.

## Security & Configuration Tips
- DummyJSON writes are non‑persistent; prioritize read paths in tests.
- Never commit secrets; prefer env vars (e.g., `K6_RPS`, `K6_DURATION`).
- Always version‑pin remote modules; avoid unversioned URLs.

