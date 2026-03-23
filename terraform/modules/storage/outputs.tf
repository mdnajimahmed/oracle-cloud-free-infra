output "volume_id" {
  value = oci_core_volume.app_data.id
}

output "volume_attachment_device" {
  description = "The device path on the instance (paravirtualized volumes appear as /dev/sdb or /dev/oracleoci/oraclevdb)"
  value       = "/dev/sdb"
}
