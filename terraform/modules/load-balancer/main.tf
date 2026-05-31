terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# ── Reserved Public IP ────────────────────────────────────────────────────────
#
# The reserved IP is managed HERE (oci_core_public_ip), NOT via the NLB's
# reserved_ips field. This bypasses a confirmed OCI provider bug (issue #1893)
# where the NLB Update API clears the IP association on every subsequent apply,
# even with lifecycle { ignore_changes = [reserved_ips] }.
#
# Fix: assign the reserved IP directly to the NLB's private IP OCID via
# oci_core_public_ip.private_ip_id. The oci_core_public_ip Update API is
# stable and Terraform enforces the association on every apply.

resource "oci_core_public_ip" "nlb" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "nlb-reserved-ip"
  private_ip_id  = data.oci_core_private_ips.nlb.private_ips[0].id
}

# Look up the NLB's private IP OCID after the NLB is created.
# The NLB gets a private IP in the subnet (e.g. 10.0.1.240); we find its OCID
# so we can assign the reserved public IP to it via oci_core_public_ip above.
data "oci_core_private_ips" "nlb" {
  subnet_id  = var.subnet_id
  ip_address = local.nlb_private_ip
  depends_on = [oci_network_load_balancer_network_load_balancer.main]
}

locals {
  # Extract the NLB's private (non-public) IP from the ip_addresses list
  nlb_private_ip = [
    for ip in oci_network_load_balancer_network_load_balancer.main.ip_addresses :
    ip.ip_address if !ip.is_public
  ][0]
}

# Network Load Balancer (always-free: 1 NLB)
# NLB operates at L3/L4 (TCP/UDP) — no TLS termination here.
# SSL is terminated downstream at Envoy Gateway.
#
# NOTE: no reserved_ips block here — the public IP is assigned via
# oci_core_public_ip.private_ip_id above. ignore_changes = [reserved_ips]
# suppresses drift warnings when OCI auto-populates that field.
resource "oci_network_load_balancer_network_load_balancer" "main" {
  compartment_id = var.compartment_ocid
  subnet_id      = var.subnet_id
  display_name   = "main-nlb"
  is_private     = false

  lifecycle {
    ignore_changes = [reserved_ips]
  }
}

# ── HTTP Backend Set (port 80) ────────────────────────────────────────────────

resource "oci_network_load_balancer_backend_set" "http" {
  name                     = "http-backends"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol           = "TCP"
    port               = 80
    interval_in_millis = 10000
    timeout_in_millis  = 3000
    retries            = 3
  }
}

resource "oci_network_load_balancer_backend" "http_vm" {
  backend_set_name         = oci_network_load_balancer_backend_set.http.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "vm-80"
  ip_address               = var.instance_private_ip
  port                     = 80
  is_backup                = false
  is_drain                 = false
  is_offline               = false
  weight                   = 1
}

resource "oci_network_load_balancer_listener" "http" {
  name                     = "http-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  default_backend_set_name = oci_network_load_balancer_backend_set.http.name
  port                     = 80
  protocol                 = "TCP"
}

# ── HTTPS Backend Set (port 443) ──────────────────────────────────────────────

resource "oci_network_load_balancer_backend_set" "https" {
  name                     = "https-backends"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol           = "TCP"
    port               = 443
    interval_in_millis = 10000
    timeout_in_millis  = 3000
    retries            = 3
  }
}

resource "oci_network_load_balancer_backend" "https_vm" {
  backend_set_name         = oci_network_load_balancer_backend_set.https.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "vm-443"
  ip_address               = var.instance_private_ip
  port                     = 443
  is_backup                = false
  is_drain                 = false
  is_offline               = false
  weight                   = 1
}

resource "oci_network_load_balancer_listener" "https" {
  name                     = "https-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  default_backend_set_name = oci_network_load_balancer_backend_set.https.name
  port                     = 443
  protocol                 = "TCP"
}
