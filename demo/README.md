# Demo OpenShift — Semantic Routing

Demo para mostrar **3 rutas** de semantic routing con modelos en MaaS y dashboard integrado.

## ¿Qué muestra?

| Ruta | Modelo | Uso |
|---|---|---|
| `general` | `llama-scout-17b` | Conversación y conocimiento general |
| `code` | `qwen3-14b` | Código, debugging, SQL |
| `privacy` | `granite-3-2-8b-instruct` | Datos personales, PII e información sensible |

El **dashboard** de vllm-sr muestra en tiempo real a qué modelo fue cada query.

## Endpoint MaaS (preconfigurado)

```
https://maas-rhdp.apps.maas.redhatworkshops.io
```

Los tres modelos comparten el mismo gateway; el router elige el `model` en cada petición.

## Instalación rápida

```bash
cd demo
cp env.demo.example demo.env
# Pon tu token del workshop en demo.env → OPENSHIFT_AI_TOKEN=...
# Y también HF_TOKEN=... (HuggingFace, para modelos de clasificación del router)
./install.sh
```

Requisitos: `oc`, `helm`, sesión activa en OpenShift.

## Archivos

| Archivo | Descripción |
|---|---|
| `install.sh` | Instala router + dashboard + routes |
| `uninstall.sh` | Elimina la demo |
| `runbook.md` | Guión de presentación (15 min) |
| `config.demo.yaml.template` | Routing llama-scout + qwen3 + granite (privacidad) |
| `helm/values-demo.yaml` | Overrides (dashboard on, sin observability) |

## URLs después de instalar

| Servicio | Route |
|---|---|
| Dashboard | `semantic-router-dashboard` → puerto 8700 |
| API chat | `semantic-router-api` → puerto 8080 |

## Siguiente paso

Lee el **[runbook.md](./runbook.md)** para el guión de la demo.
