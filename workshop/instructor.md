# Guía del instructor

Notas para facilitar el workshop de semantic routing.

## Agenda sugerida (90 min)

| Tiempo | Actividad | Material |
|---|---|---|
| 0–5 min | Introducción y objetivos | [00-introduccion](./00-introduccion.md) |
| 5–25 min | Setup: Python, Docker, vllm-sr | [01](./01-python.md) – [03](./03-vllm-sr.md) |
| 25–35 min | Arquitectura y demo del diagrama | [04-arquitectura](./04-arquitectura-y-flujo.md) |
| 35–55 min | Setup dashboard: modelos y rutas | [05-configuracion](./05-configuracion.md) |
| 55–65 min | Open WebUI y prueba rápida | [06-levantar](./06-levantar-servicios.md) |
| 65–90 min | Ejercicios prácticos | [07-ejercicios](./07-ejercicios.md) |

## Antes del workshop

- [ ] Tener token y las 3 URLs (llama / code / vision) listas para dictar — los participantes las pegan en el setup
- [ ] Probar el flujo completo: `vllm-sr serve` → setup dashboard → `docker compose up`
- [ ] Verificar que los 3 modelos remotos responden
- [ ] Tener el dashboard abierto en una pantalla compartida para la demo en vivo

## Puntos clave para explicar

### ¿Por qué dos interfaces?

- **Dashboard (8700):** transparencia — el participante *ve* el routing
- **Open WebUI (3000):** experiencia real — el usuario *no ve* el routing

### ¿Por qué tres modelos?

Un solo modelo no es óptimo para todo. El router envía cada query al modelo más adecuado según su **significado**, no por palabras clave exactas.

### Puertos (confusión frecuente)

| Puerto | Qué es |
|---|---|
| 8899 | API de chat (Open WebUI, `vllm-sr chat`) |
| 8080 | API interna (`vllm-sr eval`) |
| 8700 | Dashboard |

### Prioridades de decisions

Menor número = mayor prioridad. `code-route` (10) gana sobre `general-route` (50). `default-route` (P100) es el catch-all: no lo borres.

### ¿Qué es MMLU? (en Signals tipo Domain)

Hay que elegir **MMLU categories**. MMLU es un examen de cultura académica; el clasificador del router etiqueta el prompt con esas materias. `code` → `computer science`, `general` → `other`. Visión no es una materia MMLU (es imagen): si hay signal **Modality**, usarlo para `vision-route`.

## Demo en vivo sugerida

1. **Dashboard abierto** en pantalla compartida (sección de decisions)
2. Pide a un participante que envíe una query de código en Open WebUI
3. Muestra en el dashboard la decisión que se tomó en tiempo real
4. Repite con una query general y una de visión (si hay imagen disponible)

## Queries de demo

| Query | Ruta esperada | Modelo |
|---|---|---|
| `Write a Python function to sort a list` | code | qwen35-9b |
| `What is the capital of France?` | general | llama-32-3b |
| `Generate a SQL query to select all users` | code | qwen35-9b |
| `Tell me a story about a robot` | general | llama-32-3b |
| `What is in this image?` (+ imagen) | vision | granite-vision-32-2b |

## Problemas comunes en vivo

| Problema | Solución rápida |
|---|---|
| Primera ejecución lenta | Avisar que descarga imágenes; mostrar arquitectura mientras espera |
| `mounts denied` en macOS | File Sharing en Docker Desktop: bin de Docker + `$HOME/.vllm-sr` ([troubleshooting](./09-troubleshooting.md)) |
| Token expirado | Tener un token de respaldo |
| Routing incorrecto | Usar `vllm-sr eval --json` para mostrar señales |
| Open WebUI sin respuesta | Verificar puerto 8899 con `curl localhost:8899/v1/models` |
| Dashboard: *Bootstrap is complete* | `config.yaml` sin `setup.mode: true` / `version: "v0.3"` ([troubleshooting](./09-troubleshooting.md)) |
| Dashboard Degraded tras Activate | `docker start vllm-sr-router-container vllm-sr-envoy-container` |

## Preguntas frecuentes de participantes

**¿Puedo usar Podman en vez de Docker?**
No en este taller. `vllm-sr serve` necesita Docker.

**¿El router corre en GPU?**
No. La clasificación semántica corre en CPU local. Los modelos LLM están en OpenShift AI remoto.

**¿Puedo agregar más modelos/rutas?**
Sí, desde el dashboard.

**¿Qué pasa si ninguna regla coincide?**
Se usa el `default_model` configurado en providers (`llama-32-3b`).

## Recursos adicionales

- [vLLM Semantic Router](https://github.com/vllm-project/vllm-semantic-router)
- [Open WebUI](https://github.com/open-webui/open-webui)
