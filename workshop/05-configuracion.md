# 5. Configuración

Todo se hace en el **dashboard** (modo setup). No hace falta `.env` ni YAML.

El instructor te pasa **un token** y **tres URLs**. Pégalo todo en la UI.

## 1. Arranca vllm-sr

Desde la raíz del repo, con el entorno virtual activo:

```bash
source .venv/bin/activate
vllm-sr serve
```

La primera vez descarga imágenes — puede tardar varios minutos.

Cuando esté listo, abre: [http://localhost:8700](http://localhost:8700)

El dashboard entra en **setup**. Ahí creas endpoints y rutas, y al final pulsas **Activate**.

## 2. Auth (igual en los 3 endpoints)

En cada modelo, usa:

Header:

```
Authorization
```

Prefix:

```
Bearer
```

**API key:** el token que te da el instructor (no lo copies de esta guía).

> Las URLs van **sin** `/v1` al final.

## 3. Endpoints

En setup, crea **3 modelos**. Copia nombre y URL, pega, guarda, siguiente.

### Llama — conversación

Nombre:

```
llama-32-3b
```

URL:

```
https://<URL-LLAMA>
```

Uso: preguntas generales, redacción, conocimiento.

Marca este modelo como **default**.

### Qwen — código

Nombre:

```
qwen35-9b
```

URL:

```
https://<URL-CODE>
```

Uso: Python, SQL, debugging, scripts.

### Granite Vision — imágenes

Nombre:

```
granite-vision-32-2b
```

URL:

```
https://<URL-VISION>
```

Uso: fotos y análisis visual.

Deberías ver 3 modelos en la lista.

## 4. Dominios

En **Signals → Domains**, crea estos 3. Copia el nombre y la descripción.

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

## 5. Rutas

En **Decisions / Routes**, crea 3 reglas. Prioridad: **número más bajo gana**.

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

## 6. Activate

Pulsa **Activate**. El dashboard genera la config y sale del modo setup.

Comprueba que ves los 3 modelos:

```bash
vllm-sr model
```

## Siguiente paso

[Levantar Open WebUI →](./06-levantar-servicios.md)
