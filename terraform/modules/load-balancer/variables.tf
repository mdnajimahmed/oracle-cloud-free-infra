variable "compartment_ocid" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_private_ip" {
  description = "Private IP of the k3s instance. NLB forwards traffic here."
  type        = string
}
