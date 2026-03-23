#!/usr/bin/env bash
# Install k3s (single-node Kubernetes) on the OCI ARM instance.
# Prerequisites: cloud-init complete, block volume mounted at /mnt/app-data
#
# Usage: NLB_PUBLIC_IP="1.2.3.4" sudo bash scripts/01-install-k3s.sh
# Run as root.
set -euo pipefail

if [ -z "${NLB_PUBLIC_IP:-}" ]; then
  echo "ERROR: NLB_PUBLIC_IP environment variable is required."
  echo "Usage: NLB_PUBLIC_IP=\"<your-nlb-ip>\" sudo bash $0"
  exit 1
fi

# Private IP of this instance (used for k3s bind address)
PRIVATE_IP=$(hostname -I | awk '{print $1}')
LOCAL_PATH_DIR="/mnt/app-data/local-path-provisioner"

echo "Installing k3s..."
echo "  Private IP:    ${PRIVATE_IP}"
echo "  NLB Public IP: ${NLB_PUBLIC_IP}"
echo "  PVC storage:   ${LOCAL_PATH_DIR}"

# Install k3s:
# --disable traefik      → we use Envoy Gateway instead
# --disable servicelb    → NLB handles external traffic; klipper-lb would conflict
# --tls-san              → add NLB IP to API server cert so remote kubectl works
# --node-ip              → bind to private IP, not localhost
# --advertise-address    → advertise private IP to cluster
# --default-local-storage-path → point local-path-provisioner at block volume
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --disable servicelb \
  --tls-san ${NLB_PUBLIC_IP} \
  --tls-san ${PRIVATE_IP} \
  --node-ip ${PRIVATE_IP} \
  --advertise-address ${PRIVATE_IP} \
  --cluster-cidr 10.42.0.0/16 \
  --service-cidr 10.43.0.0/16 \
  --flannel-iface eth0 \
  --default-local-storage-path ${LOCAL_PATH_DIR}" sh -

echo "Waiting for k3s to be ready..."
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl wait --for=condition=Ready node --all --timeout=120s

# Set up kubeconfig for ubuntu user
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
# Replace 127.0.0.1 with private IP so it works from any process on the machine
sed -i "s/127.0.0.1/${PRIVATE_IP}/g" /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config
chmod 600 /home/ubuntu/.kube/config

echo ""
echo "k3s installed successfully!"
echo ""
echo "Node status:"
kubectl get nodes -o wide
echo ""
echo "To use kubectl from your laptop, copy the kubeconfig and replace the server IP:"
echo "  scp -i ~/.ssh/oci_arm_key ubuntu@<instance-ip>:~/.kube/config ~/.kube/oci-config"
echo "  Then update 'server: https://<private-ip>:6443' to 'server: https://${NLB_PUBLIC_IP}:6443'"
echo "  NOTE: you'll need to forward port 6443 on the NLB or SSH tunnel for remote kubectl"
