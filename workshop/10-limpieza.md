# 10. Limpieza

Al terminar el workshop, detén y limpia los recursos locales.

## Detener servicios

```bash
docker compose down
vllm-sr stop
```

## Eliminar datos de Open WebUI (opcional)

```bash
docker volume rm semantic-router-workshop_open-webui-data
```

## Eliminar estado de vllm-sr (opcional)

```bash
rm -rf .vllm-sr/
rm -rf "$HOME/.vllm-sr/"
rm -f "$HOME/config.yaml"
```

> Esto borra la configuración del dashboard, historial de evaluaciones y datos persistidos. Solo hazlo si quieres empezar de cero. `~/config.yaml` y `~/.vllm-sr/` aparecen si alguna vez corriste `vllm-sr serve` desde home.

## Eliminar entorno virtual (opcional)

```bash
deactivate
rm -rf .venv
```

## Verificar que todo está detenido

```bash
vllm-sr status
docker ps
```

No debería quedar ningún contenedor del workshop corriendo.
