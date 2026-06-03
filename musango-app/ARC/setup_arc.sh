#!/bin/bash
set -eu

# Force the script to look for .env in the same directory as the script file itself
# This avoids issues with where you happen to be standing in the terminal
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    echo "Loading environment from $ENV_FILE"
    # Export variables from the .env file automatically
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# Validate that required variables are set
if [ -z "${INSTALLATION_NAME:-}" ] || [ -z "${NAMESPACE:-}" ] || [ -z "${GITHUB_CONFIG_URL:-}" ] || [ -z "${GITHUB_PAT:-}" ]; then
    echo "Error: Missing required variables in .env"
    echo "Required: INSTALLATION_NAME, NAMESPACE, GITHUB_CONFIG_URL, GITHUB_PAT"
    exit 1
fi

echo "Installing ARC runner set: ${INSTALLATION_NAME} in namespace: ${NAMESPACE}..."

# Execute Helm install
helm upgrade --install "${INSTALLATION_NAME}" \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
  --set githubConfigSecret.github_token="${GITHUB_PAT}"

echo "Deployment initiated."