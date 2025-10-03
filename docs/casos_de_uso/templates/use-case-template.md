# UC00X - [Nome do Caso de Uso]

> **Status**: 🚧 Draft | ✅ Approved | 🔄 In Review  
> **Prioridade**: P0 (Crítico) | P1 (Importante) | P2 (Secundário) | P3 (Nice-to-have)  
> **Complexidade**: 1 (Muito Simples) | 2 (Simples) | 3 (Moderada) | 4 (Complexa) | 5 (Muito Complexa)  
> **Sprint**: Sprint X (Semana Y)  
> **Esforço Estimado**: Xh  

---

## 📋 Descrição

### Perfil de Usuário
[Descrever a persona que executa este caso de uso]
- **Tipo**: Visitante Anônimo | Comprador Autenticado | Administrador/Moderador
- **Distribuição de Tráfego**: X% do total
- **Objetivo de Negócio**: [O que o usuário deseja alcançar]

### Contexto
[Quando e por que este caso de uso ocorre. Exemplo: "Usuário acessa página inicial do e-commerce e deseja explorar produtos disponíveis"]

### Valor de Negócio
[Por que este UC é importante para o negócio. Exemplo: "Representa 60% do tráfego total, crítico para descoberta de produtos"]

---

## 🔗 Endpoints Envolvidos

| Método | Endpoint | SLO Individual | Observações |
|--------|----------|----------------|-------------|
| GET | `/example/{id}` | P95 < 300ms | [Notas específicas] |
| POST | `/example` | P95 < 400ms | ⚠️ FAKE: não persiste dados |

**Total de Endpoints**: X  
**Operações READ**: X  
**Operações WRITE**: X  

---

## 📊 SLOs (Service Level Objectives)

| Métrica | Threshold | Rationale |
|---------|-----------|-----------|
| `http_req_duration{feature:X}` (P95) | < 300ms | [Justificativa baseada em baseline] |
| `http_req_duration{feature:X}` (P99) | < 500ms | [Margem de segurança] |
| `http_req_failed{feature:X}` | < 0.5% | [Taxa de erro aceitável] |
| `checks{uc:UC00X}` | > 99.5% | [Validações devem passar] |

**Baseline de Referência**: `docs/casos_de_uso/fase1-baseline-slos.md`

---

## 📦 Dados de Teste

### Arquivos Necessários

| Arquivo | Localização | Volume | Fonte | Estratégia de Refresh |
|---------|-------------|--------|-------|----------------------|
| `example-data.json` | `data/test-data/` | 100 items | Gerado de `fulldummyjsondata/` | Semanal |
| `example-ids.csv` | `data/test-data/` | 50 IDs | Extração manual | Mensal |

### Geração de Dados
```bash
# Comando para gerar massa de teste (se aplicável)
node data/test-data/generators/generate-example.ts \
  --source data/fulldummyjsondata/example.json \
  --output data/test-data/example-data.json \
  --sample-size 100
```

### Dependências de Dados
- [Listar dados que dependem de outros UCs, ex: "Requer users-credentials.csv de UC003"]

---

## 🔄 Fluxo Principal

### Pré-condições
- [O que deve estar verdadeiro antes do fluxo começar, ex: "Usuário não autenticado", "Token válido disponível"]

### Steps

**Step 1: [Nome do Step]**  
```http
GET /example?limit=20&skip=0
Headers:
  Content-Type: application/json
  [Outros headers]
```

**Validações**:
- ✅ Status code = 200
- ✅ Response contains `data` array
- ✅ `data.length` <= 20

**Think Time**: 2-5s (navegação casual)

---

**Step 2: [Nome do Step]**  
```http
POST /example
Headers:
  Content-Type: application/json
  Authorization: Bearer ${token}
Body:
{
  "field1": "value1",
  "field2": "value2"
}
```

**Validações**:
- ✅ Status code = 201 (ou 200 se fake)
- ✅ Response contains `id` field
- ✅ `id` > 0

**Think Time**: 3-7s (decisão de ação)

---

### Pós-condições
- [O que deve ser verdadeiro após fluxo completo, ex: "Produto adicionado ao carrinho (simulado)", "Token refreshed"]

---

## 🔀 Fluxos Alternativos

### Cenário de Erro 1: [Nome do Erro]
**Condição**: [Quando ocorre, ex: "Token expirado"]

**Steps**:
1. Request com token inválido
2. Recebe 401 Unauthorized
3. [Ação de recuperação, ex: "Refresh token e retry"]

**Validações**:
- ✅ Status code = 401
- ✅ Error message contém "token"

---

### Edge Case 1: [Nome do Edge Case]
**Condição**: [Cenário raro, ex: "Produto fora de estoque"]

**Steps**:
1. [Passo a passo]

**Validações**:
- ✅ [Checks esperados]

---

## ⚙️ Implementação

### Localização do Teste
- **Arquivo**: `tests/api/<feature>/<test-name>.test.ts`
- **Exemplo**: `tests/api/products/browse-catalog.test.ts`

### Configuração de Cenário
```javascript
export const options = {
  scenarios: {
    uc00x_scenario: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.K6_RPS) || 5,
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '5m',
      preAllocatedVUs: 10,
      maxVUs: 50,
      tags: { feature: 'example', kind: 'browse', uc: 'UC00X' },
    },
  },
  thresholds: {
    'http_req_duration{feature:example}': ['p(95)<300'],
    'http_req_failed{feature:example}': ['rate<0.005'],
    'checks{uc:UC00X}': ['rate>0.995'],
  },
};
```

