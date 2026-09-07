# 5. Configuración

Todo se hace en el **dashboard** (modo setup). El instructor te pasa **un token** y **tres URLs**. Pégalo todo en la UI.

## 1. Arranca vllm-sr

Creamos un `config.yaml` inicial en modo setup:

```bash
cat > config.yaml << 'EOF'
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
EOF
```

Arranca el stack:

```bash
vllm-sr serve
```

La primera vez descarga imágenes — puede tardar varios minutos.

Cuando esté listo, abre: [http://localhost:8700](http://localhost:8700)

Crea una cuenta (email + contraseña) y guárdala: no hay usuario de fábrica.

Si el dashboard pide login con *Bootstrap is complete* en vez de crear cuenta, ve a [Troubleshooting](./09-troubleshooting.md).

Después del login ves **Build your first Mixture-of-Models**, paso **Connect model**. Ahí se crean y configuran los modelos. Sigue con la sección 2.

## 2. Conecta los modelos

Routing mode: **From scratch**.

Si el formulario trae un modelo de ejemplo (por ejemplo `qwen/qwen3.5-rocm` y `vllm:8000`), pulsa **Remove**. No es de este taller.

Crea **3 modelos** con **Add model**. En cada uno:

| Campo | Valor |
|---|---|
| **Provider** | `OpenAI-compatible API` |
| **Access key** | el token del instructor (igual en los 3) |
| **Base URL or Host** | la URL que te dicten, **sin** `/v1` al final |

### Llama — conversación

Model name:

```
llama-32-3b
```

Base URL or Host:

```
https://<URL-LLAMA>
```

Uso: preguntas generales, redacción, conocimiento.

Márcalo como **Default**.

### Qwen — código

Model name:

```
qwen35-9b
```

Base URL or Host:

```
https://<URL-CODE>
```

Uso: Python, SQL, debugging, scripts.

### Granite Vision — imágenes

Model name:

```
granite-vision-32-2b
```

Base URL or Host:

```
https://<URL-VISION>
```

Uso: fotos y análisis visual.

Deberías ver 3 modelos. Pulsa **Next** (Choose routing).

## 3. Dominios

En el paso **Choose routing**, crea estos 3 dominios. Copia el nombre y la descripción.

### `code`

Nombre:

```
code
```

Descripción:

```
Programación, debugging, SQL, scripts y algoritmos
```

### `vision`

Nombre:

```
vision
```

Descripción:

```
Imágenes, fotos y análisis visual
```

### `general`

Nombre:

```
general
```

Descripción:

```
Conversación, conocimiento general, redacción y preguntas abiertas
```

## 4. Rutas

Sigue en **Choose routing**. Crea 3 reglas. Prioridad: **número más bajo gana**.

### Ruta código

Nombre:

```
code-route
```

Prioridad:

```
10
```

Si el dominio es `code` → modelo `qwen35-9b`

### Ruta visión

Nombre:

```
vision-route
```

Prioridad:

```
20
```

Si el dominio es `vision` → modelo `granite-vision-32-2b`

### Ruta general

Nombre:

```
general-route
```

Prioridad:

```
100
```

Si el dominio es `general` → modelo `llama-32-3b`

## 5. Review & activate

Pulsa **Next** y luego **Activate**. El dashboard genera la config y sale del modo setup.

Comprueba que ves los 3 modelos:

```bash
vllm-sr model
```

## Siguiente paso

[Levantar Open WebUI →](./06-levantar-servicios.md)
