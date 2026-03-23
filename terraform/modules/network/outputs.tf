output "vcn_id" {
  value = oci_core_vcn.main.id
}

output "subnet_id" {
  value = oci_core_subnet.public.id
}

output "subnet_cidr" {
  value = oci_core_subnet.public.cidr_block
}
