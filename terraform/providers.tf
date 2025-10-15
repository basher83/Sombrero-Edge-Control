provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = var.pve_api_token
  insecure  = var.proxmox_insecure

  # SSH needed for uploading files to Proxmox i.e. vendor-data.yml
  ssh {
    agent = false
  }
}
