output "nlb_public_ip" {
  description = "Static reserved IP of the NLB. All DNS A records point here."
  value       = module.load_balancer.nlb_public_ip
}

output "instance_public_ip" {
  description = "Reserved public IP of the VM. Use for SSH and kubectl tunnel."
  value       = module.compute.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP of the VM within the VCN."
  value       = module.compute.instance_private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance."
  value       = "ssh -i ~/.ssh/oci_arm_key ubuntu@${module.compute.instance_public_ip}"
}
