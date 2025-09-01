terraform {
  required_version = ">= 1.3.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73.2"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = var.pve_api_token
  insecure  = var.proxmox_insecure

  # SSH credentials for file uploads (vendor_data)
  ssh {
    agent    = true
    username = var.proxmox_ssh_username
    # private_key is optional if using ssh-agent
  }
}
