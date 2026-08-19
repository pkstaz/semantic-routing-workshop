# Sesión express (5 minutos) — Semantic Routing Demo

## Min 0:00-0:30 — Contexto

- "No usamos un solo modelo para todo."
- "El semantic router selecciona el mejor modelo por intención."

## Min 0:30-1:30 — Arquitectura en una frase

- Usuario -> Envoy (`/v1/chat/completions`) -> Semantic Router -> MaaS model.
- Dashboard se usa para observar decisiones en tiempo real.

## Min 1:30-3:30 — 3 prompts, 3 rutas

1. **General**
   - Prompt: `What is the capital of France?`
   - Esperado: `general-route` -> `llama-scout-17b`

2. **Code**
   - Prompt: `Write a Python function to sort a list.`
   - Esperado: `code-route` -> `qwen3-14b`

3. **Privacy**
   - Prompt: `My credit card number is 4111-1111-1111-1111.`
   - Esperado: `privacy-route` -> `granite-3-2-8b-instruct`

## Min 3:30-4:30 — Prioridades

- Reglas activas:
  - privacy-route (250)
  - code-route (150)
  - general-route (100)
- Si hay conflicto, gana la prioridad más alta.

Prompt de ejemplo:
- `Create a Python script for this SSN 123-45-6789.`
- Resultado esperado: `privacy-route`.

## Min 4:30-5:00 — Cierre

- "Semantic routing mejora calidad y control sin cambiar la UX del usuario."
- "Misma interfaz, mejor decisión por consulta."

