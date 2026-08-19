#!/usr/bin/env bash
# Instala la demo de semantic routing en OpenShift.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GENERATED_DIR="${SCRIPT_DIR}/.generated"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}==>${NC} $*"; }
warn()  { echo -e "${YELLOW}==>${NC} $*"; }
error() { echo -e "${RED}ERROR:${NC} $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || error "Falta '$1'. Instálalo antes de continuar."
}

resolve_python() {
  if [[ -x "${REPO_ROOT}/.venv/bin/python3" ]]; then
    echo "${REPO_ROOT}/.venv/bin/python3"
  elif command -v python3 >/dev/null 2>&1; then
    echo "python3"
  else
    error "No se encontró python3. Crea el venv del workshop o instala Python 3."
  fi
}

load_env() {
  local env_file="${SCRIPT_DIR}/demo.env"
  if [[ ! -f "${env_file}" ]]; then
    error "No existe demo.env. Copia env.demo.example:\n  cp demo/env.demo.example demo/demo.env"
  fi
  # shellcheck disable=SC1090
  set -a && source "${env_file}" && set +a

  : "${DEMO_NAMESPACE:=semantic-router-demo}"
  : "${HELM_RELEASE:=semantic-router-demo}"
  : "${HELM_CHART:=oci://ghcr.io/vllm-project/charts/semantic-router}"
  : "${GENERAL_SERVICE_URL:?Define GENERAL_SERVICE_URL en demo.env}"
  : "${CODE_SERVICE_URL:?Define CODE_SERVICE_URL en demo.env}"
  : "${PRIVACY_SERVICE_URL:?Define PRIVACY_SERVICE_URL en demo.env}"
  : "${STORAGE_CLASS:=gp3-csi}"
}

check_prerequisites() {
  info "Verificando prerequisitos..."
  require_cmd oc
  require_cmd helm
  require_cmd envsubst

  oc whoami >/dev/null 2>&1 || error "No hay sesión de OpenShift. Ejecuta: oc login"
  info "Cluster: $(oc whoami --show-server)"
}

render_templates() {
  info "Generando configuración..."
  mkdir -p "${GENERATED_DIR}"

  export DEMO_NAMESPACE HELM_RELEASE \
    GENERAL_SERVICE_URL CODE_SERVICE_URL PRIVACY_SERVICE_URL

  envsubst < "${SCRIPT_DIR}/config.demo.yaml.template" > "${GENERATED_DIR}/config.yaml"
  envsubst < "${SCRIPT_DIR}/openshift/namespace.yaml.template" > "${GENERATED_DIR}/namespace.yaml"
  envsubst < "${SCRIPT_DIR}/openshift/api-service.yaml.template" > "${GENERATED_DIR}/api-service.yaml" 2>/dev/null || true

  info "Config generada en ${GENERATED_DIR}/config.yaml"
}

validate_config() {
  local validator=""
  if [[ -x "${REPO_ROOT}/.venv/bin/vllm-sr" ]]; then
    validator="${REPO_ROOT}/.venv/bin/vllm-sr"
  elif command -v vllm-sr >/dev/null 2>&1; then
    validator="vllm-sr"
  fi

  if [[ -n "${validator}" ]]; then
    info "Validando config.yaml..."
    "${validator}" validate --config "${GENERATED_DIR}/config.yaml"
  else
    warn "vllm-sr no encontrado — omitiendo validación (pip install vllm-sr)"
  fi
}

build_helm_values() {
  info "Construyendo values de Helm..."
  local python_bin
  python_bin="$(resolve_python)"

  if ! "${python_bin}" -c "import yaml" 2>/dev/null; then
    error "PyYAML no está instalado. Ejecuta:\n  pip install pyyaml\n  # o activa el venv del repo: source ../.venv/bin/activate"
  fi

  "${python_bin}" - <<'PY'
import os
import sys

try:
    import yaml
except ImportError:
    sys.exit("Instala PyYAML: pip install pyyaml")

generated = os.environ["GENERATED_DIR"]
script_dir = os.environ["SCRIPT_DIR"]

with open(os.path.join(generated, "config.yaml")) as f:
    config = yaml.safe_load(f)

with open(os.path.join(script_dir, "helm", "values-demo.yaml")) as f:
    values = yaml.safe_load(f)

values["config"] = config

# Modelos en emptyDir (ver values-demo.yaml) — evita Permission denied en PVC con restricted SCC
values.setdefault("persistence", {})["enabled"] = False
values.setdefault("extraVolumes", [{"name": "models-volume", "emptyDir": {"sizeLimit": "10Gi"}}])
values.setdefault("extraVolumeMounts", [{"name": "models-volume", "mountPath": "/app/models"}])
values.setdefault("extraEnv", [
    {"name": "HF_HOME", "value": "/app/models"},
    {"name": "HUGGINGFACE_HUB_CACHE", "value": "/app/models"},
    {"name": "HF_HUB_DISABLE_XET", "value": "1"},
    {"name": "HOME", "value": "/tmp"},
])

dashboard = values.setdefault("dashboard", {})
dashboard.setdefault("persistence", {})["enabled"] = False
if "image" not in dashboard:
    dashboard["image"] = {}
dashboard["image"]["tag"] = "v0.3.0"
dashboard.pop("podSecurityContext", None)
values.pop("securityContext", None)

token = os.environ.get("OPENSHIFT_AI_TOKEN", "")
if token and token != "your-token-here":
    values["envFromSecrets"] = ["vllm-sr-env-secrets"]

out = os.path.join(generated, "values-merged.yaml")
with open(out, "w") as f:
    yaml.safe_dump(values, f, default_flow_style=False)

print(out)
PY
}

