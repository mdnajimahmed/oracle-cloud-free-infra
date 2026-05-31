#!/usr/bin/env bash
# argocd-access.sh
# Sets up SSH tunnel + kubectl port-forward to reach ArgoCD UI.
# Nothing in this script works without the OCI SSH private key.

set -euo pipefail

OCI_KEY="${OCI_KEY:-$HOME/.ssh/oci_arm_key}"
OCI_HOST="ubuntu@140.245.107.169"
K8S_TUNNEL_PORT=6443
ARGOCD_LOCAL_PORT=8080
KUBECTL_CONTEXT="turinghatch-oci"

# ── Gate: OCI private key must be present ─────────────────────────────────
if [[ ! -f "$OCI_KEY" ]]; then
  echo "ERROR: OCI SSH key not found at $OCI_KEY"
  echo "       Without the Oracle Cloud private key, cluster access is impossible."
  exit 1
fi

echo "→ OCI key found: $OCI_KEY"

# ── SSH tunnel for kubectl ─────────────────────────────────────────────────
echo "→ Establishing SSH tunnel (k8s API → localhost:$K8S_TUNNEL_PORT)..."
pkill -f "ssh.*${K8S_TUNNEL_PORT}:127.0.0.1:6443" 2>/dev/null || true
sleep 1
ssh -o StrictHostKeyChecking=no \
    -o ConnectTimeout=10 \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -i "$OCI_KEY" \
    -fNL "${K8S_TUNNEL_PORT}:127.0.0.1:6443" \
    "$OCI_HOST"
sleep 2

# ── kubectl context ────────────────────────────────────────────────────────
kubectl config use-context "$KUBECTL_CONTEXT" >/dev/null 2>&1

if ! kubectl get nodes --request-timeout=5s >/dev/null 2>&1; then
  echo "ERROR: Cannot reach cluster through tunnel. Is your home IP in the OCI security list?"
  exit 1
fi
echo "✓ Cluster reachable"

# ── ArgoCD password ────────────────────────────────────────────────────────
# Reads from argocd-initial-admin-secret (present after install or reset).
# If you changed the password via UI, re-run: kubectl -n argocd exec deploy/argocd-server -- argocd admin initial-password reset
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null || true)

if [[ -z "$ARGOCD_PASS" ]]; then
  echo ""
  echo "WARNING: argocd-initial-admin-secret not found (password was changed via UI)."
  echo "         Run this to reset and get a new password:"
  echo "         kubectl -n argocd exec deploy/argocd-server -- argocd admin initial-password reset"
  ARGOCD_PASS="<run reset command above>"
fi

# ── Port-forward ArgoCD ────────────────────────────────────────────────────
echo "→ Port-forwarding ArgoCD → localhost:$ARGOCD_LOCAL_PORT..."
pkill -f "kubectl.*port-forward.*argocd-server" 2>/dev/null || true
sleep 1
kubectl -n argocd port-forward svc/argocd-server "$ARGOCD_LOCAL_PORT:80" \
  --context "$KUBECTL_CONTEXT" >/dev/null 2>&1 &
PF_PID=$!
sleep 2

if ! kill -0 "$PF_PID" 2>/dev/null; then
  echo "ERROR: Port-forward failed to start."
  exit 1
fi

echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│  ArgoCD UI                                  │"
echo "│  URL      : http://localhost:$ARGOCD_LOCAL_PORT          │"
echo "│  Username : admin                           │"
echo "│  Password : $ARGOCD_PASS"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "Press Ctrl+C to stop."

# Keep port-forward alive; clean up on exit
trap "kill $PF_PID 2>/dev/null; echo 'Port-forward closed.'" EXIT
wait "$PF_PID"
