terraform {
  required_version = ">= 1.3.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}
