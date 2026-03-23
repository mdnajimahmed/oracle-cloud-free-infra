output "instance_id" {
  value = oci_core_instance.arm.id
}

output "instance_public_ip" {
  value = data.oci_core_vnic.primary.public_ip_address
}

output "instance_private_ip" {
  value = data.oci_core_vnic.primary.private_ip_address
}
