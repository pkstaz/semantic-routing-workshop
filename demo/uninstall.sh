#!/usr/bin/env bash
# Elimina la demo de semantic routing en OpenShift.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/demo.env" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/demo.env"
fi

: "${DEMO_NAMESPACE:=semantic-router-demo}"
: "${HELM_RELEASE:=semantic-router-demo}"

echo "==> Desinstalando release ${HELM_RELEASE}..."
helm uninstall "${HELM_RELEASE}" --namespace "${DEMO_NAMESPACE}" 2>/dev/null || true

echo "==> Eliminando routes..."
oc delete route semantic-router-dashboard semantic-router-api \
  -n "${DEMO_NAMESPACE}" --ignore-not-found

echo "==> Eliminando secret..."
oc delete secret vllm-sr-env-secrets -n "${DEMO_NAMESPACE}" --ignore-not-found

if [[ "${1:-}" == "--delete-namespace" ]]; then
  echo "==> Eliminando namespace ${DEMO_NAMESPACE}..."
  oc delete namespace "${DEMO_NAMESPACE}" --ignore-not-found
else
  echo "==> Namespace conservado. Para eliminarlo:"
  echo "    ./uninstall.sh --delete-namespace"
fi

echo "==> Listo."
