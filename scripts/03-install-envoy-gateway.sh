#!/usr/bin/env bash
# Install Envoy Gateway using the official Helm chart.
# Envoy Gateway implements the Kubernetes Gateway API.
# Run as ubuntu user.
set -euo pipefail

ENVOY_GATEWAY_VERSION="v1.2.1"

echo "Installing Envoy Gateway ${ENVOY_GATEWAY_VERSION}..."

# Install Gateway API CRDs first (required by Envoy Gateway)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

echo "Waiting for Gateway API CRDs to be established..."
kubectl wait --for=condition=Established crd/gateways.gateway.networking.k8s.io --timeout=60s
kubectl wait --for=condition=Established crd/httproutes.gateway.networking.k8s.io --timeout=60s

# Install Envoy Gateway via Helm
helm upgrade --install envoy-gateway \
  oci://docker.io/envoyproxy/gateway-helm \
  --version "${ENVOY_GATEWAY_VERSION}" \
  --namespace envoy-gateway-system \
  --create-namespace \
  --set deployment.envoyGateway.resources.limits.memory=256Mi \
  --set deployment.envoyGateway.resources.requests.memory=64Mi \
  --wait

echo "Waiting for Envoy Gateway to be ready..."
kubectl wait --for=condition=Available deployment/envoy-gateway \
  -n envoy-gateway-system --timeout=120s

echo ""
echo "Envoy Gateway installed. Pods:"
kubectl get pods -n envoy-gateway-system
