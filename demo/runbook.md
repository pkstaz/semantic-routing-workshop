# Runbook — Demo Semantic Routing en OpenShift

Guía para presentar la demo en **15–20 minutos**.

## Modelos y rutas

| Ruta | Modelo | Endpoint MaaS |
|---|---|---|
| `general` | llama-32-3b | `.../prelude-maas/llama-32-3b` |
| `code` | qwen25-vl-7b-instruct-fp8 | `.../prelude-maas/qwen25-vl-7b-instruct-fp8` |
| `vision` | granite-vision-32-2b | `.../prelude-maas/granite-vision-32-2b` |

## Antes de la presentación (30 min)

### 1. Verificar modelos MaaS

```bash
export TOKEN="tu-token"
curl -s https://maas.apps.ocp.cloud.rhai-tmm.dev/prelude-maas/llama-32-3b/v1/models \
  -H "Authorization: Bearer $TOKEN"
curl -s https://maas.apps.ocp.cloud.rhai-tmm.dev/prelude-maas/qwen25-vl-7b-instruct-fp8/v1/models \
  -H "Authorization: Bearer $TOKEN"
curl -s https://maas.apps.ocp.cloud.rhai-tmm.dev/prelude-maas/granite-vision-32-2b/v1/models \
  -H "Authorization: Bearer $TOKEN"
```

### 2. Instalar la demo

```bash
cd demo
cp env.demo.example demo.env
# Pon tu token en demo.env → OPENSHIFT_AI_TOKEN=...
./install.sh
```

Anota las URLs que imprime el script:

- **Dashboard:** `https://semantic-router-dashboard-...`
- **API:** `https://semantic-router-api-...`

### 3. Configurar el dashboard

1. Abre la URL del dashboard
2. Crea cuenta de admin (primera visita)
3. Verifica en **Routing → Decisions**:
   - `code-route` → **qwen25-vl-7b-instruct-fp8**
   - `vision-route` → **granite-vision-32-2b**
   - `general-route` → **llama-32-3b**

### 4. Prueba rápida pre-demo

```bash
oc port-forward -n semantic-router-demo svc/semantic-router-demo 8080:8080 &

vllm-sr eval --prompt "Write a Python function to sort a list" \
  --endpoint http://localhost:8080

vllm-sr eval --prompt "What is the capital of France?" \
  --endpoint http://localhost:8080

vllm-sr eval --prompt "What is in this image?" \
  --endpoint http://localhost:8080
```

> **Nota:** En OpenShift, el puerto 8080 expone la API de clasificación/eval (`/api/v1/eval`), no chat completions directo. Para chat en vivo usa el dashboard o un proxy Envoy local.

**Esperado:**

| Query | Decision | Modelo |
|---|---|---|
| Python function... | `code-route` | qwen25-vl-7b-instruct-fp8 |
| Capital of France | `general-route` | llama-32-3b |
| What is in this image? | `vision-route` | granite-vision-32-2b |

---

## Guión de la demo (15 min)

### Min 0–2: Contexto

> "Tenemos tres modelos en MaaS, cada uno especializado.
> El semantic router elige automáticamente según el significado de la pregunta."

```
Usuario → Semantic Router → llama-32-3b      (general)
                         → qwen25-vl-7b      (código)
                         → granite-vision-32-2b (visión)
```

### Min 2–5: Dashboard — reglas

1. Abrir **dashboard**
2. Mostrar **domains**: `code`, `vision`, `general`
3. Mostrar **decisions** y prioridades: 10 → 20 → 100

### Min 5–12: Playground — routing en vivo

| # | Query | Resultado esperado |
|---|---|---|
| 1 | `What is the capital of France?` | `general-route` → llama-32-3b |
| 2 | `Write a Python function to calculate Fibonacci` | `code-route` → qwen25-vl-7b |
| 3 | `Generate a SQL query to select all users` | `code-route` → qwen25-vl-7b |
| 4 | `What is in this image?` (+ imagen) | `vision-route` → granite-vision-32-2b |
| 5 | `Describe the objects in this photo` (+ imagen) | `vision-route` → granite-vision-32-2b |

**Punto clave:** señalar señales (signals), dominio detectado y confianza.

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

> "Tres modelos, una interfaz. El operador ve cada decisión en el dashboard."

---

## Queries de respaldo

| Si falla... | Usa esta alternativa |
|---|---|
| Código ambiguo | `Debug this JavaScript: function add(a,b) { return a - b }` |
| General ambigua | `Explain photosynthesis in simple terms` |
| Visión sin imagen | Adjuntar cualquier imagen + `Describe this image` |
| Forzar código | `Write a bash script to backup files daily` |

---

## Si algo falla en vivo

| Problema | Acción rápida |
|---|---|
| Pod no ready | `oc get pods -n semantic-router-demo` |
| 401/403 de MaaS | Verificar `OPENSHIFT_AI_TOKEN` |
| 503 del modelo | Probar endpoint MaaS directo con curl |
| Routing incorrecto | `vllm-sr eval --prompt "..." --json` |
| Visión no enruta | Confirmar que la query menciona imagen/foto |
| SCC / pod forbidden | Re-ejecutar `./install.sh` — concede `anyuid` al dashboard |
| Router CrashLoop (HF) | Verificar `HF_TOKEN` empieza por `hf_`; reinstalar con `./install.sh` |
| Permission denied /app/models | Resuelto con `emptyDir` + `HF_HUB_DISABLE_XET=1` en values |
| Routing sin decisión | Dominios custom requieren `mmlu_categories`; visión usa keywords |

---

## Después de la demo

```bash
./uninstall.sh
./uninstall.sh --delete-namespace
```
