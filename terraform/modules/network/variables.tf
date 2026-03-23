variable "compartment_ocid" {
  type = string
}

variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "your_home_ip" {
  description = "Your IP in CIDR notation to restrict SSH and k8s API access."
  type        = string
  default     = "0.0.0.0/0"
}
