# Componentes de la demo (Semantic Router en OpenShift)

Este documento explica los componentes principales de la demo y el rol de cada uno en el flujo de routing.

## Vista rápida de arquitectura

1. Usuario envía una consulta desde el Dashboard (Playground) o por la ruta pública de chat.
2. La consulta entra por `Envoy` (puerto 8899), que actúa como gateway de chat.
3. Envoy llama al `Semantic Router` (gRPC ext_proc + lógica de decisiones).
4. El router evalúa `signals` y `decisions`, selecciona un modelo y reenvía al backend MaaS.
5. MaaS responde y el resultado vuelve al usuario por Envoy.

## Componentes principales

### 1) Dashboard

- **Qué es:** UI web de administración y pruebas.
- **Para qué sirve:**
  - Probar prompts en el Playground.
  - Ver/editar configuración de routing.
  - Ver decisiones tomadas por el router.
- **No hace directamente:** inferencia de modelos.
- **Route OpenShift:** `semantic-router-dashboard`.
- **Puerto interno:** `8700`.

### 2) Envoy

- **Qué es:** proxy de entrada para la API estilo OpenAI (`/v1/chat/completions`).
- **Para qué sirve:**
  - Recibe peticiones de chat.
  - Las pasa por el pipeline de routing (ext_proc).
  - Devuelve la respuesta final al cliente.
- **Por qué es clave:** el router HTTP en `8080` no es el endpoint principal de chat para la demo.
- **Route OpenShift:** `semantic-router-chat`.
- **Puerto interno:** `8899`.

### 3) API de evaluación (Eval API)

- **Qué es:** endpoint para inspeccionar clasificación/routing sin usar chat completo.
- **Endpoint:** `/api/v1/eval`.
- **Uso típico:** validar qué decisión/modelo escogería el router para un texto.
- **Route OpenShift:** `semantic-router-api`.
- **Puerto interno:** `8080`.

### 4) Semantic Router (core)

- **Qué es:** servicio central que decide a qué modelo enviar cada request.
- **Funciones principales:**
  - Clasificación semántica.
  - Aplicación de reglas (`decisions`).
  - Selección de modelo por prioridad y señales.
- **Puertos internos:**
  - `8080` (API HTTP de servicio/eval).
  - `50051` (gRPC usado por ext_proc).
  - `9190` (métricas).

### 5) Models (modelos en MaaS)

- **Qué son:** LLMs remotos consumidos por API OpenAI-compatible.
- **En esta demo:**
  - `llama-scout-17b` para consultas generales.
  - `qwen3-14b` para código.
  - `granite-3-2-8b-instruct` para datos sensibles/PII.
- **Gateway MaaS:** `https://maas-rhdp.apps.maas.redhatworkshops.io`.

### 6) Providers

- **Qué son:** configuración de conexión a cada modelo/backend.
- **Incluye:**
  - `base_url`
  - `api_key_env`
  - `provider` (`openai`)
  - `chat_path` (`/v1/chat/completions`)
- **Objetivo:** separar la lógica de routing de la conectividad al backend.

### 7) Signals

- **Qué son:** señales semánticas usadas para clasificar intención.
- **Tipos usados en la demo:**
  - `domains` (ej. `code`, `general`).
  - `keywords` (ej. `sensitive_data`: ssn, credit card, datos personales).
- **Resultado:** activan condiciones que luego consumen las decisiones.

### 8) Decisions

- **Qué son:** reglas que mapean señales a un modelo destino.
- **Incluyen:**
  - `rules` (condiciones AND/OR con signals).
  - `priority` (desempate entre reglas).
  - `modelRefs` (modelo final).
- **Ejemplo en demo:**
  - `privacy-route` prioridad 250.
  - `code-route` prioridad 150.
  - `general-route` prioridad 100.

### 9) Routes y Services de OpenShift

- **Services:** exponen pods internamente por nombre DNS.
- **Routes:** publican endpoints HTTPS hacia fuera del cluster.
- **En demo:**
  - `semantic-router-dashboard` -> Dashboard.
  - `semantic-router-chat` -> Envoy (chat).
  - `semantic-router-api` -> Eval API (router 8080).

### 10) Secrets y variables de entorno

- **`OPENSHIFT_AI_TOKEN`:** token para autenticación contra MaaS.
- **`HF_TOKEN`:** token para descargar modelos de clasificación (mmBERT) en arranque.
- **Importante:** si cambia token/config, suele requerirse rollout/restart para que el pod tome los nuevos valores.

## Flujo por tipo de consulta

### General

- Prompt: "What is the capital of France?"
- Señales: domain `general`.
- Decisión esperada: `general-route`.
- Modelo: `llama-scout-17b`.

### Code

- Prompt: "Write a Python function to sort a list."
- Señales: domain `code`.
- Decisión esperada: `code-route`.
- Modelo: `qwen3-14b`.

### Privacy / PII

- Prompt: "My credit card number is 4111-1111-1111-1111."
- Señales: keyword `sensitive_data`.
- Decisión esperada: `privacy-route`.
- Modelo: `granite-3-2-8b-instruct`.

## Notas operativas

- `semantic-router-chat` (Envoy) es la entrada correcta para chat.
- `semantic-router-api` (`/api/v1/eval`) es para evaluación de routing, no chat interactivo.
- Tras instalar, puede haber una ventana de warmup mientras cargan clasificadores; en ese periodo pueden aparecer errores transitorios.
