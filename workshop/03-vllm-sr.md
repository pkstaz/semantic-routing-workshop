# 3. Instalar vllm-sr CLI

Con el entorno virtual activo (ver [Requisitos de Python](./01-python.md)):

```bash
pip install vllm-sr
```

## Verificar la instalación

```bash
vllm-sr --help
vllm-sr --version
```

Si ves la ayuda del CLI, la instalación fue correcta.

## Qué instala

El paquete `vllm-sr` incluye el CLI que orquesta:

- **Router** — clasificación y decisiones de routing
- **Envoy** — proxy con API OpenAI-compatible (puerto 8899)
- **Dashboard** — UI web (puerto 8700)

## Siguiente paso

[Arquitectura y flujo →](./04-arquitectura-y-flujo.md)

## Más ayuda

- [vLLM Semantic Router en GitHub](https://github.com/vllm-project/vllm-semantic-router)