create_namespace() {
  info "Creando namespace ${DEMO_NAMESPACE}..."
  oc apply -f "${GENERATED_DIR}/namespace.yaml"
}

apply_scc_bindings() {
  info "Concediendo SCC anyuid al dashboard (entrypoint requiere arrancar como root)..."
  # El deployment del dashboard no fija serviceAccountName — usa el SA default del namespace.
  oc adm policy add-scc-to-user anyuid -z default -n "${DEMO_NAMESPACE}" 2>/dev/null \
    || warn "No se pudo enlazar anyuid — el dashboard puede fallar en clusters sin permisos SCC"
}

create_secret() {
  if [[ -n "${OPENSHIFT_AI_TOKEN:-}" && "${OPENSHIFT_AI_TOKEN}" != "your-token-here" ]]; then
    info "Creando secret para backends MaaS..."
    oc create secret generic vllm-sr-env-secrets \
      --namespace "${DEMO_NAMESPACE}" \
      --from-literal=OPENSHIFT_AI_TOKEN="${OPENSHIFT_AI_TOKEN}" \
      --dry-run=client -o yaml | oc apply -f -
  else
    warn "OPENSHIFT_AI_TOKEN no configurado — backends MaaS sin auth"
  fi

  if [[ -n "${HF_TOKEN:-}" && "${HF_TOKEN}" != "your-hf-token-here" ]]; then
    if [[ "${HF_TOKEN}" == yhf_* ]]; then
      warn "HF_TOKEN empieza por 'yhf_' — suele ser un typo; corrígelo a 'hf_' en demo.env"
    fi
    info "Creando secret hf-token-secret (modelos de clasificación)..."
    oc create secret generic hf-token-secret \
      --namespace "${DEMO_NAMESPACE}" \
      --from-literal=token="${HF_TOKEN}" \
      --dry-run=client -o yaml | oc apply -f -
  else
    error "HF_TOKEN requerido en demo.env — el router necesita descargar modelos mmBERT desde HuggingFace.\n  Obtén uno en: https://huggingface.co/settings/tokens"
  fi
}

restart_router_for_secret() {
  if oc get deployment "${HELM_RELEASE}" -n "${DEMO_NAMESPACE}" >/dev/null 2>&1; then
    info "Reiniciando router para cargar OPENSHIFT_AI_TOKEN actualizado..."
    oc rollout restart deployment/"${HELM_RELEASE}" -n "${DEMO_NAMESPACE}" >/dev/null
    oc rollout status deployment/"${HELM_RELEASE}" -n "${DEMO_NAMESPACE}" --timeout=180s
  fi
}

deploy_helm() {
  info "Desplegando ${HELM_RELEASE} con Helm..."
  local helm_args=(
    upgrade --install "${HELM_RELEASE}" "${HELM_CHART}"
    --namespace "${DEMO_NAMESPACE}"
    -f "${GENERATED_DIR}/values-merged.yaml"
    --wait
    --timeout 25m
  )

  if [[ -n "${HELM_CHART_VERSION:-}" ]]; then
    helm_args+=(--version "${HELM_CHART_VERSION}")
  fi

  helm "${helm_args[@]}"
}

