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
    source_type              = "image"
    source_id                = var.arm_image_ocid
    boot_volume_size_in_gbs  = var.boot_volume_size_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "primary-vnic"
    assign_public_ip = true  # Ephemeral IP for SSH during setup; NLB handles production traffic
    hostname_label   = "k3s-node"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/cloud-init.yaml"))
  }

  availability_config {
    recovery_action = "RESTORE_INSTANCE"  # Auto-restore if OCI reclaims during capacity event
  }

  # Prevent accidental replacement — changing this would destroy and recreate the VM
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,  # Allow image updates without destroying instance
    ]
  }
}

# Fetch the private IP of the instance's primary VNIC
data "oci_core_vnic_attachments" "arm" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.arm.id
}

data "oci_core_vnic" "primary" {
  vnic_id = data.oci_core_vnic_attachments.arm.vnic_attachments[0].vnic_id
}
