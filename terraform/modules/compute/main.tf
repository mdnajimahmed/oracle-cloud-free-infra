terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_core_instance" "arm" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = "k3s-node"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gbs
  }

  source_details {
    source_type             = "image"
    source_id               = var.arm_image_ocid
    boot_volume_size_in_gbs = var.boot_volume_size_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "primary-vnic"
    assign_public_ip = false  # Reserved IP managed via oci_core_public_ip.vm below
    hostname_label   = "k3s-node"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/cloud-init.yaml"))
  }

  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }

  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
      create_vnic_details,  # IP assignment managed separately; prevents instance replacement
    ]
  }
}

# ── Reserved Public IP for SSH / kubectl access ───────────────────────────────
#
# Always reserved (never ephemeral) so the IP survives reboots and OCI
# maintenance events. Same pattern as the NLB IP — assigned via
# oci_core_public_ip.private_ip_id to bypass the OCI provider bug.

data "oci_core_vnic_attachments" "arm" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.arm.id
}

data "oci_core_vnic" "primary" {
  vnic_id = data.oci_core_vnic_attachments.arm.vnic_attachments[0].vnic_id
}

data "oci_core_private_ips" "vm_primary" {
  subnet_id  = var.subnet_id
  ip_address = data.oci_core_vnic.primary.private_ip_address
  depends_on = [oci_core_instance.arm]
}

resource "oci_core_public_ip" "vm" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "vm-reserved-ip"
  private_ip_id  = data.oci_core_private_ips.vm_primary.private_ips[0].id
}
