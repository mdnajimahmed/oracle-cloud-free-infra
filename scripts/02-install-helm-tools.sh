#!/usr/bin/env bash
# Install Helm and configure kubectl for the ubuntu user.
# Run as ubuntu user (not root).
set -euo pipefail

echo "Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Verifying Helm..."
helm version

# Add commonly needed Helm repos
helm repo add jetstack   https://charts.jetstack.io
helm repo update

echo ""
echo "Tools installed:"
echo "  kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "  helm:    $(helm version --short)"
