output "nlb_public_ip" {
  description = "Static public IP of the Network Load Balancer. Point your DNS A records here."
  value       = module.load_balancer.nlb_public_ip
}

output "instance_public_ip" {
  description = "Ephemeral public IP of the compute instance. Use this for SSH during setup."
  value       = module.compute.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP of the compute instance within the VCN."
  value       = module.compute.instance_private_ip
}

output "ssh_command" {
  description = "Ready-to-use SSH command to connect to the instance."
  value       = "ssh -i ~/.ssh/oci_arm_key ubuntu@${module.compute.instance_public_ip}"
}
