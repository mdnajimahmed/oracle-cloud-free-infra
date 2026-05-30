terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# Reserved Public IP — free when attached to a running resource
# This IP never changes, even if you rebuild the VM or the NLB
resource "oci_core_public_ip" "nlb" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "nlb-reserved-ip"
}

# Network Load Balancer (always-free: 1 NLB)
# NLB operates at L3/L4 (TCP/UDP) — no TLS termination here
# SSL is terminated downstream at Envoy Gateway
resource "oci_network_load_balancer_network_load_balancer" "main" {
  compartment_id = var.compartment_ocid
  subnet_id      = var.subnet_id
  display_name   = "main-nlb"
  is_private     = false

  reserved_ips {
    id = oci_core_public_ip.nlb.id
  }

  # OCI terraform provider bug: re-applying clears the reserved IP association.
  # Prevent terraform from touching reserved_ips after initial creation.
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
