terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# Fetch OCI's predefined backup policies
data "oci_core_volume_backup_policies" "predefined" {}

# Pick the "Bronze" policy: 5 daily backups retained for 2 weeks
# Bronze is the lightest policy; perfect for always-free (5-backup limit)
locals {
  bronze_policy_id = [
    for p in data.oci_core_volume_backup_policies.predefined.volume_backup_policies :
    p.id if lower(p.display_name) == "bronze"
  ][0]
}

resource "oci_core_volume" "app_data" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = "app-data-volume"
  size_in_gbs         = 150

  # Free tier: 200GB total across ALL block volumes including boot volume.
  # Boot volume = 50GB, so data volume must be <= 150GB to stay within 200GB total.
}

# Paravirtualized attachment: better IOPS than iSCSI on ARM A1
resource "oci_core_volume_attachment" "app_data" {
  attachment_type = "paravirtualized"
  instance_id     = var.instance_id
  volume_id       = oci_core_volume.app_data.id
  display_name    = "app-data-attachment"
  is_read_only    = false
  is_shareable    = false

  # Wait for instance to be running before attaching
  depends_on = [oci_core_volume.app_data]
}

# Assign the Bronze backup policy (5 daily backups)
resource "oci_core_volume_backup_policy_assignment" "daily_backup" {
  asset_id  = oci_core_volume.app_data.id
  policy_id = local.bronze_policy_id
}
