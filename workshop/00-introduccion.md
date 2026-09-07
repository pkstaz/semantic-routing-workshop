# 0. Introducción

## Objetivo

En este workshop vas a montar un **semantic router** que clasifica cada consulta del usuario y la envía al modelo más adecuado en OpenShift AI — sin que el usuario tenga que elegir modelo manualmente.

## Qué aprenderás

- Cómo funciona el routing semántico con `vllm-sr`
- Cómo configurar reglas que dirigen consultas a distintos modelos
- Cómo visualizar las decisiones de routing en tiempo real
- Cómo integrar el router con Open WebUI para una experiencia de chat transparente

## Stack del workshop

| Componente | Puerto | Rol |
|---|---|---|
| **vllm-sr** (Envoy) | 8899 | API de chat OpenAI-compatible |
| **vllm-sr** (router) | 8080 | API interna (eval, debugging) |
| **vllm-sr** (dashboard) | 8700 | Visualización y playground |
| **Open WebUI** | 3000 | Chat para el usuario final |

## Modelos remotos (OpenShift AI)

| Modelo | Ruta | Uso |
|---|---|---|
| `llama-32-3b` | general | Conversación, conocimiento general |
| `qwen35-9b` | code | Código, debugging, SQL |
| `granite-vision-32-2b` | vision | Imágenes y análisis visual |

## Flujo del taller

1. Arrancas `vllm-sr` y configuras endpoints y rutas en el setup del dashboard.
2. Exploras las reglas de routing en el **dashboard**.
3. Pruebas queries en el **playground** y ves qué modelo se eligió.
4. Chateas en **Open WebUI** como usuario final.
5. El instructor muestra en el dashboard las decisiones tomadas en segundo plano.

## Siguiente paso

[Requisitos de Python →](./01-python.md)
