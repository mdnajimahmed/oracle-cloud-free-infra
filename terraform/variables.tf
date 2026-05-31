# ─── OCI Authentication ─────────────────────────────────────────────────────

variable "tenancy_ocid" {
  description = "OCID of your OCI tenancy. Found at: Profile → Tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of your OCI user. Found at: Profile → My Profile"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API signing key. Found when creating the API key."
  type        = string
}

variable "private_key" {
  description = "Contents of your OCI API private key PEM file. Set via TF_VAR_private_key env var."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OCI region identifier (e.g., us-ashburn-1, ap-singapore-1)"
  type        = string
}

# ─── Tenancy / Compartment ───────────────────────────────────────────────────

variable "compartment_ocid" {
  description = "OCID of the compartment to create resources in. Can be root (= tenancy OCID) or a child compartment."
  type        = string
}

# ─── Compute ─────────────────────────────────────────────────────────────────

variable "availability_domain" {
  description = "Availability domain name (e.g., GrCH:US-ASHBURN-AD-1). Found in Console → Compute → Create Instance."
  type        = string
}

variable "arm_image_ocid" {
  description = "OCID of the Canonical Ubuntu 22.04 aarch64 image for your region. Found in Console → Compute → Create Instance → Change Image."
  type        = string
}

variable "ssh_public_key" {
  description = "Contents of your SSH public key file (e.g., ~/.ssh/oci_arm_key.pub). Used to SSH into the instance."
  type        = string
}

variable "instance_ocpus" {
  description = "Number of OCPUs for the ARM A1 instance. Free tier allows up to 4."
  type        = number
  default     = 4
}

variable "instance_memory_gbs" {
  description = "Memory in GB for the ARM A1 instance. Free tier allows up to 24."
  type        = number
  default     = 24
}

variable "boot_volume_size_gbs" {
  description = "Boot volume size in GB. Keep small — app data goes on the dedicated block volume."
  type        = number
  default     = 50
}

# ─── Networking ──────────────────────────────────────────────────────────────

variable "vcn_cidr" {
  description = "CIDR block for the Virtual Cloud Network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "your_home_ip" {
  description = "Your home/office IP address with CIDR (e.g., 1.2.3.4/32). Used to restrict SSH and k8s API access."
  type        = string
  default     = "0.0.0.0/0"  # Change to your IP for better security
}
