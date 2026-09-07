# Semantic Router Workshop

Workshop comunitario sobre **semantic routing** con [vLLM Semantic Router](https://github.com/vllm-project/vllm-semantic-router) (`vllm-sr`), Open WebUI y modelos remotos en OpenShift AI.

## Qué vas a construir

```
Open WebUI :3000  ──►  vllm-sr (Envoy :8899)  ──►  OpenShift AI
                              │
Dashboard :8700  ◄────────────┘
         (visualizar routing)
```

Tres modelos remotos, una sola interfaz de chat:

| Ruta | Modelo | Uso |
|---|---|---|
| `general` | llama-32-3b | Conversación y conocimiento general |
| `code` | qwen35-9b | Código y debugging |
| `vision` | granite-vision-32-2b | Imágenes y análisis visual |

## Requisitos

- macOS Apple Silicon (arm64) o Linux arm64/amd64
- Python 3.12
- Podman + podman-compose
- Token y endpoints de OpenShift AI

## Empezar

### Guía publicada (GitHub Pages)

Versión web del taller, con layout tipo DevOpsDays Santiago: **[pkstaz.github.io/semantic-routing-workshop](https://pkstaz.github.io/semantic-routing-workshop/)**

En el repo: **Settings → Pages → Deploy from a branch** → rama `devopsdays`, carpeta `/docs` → Save.

Si el repo es privado, hazlo público (GitHub Free no publica Pages en repos privados). No uses *GitHub Actions* como source: el entorno `github-pages` suele bloquear ramas que no son `master`.

### Workshop local (Podman)

Sigue las guías en orden: **[workshop/README.md](./workshop/README.md)**

### Demo OpenShift (presentación)

Demo rápida con 3 rutas (llama + qwen + granite-vision) en MaaS: **[demo/README.md](./demo/README.md)**

## Estructura del repo

```
semantic-router-workshop/
├── workshop/           # Guías del taller local (léelas en orden)
├── demo/               # Demo OpenShift (install.sh + runbook)
├── config/
│   └── config.example.yaml
├── podman-compose.yml
├── .env.example
└── README.md
```
