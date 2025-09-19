# Ubuntu Server Minimal - Cloud Image Based Template
# ---
# Packer Template to create a minimal Ubuntu Server on Proxmox
# This template performs ONLY cloning with NO post-provisioning

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_node_name" {
  type      = string
  sensitive = true
}

variable "instance_username" {
  type      = string
  sensitive = true
  default   = "ubuntu"
}

variable "instance_password" {
  type      = string
  sensitive = true
}

variable "clone_vm" {
  type        = string
  description = "Name or ID of the cloud-init template to clone from"
  default     = "ubuntu24"
}

variable "template_id" {
  type        = number
  description = "Template VM ID"
  default     = 8025
}

# Locals for timestamp
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# Resource Definition for the VM Template
source "proxmox-clone" "ubuntu-minimal" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  # VM General Settings
  node                 = var.proxmox_node_name
  vm_id                = var.template_id
  vm_name              = "ubuntu-2404-minimal-${local.timestamp}"
  template_name        = "ubuntu-2404-minimal-${local.timestamp}"
  template_description = "Ubuntu 24.04 Minimal - Cloud image, no modifications. Built ${formatdate("YYYY-MM-DD hh:mm", timestamp())}"

  # Clone from existing cloud-init template
  clone_vm   = var.clone_vm
  full_clone = true

  # VM System Settings
  qemu_agent = true

  # VM CPU Settings
  cores = "1"

  # VM Memory Settings
  memory = "2048"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # SSH Settings for connection during build - use key authentication
  ssh_username = var.instance_username
  # ssh_password = var.instance_password  # Commented out - using key auth
  ssh_timeout  = "15m"
  # Use SSH agent for authentication - the key should be loaded in your agent
  ssh_agent_auth = true
}

# Build Definition - Minimal, no provisioning
build {
  name    = "ubuntu-server-minimal"
  sources = ["source.proxmox-clone.ubuntu-minimal"]

  # Minimal cleanup provisioner only - prepare for templating
  provisioner "shell" {
    inline = [
      "sudo cloud-init clean --logs",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo sync"
    ]
  }
}