apply_router_pod_label() {
  info "Etiquetando pods del router (excluye dashboard)..."
  # El chart no distingue router vs dashboard en el Service principal.
  oc label deployment "${HELM_RELEASE}" -n "${DEMO_NAMESPACE}" \
    app.kubernetes.io/component=router --overwrite 2>/dev/null || true
  oc patch deployment "${HELM_RELEASE}" -n "${DEMO_NAMESPACE}" --type=strategic -p '
{
  "spec": {
    "template": {
      "metadata": {
        "labels": {
          "app.kubernetes.io/component": "router"
        }
      }
    }
  }
}' 2>/dev/null || true
  # Etiquetar pods ya en ejecución sin esperar rollout completo
  local pod
  while IFS= read -r pod; do
    [[ -z "${pod}" ]] && continue
    local component
    component="$(oc get pod "${pod}" -n "${DEMO_NAMESPACE}" \
      -o jsonpath='{.metadata.labels.app\.kubernetes\.io/component}' 2>/dev/null || true)"
    if [[ "${component}" != "dashboard" ]]; then
      oc label pod "${pod}" -n "${DEMO_NAMESPACE}" \
        app.kubernetes.io/component=router --overwrite >/dev/null 2>&1 || true
    fi
  done < <(oc get pods -n "${DEMO_NAMESPACE}" \
    -l "app.kubernetes.io/instance=${HELM_RELEASE},app.kubernetes.io/name=semantic-router" \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)
}

apply_api_service() {
  info "Creando Service dedicado para la API del router..."
  envsubst < "${SCRIPT_DIR}/openshift/api-service.yaml.template" \
    > "${GENERATED_DIR}/api-service.yaml"
  oc apply -f "${GENERATED_DIR}/api-service.yaml"
}

deploy_envoy() {
  info "Desplegando Envoy (chat API /v1/chat/completions en :8899)..."
  local vllm_sr=""
  if [[ -x "${REPO_ROOT}/.venv/bin/vllm-sr" ]]; then
    vllm_sr="${REPO_ROOT}/.venv/bin/vllm-sr"
  elif command -v vllm-sr >/dev/null 2>&1; then
    vllm_sr="vllm-sr"
  else
    error "vllm-sr requerido para generar config de Envoy"
  fi

  local python_bin raw_envoy
  python_bin="$(resolve_python)"
  raw_envoy="${GENERATED_DIR}/envoy.raw.yaml"

  "${vllm_sr}" config envoy --config "${GENERATED_DIR}/config.yaml" 2>/dev/null \
    | sed -n '/^admin:/,$p' > "${raw_envoy}"

  "${python_bin}" - "${HELM_RELEASE}" "${raw_envoy}" "${GENERATED_DIR}/envoy.yaml" <<'PY'
import re, sys
host, infile, outfile = sys.argv[1], sys.argv[2], sys.argv[3]
with open(infile) as f:
    text = f.read()
text = text.replace("address: 127.0.0.1", f"address: {host}")
text = re.sub(
    r"(# ExtProc service \(semantic router\)\n  - name: extproc_service\n    connect_timeout: [^\n]+\n    )type: STATIC",
    r"\1type: LOGICAL_DNS\n    dns_lookup_family: V4_ONLY",
    text,
    count=1,
)
text = re.sub(
    r"(name: extproc_service.*?port_value: 50051\n)",
    rf'\1            hostname: "{host}"\n',
    text,
    count=1,
    flags=re.DOTALL,
)
with open(outfile, "w") as f:
    f.write(text)
PY

  oc create configmap "${HELM_RELEASE}-envoy-config" \
    --namespace "${DEMO_NAMESPACE}" \
    --from-file=envoy.yaml="${GENERATED_DIR}/envoy.yaml" \
    --dry-run=client -o yaml | oc apply -f -

  envsubst < "${SCRIPT_DIR}/openshift/envoy-deployment.yaml.template" \
    > "${GENERATED_DIR}/envoy-deployment.yaml"
  oc apply -f "${GENERATED_DIR}/envoy-deployment.yaml"
}

patch_dashboard_envoy_url() {
  info "Configurando dashboard para usar Envoy (chat API)..."
  oc set env deployment/"${HELM_RELEASE}-dashboard" -n "${DEMO_NAMESPACE}" \
    TARGET_ROUTER_API_URL="http://${HELM_RELEASE}-envoy:8899" --overwrite
  oc rollout status deployment/"${HELM_RELEASE}-dashboard" -n "${DEMO_NAMESPACE}" --timeout=120s
}

