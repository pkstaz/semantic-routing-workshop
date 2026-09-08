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

Deberías ver 3 modelos. Pulsa **Next**.

En **Choose routing** deja **From scratch** (Default catch-all). No elijas Balance, Security ni From remote.

Pulsa **Next** otra vez.

## 3. Review & activate

Estás en **Review & activate**. Aquí se valida y se activa.

Comprueba:

- Badge **READY**
- Listener **:8899**
- Models **3**
- Routing mode **From scratch**

**Decisions: 1** y **Signals: 0** es normal: From scratch deja un catch-all. Signals y decisions de código/visión/general se agregan **después** de activar (secciones 4 y 5).

Si algo no cuadra, pulsa **Revalidate**. Si está READY, pulsa **Activate**.

El dashboard puede quedar **Degraded** / **Starting router services** unos segundos: en setup, Router y Envoy arrancan al activar. Recarga hasta ver Router y Envoy **running**.

Si se quedan en **unknown**, arráncalos a mano:

```bash
docker start vllm-sr-router-container vllm-sr-envoy-container
```

Comprueba que ves los 3 modelos:

```bash
vllm-sr model list
```

## 4. Signals

En el dashboard, **Quick Actions → Manage Signals** (o pestaña **Signals** del Manager).

La lista empieza vacía (**0 ITEMS**). Pulsa **Add Signal** y crea **3** de tipo **Domain**.

### `code`

| Campo | Valor |
|---|---|
| **Type** | Domain |
| **Name** | `code` |
| **Description** | `Programación, debugging, SQL, scripts y algoritmos` |

### `vision`

| Campo | Valor |
|---|---|
| **Type** | Domain |
| **Name** | `vision` |
| **Description** | `Imágenes, fotos y análisis visual` |

### `general`

| Campo | Valor |
|---|---|
| **Type** | Domain |
| **Name** | `general` |
| **Description** | `Conversación, conocimiento general, redacción y preguntas abiertas` |

Guarda cada uno. Debes ver **3 ITEMS**.

## 5. Decisions

Pestaña **Decisions** del Manager (o **Manage Decisions**).

Ya existe `default-route` (**P100**, 0 conditions, 1 model): es el catch-all. **No lo borres.**

Pulsa **Add Decision** y crea **3** reglas. Prioridad: **número más bajo gana** (deben ser < 100 para ganar al catch-all).

En cada una:

- **Conditions:** type `domain`, name = el signal (`code`, `vision` o `general`)
- **Models:** el modelo de esa ruta

### `code-route`

| Campo | Valor |
|---|---|
| **Name** | `code-route` |
| **Priority** | `10` |
| **Condition** | domain `code` |
| **Model** | `qwen35-9b` |

### `vision-route`

| Campo | Valor |
|---|---|
| **Name** | `vision-route` |
| **Priority** | `20` |
| **Condition** | domain `vision` |
| **Model** | `granite-vision-32-2b` |

### `general-route`

| Campo | Valor |
|---|---|
| **Name** | `general-route` |
| **Priority** | `50` |
| **Condition** | domain `general` |
| **Model** | `llama-32-3b` |

Al terminar: 3 signals y 4 decisions (`code-route`, `vision-route`, `general-route`, `default-route`).

## Siguiente paso

[Levantar Open WebUI →](./06-levantar-servicios.md)
