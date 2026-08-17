# Demo OpenShift — Semantic Routing

Demo para mostrar **3 rutas** de semantic routing con modelos en MaaS y dashboard integrado.

## ¿Qué muestra?

| Ruta | Modelo | Uso |
|---|---|---|
| `general` | `llama-32-3b` | Conversación y conocimiento general |
| `code` | `qwen25-vl-7b-instruct-fp8` | Código, debugging, SQL |
| `vision` | `granite-vision-32-2b` | Imágenes y análisis visual |

El **dashboard** de vllm-sr muestra en tiempo real a qué modelo fue cada query.

## Endpoints MaaS (preconfigurados)

```
https://maas.apps.ocp.cloud.rhai-tmm.dev/prelude-maas/llama-32-3b
https://maas.apps.ocp.cloud.rhai-tmm.dev/prelude-maas/qwen25-vl-7b-instruct-fp8
https://maas.apps.ocp.cloud.rhai-tmm.dev/prelude-maas/granite-vision-32-2b
```

## Instalación rápida

```bash
cd demo
cp env.demo.example demo.env
# Pon tu token en demo.env → OPENSHIFT_AI_TOKEN=...
./install.sh
```

Requisitos: `oc`, `helm`, sesión activa en OpenShift.

## Archivos

| Archivo | Descripción |
|---|---|
| `install.sh` | Instala router + dashboard + routes |
| `uninstall.sh` | Elimina la demo |
| `runbook.md` | Guión de presentación (15 min) |
| `config.demo.yaml.template` | Routing llama + qwen + granite-vision |
| `helm/values-demo.yaml` | Overrides (dashboard on, sin observability) |

## URLs después de instalar

| Servicio | Route |
|---|---|
| Dashboard | `semantic-router-dashboard` → puerto 8700 |
| API chat | `semantic-router-api` → puerto 8080 |

## Siguiente paso

Lee el **[runbook.md](./runbook.md)** para el guión de la demo.
