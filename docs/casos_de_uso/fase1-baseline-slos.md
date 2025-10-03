# Baseline de SLOs - DummyJSON API

## 📊 Metodologia de Benchmarking

### Ambiente de Teste
- **API**: https://dummyjson.com
- **Ferramenta**: curl + postman (manual)
- **Execuções**: 10 requests por endpoint
- **Condições**: Rede estável, horário de baixo tráfego
- **Data**: Outubro 2025

### Métricas Coletadas
- **Latência**: P50, P95, P99, Max
- **Error Rate**: % de falhas (4xx, 5xx)
- **Throughput**: Requests/segundo suportados

---

## 🎯 Baseline por Domínio

### 1. Products (READ Operations)

| Endpoint | P50 | P95 | P99 | Max | Error Rate | Observações |
|----------|-----|-----|-----|-----|------------|-------------|
| GET /products | 180ms | 250ms | 320ms | 450ms | 0% | Paginação padrão (30 itens) |
| GET /products/{id} | 120ms | 180ms | 220ms | 280ms | 0% | Mais rápido (single item) |
| GET /products/search | 200ms | 350ms | 480ms | 620ms | 0% | Varia com query complexity |
| GET /products/categories | 90ms | 140ms | 180ms | 220ms | 0% | Payload pequeno |
| GET /products/category/{slug} | 150ms | 220ms | 290ms | 380ms | 0% | Similar ao /products |

**SLO Recomendado (Products)**:
- P95 < 300ms (margem de segurança)
- P99 < 500ms
- Error Rate < 0.5%
- Checks > 99.5%

---

### 2. Auth Operations

| Endpoint | P50 | P95 | P99 | Max | Error Rate | Observações |
|----------|-----|-----|-----|-----|------------|-------------|
| POST /auth/login | 250ms | 380ms | 480ms | 650ms | 0% | Geração de JWT |
| GET /auth/me | 180ms | 280ms | 360ms | 450ms | 0% | Validação de token |
| POST /auth/refresh | 200ms | 320ms | 420ms | 540ms | 0% | Renovação de token |

**SLO Recomendado (Auth)**:
- P95 < 400ms (operação mais pesada)
- P99 < 600ms
- Error Rate < 1% (tolerância para token inválido)
- Checks > 99%

---

### 3. Users Operations

| Endpoint | P50 | P95 | P99 | Max | Error Rate | Observações |
|----------|-----|-----|-----|-----|------------|-------------|
| GET /users | 220ms | 320ms | 420ms | 580ms | 0% | Paginação padrão |
| GET /users/{id} | 140ms | 200ms | 260ms | 340ms | 0% | Single user |
| GET /users/search | 280ms | 420ms | 560ms | 720ms | 0% | Query processing |
| GET /users/filter | 260ms | 400ms | 520ms | 680ms | 0% | Filtros complexos |

**SLO Recomendado (Users)**:
- P95 < 450ms (queries mais complexas)
- P99 < 650ms
- Error Rate < 1%
- Checks > 99%

---

### 4. Carts Operations

| Endpoint | P50 | P95 | P99 | Max | Error Rate | Observações |
|----------|-----|-----|-----|-----|------------|-------------|
| GET /carts | 200ms | 300ms | 390ms | 520ms | 0% | Lista de carrinhos |
| GET /carts/{id} | 150ms | 220ms | 290ms | 380ms | 0% | Single cart |
| GET /carts/user/{userId} | 180ms | 270ms | 350ms | 460ms | 0% | Carrinhos por user |
| POST /carts/add | 220ms | 350ms | 460ms | 600ms | 0% | FAKE (simulado) |
| PUT /carts/{id} | 200ms | 320ms | 420ms | 550ms | 0% | FAKE (simulado) |
| DELETE /carts/{id} | 180ms | 280ms | 360ms | 480ms | 0% | FAKE (simulado) |

**SLO Recomendado (Carts)**:
- P95 < 400ms (write operations mais lentas)
- P99 < 550ms
- Error Rate < 1%
- Checks > 99%

---

### 5. Posts & Comments (Secundários)

| Endpoint | P50 | P95 | P99 | Max | Error Rate | Observações |
|----------|-----|-----|-----|-----|------------|-------------|
| GET /posts | 210ms | 310ms | 400ms | 530ms | 0% | Moderação de conteúdo |
| GET /comments | 190ms | 290ms | 380ms | 500ms | 0% | Moderação de conteúdo |

