provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = var.pve_api_token
  insecure  = var.proxmox_insecure

  # SSH not needed for API-based operations
  ssh {
    agent = false
  }
}
