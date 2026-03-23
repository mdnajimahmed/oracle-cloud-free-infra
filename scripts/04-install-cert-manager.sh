#!/usr/bin/env bash
# Install cert-manager for automatic TLS certificate management via Let's Encrypt.
# Run as ubuntu user.
set -euo pipefail

CERT_MANAGER_VERSION="v1.16.2"

echo "Installing cert-manager ${CERT_MANAGER_VERSION}..."

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version "${CERT_MANAGER_VERSION}" \
  --set crds.enabled=true \
  --set resources.requests.cpu=10m \
  --set resources.requests.memory=32Mi \
  --wait

echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=Available deployment/cert-manager \
  -n cert-manager --timeout=120s
kubectl wait --for=condition=Available deployment/cert-manager-webhook \
  -n cert-manager --timeout=120s

echo ""
echo "cert-manager installed. Pods:"
kubectl get pods -n cert-manager

echo ""
echo "Next: apply k8s/gateway/clusterissuer.yaml to create the Let's Encrypt issuers."
