# ── Non-sensitive static config (safe to commit) ─────────────────────────────
# Sensitive values (tenancy_ocid, user_ocid, fingerprint, compartment_ocid,
# private_key, ssh_public_key, your_home_ip) are injected via TF_VAR_*
# environment variables — set as GitHub Secrets in CI, or export locally.

region              = "ap-singapore-1"
availability_domain = "OzFE:AP-SINGAPORE-1-AD-1"

# Ubuntu 22.04 aarch64 — ap-singapore-1 (2026-02-28)
arm_image_ocid = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaa7xuwcdxhfc7qg6w27itolxfwqorqzptqqov3himjpnexboccm5a"

instance_ocpus       = 4
instance_memory_gbs  = 24
boot_volume_size_gbs = 50

vcn_cidr    = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"