apply_routes() {
  info "Creando OpenShift Routes..."

  local dashboard_svc
  dashboard_svc="$(oc get svc -n "${DEMO_NAMESPACE}" \
    -l "app.kubernetes.io/instance=${HELM_RELEASE},app.kubernetes.io/component=dashboard" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"

  : "${dashboard_svc:=${HELM_RELEASE}-dashboard}"

  export DASHBOARD_SVC="${dashboard_svc}"
  export API_SVC="${HELM_RELEASE}-api"
  export CHAT_SVC="${HELM_RELEASE}-envoy"

  cat > "${GENERATED_DIR}/routes.yaml" <<EOF
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: semantic-router-dashboard
  namespace: ${DEMO_NAMESPACE}
spec:
  to:
    kind: Service
    name: ${DASHBOARD_SVC}
    weight: 100
  port:
    targetPort: 8700
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: semantic-router-api
  namespace: ${DEMO_NAMESPACE}
spec:
  to:
    kind: Service
    name: ${API_SVC}
    weight: 100
  port:
    targetPort: 8080
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: semantic-router-chat
  namespace: ${DEMO_NAMESPACE}
spec:
  to:
    kind: Service
    name: ${CHAT_SVC}
    weight: 100
  port:
    targetPort: 8899
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
EOF

  oc apply -f "${GENERATED_DIR}/routes.yaml"
  info "Routes → dashboard:${DASHBOARD_SVC}  eval-api:${API_SVC}  chat:${CHAT_SVC}"
}

wait_for_pods() {
  info "Esperando pods..."
  oc wait --for=condition=Ready pod \
    -l "app.kubernetes.io/instance=${HELM_RELEASE}" \
    -n "${DEMO_NAMESPACE}" \
    --timeout=600s 2>/dev/null || true
}

wait_for_router_ready() {
  info "Esperando que el router termine de cargar modelos de clasificación (~1-2 min)..."
  local router_pod=""
  local i
  for i in $(seq 1 60); do
    router_pod="$(oc get pods -n "${DEMO_NAMESPACE}" \
      -l "app.kubernetes.io/instance=${HELM_RELEASE},app.kubernetes.io/component=router" \
      -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
    if [[ -n "${router_pod}" ]] && oc logs -n "${DEMO_NAMESPACE}" "${router_pod}" 2>/dev/null | grep -q "startup_complete"; then
      info "Router listo (${router_pod})"
      return 0
    fi
    sleep 5
  done
  warn "El router aún no reporta startup_complete — el playground puede devolver 500 unos minutos más"
}

warmup_router() {
  info "Calentando backends MaaS (evita 500 en el primer request del playground)..."
  local chat_host prompt
  chat_host="$(oc get route semantic-router-chat -n "${DEMO_NAMESPACE}" -o jsonpath='{.spec.host}' 2>/dev/null || true)"
  if [[ -z "${chat_host}" ]]; then
    warn "Route semantic-router-chat no disponible — omite warmup"
    return 0
  fi
  for prompt in "What is the capital of France?" "Write a Python function to sort a list"; do
    if ! curl -sf -X POST "https://${chat_host}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d "{\"model\":\"auto\",\"messages\":[{\"role\":\"user\",\"content\":\"${prompt}\"}],\"max_tokens\":5}" >/dev/null; then
      warn "Warmup falló para: ${prompt}"
    fi
    sleep 2
  done
  info "Warmup completado"
}

print_summary() {
  local dashboard_url api_url chat_url
  dashboard_url="$(oc get route semantic-router-dashboard -n "${DEMO_NAMESPACE}" -o jsonpath='{.spec.host}' 2>/dev/null || true)"
  api_url="$(oc get route semantic-router-api -n "${DEMO_NAMESPACE}" -o jsonpath='{.spec.host}' 2>/dev/null || true)"
  chat_url="$(oc get route semantic-router-chat -n "${DEMO_NAMESPACE}" -o jsonpath='{.spec.host}' 2>/dev/null || true)"

  echo ""
  info "Demo desplegada correctamente"
  echo ""
  echo "  Namespace:  ${DEMO_NAMESPACE}"
  echo "  Release:    ${HELM_RELEASE}"
  echo ""
  if [[ -n "${dashboard_url}" ]]; then
    echo "  Dashboard:  https://${dashboard_url}"
  fi
  if [[ -n "${chat_url}" ]]; then
    echo "  Chat API:   https://${chat_url}/v1/chat/completions"
  fi
  if [[ -n "${api_url}" ]]; then
    echo "  Eval API:   https://${api_url}/api/v1/eval"
  fi
  echo ""
  echo "  Siguiente paso: demo/runbook.md"
  echo ""
  oc get pods -n "${DEMO_NAMESPACE}"
}

main() {
  load_env
  check_prerequisites
  render_templates
  validate_config

  export GENERATED_DIR SCRIPT_DIR OPENSHIFT_AI_TOKEN="${OPENSHIFT_AI_TOKEN:-}" STORAGE_CLASS
  build_helm_values

  create_namespace
  apply_scc_bindings
  create_secret
  deploy_helm
  restart_router_for_secret
  apply_router_pod_label
  apply_api_service
  deploy_envoy
  patch_dashboard_envoy_url
  apply_routes
  wait_for_pods
  wait_for_router_ready
  warmup_router
  print_summary
}

main "$@"
