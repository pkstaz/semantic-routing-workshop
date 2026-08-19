# Speaker Notes (ES) — sesión de demo

Guion literal para presentar la demo de semantic routing.

## Bloque 0 — Apertura (30-45s)

"Hoy no vamos a usar un solo modelo para todo.  
Vamos a usar un semantic router que decide automáticamente qué modelo usar según la intención del prompt."

"La idea central es simple: mejor calidad y mejor control operacional, sin cambiar la experiencia del usuario."

## Bloque 1 — Dashboard (1-2 min)

"Este es el Dashboard. Aquí podemos probar prompts, ver decisiones y entender por qué una consulta fue a cierto modelo."

"No solo vemos la respuesta final: también vemos trazabilidad del routing."

Acción:
- Abrir Playground.
- Enviar: `What is the capital of France?`

## Bloque 2 — Envoy + Chat path (1 min)

"El chat entra por Envoy, que expone `/v1/chat/completions`."

"Envoy conecta la petición con el pipeline del router.  
Por eso el endpoint de chat real para la demo es la route de chat, no la de eval."

## Bloque 3 — Signals y Decisions (2-3 min)

"El router usa señales: domains y keywords."

"Luego aplica decisiones con prioridad:
- privacy-route (250)
- code-route (150)
- general-route (100)"

"Si una consulta mezcla categorías, gana la de mayor prioridad."

## Bloque 4 — Model mapping (2 min)

"En esta demo:
- general -> llama-scout-17b
- code -> qwen3-14b
- privacy -> granite-3-2-8b-instruct"

"Cada modelo está optimizado para un tipo de consulta distinto."

## Bloque 5 — Demo de 3 prompts (4-5 min)

1) General  
`What is the capital of France?`  
"Esperamos general-route y modelo llama-scout-17b."

2) Code  
`Write a Python function to sort a list.`  
"Esperamos code-route y modelo qwen3-14b."

3) Privacy  
`My credit card number is 4111-1111-1111-1111.`  
"Esperamos privacy-route y modelo granite-3-2-8b-instruct."

## Bloque 6 — Caso ambiguo (1-2 min)

`Create a Python script to process this SSN 123-45-6789.`

"Aunque parece código, contiene dato sensible.  
Por prioridad, debe ganar privacy-route."

## Bloque 7 — Cierre (30-45s)

"El valor del semantic routing es combinar calidad, gobernanza y observabilidad."

"No cambiamos cómo el usuario pregunta; cambiamos cómo el sistema decide."

"Ese es el salto: de un LLM único a una estrategia de enrutamiento inteligente."

