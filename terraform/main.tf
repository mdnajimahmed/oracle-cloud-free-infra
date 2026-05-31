terraform {
  required_version = "1.15.5"

  cloud {
    organization = "turinghatch"
    workspaces {
      name = "oracle-cloud-free-infra"
    }
  }

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

module "network" {
  source = "./modules/network"

  compartment_ocid = var.compartment_ocid
  vcn_cidr         = var.vcn_cidr
  subnet_cidr      = var.subnet_cidr
  your_home_ip     = var.your_home_ip
}

module "compute" {
  source = "./modules/compute"

  compartment_ocid     = var.compartment_ocid
  availability_domain  = var.availability_domain
  subnet_id            = module.network.subnet_id
  arm_image_ocid       = var.arm_image_ocid
  ssh_public_key       = var.ssh_public_key
  instance_ocpus       = var.instance_ocpus
  instance_memory_gbs  = var.instance_memory_gbs
  boot_volume_size_gbs = var.boot_volume_size_gbs
}

module "storage" {
  source = "./modules/storage"

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  instance_id         = module.compute.instance_id
}

module "load_balancer" {
  source = "./modules/load-balancer"

  compartment_ocid    = var.compartment_ocid
  subnet_id           = module.network.subnet_id
  instance_private_ip = module.compute.instance_private_ip
}
