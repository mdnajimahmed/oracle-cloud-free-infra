# oracle-cloud-free-infra

OCI always-free tier infrastructure for [turinghatch.com](https://turinghatch.com) — single-node k3s on ARM, Envoy Gateway, PostgreSQL, Java backend, React frontend.

## Architecture

```
Internet
    │
    ▼
[DNS A record → turinghatch.com]
    │
    ▼
[OCI Network Load Balancer]  ← Reserved static public IP (free)
    │  TCP passthrough port 80 + 443
    ▼
[ARM VM: 4 OCPU / 24GB RAM — Ubuntu 22.04 + k3s]
    │
    └── [Envoy Gateway]  ← SSL terminates here (cert-manager + Let's Encrypt)
              │
          [HTTPRoutes]
              │
        ┌─────┴─────┐
        │             │
    [React]    [Java Backend]
                      │
                 [PostgreSQL]
                      │
                 [200GB Block Volume + 5 daily backups]
```

**Free tier resources used:**

| Resource | Limit | Used |
|----------|-------|------|
| ARM A1 compute | 4 OCPU, 24GB | 4 OCPU, 24GB (1 VM) |
| Block Volume | 200GB | 200GB (1 volume) |
| Block Volume backups | 5 | 5 daily (Bronze policy) |
| Network Load Balancer | 1 | 1 |
| Reserved Public IP | 2 | 1 (on NLB) |

---

## Prerequisites

Install these on your local machine:

```bash
# Terraform
brew tap hashicorp/tap && brew install hashicorp/tap/terraform

# OCI CLI
brew install oci-cli

# Verify
terraform version
oci --version
```

---

## Step 1 — OCI Console Setup (~15 min)

Collect several values from the OCI Console before running Terraform.

### 1.1 Sign In and Note Your Region

Go to [cloud.oracle.com](https://cloud.oracle.com) and sign in. Your region is visible in the URL and top-right (e.g., `us-ashburn-1`).

### 1.2 Collect OCIDs

| What | Where to find it |
|------|-----------------|
| **Tenancy OCID** | Top-right avatar → "Tenancy: [name]" → copy OCID |
| **User OCID** | Top-right avatar → "My Profile" → copy OCID |
| **Compartment OCID** | Left menu → Identity & Security → Compartments → use root (= tenancy OCID) or create `free-infra` |

### 1.3 Create API Signing Key

This is how Terraform authenticates to OCI.

1. Top-right avatar → **My Profile** → **API Keys** → **Add API Key**
2. Select **Generate API Key Pair**
3. Download the **private key** `.pem` file and note the **fingerprint**
4. Run locally:
   ```bash
   mkdir -p ~/.oci
   mv ~/Downloads/oci_api_key.pem ~/.oci/oci_api_key.pem
   chmod 600 ~/.oci/oci_api_key.pem
   ```

### 1.4 Find Ubuntu ARM Image OCID (region-specific)

1. Left menu → **Compute** → **Instances** → **Create Instance**
2. Click **Change image** → **Platform Images** → **Canonical Ubuntu** → `22.04` → architecture `aarch64`
3. Copy the **Image OCID**
4. **Cancel** the wizard (don't create the instance)

### 1.5 Find Your Availability Domain

On the same "Create Instance" wizard, note the **Availability Domain** name (e.g., `GrCH:US-ASHBURN-AD-1`). Cancel when done.

---

## Step 2 — Local CLI Setup (~10 min)

```bash
# Configure OCI CLI (creates ~/.oci/config)
oci setup config
# Paste when prompted: tenancy OCID, user OCID, region, fingerprint, private key path

# Verify connection
oci iam region list

# Generate SSH keypair for the VM
ssh-keygen -t ed25519 -f ~/.ssh/oci_arm_key -C "oci-arm-instance"

# Copy your public key — needed for terraform.tfvars
cat ~/.ssh/oci_arm_key.pub
```

---

## Step 3 — Configure Terraform

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — fill in all the values collected above
```

Key values to fill in:
- `tenancy_ocid`, `user_ocid`, `fingerprint`, `region`
- `compartment_ocid`
- `availability_domain`, `arm_image_ocid`
- `ssh_public_key` (contents of `~/.ssh/oci_arm_key.pub`)
- `your_home_ip` — your IP in CIDR notation (e.g., `1.2.3.4/32`). Find it: `curl ifconfig.me`

---

## Step 4 — Provision Infrastructure

```bash
cd terraform/
terraform init
terraform plan   # Review: should show ~15 resources to create
terraform apply  # Takes ~5 min

# After apply, note the outputs:
terraform output
# nlb_public_ip      → point DNS A records here
# instance_public_ip → SSH to this during setup
# ssh_command        → ready-to-use SSH command
```

---

## Step 5 — DNS

In your domain registrar for `turinghatch.com`, add A records pointing to `nlb_public_ip`:

| Type | Host | Value |
|------|------|-------|
| A | @ | `<nlb_public_ip>` |
| A | www | `<nlb_public_ip>` |
| A | api | `<nlb_public_ip>` |

Set TTL to 300 seconds initially.

---

## Step 6 — Bootstrap the VM

```bash
# Get IPs from Terraform output
SSH_IP=$(cd terraform && terraform output -raw instance_public_ip)
NLB_IP=$(cd terraform && terraform output -raw nlb_public_ip)

# Copy scripts to the VM
scp -i ~/.ssh/oci_arm_key -r scripts/ ubuntu@${SSH_IP}:~/

# SSH in
ssh -i ~/.ssh/oci_arm_key ubuntu@${SSH_IP}

# Wait for cloud-init to finish (2-3 min after first boot)
sudo cloud-init status --wait

# Run scripts in order:
sudo bash scripts/05-mount-block-volume.sh                             # 1. Mount block volume
NLB_PUBLIC_IP="${NLB_IP}" sudo bash scripts/01-install-k3s.sh         # 2. Install k3s
bash scripts/02-install-helm-tools.sh                                  # 3. Install Helm
bash scripts/03-install-envoy-gateway.sh                               # 4. Install Envoy Gateway
bash scripts/04-install-cert-manager.sh                                # 5. Install cert-manager
```

---

## Step 7 — Deploy Applications

Edit these files before applying:
- `k8s/gateway/clusterissuer.yaml` — change `admin@turinghatch.com` to your email
- `k8s/apps/postgres/secret.yaml` — set real base64-encoded credentials (`echo -n "password" | base64`)
- `k8s/apps/backend/deployment.yaml` — set your actual container image
- `k8s/apps/frontend/deployment.yaml` — set your actual container image

Then apply:

```bash
kubectl apply -f k8s/gateway/
kubectl apply -f k8s/apps/namespace.yaml
kubectl apply -f k8s/apps/postgres/
kubectl apply -f k8s/apps/backend/
kubectl apply -f k8s/apps/frontend/
```

> **Tip:** `certificate.yaml` defaults to `letsencrypt-staging` to avoid rate limits while testing. Once everything works, change to `letsencrypt-prod` and delete the old secret so cert-manager re-issues.

---

## Verification

```bash
kubectl get nodes                                              # Node Ready
kubectl get pods -A                                           # All pods Running
kubectl describe certificate turinghatch-tls -n turinghatch  # Cert issued

curl -I http://turinghatch.com                                # 301 → HTTPS
curl -I https://turinghatch.com                               # 200, valid cert
curl -I https://api.turinghatch.com/actuator/health           # Backend healthy
```

---

## Repository Structure

```
oracle-cloud-free-infra/
├── terraform/
│   ├── main.tf                      # Provider + module wiring
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example     # Template — copy to terraform.tfvars
│   └── modules/
│       ├── network/                 # VCN, subnet, security list
│       ├── compute/                 # ARM A1 instance, cloud-init
│       ├── storage/                 # 200GB block volume + Bronze backup policy
│       └── load-balancer/           # NLB, reserved IP, listeners (80 + 443)
├── scripts/                         # Run on VM in order (01 → 05)
│   ├── 01-install-k3s.sh
│   ├── 02-install-helm-tools.sh
│   ├── 03-install-envoy-gateway.sh
│   ├── 04-install-cert-manager.sh
│   └── 05-mount-block-volume.sh
└── k8s/
    ├── gateway/                     # GatewayClass, Gateway, ClusterIssuer
    └── apps/
        ├── namespace.yaml
        ├── postgres/                # PostgreSQL 16 StatefulSet on block volume
        ├── backend/                 # Java backend Deployment + HTTPRoute
        └── frontend/                # React frontend Deployment + HTTPRoute + Certificate
```
