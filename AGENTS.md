# Repository Guidelines - Dual AI Workflow

## 🤖 AI Agents Strategy

### **Parallel Implementation Race** 🏁
Both AI agents will implement the **SAME complete k6 monorepo project** independently:

- **Codex CLI (GPT-5)** - Branch: `feature/codex-implementation`
  - **Guidelines**: THIS file (`AGENTS.md`)
  
- **GitHub Copilot (Claude Sonnet 4.5)** - Branch: `feature/copilot-implementation`
  - **Guidelines**: `.github/copilot-instructions.md`

### **Competition Rules**
- ✅ **SAME scope**: Implement all 13 UCs (UC001-UC013) + 3 libs + 15 data files
- ✅ **SAME quality bar**: Follow Phase 3 templates, ADRs, SLOs
- ✅ **SEPARATE branches**: No cross-pollination during development
- ✅ **FINAL evaluation**: User compares quality/completeness and chooses winner (or merges best parts)

### **Success Criteria**
- Code quality (TypeScript, k6 best practices)
- Test coverage (13/13 UCs implemented)
- SLO compliance (thresholds validated)
- Documentation quality (comments, README updates)
- Runnable tests (k6 run tests/...)
- CI/CD readiness (smoke/baseline/stress/soak)

---

## 📋 Codex CLI Guidelines (GPT-5)
As regras aqui definidas não devem ser seguidas pelo Copilot (Claude Sonnet 4.5), somente pelo Codex CLI (GPT-5).

Purpose: primary implementer for the k6 + TypeScript monorepo on branch `feature/codex-implementation`. Own design, code, tests, data, and docs for all UCs. Prepare focused patches; commit frequently (atomic, Conventional Commits) and push at phase boundaries. Validate each increment against the PRD and use‑case docs.

## Project Structure & Inputs
- Core docs: `docs/planejamento/PRD.md`, `.github/copilot-instructions.md`.
- Use cases: `docs/casos_de_uso/UC00X-*.md` (Phase 4).
- Data: `data/fulldummyjsondata/` (read‑only) → generate `data/test-data/`.
- Code (planned/active): `tests/`, `libs/`, `configs/`.

Planned libs (owned by Codex):
- `libs/observability/` – metric/tag helpers, custom summary, thresholds registry.
- `libs/data/` – lightweight data loader + generators for `test-data/`.
- `libs/http/` – small HTTP wrapper (base URL, common headers, retries/backoff).

## Implementation Workflow (Patch‑First)
- Plan next UC from `docs/feedbackAI/plano.md` and `docs/casos_de_uso/UC00X-*.md`.
- Scaffold tests under `tests/api/<feature>/<action>.test.ts` with required tags/metrics.
- Use only open‑model executors; set thresholds per UC/feature via helpers.
- Load data only from `data/test-data/` (generate via `libs/data` when needed).
- Run locally with envs: `K6_RPS=5 K6_DURATION=2m k6 run tests/...`.
- Keep diffs small; use Conventional Commits in messages; commit at each implementação relevante.
- Update docs (README, ADRs) alongside code; include exact run command + expected SLOs.

## Coding Style & Naming
- TypeScript; indent 2 spaces; small diffs.
- Tests: `<action>-<resource>.test.ts` (e.g., `browse-catalog.test.ts`).
- Tags (mandatory): `feature`, `kind`, `uc`.
  - Example: `tags: { feature: 'products', kind: 'browse', uc: 'UC001' }`.
- Metrics: snake_case `<feature>_<action>_<unit>` (e.g., `product_list_duration_ms`).
- Pin remote modules (e.g., `https://jslib.k6.io/k6-utils/1.4.0/index.js`).

## Testing & Quality Gates
- Executors: open‑model only (`constant-arrival-rate`, `ramping-arrival-rate`).
- Thresholds by feature/use case:
  - `'http_req_duration{feature:products}': ['p(95)<300']`
  - `'checks{uc:UC00X}': ['rate>0.995']`
- Checks human‑readable; think times per Personas (Phase 1).
- Data source: only `data/test-data/`; never load from `fulldummyjsondata/` in tests.

## Deliverables (owned by Codex)
- 13/13 UCs implemented with runnable k6 tests.
- 3 libs (`observability`, `data`, `http`) documented and used by tests.
- 15+ curated files under `data/test-data/` (non‑PII, deterministic where possible).
- Baseline README instructions and commands to run each UC suite.
- ADRs for key decisions (data strategy, retries, thresholds rationale).

## Branch & PR Policy
- Work happens on `feature/codex-implementation`; keep history clean (no force‑push after review start).
- Commit policy: commits at cada implementação relevante (pequenos, atômicos, com contexto de UC/feature). Mensagens no padrão Conventional Commits.
- Push policy: push ao final de fases significativas (ex.: libs básicas prontas; UCs 1–3 concluídas com baseline; observability integrada) e quando necessário para acionar CI/PR. Evite pushes muito fragmentados.
- Sincronização: rebase com `main` antes de abrir PR; após PR aberto, evitar reescrita de histórico.
- Abrir PR para `main` quando o mínimo estiver OK (smoke/baseline verdes para o conjunto inicial de UCs). Descrever: escopo, links de UC, comandos de execução, envs, thresholds e resumos de k6.

## PR Review Checklist (Reviewer)
- Links to UC doc and PRD section; rationale “what/why”.
- Exact run command + envs; expected SLOs/thresholds; sample k6 summary.
- Tagging correct; file naming matches patterns; metrics naming snake_case.
- Open‑model executor used; data loaded from `test-data/`.
- Conventional Commits nas mensagens; política de commit/push respeitada (commits atômicos, push por fase).

## Commit & Push Policy (Resumo)
- Commit: cada implementação relevante (novo teste UC, ajuste em lib, mudança de thresholds, geração de `test-data`). Mensagens curtas e objetivas com escopo claro (ex.: `feat(tests/products): add UC001 browse-catalog`).
- Push: ao concluir um bloco coeso de trabalho (fase). Exemplos de fases:
  - Bootstrap de libs (`observability`, `data`, `http`) integradas ao primeiro teste
  - Pacote inicial de UCs (p.ex., UC001–UC003) com smoke e baseline verdes
  - Integração de `handleSummary` + artefatos no CI
- PRs: abrir quando houver valor revisável e executável; manter incrementais, evitando WIP ruidoso.

## Security & Config
- No secrets in repo; use env vars (e.g., `K6_RPS`, `K6_DURATION`).
- Version‑pin remote modules; document any new thresholds/configs in `configs/`.

## Ownership & Expectations
- Codex is accountable for completeness, quality, and clarity on this branch.
- Outperform Copilot branch by stricter tagging, better thresholds rationale, reusable libs, and cleaner docs.
- Prefer correctness and maintainability over premature optimization; avoid flakiness.
