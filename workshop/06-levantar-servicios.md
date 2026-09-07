# 6. Levantar Open WebUI

`vllm-sr` ya debería estar corriendo del [paso 5](./05-configuracion.md). Si lo cerraste, vuelve a arrancarlo (con el `config.yaml` que ya creaste):

```bash
source .venv/bin/activate
vllm-sr serve
```

Verifica:

```bash
vllm-sr status
```

Dashboard: [http://localhost:8700](http://localhost:8700)

| Puerto | Servicio |
|---|---|
| **8899** | API de chat (Open WebUI apunta aquí) |
| **8080** | API interna del router (`vllm-sr eval`) |
| **8700** | Dashboard web |

## 1. Open WebUI

En **otra terminal**, desde la raíz del repositorio:

```bash
podman-compose up -d
```

Abre: [http://localhost:3000](http://localhost:3000)

La primera vez crea una cuenta local (solo para este entorno).

`podman-compose.yml` ya apunta al router:

```yaml
OPENAI_API_BASE_URL=http://host.containers.internal:8899/v1
```

No eliges modelo en Open WebUI — el router lo hace por ti.

## 2. Probar rápido

```bash
vllm-sr eval --prompt "Write a Python function to sort a list"
vllm-sr chat "What is the capital of France?"
```

## 3. Detener (cuando termines el taller)

```bash
podman-compose down
vllm-sr stop
```

## Siguiente paso

[Ejercicios prácticos →](./07-ejercicios.md)
