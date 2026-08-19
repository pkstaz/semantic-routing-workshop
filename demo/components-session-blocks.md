# Mini bloques de explicación (guion de sesión)

Este documento está pensado para exponer la demo en bloques cortos de 1-3 minutos.

## Bloque 0 — Contexto rápido (1 min)

- **Objetivo:** explicar qué problema resolvemos.
- **Mensaje clave:** "No todos los prompts deben ir al mismo modelo; el router elige el mejor."
- **Frase sugerida:**  
  "En vez de un único LLM, usamos semantic routing para enviar cada consulta al modelo más adecuado."

---

## Bloque 1 — Dashboard (2 min)

- **Qué explicar:** interfaz de operación y pruebas.
- **Qué mostrar en pantalla:**
  - Playground.
  - Sección de decisions/signals.
- **Mensaje clave:** "Aquí vemos y gobernamos el routing, no solo el texto de respuesta."
- **Demo rápida:** enviar un prompt general y mostrar el modelo seleccionado.

---

## Bloque 2 — Envoy (2 min)

- **Qué explicar:** gateway de chat y punto de entrada.
- **Mensaje clave:** "Todo chat entra por Envoy; Envoy conecta cliente con el pipeline del router."
- **Punto técnico simple:** endpoint de chat = `/v1/chat/completions` en route `semantic-router-chat`.
- **Demo rápida:** mencionar que Playground usa esta ruta de chat.

---

## Bloque 3 — API de evaluación (2 min)

- **Qué explicar:** endpoint para validar decisiones sin ejecutar chat completo.
- **Mensaje clave:** "Eval API sirve para observar routing de forma controlada."
- **Endpoint:** `/api/v1/eval` (route `semantic-router-api`).
- **Demo rápida:** enviar texto de ejemplo y leer `routing_decision`.

---

## Bloque 4 — Models (2 min)

- **Qué explicar:** por qué hay varios modelos.
- **Mensaje clave:** "Cada modelo tiene fortalezas distintas."
- **Mapping de la demo:**
  - `llama-scout-17b` -> general
  - `qwen3-14b` -> code
  - `granite-3-2-8b-instruct` -> privacy/PII
- **Demo rápida:** repetir 3 prompts y comparar modelo final.

---

## Bloque 5 — Signals (2 min)

- **Qué explicar:** señales semánticas que detecta el router.
- **Mensaje clave:** "Las señales son la base de la decisión."
- **Tipos en demo:**
  - `domains` (`general`, `code`)
  - `keywords` (`sensitive_data`)
- **Demo rápida:** prompt con "credit card" para activar señal sensible.

---

## Bloque 6 — Decisions (3 min)

- **Qué explicar:** reglas que convierten señales en elección de modelo.
- **Mensaje clave:** "La prioridad decide empates."
- **Decisiones activas:**
  - `privacy-route` (250)
  - `code-route` (150)
  - `general-route` (100)
- **Demo rápida:** prompt ambiguo (código + dato sensible) para mostrar que gana `privacy-route`.

---

## Bloque 7 — Providers y autenticación (2 min)

- **Qué explicar:** cómo llega la llamada al MaaS.
- **Mensaje clave:** "El router separa reglas de negocio (routing) de conectividad (providers)."
- **Config relevante:**
  - `base_url`
  - `provider: openai`
  - `api_key_env: OPENSHIFT_AI_TOKEN`
- **Demo rápida:** mostrar que mismo `base_url`, distinto `model`.

---

## Bloque 8 — OpenShift components (2 min)

- **Qué explicar:** piezas de despliegue.
- **Mensaje clave:** "Cada route expone una responsabilidad diferente."
- **Resumen:**
  - `semantic-router-dashboard` -> UI
  - `semantic-router-chat` -> chat por Envoy
  - `semantic-router-api` -> eval
- **Demo rápida:** abrir las 3 URLs y aclarar propósito.

---

## Bloque 9 — Cierre (1 min)

- **Mensaje final sugerido:**  
  "Con semantic routing, mejoramos calidad y control operacional sin cambiar la experiencia del usuario."
- **Takeaway técnico:** routing semántico + reglas explícitas + observabilidad en dashboard.

---

## Prompts sugeridos por bloque

- **General:** "What is the capital of France?"
- **Code:** "Write a Python function to sort a list."
- **Privacy:** "My credit card number is 4111-1111-1111-1111."
- **Ambiguo:** "Create a Python script to process this SSN 123-45-6789."

---

## Plan de tiempo sugerido (15-20 min)

- Bloques 0-2: 5 min
- Bloques 3-6: 8-10 min
- Bloques 7-9: 3-5 min

