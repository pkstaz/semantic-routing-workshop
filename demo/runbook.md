# Runbook — Demo Semantic Routing en OpenShift

Guía para presentar la demo en **15–20 minutos**.

## Modelos y rutas

| Ruta | Modelo | Uso |
|---|---|---|
| `general` | llama-scout-17b | Conversación y conocimiento general |
| `code` | qwen3-14b | Código, debugging, SQL |
| `privacy` | granite-3-2-8b-instruct | Datos personales, PII e información sensible |

Gateway MaaS: `https://maas-rhdp.apps.maas.redhatworkshops.io`

## Antes de la presentación (30 min)

### 1. Verificar modelos MaaS

```bash
export TOKEN="tu-token-del-workshop"
curl -s https://maas-rhdp.apps.maas.redhatworkshops.io/v1/models \
  -H "Authorization: Bearer $TOKEN" | jq '.data[].id'
```

Debes ver entre otros: `llama-scout-17b`, `qwen3-14b`, `granite-3-2-8b-instruct`.

### 2. Instalar la demo

```bash
cd demo
cp env.demo.example demo.env
# Pon tu token del workshop en demo.env → OPENSHIFT_AI_TOKEN=...
./install.sh
```

Anota las URLs que imprime el script:

- **Dashboard:** `https://semantic-router-dashboard-...`
- **API:** `https://semantic-router-api-...`

### 3. Configurar el dashboard

1. Abre la URL del dashboard
2. Crea cuenta de admin (primera visita)
3. Verifica en **Routing → Decisions**:
   - `privacy-route` → **granite-3-2-8b-instruct**
   - `code-route` → **qwen3-14b**
   - `general-route` → **llama-scout-17b**

### 4. Prueba rápida pre-demo

```bash
oc port-forward -n semantic-router-demo svc/semantic-router-demo 8080:8080 &

curl -s -X POST https://semantic-router-api-semantic-router-demo.apps.ocp.jmjdh.sandbox2571.opentlc.com/api/v1/eval \
  -H "Content-Type: application/json" \
  -d '{"text":"Write a Python function to sort a list"}' | jq '.routing_decision, .recommended_models'
```

> **Nota:** En OpenShift, el puerto 8080 expone la API de clasificación/eval (`/api/v1/eval`), no chat completions directo. Para chat en vivo usa el dashboard o un proxy Envoy local.

**Esperado:**

| Query | Decision | Modelo |
|---|---|---|
| Python function... | `code-route` | qwen3-14b |
| Capital of France | `general-route` | llama-scout-17b |
| My SSN is... personal information | `privacy-route` | granite-3-2-8b-instruct |

---

## Guión de la demo (15 min)

### Min 0–2: Contexto

> "Tenemos tres modelos en MaaS, cada uno especializado.
> El semantic router elige automáticamente según el significado de la pregunta."

```
Usuario → Semantic Router → llama-scout-17b           (general)
                         → qwen3-14b                  (código)
                         → granite-3-2-8b-instruct    (datos sensibles)
```

### Min 2–5: Dashboard — reglas

1. Abrir **dashboard**
2. Mostrar **domains**: `code`, `general` y **keywords**: `sensitive_data`
3. Mostrar **decisions** y prioridades: privacy (250) → code (150) → general (100)

### Min 5–12: Playground — routing en vivo

| # | Query | Resultado esperado |
|---|---|---|
| 1 | `What is the capital of France?` | `general-route` → llama-scout-17b |
| 2 | `Write a Python function to calculate Fibonacci` | `code-route` → qwen3-14b |
| 3 | `Generate a SQL query to select all users` | `code-route` → qwen3-14b |
| 4 | `My credit card number is 4111-1111-1111-1111` | `privacy-route` → granite-3-2-8b-instruct |
| 5 | `Summarize this employee's salary and home address` | `privacy-route` → granite-3-2-8b-instruct |

**Punto clave:** señalar señales (signals), dominio detectado y confianza. La ruta de privacidad tiene prioridad más alta que código y general.

### Min 12–14: API — chat real

```bash
curl -s https://<ROUTE_API>/v1/chat/completions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "auto",
    "messages": [{"role": "user", "content": "How do I sort a list in Python?"}]
  }' | jq '.model, .choices[0].message.content[:200]'
```

### Min 14–15: Cierre

> "Tres modelos, una interfaz. El operador ve cada decisión en el dashboard.
> Las consultas con datos personales se enrutan a Granite de forma automática."

---

## Queries de respaldo

| Si falla... | Usa esta alternativa |
|---|---|
| Código ambiguo | `Debug this JavaScript: function add(a,b) { return a - b }` |
| General ambigua | `Explain photosynthesis in simple terms` |
| Privacidad sin enrutar | `Process this personal information: John Doe, SSN 123-45-6789` |
| Forzar código | `Write a bash script to backup files daily` |

---

## Si algo falla en vivo

| Problema | Acción rápida |
|---|---|
| Pod no ready | `oc get pods -n semantic-router-demo` |
| 401/403 de MaaS | Verificar `OPENSHIFT_AI_TOKEN` (token del workshop, no del cluster viejo) |
| 503 del modelo | Probar endpoint MaaS directo con curl |
| Routing incorrecto | `vllm-sr eval --prompt "..." --json` |
| 400 tool_choice auto en código | CodeLlama no soporta `tool_choice: auto` del dashboard; la ruta code usa `qwen3-14b`. Tools global desactivado en config. |
| Privacidad no enruta | Confirmar que la query menciona PII (SSN, credit card, personal information, etc.) |
| SCC / pod forbidden | Re-ejecutar `./install.sh` — concede `anyuid` al dashboard |
| Router CrashLoop (HF) | Verificar `HF_TOKEN` empieza por `hf_`; reinstalar con `./install.sh` |
| Permission denied /app/models | Resuelto con `emptyDir` + `HF_HUB_DISABLE_XET=1` en values |
| 404 page not found en playground | El chart no incluye Envoy; el chat va por `:8899`, no por el apiserver `:8080`. Re-ejecuta `./install.sh` (despliega Envoy y reconfigura el dashboard) |
| 502 Bad Gateway / connection refused :8080 | La Route apuntaba al Service del chart que incluía el pod del dashboard. `./install.sh` crea `${HELM_RELEASE}-api` solo para el router |

---

## Después de la demo

```bash
./uninstall.sh
./uninstall.sh --delete-namespace
```
