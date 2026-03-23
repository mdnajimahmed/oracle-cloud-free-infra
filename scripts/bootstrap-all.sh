#!/usr/bin/env bash
# One-shot bootstrap: runs all setup steps in sequence.
# Usage: NLB_PUBLIC_IP="x.x.x.x" bash bootstrap-all.sh
# Run as ubuntu user (sudo is called internally where needed).
set -euo pipefail

if [ -z "${NLB_PUBLIC_IP:-}" ]; then
  echo "ERROR: NLB_PUBLIC_IP is required"
  echo "Usage: NLB_PUBLIC_IP=\"x.x.x.x\" bash bootstrap-all.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "▶ Step 1/5: Mount block volume"
sudo bash "${SCRIPT_DIR}/05-mount-block-volume.sh"

echo "▶ Step 2/5: Install k3s"
NLB_PUBLIC_IP="${NLB_PUBLIC_IP}" sudo bash "${SCRIPT_DIR}/01-install-k3s.sh"

# Make kubectl available to current user immediately
export KUBECONFIG=/home/ubuntu/.kube/config

echo "▶ Step 3/5: Install Helm"
bash "${SCRIPT_DIR}/02-install-helm-tools.sh"

echo "▶ Step 4/5: Install Envoy Gateway"
bash "${SCRIPT_DIR}/03-install-envoy-gateway.sh"

echo "▶ Step 5/5: Install cert-manager"
bash "${SCRIPT_DIR}/04-install-cert-manager.sh"

echo ""
echo "✓ Bootstrap complete. Cluster ready."
kubectl get nodes
kubectl get pods -A
