# 2. Docker y Docker Compose

Este workshop usa **Docker**. `vllm-sr serve` levanta sus contenedores con Docker; Open WebUI también.

## Verificar instalación

```bash
docker --version
docker compose version
which docker
```

`docker --version` debe decir **Docker version ...**. Si dice `podman`, el CLI no es Docker.

En macOS, si `which docker` no encuentra nada, Docker Desktop no está en el PATH. En esta terminal:

```bash
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export CONTAINER_RUNTIME=docker
```

Docker Desktop (o el daemon) debe estar **en ejecución**.

## Instalar (macOS)

```bash
brew install --cask docker
```

Abre **Docker Desktop** y espera a que el icono de la ballena deje de animarse.

## Instalar (Linux)

Sigue la guía de tu distro: [Install Docker Engine](https://docs.docker.com/engine/install/). Incluye el plugin **Compose**.

En Ubuntu/Debian, algo así:

```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose-v2
sudo usermod -aG docker "$USER"
```

Cierra sesión y vuelve a entrar para que el grupo `docker` aplique.

## Verificar que Docker funciona

```bash
docker run --rm hello-world
```

## Notas

- `vllm-sr serve` necesita Docker; con Podman no funciona en este taller.
- Las imágenes `linux/arm64` (Apple Silicon) y `linux/amd64` (Linux típico) se resuelven solas.
- En **macOS**, si `vllm-sr serve` falla con `mounts denied`, hay que compartir rutas en Docker Desktop: [Troubleshooting](./09-troubleshooting.md).

## Más ayuda

- [Docker Desktop](https://docs.docker.com/desktop/)
- [Docker Compose](https://docs.docker.com/compose/)

## Siguiente paso

[Instalar vllm-sr CLI →](./03-vllm-sr.md)
