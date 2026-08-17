# 5. Configuración

## 1. Variables de entorno

Copia el archivo de ejemplo y edítalo con tus credenciales de OpenShift AI:

```bash
cp .env.example .env
```

Edita `.env`:

```env
LLAMA_ENDPOINT=https://tu-host-openshift-ai/llama-32-3b
QWEN_CODE_ENDPOINT=https://tu-host-openshift-ai/qwen35-9b
GRANITE_VISION_ENDPOINT=https://tu-host-openshift-ai/granite-vision-32-2b
OPENSHIFT_AI_TOKEN=tu-token-aqui
```

> Los endpoints son la URL base del modelo **sin** `/v1` al final.

Exporta el token para que `vllm-sr` lo use al conectar con los backends:

```bash
export OPENSHIFT_AI_TOKEN=$(grep OPENSHIFT_AI_TOKEN .env | cut -d= -f2-)
```

## 2. Configurar el routing

Tienes dos opciones. Para el workshop recomendamos la **Opción A** (dashboard).

### Opción A — Dashboard (recomendado)

La primera vez que ejecutes `vllm-sr serve` sin `config.yaml`, el dashboard abre en **modo setup**. Desde ahí:

1. **Providers** — agrega los 3 modelos con sus endpoints de OpenShift AI:
   - `llama-32-3b` → `LLAMA_ENDPOINT`
   - `qwen35-9b` → `QWEN_CODE_ENDPOINT`
   - `granite-vision-32-2b` → `GRANITE_VISION_ENDPOINT`
   - Auth: `Authorization: Bearer` con tu `OPENSHIFT_AI_TOKEN`

2. **Signals → Domains** — crea tres dominios:
   - `code` — programación, debugging, SQL, scripts
   - `vision` — imágenes, fotos, análisis visual
   - `general` — conversación y conocimiento general

3. **Decisions** — crea tres reglas (prioridad: code=10, vision=20, general=100):

   | Decision | Condición | Modelo |
   |---|---|---|
   | `code-route` | domain = `code` | `qwen35-9b` |
   | `vision-route` | domain = `vision` | `granite-vision-32-2b` |
   | `general-route` | domain = `general` | `llama-32-3b` |

4. **Activate** — activa la configuración desde el dashboard.

### Opción B — Archivo YAML

Si prefieres configurar por archivo:

```bash
cp config/config.example.yaml config.yaml
```

Edita `config.yaml` reemplazando los endpoints con los valores de tu `.env`.

Valida antes de usar:

```bash
vllm-sr validate --config config.yaml
```

Luego arranca con:

```bash
vllm-sr serve --config config.yaml
```

> Referencia completa del YAML: [`config/config.example.yaml`](../config/config.example.yaml)

## 3. Verificar la configuración

```bash
vllm-sr validate --config config.yaml   # si usas YAML
vllm-sr model                             # lista modelos configurados
```

## Siguiente paso

[Levantar los servicios →](./06-levantar-servicios.md)
