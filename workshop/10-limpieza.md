# 10. Limpieza

Al terminar el workshop, detén y limpia los recursos locales.

## Detener servicios

```bash
podman-compose down
vllm-sr stop
```

## Eliminar datos de Open WebUI (opcional)

```bash
podman volume rm semantic-router-workshop_open-webui-data
```

## Eliminar estado de vllm-sr (opcional)

```bash
rm -rf .vllm-sr/
```

> Esto borra la configuración del dashboard, historial de evaluaciones y datos persistidos. Solo hazlo si quieres empezar de cero.

## Eliminar entorno virtual (opcional)

```bash
deactivate
rm -rf .venv
```

## Verificar que todo está detenido

```bash
vllm-sr status
podman ps
```

No debería quedar ningún contenedor del workshop corriendo.
