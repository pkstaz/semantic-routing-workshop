# 2. Podman y podman-compose

Este workshop usa **Podman** (no Docker) para correr Open WebUI. `vllm-sr serve` también usa Podman internamente para levantar sus contenedores.

## Verificar instalación

```bash
podman --version
podman-compose --version
```

## Instalar (macOS)

```bash
brew install podman podman-compose
```

Inicializa y arranca la máquina virtual de Podman (solo macOS):

```bash
podman machine init    # solo la primera vez
podman machine start
```

## Instalar (Linux)

Usa el gestor de paquetes de tu distro. En Fedora/RHEL:

```bash
sudo dnf install podman podman-compose
```

## Verificar que Podman funciona

```bash
podman run --rm hello-world
```

## Notas importantes

- **No montamos** `/var/run/docker.sock` — Podman es rootless y no lo necesita.
- Las imágenes deben ser `linux/arm64` (Apple Silicon) o multi-arch.
- `vllm-sr serve` detecta Podman automáticamente si Docker no está disponible.

## Más ayuda

- [Podman docs](https://docs.podman.io/)
- [podman-compose](https://github.com/containers/podman-compose)

## Siguiente paso

[Instalar vllm-sr CLI →](./03-vllm-sr.md)
