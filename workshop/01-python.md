# 1. Requisitos de Python

Este workshop usa **Python 3.12**.

`vllm-sr` (vLLM Semantic Router) requiere Python **3.10 o superior**. Usamos 3.12 para alinearlo con el entorno local del taller.

## Verificar si ya lo tienes

```bash
python3.12 --version
```

Deberías ver algo como `Python 3.12.x`. Si el comando no existe, instálalo.

## Instalar Python 3.12

**macOS (Homebrew):**

```bash
brew install python@3.12
```

**Linux:** usa el gestor de paquetes de tu distro o descarga el instalador desde [python.org](https://www.python.org/downloads/).

## Crear y usar el entorno virtual

Desde la raíz del repositorio:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python --version
```

Con el entorno activo, `python` y `pip` apuntan a Python 3.12.

Para salir del entorno:

```bash
deactivate
```

## Siguiente paso

[Docker y Docker Compose →](./02-docker.md)

## Más ayuda

Para instalación, versiones o problemas con Python, consulta la [documentación oficial de Python](https://docs.python.org/3/).