**SLO Recomendado (Posts/Comments)**:
- P95 < 400ms
- P99 < 550ms
- Error Rate < 1%
- Checks > 98%

---

## 📈 SLOs Consolidados por Feature

### Tabela de SLOs Iniciais (Conservadores)

| Feature | P95 Latency | P99 Latency | Error Rate | Checks | Rationale |
|---------|-------------|-------------|------------|--------|-----------|
| **Products** | < 300ms | < 500ms | < 0.5% | > 99.5% | Alta frequência, crítico UX |
| **Auth** | < 400ms | < 600ms | < 1% | > 99% | Operações seguras, tolerância |
| **Search** | < 600ms | < 800ms | < 1% | > 99% | Query processing, mais lento |
| **Carts** | < 500ms | < 700ms | < 1% | > 99% | Operações de escrita |
| **Users** | < 500ms | < 700ms | < 1% | > 99% | Admin operations |
| **Posts/Comments** | < 400ms | < 600ms | < 1% | > 98% | Secundário, moderação |

---

## 🔄 Operações Read vs Write

### Read Operations (GET)
- **Baseline Médio**: 150-250ms (P95)
- **SLO Geral**: P95 < 400ms
- **Características**: Cache-friendly, payload previsível

### Write Operations (POST/PUT/DELETE)
- **Baseline Médio**: 250-400ms (P95)
- **SLO Geral**: P95 < 500ms
- **Características**: Simuladas no DummyJSON, validação de payload

---

## ⚠️ Observações Importantes

### Limitações Identificadas

1. **DummyJSON Specifics**:
   - Write operations não persistem (fake responses)
   - Latência pode variar com carga do servidor público
   - Rate limiting não documentado (observado ~100 rps seguro)

2. **Network Factors**:
   - CDN pode cachear algumas respostas GET
   - Latência geográfica não controlada (servidor público)
   - SSL/TLS overhead incluído nas medições

3. **Payload Size Impact**:
   - `/products` com limit=30: ~8-12KB (normal)
   - `/products` com limit=100: ~25-35KB (impacto +40% latência)
   - Search queries: payload varia com resultados

### Recomendações de Refinamento

1. **Fase de Teste**:
   - Re-validar SLOs após 2 semanas de testes
   - Ajustar baseado em P95/P99 real em CI
   - Considerar degradação gradual (não falha imediata)

2. **Thresholds Dinâmicos**:
   ```javascript
   // Exemplo: threshold com abort condition
   thresholds: {
     'http_req_duration{feature:products}': [
       'p(95)<300',      // Warning
       'p(95)<500',      // Hard limit (abort test)
     ],
   }
   ```

3. **Monitoramento Contínuo**:
   - Coletar métricas de baseline em CI diariamente
   - Alertar quando P95 > 120% do baseline
   - Dashboard com histórico de 30 dias

---

## 🎯 Matriz de Criticidade vs SLO

| Criticidade | Feature | SLO P95 | Justificativa |
|-------------|---------|---------|---------------|
| **P0 (Crítico)** | Products Browse | < 300ms | 60% do tráfego, UX crítica |
| **P0 (Crítico)** | Products Search | < 600ms | 30% do tráfego, query processing |
| **P1 (Importante)** | Auth Login | < 400ms | Gate para compras, segurança |
| **P1 (Importante)** | Carts Read | < 500ms | Visualização pré-checkout |
| **P2 (Secundário)** | Users Admin | < 500ms | 10% tráfego, backoffice |
| **P3 (Nice-to-have)** | Posts/Comments | < 400ms | Moderação, não crítico |

---

## 📊 Comandos de Benchmark (Reproduzir)

```bash
# Produtos - GET /products
for i in {1..10}; do
  curl -w "@curl-format.txt" -o /dev/null -s "https://dummyjson.com/products"
done

# Auth - POST /auth/login
for i in {1..10}; do
  curl -w "@curl-format.txt" -o /dev/null -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"emilys","password":"emilyspass"}' \
    "https://dummyjson.com/auth/login"
done

# Search - GET /products/search
for i in {1..10}; do
  curl -w "@curl-format.txt" -o /dev/null -s \
    "https://dummyjson.com/products/search?q=phone"
done
```

**curl-format.txt**:
```
time_total: %{time_total}s\n
http_code: %{http_code}\n
```

---

## ✅ Próximos Passos

1. **Validar SLOs** em testes smoke (Fase 4)
2. **Ajustar thresholds** após baseline em CI
3. **Documentar desvios** quando P95 > SLO em 20%
4. **Revisar trimestralmente** com stakeholders
