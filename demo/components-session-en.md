# Session Script (EN) — Semantic Routing Demo

## 1) Opening (30-45s)

"Today we are not using one model for every request.  
We use a semantic router that automatically selects the best model based on request intent."

"The value is simple: better quality and better operational control, without changing user experience."

## 2) What to show first (1 min)

- Open the Dashboard Playground.
- Explain that this UI is used for:
  - testing prompts,
  - inspecting routing decisions,
  - understanding why a model was selected.

## 3) Core flow (1 min)

"Chat requests enter through Envoy at `/v1/chat/completions`."

"Envoy sends requests through the router pipeline, then the router chooses a model and forwards to MaaS."

## 4) Signals and decisions (2 min)

"The router evaluates signals (domains + keywords), then applies decisions with priorities."

Current priorities:
- `privacy-route` (250)
- `code-route` (150)
- `general-route` (100)

"If multiple rules match, higher priority wins."

## 5) Model mapping (1 min)

- `general` -> `llama-scout-17b`
- `code` -> `qwen3-14b`
- `privacy` -> `granite-3-2-8b-instruct`

## 6) Live prompt set (3-4 min)

1. General prompt  
`What is the capital of France?`  
Expected: `general-route` -> `llama-scout-17b`

2. Code prompt  
`Write a Python function to sort a list.`  
Expected: `code-route` -> `qwen3-14b`

3. Privacy prompt  
`My credit card number is 4111-1111-1111-1111.`  
Expected: `privacy-route` -> `granite-3-2-8b-instruct`

4. Ambiguous prompt  
`Create a Python script to process this SSN 123-45-6789.`  
Expected: `privacy-route` (priority override).

## 7) Closing (30-45s)

"Semantic routing lets us keep one user entry point while applying specialized models behind the scenes."

"So we gain quality, governance, and observability with minimal UX change."

