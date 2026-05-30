terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "main-vcn"
  dns_label      = "mainvcn"
}

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "main-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "public-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "public-security-list"

  # ── Egress: allow all outbound ──────────────────────────────────────────
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }

  # ── Ingress: HTTP ────────────────────────────────────────────────────────
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    description = "HTTP from internet (cert-manager ACME + HTTP→HTTPS redirect)"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # ── Ingress: HTTPS ───────────────────────────────────────────────────────
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS from internet"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # ── Ingress: SSH (restricted to your IP) ────────────────────────────────
  ingress_security_rules {
    protocol    = "6"
    source      = var.your_home_ip
    description = "SSH access"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # ── Ingress: k3s API server (restricted to your IP) ─────────────────────
  ingress_security_rules {
    protocol    = "6"
    source      = var.your_home_ip
    description = "k3s API server for remote kubectl"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # ── Ingress: Internal VCN traffic (all protocols) ───────────────────────
  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr
    description = "Allow all intra-VCN traffic"
  }

  # ── Ingress: ICMP path MTU discovery ────────────────────────────────────
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    description = "ICMP type 3 (destination unreachable) for path MTU discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }

  # ── Ingress: ICMP from VCN ───────────────────────────────────────────────
  ingress_security_rules {
    protocol    = "1"
    source      = var.vcn_cidr
    description = "ICMP from VCN"
    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = var.subnet_cidr
  display_name      = "public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.public.id]

  # Public subnet: instances can have public IPs
  prohibit_public_ip_on_vnic = false
}
