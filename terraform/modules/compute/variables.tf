variable "compartment_ocid" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "arm_image_ocid" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "instance_ocpus" {
  type    = number
  default = 4
}

variable "instance_memory_gbs" {
  type    = number
  default = 24
}

variable "boot_volume_size_gbs" {
  type    = number
  default = 50
}
