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

Purpose: quality gate for the k6 + TypeScript monorepo. Acts as the reviewer (Head of Non‑Functional Testing). Do not push unless explicitly requested. Validate every change against the PRD and Copilot instructions.

## Project Structure & Inputs
- Core docs: `docs/planejamento/PRD.md`, `.github/copilot-instructions.md`.
- Use cases: `docs/casos_de_uso/UC00X-*.md` (Phase 4).
- Data: `data/fulldummyjsondata/` (read‑only) → generate `data/test-data/`.
- Code (planned/active): `tests/`, `libs/`, `configs/`.

## Review Workflow (No Push)
- Reproduce locally: `k6 run tests/api/<feature>/<test>.test.ts`.
- Parametrize: `K6_RPS=5 K6_DURATION=2m k6 run tests/...`.
- Type check when available: `npm run typecheck`.
- Provide focused patches or comments; request approval before commit/push.

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

## PR Review Checklist (Reviewer)
- Links to UC doc and PRD section; rationale “what/why”.
- Exact run command + envs; expected SLOs/thresholds; sample k6 summary.
- Tagging correct; file naming matches patterns; metrics naming snake_case.
- Open‑model executor used; data loaded from `test-data/`.
- Conventional Commits style in commits; no push without request.

## Security & Config
- No secrets in repo; use env vars (e.g., `K6_RPS`, `K6_DURATION`).
- Version‑pin remote modules; document any new thresholds/configs in `configs/`.
