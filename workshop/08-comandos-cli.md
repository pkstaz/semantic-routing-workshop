# 8. Comandos CLI útiles

Referencia rápida de comandos `vllm-sr` para el workshop.

## Estado y ciclo de vida

```bash
vllm-sr serve                    # Iniciar el stack completo
vllm-sr serve --config config.yaml
vllm-sr status                   # Ver estado de contenedores
vllm-sr stop                     # Detener todo
vllm-sr dashboard                # Abrir dashboard en el navegador
```

## Evaluar routing (sin enviar al modelo)

```bash
# Resumen legible
vllm-sr eval --prompt "Write a shell script to backup files"

# JSON completo
vllm-sr eval --prompt "What is 2+2?" --json

# Multi-turn
vllm-sr eval --messages '[{"role":"user","content":"Hello"}]'
```

## Chat (envía al modelo vía Envoy)

```bash
vllm-sr chat "Hello, how are you?"
vllm-sr chat --json "Explain recursion in Python"
```

## Modelos y configuración

```bash
vllm-sr model list                         # Listar modelos configurados
vllm-sr validate --config config.yaml      # Validar YAML
vllm-sr config router                      # Ver config efectiva del router
```

## Logs

```bash
vllm-sr logs router
vllm-sr logs envoy
vllm-sr logs dashboard
vllm-sr logs router -f                       # Follow (streaming)
```

## Puertos alternativos (stacks paralelos)

```bash
VLLM_SR_STACK_NAME=lane-b VLLM_SR_PORT_OFFSET=200 vllm-sr serve
# Dashboard en :8900, listener en :9099, etc.
```

## Siguiente paso

Si algo falla: [Troubleshooting →](./09-troubleshooting.md)
