# oracle-cloud-free-infra

OCI Always Free tier infrastructure for [turinghatch.com](https://turinghatch.com) — single-node k3s on ARM, Envoy Gateway, PostgreSQL, placeholder backend and frontend (nginx:alpine — replace with real images).

---

## What is actually running today

Verified state as of 2026-05-29.

| Component | Status | Detail |
|-----------|--------|--------|
| Public URL | Working | `https://turinghatch.com` → HTTP 200 |
| HTTP→HTTPS redirect | Working | `http://turinghatch.com` → 301 |
| `www` redirect | Working | `https://www.turinghatch.com` → 301 → apex |
| TLS certificate | Valid | Let's Encrypt production, expires 2026-08-27, auto-renews |
| k3s cluster | Running | 1 node, all system pods healthy |
| Envoy Gateway | Running | 1/1 pod, hostNetwork, ports 10080/10443 |
| cert-manager | Running | v1.16.2, Gateway API mode enabled |
| frontend pod | Running | nginx:alpine placeholder, 1 replica |
| backend pod | Running | nginx:alpine placeholder, 1 replica |
| postgres pod | Running | postgres:16-alpine, 1 replica, data on block volume |
| Block volume backup | Active | OCI Bronze policy assigned (daily incremental) |

---

## Architecture

```
Internet
    │
    ▼ DNS A: turinghatch.com → 140.245.107.169
    │
    ▼
[Reserved Public IP: 140.245.107.169]
    │  attached directly to VM VNIC
    │  (NLB also provisioned; see "Known issues")
    │
    ▼
[ARM VM: 4 OCPU / 24 GB RAM — Ubuntu 22.04.5 LTS — k3s v1.35.5]
    │
    ├── iptables PREROUTING (enp0s6):
    │       TCP 80  → redirect → 10080
    │       TCP 443 → redirect → 10443
    │
    ▼
[Envoy Gateway — hostNetwork — ports 10080 / 10443]
    │  TLS terminates here (cert-manager + Let's Encrypt)
    │
    ├── HTTP listener (port 80)
    │       ALL traffic → 301 redirect → HTTPS
    │
    ├── HTTPS listener (port 443, *.turinghatch.com)
    │       www.turinghatch.com → 301 redirect → apex
    │
    └── HTTPS-apex listener (port 443, turinghatch.com)
            /api/*    → backend-svc:80
            /*        → frontend-svc:80
                           │
                      [PostgreSQL 16]
                           │
                [150 GB Block Volume /mnt/app-data]
                           │
                [OCI Bronze Backup Policy — daily snapshots]
```

---

## OCI resources provisioned (Terraform-managed)

| Resource | Name | Notes |
|----------|------|-------|
| VCN | main-vcn | 10.0.0.0/16 |
| Public subnet | public-subnet | 10.0.1.0/24 |
| Internet gateway | main-igw | Default route 0.0.0.0/0 |
| Route table | public-route-table | All traffic via IGW |
| Security list | public-security-list | Ingress: 22/tcp (home IP only), 80/tcp, 443/tcp, ICMP type 3; egress: all |
| ARM VM | k3s-node | VM.Standard.A1.Flex, 4 OCPU, 24 GB, 50 GB boot |
| Block volume | app-data-volume | 150 GB, paravirtualized attachment |
| Volume backup policy | Bronze | Assigned to block volume; daily incremental (7-day) + monthly full |
| Reserved public IP | nlb-reserved-ip | 140.245.107.169 — currently on VM VNIC, not NLB (see Known Issues) |
| Network Load Balancer | main-nlb | Provisioned with backends VM:80 and VM:443 — not in active traffic path |

**Always Free tier usage:**

| Resource | Free limit | Used |
|----------|-----------|------|
| ARM A1 compute | 4 OCPU, 24 GB | 4 OCPU, 24 GB (1 VM) |
| Block volume storage | 200 GB total | 200 GB (150 GB data + 50 GB boot) |
| Network Load Balancer | 1 | 1 |
| Reserved Public IP | 2 | 1 |

---

## Cluster capacity

Node: k3s-node (Ubuntu 22.04.5 LTS, kernel 6.8.0-1044-oracle, aarch64)

```
Total:    4 CPU   /  24 GB RAM
Reserved: 540m CPU (13%)  /  1068 Mi RAM (4%)   ← requests
Limits:   1200m CPU (30%) /  2602 Mi RAM (10%)
In use:   ~76m CPU (1%)   /  ~1401 Mi RAM (5%)  ← live usage
Available for apps: ~3.9 CPU  /  ~22.5 GB RAM
Max pods: 110
```

Disk:
- Boot (`/dev/sda`, 50 GB): 10 GB used, 39 GB free
- Block volume (`/dev/sdb`, 150 GB → `/mnt/app-data`): 46 MB used, 140 GB free

---

## Reboot and failure behaviour

### VM reboots

Everything survives a clean reboot automatically:

| Component | How it survives |
|-----------|----------------|
| k3s | systemd service, `enabled` → auto-starts |
| Block volume | `/etc/fstab` entry with `_netdev,nofail` → mounts before k3s starts |
| iptables rules | `netfilter-persistent`, rules saved to `/etc/iptables/rules.v4` |
| All k8s pods | k3s restarts them; restart policy = Always |
| Postgres data | Block volume remounts; StatefulSet PVC/PV persist in k3s etcd (stored on boot disk) |
| TLS secret | Stored in k3s etcd on boot disk; persists |
| cert-manager | Checks renewal daily; auto-renews 45 days before expiry |

Expected downtime on reboot: ~60–90 seconds (k3s start + pod readiness).

### Postgres pod deleted

If the pod is deleted (`kubectl delete pod postgres-0`), k3s recreates it immediately. The PVC (`postgres-data-postgres-0`) and PV are not deleted — the new pod remounts the same block volume path. **Data is intact.**

### PVC deleted

**DANGEROUS.** The `local-path` StorageClass has `reclaimPolicy: Delete`. If the PVC is deleted, the provisioner deletes the directory `/mnt/app-data/local-path-provisioner/pvc-xxx/` on the block volume. **Postgres data is gone from the filesystem.** The block volume itself remains; an OCI snapshot backup may allow recovery (see below).

### Block volume deleted via OCI console

Data is gone unless an OCI backup exists. Recovery from backup: see Runbook section below.

---

## Postgres backup

**What is configured:** OCI Bronze volume backup policy on the 150 GB block volume.
- Daily incremental backups, retained for 7 days
- Monthly full backup

**What this covers:** a point-in-time snapshot of the entire block volume filesystem, including the postgres data directory. This is a crash-consistent backup (not a logical `pg_dump`).

**What is NOT configured:** `pg_dump` / logical SQL backup. This means you cannot restore a single table or database easily — only the whole volume. For production use, add a `pg_dump` CronJob.

**Restore procedure:** see Runbook below.

---

## Is this production-ready?

**Short answer:** The infrastructure layer is solid and working. The application layer has placeholders. Several things need attention before you go live with real traffic.

### Ready
- HTTPS with valid Let's Encrypt cert, auto-renews
- Postgres data on dedicated block volume with daily OCI backup
- Block volume survives VM reboots and pod restarts
- All iptables and mount rules persist across reboots
- Gateway routing for `/api/*` (backend) and `/*` (frontend) is wired correctly
- Cluster has ~22 GB RAM and ~3.9 CPU free for real workloads

### Not ready / action required before go-live

| Issue | Risk | Fix |
|-------|------|-----|
| frontend/backend images are `nginx:alpine` (placeholders) | App doesn't work | Replace with real images in `k8s/apps/*/deployment.yaml` |
| Only crash-consistent (volume snapshot) backup for Postgres | Can't restore to arbitrary point; can't restore a single table | Add `pg_dump` CronJob to object storage |
| `local-path` reclaimPolicy: Delete | Accidental PVC deletion destroys data | Consider a custom StorageClass with `reclaimPolicy: Retain` for Postgres |
| Single node, single VM | VM reboot = full downtime | Acceptable for free tier; document SLA accordingly |
| NLB not in traffic path (terraform state drift) | NLB is provisioned but unused; reserved IP is on VM directly | See Known Issues; run `terraform apply` after `terraform state rm` to re-align OR leave as-is (works fine) |
| Postgres secret is a base64-encoded placeholder | Security | Set a real password: `echo -n 'your-password' \| base64` |
| SSH port 22 open to your home IP only | SSH locked down | Good; verify `your_home_ip` in tfvars is still your current IP |

---

## Prerequisites

Local machine:

```bash
# Terraform >= 1.5
brew tap hashicorp/tap && brew install hashicorp/tap/terraform

# OCI CLI
brew install oci-cli

# Verify
terraform version    # >= 1.5
oci --version
```

---

## Step 1 — OCI Console setup (~15 min)

### 1.1 Collect OCIDs

| What | Where to find it |
|------|-----------------|
| Tenancy OCID | Top-right avatar → "Tenancy: [name]" → copy OCID |
| User OCID | Top-right avatar → "My Profile" → copy OCID |
| Compartment OCID | Identity & Security → Compartments → use root (= tenancy OCID) or create one |

### 1.2 Create API signing key

1. Top-right avatar → **My Profile** → **API Keys** → **Add API Key** → **Generate API Key Pair**
2. Download private key `.pem`, note fingerprint
3. `mkdir -p ~/.oci && mv ~/Downloads/oci_api_key.pem ~/.oci/oci_api_key.pem && chmod 600 ~/.oci/oci_api_key.pem`

### 1.3 Find Ubuntu ARM image OCID (region-specific)

1. Compute → Instances → Create Instance → Change image → Platform Images → Canonical Ubuntu 22.04 aarch64
2. Copy the Image OCID, then cancel the wizard

### 1.4 Find availability domain

Same "Create Instance" wizard → note the Availability Domain name (e.g., `GrCH:AP-SINGAPORE-1-AD-1`). Cancel.

---

## Step 2 — Local CLI setup (~10 min)

```bash
# Configure OCI CLI
oci setup config   # paste tenancy OCID, user OCID, region, fingerprint, private key path

# Verify
oci iam region list

# SSH keypair for the VM
ssh-keygen -t ed25519 -f ~/.ssh/oci_arm_key -C "oci-arm-instance"
cat ~/.ssh/oci_arm_key.pub   # needed for terraform.tfvars
```

---

## Step 3 — Configure Terraform

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
```

Required values:
- `tenancy_ocid`, `user_ocid`, `fingerprint`, `private_key_path`
- `region` (e.g., `ap-singapore-1`)
- `compartment_ocid`
- `availability_domain`, `arm_image_ocid`
- `ssh_public_key` (content of `~/.ssh/oci_arm_key.pub`)
- `your_home_ip` (CIDR, e.g., `1.2.3.4/32` — run `curl ifconfig.me`)

---

## Step 4 — Provision infrastructure

```bash
cd terraform/
terraform init
terraform plan    # ~15 resources to create
terraform apply   # ~5 min

terraform output
# nlb_public_ip      → use for DNS A records
# instance_public_ip → SSH target
```

> **Note:** The `reserved_ips` block in the NLB resource has `lifecycle { ignore_changes = [reserved_ips] }`. This is intentional — it works around an OCI terraform provider bug (issues #1708, #1893) where re-applying silently disassociates the reserved IP from the NLB.

---

## Step 5 — DNS

Point `turinghatch.com` and `www.turinghatch.com` A records to `nlb_public_ip`. TTL 300 to start.

---

## Step 6 — Bootstrap the VM

```bash
SSH_IP=$(cd terraform && terraform output -raw instance_public_ip)

scp -i ~/.ssh/oci_arm_key -r scripts/ ubuntu@${SSH_IP}:~/
ssh -i ~/.ssh/oci_arm_key ubuntu@${SSH_IP}

# Wait for cloud-init
sudo cloud-init status --wait

# Run in order:
sudo bash scripts/05-mount-block-volume.sh
NLB_PUBLIC_IP="<nlb_public_ip>" sudo bash scripts/01-install-k3s.sh
bash scripts/02-install-helm-tools.sh
bash scripts/03-install-envoy-gateway.sh
bash scripts/04-install-cert-manager.sh
```

---

## Step 7 — Deploy applications

Edit before applying:
- `k8s/gateway/clusterissuer.yaml` — set your email
- `k8s/apps/postgres/secret.yaml` — set base64-encoded credentials
- `k8s/apps/backend/deployment.yaml` — set real image
- `k8s/apps/frontend/deployment.yaml` — set real image

```bash
kubectl apply -f k8s/gateway/
kubectl apply -f k8s/apps/namespace.yaml
kubectl apply -f k8s/apps/postgres/
kubectl apply -f k8s/apps/backend/
kubectl apply -f k8s/apps/frontend/
```

Then create the ReferenceGrant (required for cross-namespace TLS secret access — Gateway is in `envoy-gateway-system`, TLS secret is in `turinghatch`):

```bash
kubectl apply -f k8s/gateway/referencegrant.yaml
```

Verify cert issuance:

```bash
kubectl -n turinghatch describe certificate turinghatch-tls
# Status: Ready = True, Message: Certificate is up to date
```

---

## Verification

```bash
curl -I http://turinghatch.com       # 301 Moved Permanently → https://turinghatch.com/
curl -I https://turinghatch.com      # 200 OK
curl -I https://www.turinghatch.com  # 301 → https://turinghatch.com/

kubectl get pods -A                  # All Running
kubectl get certificate -n turinghatch   # READY = True
```

---

## Repository structure

```
oracle-cloud-free-infra/
├── terraform/
│   ├── main.tf                      # Provider + module wiring
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── modules/
│       ├── network/                 # VCN, subnet, security list, IGW, route table
│       ├── compute/                 # ARM A1 VM, cloud-init bootstrap
│       ├── storage/                 # 150 GB block volume, paravirtualized attach, Bronze backup policy
│       └── load-balancer/           # NLB, reserved IP, backend sets + listeners (80, 443)
├── scripts/                         # Run on VM in order (01 → 05)
│   ├── 01-install-k3s.sh
│   ├── 02-install-helm-tools.sh
│   ├── 03-install-envoy-gateway.sh
│   ├── 04-install-cert-manager.sh
│   └── 05-mount-block-volume.sh
└── k8s/
    ├── gateway/
    │   ├── gatewayclass.yaml        # GatewayClass referencing EnvoyProxy config
    │   ├── gateway.yaml             # Gateway: http, https (*.turinghatch.com), https-apex (turinghatch.com)
    │   ├── envoyproxy-config.yaml   # hostNetwork:true, replicas:1, ClusterIP service
    │   ├── clusterissuer.yaml       # Let's Encrypt staging + production ClusterIssuers
    │   └── referencegrant.yaml      # Allows Gateway (envoy-gateway-system) to read TLS secret (turinghatch)
    └── apps/
        ├── namespace.yaml           # turinghatch namespace
        ├── postgres/                # StatefulSet, headless + clusterIP services, Secret, 100Gi PVC
        ├── backend/                 # Deployment (nginx:alpine placeholder), Service, HTTPRoute (/api/*)
        └── frontend/                # Deployment (nginx:alpine placeholder), Service, HTTPRoutes, Certificate
```

---

## Runbook

### SSH access

```bash
ssh -i ~/.ssh/oci_arm_key ubuntu@140.245.107.169
```

### Check cluster health

```bash
kubectl get nodes
kubectl get pods -A
kubectl top node
kubectl top pod -A
```

### Check certificate status

```bash
kubectl -n turinghatch describe certificate turinghatch-tls
kubectl -n turinghatch get certificaterequest,order,challenge
```

If a challenge is stuck or failing:

```bash
kubectl -n turinghatch describe challenge   # look at Status.Reason
```

### Force cert renewal

```bash
kubectl -n turinghatch delete secret turinghatch-tls
# cert-manager detects the missing secret and re-issues within ~60 seconds
```

### Restart a pod

```bash
kubectl -n turinghatch rollout restart deployment/frontend
kubectl -n turinghatch rollout restart deployment/backend
kubectl -n turinghatch delete pod postgres-0   # StatefulSet recreates it; data is on block volume
```

### View application logs

```bash
kubectl -n turinghatch logs deployment/frontend
kubectl -n turinghatch logs deployment/backend
kubectl -n turinghatch logs postgres-0
```

### Connect to Postgres

```bash
kubectl -n turinghatch exec -it postgres-0 -- psql -U appuser -d appdb
```

### Deploy a new image

```bash
kubectl -n turinghatch set image deployment/frontend frontend=myrepo/frontend:v1.2.3
kubectl -n turinghatch set image deployment/backend backend=myrepo/backend:v1.2.3
kubectl -n turinghatch rollout status deployment/frontend
```

### Check iptables rules (on VM)

```bash
sudo iptables -t nat -L PREROUTING -n -v
# Should see: REDIRECT tcp enp0s6 dpt:80 → 10080
#             REDIRECT tcp enp0s6 dpt:443 → 10443
#             REDIRECT tcp cni0 dst:10.0.1.252 dpt:80 → 10080
#             REDIRECT tcp cni0 dst:10.0.1.252 dpt:443 → 10443

sudo iptables -L INPUT -n -v | head -10
# Should see: ACCEPT tcp dpt:10080 (before kube-router REJECT)
#             ACCEPT tcp dpt:10443 (before kube-router REJECT)
```

If rules are missing after reboot:

```bash
sudo netfilter-persistent reload
```

### Restore Postgres from OCI block volume backup

This restores the entire block volume to a previous snapshot state.

1. In OCI Console → **Block Storage** → **Block Volume Backups** → find `app-data-volume` backups
2. Click the desired backup → **Restore Block Volume** → give it a name → Create
3. Detach the current block volume from the VM:
   - OCI Console → Compute → Instances → k3s-node → Attached Block Volumes → Detach `app-data-volume`
   - Or: `oci compute volume-attachment detach --volume-attachment-id <ocid>`
4. Stop Postgres so it releases the volume:
   ```bash
   kubectl -n turinghatch scale statefulset postgres --replicas=0
   ```
5. Unmount the volume on the VM:
   ```bash
   sudo umount /mnt/app-data
   ```
6. Attach the restored volume to the VM (paravirtualized attachment) in OCI Console
7. The new volume appears as `/dev/sdb` (verify with `lsblk`). Mount it:
   ```bash
   sudo mount /dev/sdb /mnt/app-data
   ```
8. Scale Postgres back up:
   ```bash
   kubectl -n turinghatch scale statefulset postgres --replicas=1
   kubectl -n turinghatch get pod postgres-0 -w
   ```
9. Update `/etc/fstab` UUID if the new volume has a different UUID:
   ```bash
   sudo blkid /dev/sdb   # get UUID
   sudo vim /etc/fstab   # update UUID line
   ```

> Note: The PVC/PV in Kubernetes points to a path on /mnt/app-data. As long as the path `/mnt/app-data/local-path-provisioner/pvc-xxx/pgdata` exists on the restored volume, Postgres will find its data.

### Terraform re-apply after drift

The reserved IP (140.245.107.169) is currently attached to the VM VNIC directly (not the NLB — see Known Issues). Terraform state shows it as NLB-attached. Running `terraform apply` may attempt to modify the NLB, but the `lifecycle { ignore_changes = [reserved_ips] }` block prevents it from touching the IP assignment.

If you need to re-provision the NLB:

```bash
terraform -chdir=terraform apply -replace=module.load_balancer.oci_network_load_balancer_network_load_balancer.main
```

Then verify the reserved IP is still reachable:

```bash
curl -I https://turinghatch.com
```

---

## Known issues

### 1. Reserved IP is on VM VNIC, not NLB (terraform state drift)

**What happened:** During setup, the OCI terraform provider bug (#1708, #1893) caused the reserved IP to be disassociated from the NLB on multiple `terraform apply` runs. As a workaround, the reserved IP was manually assigned to the VM's VNIC primary private IP via OCI CLI. The NLB was later recreated, and terraform state thinks the IP is on the NLB — but the actual OCI state has it on the VM VNIC.

**Verified via OCI CLI:**
```
"assignedEntityType": "PRIVATE_IP"   ← VM's VNIC private IP, not NLB
"state": "ASSIGNED"
```

**Effect:** Traffic flows directly VM → iptables → Envoy, bypassing the NLB. SSH also goes directly to the VM. The NLB exists and its backends are configured (VM:80 and VM:443), but it is not in the active traffic path.

**Risk:** The current setup works. If the VM VNIC changes (e.g., VM is replaced by terraform), the reserved IP would need to be manually re-assigned.

**Fix (optional):** To put the NLB back in the traffic path, use OCI CLI to move the reserved IP from the VM VNIC back to the NLB's frontend private IP.

### 2. No logical (pg_dump) Postgres backup

Only the block volume snapshot (OCI Bronze policy) is configured. This is a crash-consistent filesystem-level backup, not a logical SQL dump. You cannot restore a single database or table.

**Fix:** Add a Kubernetes CronJob that runs `pg_dump` and uploads to OCI Object Storage.

### 3. Single node, no HA

One VM. Any reboot, crash, or OCI capacity event causes full downtime. k3s sets `recovery_action = "RESTORE_INSTANCE"` which asks OCI to restore the VM after a capacity event, but this takes time.

### 4. local-path StorageClass reclaimPolicy: Delete

If the Postgres PVC is accidentally deleted, the data directory on the block volume is immediately deleted. The OCI block volume snapshot is the only recovery path.

---

## Lessons learned

These are real issues encountered during setup and the exact fixes applied.

### 1. OCI NLB reserved_ips terraform provider bug

**Issue:** Terraform provider bug #1708 / #1893. Every time `terraform apply` runs on an NLB resource that has a `reserved_ips` block, the provider silently removes the public IP association. The IP state changes from `ASSIGNED` to `AVAILABLE`. The NLB gets a new ephemeral IP and the reserved IP floats.

**Fix:** Add `lifecycle { ignore_changes = [reserved_ips] }` to the NLB resource. This tells terraform to stop managing the IP association after creation. The NLB resource in `terraform/modules/load-balancer/main.tf` has this in place.

**Recovery when IP is disassociated:** Use OCI CLI:
```bash
oci network public-ip update \
  --public-ip-id "<reserved-ip-ocid>" \
  --private-ip-id "<vm-vnic-private-ip-ocid>"
```

### 2. cert-manager Gateway API requires --enable-gateway-api flag

By default, cert-manager ignores Gateway API resources even if the CRDs are installed. The `--enable-gateway-api` feature gate must be added to the cert-manager controller deployment args:

```bash
kubectl -n cert-manager patch deployment cert-manager --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'
```

This is now in `scripts/04-install-cert-manager.sh`.

### 3. Gateway API cross-namespace TLS secret requires ReferenceGrant

The Gateway resource lives in `envoy-gateway-system`. The TLS certificate secret lives in `turinghatch`. Without a `ReferenceGrant`, Envoy Gateway rejects the HTTPS listeners with `Certificate ref to secret turinghatch/turinghatch-tls not permitted by any ReferenceGrant`. Port 10443 never opens.

Fix: `k8s/gateway/referencegrant.yaml` — a ReferenceGrant in the `turinghatch` namespace that allows the Gateway in `envoy-gateway-system` to read the secret.

Symptom: `https://` returns "Connection refused" even though cert-manager says the cert is Ready.

### 4. kube-router REJECT rule blocks Envoy ports in INPUT chain

kube-router (k3s's NetworkPolicy engine) inserts a blanket `REJECT all -- icmp-host-prohibited` rule in the INPUT chain. This rule sits BEFORE UFW's rules. After iptables redirects port 80 → 10080 in PREROUTING, the packet hits INPUT on port 10080 — but UFW only allows port 80. kube-router's REJECT fires before UFW can evaluate it.

Fix: Insert ACCEPT rules for ports 10080 and 10443 into INPUT before kube-router's REJECT:

```bash
sudo iptables -I INPUT -p tcp --dport 10080 -m state --state NEW -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 10443 -m state --state NEW -j ACCEPT
sudo netfilter-persistent save
```

These rules are now in `/etc/iptables/rules.v4` and survive reboots.

### 5. iptables PREROUTING must be scoped to external interface

A PREROUTING REDIRECT for ports 80/443 without an `-i` interface filter applies to ALL interfaces, including `cni0` (pod network). This causes pods trying to reach external HTTPS servers (e.g., Let's Encrypt, Cloudflare) to have their traffic intercepted and redirected to local Envoy — which obviously has no route to `acme-v02.api.letsencrypt.org`. cert-manager's ACME HTTP client fails silently.

Fix: Scope the PREROUTING rules to the external interface only:

```bash
sudo iptables -t nat -A PREROUTING -i enp0s6 -p tcp --dport 80 -j REDIRECT --to-port 10080
sudo iptables -t nat -A PREROUTING -i enp0s6 -p tcp --dport 443 -j REDIRECT --to-port 10443
```

The `cni0` redirect rules (for hairpin — see next item) are also scoped: `-i cni0 -d 10.0.1.252`.

### 6. OCI NLB hairpin NAT — cert-manager self-check fails

cert-manager's ACME HTTP-01 solver self-check resolves `turinghatch.com` → NLB IP → NLB backend → VM. But OCI NLB does not support hairpin connections: when the backend VM is the same machine that originates the request, the NLB drops it. cert-manager's self-check times out.

Fix in two parts:
1. CoreDNS custom server block: overrides `turinghatch.com` to resolve to the VM's private IP (`10.0.1.252`) for in-cluster lookups:
   ```yaml
   # kubectl apply -n kube-system configmap coredns-custom
   turinghatch.com:53 {
       hosts {
           10.0.1.252 turinghatch.com
           10.0.1.252 www.turinghatch.com
           fallthrough
       }
       cache 30
   }
   ```
2. iptables PREROUTING for `cni0` → `10.0.1.252` redirects port 80 → 10080 and 443 → 10443. This makes the internal hairpin path work.

### 7. Envoy Gateway hostNetwork with replicas > 1

With `hostNetwork: true`, Envoy binds port 10080 and 10443 directly on the host. Only one Envoy pod can run on a single-node cluster — the second pod fails to schedule with "didn't have free ports for the requested pod ports."

Envoy Gateway's default replica count is 2. Set it to 1 in `k8s/gateway/envoyproxy-config.yaml`:

```yaml
envoyDeployment:
  replicas: 1
```

If a rolling update creates a new ReplicaSet that can't schedule, rollback to clear it:

```bash
kubectl -n envoy-gateway-system rollout undo deployment/envoy-envoy-gateway-system-main-gateway-<hash>
```

### 8. CoreDNS custom server block uses .server extension, not .override

The `coredns-custom` ConfigMap key must end in `.server` to create a new server block in CoreDNS. Using `.override` fails with `plugin/hosts: this plugin can only be used once per Server Block` because CoreDNS already has a `hosts` plugin in the main block.

Correct key: `turinghatch.server`  
Wrong key: `turinghatch.override`
