# 7. Ejercicios prácticos

Con los servicios corriendo, sigue estos ejercicios en orden.

## Ejercicio 1 — Explorar el dashboard

1. Abre [http://localhost:8700](http://localhost:8700)
2. Navega a la sección de **routing rules** / **decisions**
3. Identifica las tres rutas: `code`, `vision`, `general`
4. Revisa qué modelo está asignado a cada una

**Pregunta:** ¿Qué pasa si dos reglas coinciden? (Pista: mira el campo `priority`)

## Ejercicio 2 — Playground: routing de código

En el **playground** del dashboard, envía:

```
Write a Python function to calculate the Fibonacci sequence.
```

**Observa:**
- Qué decisión (`decision`) se activó
- Qué modelo se eligió
- Qué señales (`signals`) contribuyeron

**Resultado esperado:** decisión `code-route` → modelo `qwen35-9b`

## Ejercicio 3 — Playground: consulta general

```
What is the capital of France?
```

**Resultado esperado:** decisión `general-route` → modelo `llama-32-3b`

## Ejercicio 4 — Playground: consulta de visión

Si tu setup soporta imágenes en el playground, adjunta una imagen y pregunta:

```
What is in this image?
```

**Resultado esperado:** decisión `vision-route` → modelo `granite-vision-32-2b`

## Ejercicio 5 — CLI: eval sin UI

Desde la terminal:

```bash
vllm-sr eval --prompt "Generate a SQL query to select all users from a table"
```

Compara el output con lo que viste en el playground.

Prueba con JSON completo:

```bash
vllm-sr eval --prompt "Hello, how are you?" --json
```

## Ejercicio 6 — Open WebUI: experiencia de usuario

1. Abre [http://localhost:3000](http://localhost:3000)
2. Inicia sesión (cuenta local)
3. Envía estas tres consultas **sin elegir modelo**:

| Query | Modelo esperado |
|---|---|
| `How do I sort a list in Python?` | qwen35-9b |
| `Tell me a short story about a robot` | llama-32-3b |
| `Explain photosynthesis in simple terms` | llama-32-3b |

4. Mientras chateas, el instructor muestra en el dashboard las decisiones tomadas.

## Ejercicio 7 — Comparar las dos interfaces

Envía la misma query en el **playground** y en **Open WebUI**:

```
Can you help me debug my JavaScript code?
```

| Interfaz | ¿Ves el routing? | ¿Ves la respuesta del modelo? |
|---|---|---|
| Dashboard playground | Sí | Sí |
| Open WebUI | No | Sí |

**Conclusión:** el routing es transparente para el usuario final.

## Ejercicio 8 (opcional) — Modificar una regla

1. En el dashboard, edita la descripción del dominio `code` para incluir "kubernetes"
2. Activa la configuración
3. Prueba: `How do I deploy a pod in Kubernetes?`
4. Verifica que sigue yendo a `qwen35-9b`

## Siguiente paso

[Comandos CLI útiles →](./08-comandos-cli.md)