### Tags Obrigatórias
```javascript
tags: { 
  feature: 'example',  // Domain area
  kind: 'browse',      // Operation type
  uc: 'UC00X'          // Use case ID
}
```

---

## 🧪 Comandos de Teste

### Execução Local
```bash
# Smoke test (validação rápida)
K6_RPS=1 K6_DURATION=30s k6 run tests/api/example/test-name.test.ts

# Baseline (5 min, 5 RPS)
K6_RPS=5 K6_DURATION=5m k6 run tests/api/example/test-name.test.ts

# Stress (10 min, 20 RPS)
K6_RPS=20 K6_DURATION=10m k6 run tests/api/example/test-name.test.ts
```

### CI/CD
```bash
# GitHub Actions smoke test (PR)
.github/workflows/k6-pr-smoke.yml

# GitHub Actions baseline (main branch)
.github/workflows/k6-main-baseline.yml
```

---

## 📈 Métricas Customizadas

### Trends (Latência)
```javascript
import { Trend } from 'k6/metrics';

const exampleDuration = new Trend('example_operation_duration_ms');

// No VU code:
exampleDuration.add(res.timings.duration);
```

### Counters (Eventos de Negócio)
```javascript
import { Counter } from 'k6/metrics';

const exampleErrors = new Counter('example_operation_errors');
const exampleSuccess = new Counter('example_operation_success');

// No VU code:
if (res.status === 200) {
  exampleSuccess.add(1);
} else {
  exampleErrors.add(1);
}
```

### Dashboards
- **Grafana**: [Link para dashboard se disponível]
- **k6 Cloud**: [Link para projeto se disponível]

---

## ⚠️ Observações Importantes

### Limitações da API
- [Documentar limitações conhecidas, ex: "DummyJSON POST/PUT/DELETE não persistem dados (fake responses)"]
- [Outras observações técnicas]

### Particularidades do Teste
- [Notas sobre comportamento esperado, ex: "Paginação usa limit/skip, não page/size"]
- [Outras particularidades]

### Considerações de Desempenho
- [Notas sobre otimização, ex: "Use SharedArray para carregar dados, evita duplicação em memória"]

---

## 🔗 Dependências

### UCs Dependentes (Bloqueadores)
- [Listar UCs que DEVEM estar completos antes deste, ex: "UC003 (Auth) - requer token válido"]

### UCs que Usam Este (Fornece Para)
- [Listar UCs que REUTILIZAM este, ex: "UC009 (User Journey) - integra este fluxo no step 2"]

### Libs Necessárias
- [Listar libs externas, ex: "`libs/http/auth.ts` - funções login(), getToken()"]

### Dados Requeridos
- [Listar dados externos, ex: "`data/test-data/users-credentials.csv` de UC003"]

---

## 📂 Libs/Helpers Criados

### [Nome da Lib] (se aplicável)
**Localização**: `libs/<categoria>/<nome>.ts`

**Funções Exportadas**:
```typescript
// Exemplo:
export function exampleHelper(param: string): SomeType {
  // implementação
}

export const exampleConstant = 'value';
```

**Uso**:
```typescript
import { exampleHelper } from '../../../libs/example/helper';

// No VU code:
const result = exampleHelper('test');
```

**Testes Unitários**: `tests/unit/libs/example/helper.test.ts` (se aplicável)

---

## 📝 Histórico de Mudanças

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-10-03 | [Nome] | Criação inicial do UC |
| | | |

---

## ✅ Checklist de Completude

Antes de marcar como ✅ Approved:

- [ ] Perfil de usuário está claro e realista
- [ ] Todos os endpoints estão documentados com método HTTP
- [ ] SLOs estão definidos e justificados (referência: baseline)
- [ ] Fluxo principal está detalhado passo a passo
- [ ] Validações (checks) estão especificadas
- [ ] Dados de teste estão identificados (fonte + volume)
- [ ] Headers obrigatórios estão documentados
- [ ] Think times estão especificados onde necessário
- [ ] Edge cases e cenários de erro estão mapeados
- [ ] Dependências de outros UCs estão listadas
- [ ] Limitações da API (ex: fake POST) estão documentadas
- [ ] Arquivo nomeado corretamente: `UC00X-kebab-case.md`
- [ ] Libs/helpers criados estão documentados (se aplicável)
- [ ] Comandos de teste estão corretos e testados
- [ ] Tags obrigatórias estão especificadas (feature, kind, uc)
- [ ] Métricas customizadas estão documentadas (se aplicável)

---

## 📚 Referências

- [DummyJSON API Docs](https://dummyjson.com/docs)
- [k6 Documentation](https://grafana.com/docs/k6/latest/)
- Baseline SLOs: `docs/casos_de_uso/fase1-baseline-slos.md`
- Matriz de Priorização: `docs/casos_de_uso/fase2-matriz-priorizacao.md`
- Roadmap: `docs/casos_de_uso/fase2-roadmap-implementacao.md`
- Mapa de Dependências: `docs/casos_de_uso/fase2-mapa-dependencias.md`
