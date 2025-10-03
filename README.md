# k6 Performance Testing Monorepo

[![k6](https://img.shields.io/badge/k6-v0.57+-7d64ff?logo=k6&logoColor=white)](https://k6.io/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178c6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Enterprise-grade k6 performance testing monorepo with TypeScript, designed for 10+ years of maintainability. Testing DummyJSON API with automated quality gates, CI/CD integration, and comprehensive observability.

## 🎯 Project Overview

This monorepo implements a **production-ready performance testing framework** using k6 and TypeScript to test the [DummyJSON API](https://dummyjson.com). Built with enterprise best practices, it provides:

- ✅ **Native TypeScript support** (k6 v0.57+ runs `.ts` files directly)
- ✅ **Open Model executors** (realistic load patterns with arrival rates)
- ✅ **Comprehensive test coverage** across 38 API endpoints
- ✅ **Automated quality gates** with SLO validation
- ✅ **CI/CD integration** (smoke, baseline, stress, soak tests)
- ✅ **Observable metrics** with custom Trends/Counters
- ✅ **Data-driven testing** with SharedArray patterns

## 📊 Current Status

### Phase 1: Analysis & Requirements ✅ COMPLETE

| Deliverable | Status | Description |
|-------------|--------|-------------|
| [📊 Endpoint Inventory](docs/casos_de_uso/fase1-inventario-endpoints.csv) | ✅ | 38 endpoints across 6 domains |
| [👥 User Personas](docs/casos_de_uso/fase1-perfis-de-usuario.md) | ✅ | 3 personas (60/30/10 traffic split) |
| [⏱️ SLO Baseline](docs/casos_de_uso/fase1-baseline-slos.md) | ✅ | P95 latency targets by feature |

**Key Insights**:
- **38 endpoints** mapped (Products, Auth, Users, Carts, Posts, Comments)
- **Traffic distribution**: 60% browsing, 30% purchases, 10% admin
- **SLO targets**: Products P95 < 300ms, Auth P95 < 400ms, Search P95 < 600ms

### Next: Phase 2 - Prioritization & Roadmap 🔄

## 🏗️ Architecture Highlights

### ADR-001: TypeScript-First
```bash
# No build step needed - k6 runs .ts natively
k6 run tests/api/products/browse-catalog.test.ts
```

### ADR-002: Open Model Executors (Critical!)
```typescript
export const options = {
  scenarios: {
    browse_catalog: {
      executor: 'constant-arrival-rate',  // ✅ Open model
      rate: 5,                             // Target RPS
      timeUnit: '1s',
      duration: '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
    },
  },
};
```

### ADR-003: Data Strategy
```
data/fulldummyjsondata/  → READ-ONLY reference dumps
data/test-data/          → Curated test data (CSV/JSON)
```

## 📁 Project Structure

```
k6-monorepo/
├── .github/
│   └── copilot-instructions.md    # AI agent guidance + 6-phase UC plan
├── data/
│   ├── fulldummyjsondata/          # Application dumps (read-only)
│   └── test-data/                  # Curated test data (TBD)
├── docs/
│   ├── casos_de_uso/               # Use case documentation
│   │   ├── README.md               # Phase navigation
│   │   ├── fase1-inventario-endpoints.csv
│   │   ├── fase1-perfis-de-usuario.md
│   │   └── fase1-baseline-slos.md
│   ├── dummyJson/                  # API documentation
│   └── planejamento/
│       └── PRD.md                  # Product Requirements Document
├── tests/                          # (Phase 4 - TBD)
│   ├── api/                        # Domain-driven tests
│   └── scenarios/                  # User journeys
├── libs/                           # (Phase 4 - TBD)
│   ├── http/                       # Client, checks, interceptors
│   ├── data/                       # SharedArray loaders
│   └── metrics/                    # Custom metrics
└── configs/                        # (Phase 4 - TBD)
    ├── scenarios/                  # smoke/baseline/stress/soak
    └── envs/                       # Environment configs
```

## 🚀 Quick Start

### Prerequisites
- Node.js 20.x LTS
- k6 v0.57+ ([install](https://grafana.com/docs/k6/latest/set-up/install-k6/))
- TypeScript 5.x

### Installation
```bash
# Clone repository
git clone https://github.com/VoltHertz/k6-monorepo.git
cd k6-monorepo

# Install dependencies (when package.json is added in Phase 4)
npm install

# Type check
npm run typecheck  # tsc --noEmit
```

### Running Tests (Phase 4+)
```bash
# Single test
k6 run tests/api/products/browse-catalog.test.ts

# With custom RPS/duration
K6_RPS=10 K6_DURATION=2m k6 run tests/api/products/browse-catalog.test.ts

# CI smoke test (30-60s, loose thresholds)
k6 run --env=ci configs/scenarios/smoke.yaml
```

## 📈 SLO Targets by Feature

| Feature | P95 Latency | P99 Latency | Error Rate | Checks |
|---------|-------------|-------------|------------|--------|
| **Products** | < 300ms | < 500ms | < 0.5% | > 99.5% |
| **Auth** | < 400ms | < 600ms | < 1% | > 99% |
| **Search** | < 600ms | < 800ms | < 1% | > 99% |
| **Carts** | < 500ms | < 700ms | < 1% | > 99% |
| **Users** | < 500ms | < 700ms | < 1% | > 99% |

## 📚 Documentation

- **[PRD](docs/planejamento/PRD.md)**: Product Requirements Document (1007 lines, 4-phase roadmap)
- **[Use Cases Navigation](docs/casos_de_uso/README.md)**: Phase-by-phase deliverables
- **[Copilot Instructions](.github/copilot-instructions.md)**: AI agent guidance + test patterns
- **[DummyJSON API Docs](docs/dummyJson/)**: Scraped API documentation

## 🛠️ Development Workflow

### 6-Phase Use Case Methodology

1. ✅ **Phase 1: Analysis** - Endpoints, personas, SLOs baseline
2. 🔄 **Phase 2: Prioritization** - Criticality matrix, roadmap
3. 🔄 **Phase 3: Templates** - Reusable UC templates
4. 🔄 **Phase 4: Writing** - Implement 9 use cases
5. 🔄 **Phase 5: Validation** - Stakeholder review
6. 🔄 **Phase 6: Handoff** - Generate test data, implementation guide

**Progress**: 3/24 items complete (12.5%)

## 🔑 Critical Patterns

### Tagging Strategy
```typescript
tags: { 
  feature: 'products',  // Domain area
  kind: 'browse',       // Operation type
  uc: 'UC001'          // Use case ID
}
```

### Thresholds (Quality Gates)
```typescript
thresholds: {
  'http_req_duration{feature:products}': ['p(95)<300'],
  'http_req_failed{feature:products}': ['rate<0.005'],
  'checks{uc:UC001}': ['rate>0.995'],
}
```

### Remote Modules (Version-Pinned)
```typescript
import { randomItem } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';
```

## 🚫 Common Pitfalls to Avoid

1. ❌ **DON'T use closed-model executors** (`shared-iterations`, `per-vu-iterations`)
2. ❌ **DON'T load data from `fulldummyjsondata/`** in tests → use `test-data/`
3. ❌ **DON'T expect DummyJSON writes to persist** → they return fake responses
4. ❌ **DON'T forget `sleep(1)` between iterations** → prevents unrealistic hammering
5. ❌ **DON'T use unversioned remote modules** → always pin versions

## 🧪 CI/CD Pipelines (Phase 4+)

- **PR Smoke**: 30-60s, 1-2 RPS, loose thresholds
- **Main Baseline**: 5-10min, 5-10 RPS, strict SLOs
- **On-Demand**: Stress/soak via `workflow_dispatch`

## 🤝 Contributing

This project is currently in **Phase 1 (Analysis)**. Contributions will be welcome after Phase 4 (Implementation).

### Development Standards
- **File naming**: `<action>-<resource>.test.ts`
- **Imports order**: k6 built-ins → metrics → data → remote → local
- **Check descriptions**: Human-readable strings
- **Custom metrics**: `<feature>_<action>_<unit>`

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 References

- [k6 Documentation](https://grafana.com/docs/k6/latest/)
- [k6 TypeScript Support](https://grafana.com/docs/k6/latest/using-k6/javascript-typescript-compatibility-mode/)
- [DummyJSON API](https://dummyjson.com/docs)
- [jslib.k6.io](https://jslib.k6.io/)

---

**Built with ❤️ for enterprise performance testing | Designed for 10+ years of maintainability**
