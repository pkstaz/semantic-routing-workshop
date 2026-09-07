# 4. Arquitectura y flujo del workshop

## Interfaces

Usaremos **dos interfaces** complementarias:

| Interfaz | Puerto | Para qué |
|---|---|---|
| **Dashboard vllm-sr** | 8700 | Explicar y visualizar el routing |
| **Open WebUI** | 3000 | Experiencia final de chat para el usuario |

### Puertos de vllm-sr

| Puerto | Componente | Uso |
|---|---|---|
| **8899** | Envoy | API de chat — Open WebUI apunta aquí |
| **8080** | Router | API interna — `vllm-sr eval`, debugging |
| **8700** | Dashboard | UI web con playground y métricas |

### Dashboard vllm-sr (puerto 8700)

`vllm-sr` incluye un dashboard web con:

- **Playground de chat** — probar el routing sin Open WebUI
- **Reglas de routing** — visualización en tiempo real
- **Métricas** — qué modelo se eligió para cada query
- **Editor visual** del `config.yaml`

### Open WebUI (puerto 3000)

Chat orientado al usuario final. Apunta al semantic router en el puerto **8899** (API OpenAI-compatible vía Envoy). El usuario no ve el router; solo conversa.

## Flujo del workshop

1. El participante abre el **dashboard** (`http://localhost:8700`) y revisa las reglas definidas.
2. Escribe una query en el **playground** del dashboard y ve en tiempo real qué modelo fue elegido y por qué.
3. Abre **Open WebUI** (`http://localhost:3000`) y chatea con normalidad, sin ver el router.
4. El instructor muestra en el dashboard las decisiones de routing que se tomaron en segundo plano.

## Cómo se levanta cada pieza

| Componente | Comando |
|---|---|
| vllm-sr (router + envoy + dashboard) | `vllm-sr serve` |
| Open WebUI | `docker compose up -d` |

## Diagrama

```
Participante                    Instructor
     │                               │
     ▼                               ▼
Open WebUI :3000              Dashboard :8700
     │                               │
     └──────────► Envoy :8899 ◄──────┘
                      │
                      ▼
              vLLM Semantic Router
                      │
                      ▼
            Modelos en OpenShift AI
         (llama / qwen / granite-vision)
```

## Siguiente paso

[Configuración →](./05-configuracion.md)
