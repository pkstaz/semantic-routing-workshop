# 6. Levantar los servicios

## 1. Semantic router (API + dashboard)

Desde la raíz del repositorio, con el entorno virtual activo:

```bash
source .venv/bin/activate
export OPENSHIFT_AI_TOKEN=$(grep OPENSHIFT_AI_TOKEN .env | cut -d= -f2-)
vllm-sr serve
```

Si usas un archivo de configuración:

```bash
vllm-sr serve --config config.yaml
```

La primera ejecución descarga imágenes de contenedor — puede tardar varios minutos.

### Puertos disponibles

| Puerto | Servicio |
|---|---|
| **8899** | API de chat (Open WebUI apunta aquí) |
| **8080** | API interna del router (`vllm-sr eval`) |
| **8700** | Dashboard web |

Verifica que esté corriendo:

```bash
vllm-sr status
```

Abre el dashboard: [http://localhost:8700](http://localhost:8700)

> Anota los puertos que muestra `vllm-sr serve` al arrancar. Si cambiaste el listener en `config.yaml`, actualiza `CHAT_API_PORT` en tu `.env`.

## 2. Open WebUI

En **otra terminal**, desde la raíz del repositorio:

```bash
cp .env.example .env   # si aún no lo tienes
podman-compose up -d
```

Abre Open WebUI: [http://localhost:3000](http://localhost:3000)

La primera vez te pedirá crear una cuenta local (solo para este entorno de demo).

### Conectar Open WebUI al router

`podman-compose.yml` ya configura:

```yaml
OPENAI_API_BASE_URL=http://host.containers.internal:8899/v1
```

No necesitas configurar modelos manualmente en Open WebUI — el router elige el modelo por ti.

## 3. Verificar end-to-end

```bash
# Desde el CLI — prueba routing sin UI
vllm-sr eval --prompt "Write a Python function to sort a list"
vllm-sr chat "What is the capital of France?"
```

## 4. Detener

```bash
podman-compose down
vllm-sr stop
```

## Siguiente paso

[Ejercicios prácticos →](./07-ejercicios.md)
