output "nlb_id" {
  value = oci_network_load_balancer_network_load_balancer.main.id
}

output "nlb_public_ip" {
  description = "The static reserved public IP attached to the NLB. Point all DNS A records here."
  value       = oci_core_public_ip.nlb.ip_address
}
