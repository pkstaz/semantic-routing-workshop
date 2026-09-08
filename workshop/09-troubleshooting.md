# 9. Troubleshooting

## `vllm-sr serve` falla al arrancar

**Síntoma:** error al descargar imágenes o iniciar contenedores.

```bash
# Verificar que Docker está corriendo
docker info

# Ver logs detallados
vllm-sr serve --log-level debug

# Ver logs de un servicio específico
vllm-sr logs router
```

## `Unsupported container runtime: podman`

**Síntoma:**

```
ERROR - Podman is not supported for local vLLM Semantic Router deployment.
ERROR - Unsupported container runtime: podman
ERROR - Use Docker for local `vllm-sr serve` workflows.
```

`vllm-sr` no encontró `docker` en el PATH y cayó a Podman. En este taller hace falta Docker.

También pasa si corres `vllm-sr serve` desde `~` en vez de la raíz del repo. Eso además crea `~/config.yaml` y `~/.vllm-sr/` (otra cuenta del dashboard, distinta a la del repo).

```bash
# 1. Ir al repo
cd /ruta/al/semantic-router-workshop
source .venv/bin/activate

# 2. macOS: CLI de Docker Desktop + forzar runtime
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export CONTAINER_RUNTIME=docker

# 3. Comprobar que es Docker de verdad
docker --version
which docker

# 4. Arrancar
vllm-sr serve
```

Si `docker --version` sigue fallando, abre **Docker Desktop** y espera a que esté en ejecución.

## Puerto 8700 ocupado (`port is already allocated`)

**Síntoma:**

```
Bind for 0.0.0.0:8700 failed: port is already allocated
```

en el contenedor `vllm-sr-dashboard-container`.

El dashboard **siempre** usa **8700**. Si en `config.yaml` el `listener` también está en 8700, Docker intenta montar dos cosas en el mismo puerto.

1. Para el stack a medias:

```bash
vllm-sr stop
```

2. El listener de chat debe ser **8899**:

```yaml
listeners:
  - name: main
    address: "0.0.0.0"
    port: 8899
```

3. Arranca de nuevo:

```bash
vllm-sr serve
```

Si sigue ocupado:

```bash
lsof -nP -iTCP:8700 -sTCP:LISTEN
docker ps -a | grep vllm-sr
```

## macOS: `mounts denied` / File Sharing (Docker Desktop)

**Síntoma:** `vllm-sr serve` falla con algo así:

```
Failed to start container: docker: Error response from daemon: mounts denied:
The path /Applications/Docker.app/Contents/Resources/bin/docker is not shared from the host and is not known to Docker.
You can configure shared paths from Docker -> Preferences... -> Resources -> File Sharing.
```

Esto es de **Docker Desktop en macOS**. En Linux (Docker Engine) no suele pasar. En Windows, si usas Docker Desktop, la pantalla de File Sharing es parecida.

Hay que hacerlo por la GUI:

1. Abre **Docker Desktop**
2. **Settings → Resources → File Sharing**
3. Pulsa **"+"** y agrega estas rutas:

```
/Applications/Docker.app/Contents/Resources/bin
```

```
$HOME/.vllm-sr
```

En File Sharing pega la ruta absoluta de tu home, no la variable. Ejemplo de forma: `/Users/<tu-usuario>/.vllm-sr`.

4. **Apply & Restart**
5. Vuelve a correr:

```bash
vllm-sr serve
```

## `vllm-sr eval` devuelve error de conexión

**Síntoma:** `Router is not running at http://localhost:8080`

```bash
vllm-sr status          # ¿Está corriendo?
vllm-sr serve           # Reiniciar si es necesario
```

> `eval` usa el puerto **8080** (API interna del router), no el 8899 de Envoy.

## Open WebUI no recibe respuestas

**Verificar:**

1. ¿`vllm-sr serve` está corriendo?
2. ¿Open WebUI apunta a Envoy en el puerto **8899**?

```bash
# Probar la API de chat directamente
curl http://localhost:8899/v1/models

# Probar un chat
vllm-sr chat "hello"
```

3. ¿Open WebUI apunta al puerto correcto?

```bash
docker inspect open-webui | grep OPENAI_API_BASE_URL
```

## Error 401 / 403 desde OpenShift AI

**Síntoma:** el router conecta pero el modelo remoto rechaza la petición.

- En el dashboard, revisa el **API key** (Bearer) de cada endpoint: el token puede haber expirado
- Confirma que las URLs están **sin** `/v1` al final
- Pide al instructor un token de respaldo si el actual falla

## El routing elige el modelo incorrecto

```bash
# Diagnosticar qué señales se activaron
vllm-sr eval --prompt "tu query aquí" --json
```

- Revisa las descripciones de los dominios en el dashboard
- Ajusta prioridades (`priority`) si dos reglas compiten
- El dominio con **menor** `priority` gana cuando hay empate

## Dashboard pide login (“Bootstrap is complete”)

**Síntoma:** [http://localhost:8700](http://localhost:8700) muestra *Sign in* con **Bootstrap is complete**. No hay usuario de fábrica; ese texto sale cuando el dashboard **cierra el registro**.

Causa habitual en este taller: `config.yaml` sin bloque `setup:` (por ejemplo `version: "1.0"` solo con `listeners`). Entonces `vllm-sr serve` **no** activa modo setup, `/api/auth/bootstrap/can-register` devuelve `canRegister: false` y el login no sirve.

1. Deja el YAML así (puerto **8899**, `setup.mode: true`):

```yaml
version: "v0.3"

listeners:
  - name: http-8899
    address: "0.0.0.0"
    port: 8899
    timeout: "300s"

setup:
  mode: true
  state: bootstrap
  created_by: vllm-sr serve
```

2. Para y borra el estado de cuentas **con el stack detenido**, desde la **raíz del repo** (no desde `~`):

```bash
cd /ruta/al/semantic-router-workshop
source .venv/bin/activate
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export CONTAINER_RUNTIME=docker

vllm-sr stop
rm -rf .vllm-sr/dashboard-data
rm -rf "$HOME/.vllm-sr/dashboard-data"
rm -f "$HOME/config.yaml"

vllm-sr serve
```

3. Abre [http://localhost:8700](http://localhost:8700) con recarga forzada. Debe pedir **crear cuenta**, no *Bootstrap is complete*.

Si corriste `serve` desde home, `~/config.yaml` y `~/.vllm-sr/` son otro workspace.

## Dashboard Degraded / Starting router services

**Síntoma:** después de **Activate**, el dashboard muestra *Starting router services*, Router y Envoy en **unknown**, Services Healthy **1/3**.

En modo setup esos contenedores se crean parados. Activate debería arrancarlos; en macOS a veces no los encuentra (`router container ... not found`).

```bash
docker start vllm-sr-router-container vllm-sr-envoy-container
vllm-sr status
```

Recarga el dashboard. Router y Envoy deben pasar a **running**.

## Puerto ya en uso

```bash
# Ver qué proceso usa el puerto
lsof -i :8899
lsof -i :8700

# Detener el stack anterior
vllm-sr stop
```

## Imágenes lentas en la primera ejecución

La primera vez, `vllm-sr serve` descarga imágenes de contenedor (~varios GB). Es normal. Las siguientes ejecuciones son más rápidas.

## Más ayuda

- [vLLM Semantic Router — Issues](https://github.com/vllm-project/vllm-semantic-router/issues)
- [vllm-sr docs](https://github.com/vllm-project/vllm-semantic-router/blob/main/README.md)
