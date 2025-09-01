# --- Jump Host Production Environment Variables ---

variable "template_id" {
  type        = number
  default     = 8000 # Ubuntu 22.04 template
  description = "Template ID for VM cloning"
}

variable "template_node" {
  type        = string
  default     = "lloyd"
  description = "Node where the template VM exists"
}

# --- Shared Environment Variables ---

variable "vm_datastore" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox datastore for VM disks"
}

variable "vm_bridge_1" {
  type        = string
  default     = "vmbr0"
  description = "Primary network bridge for VMs"
}

variable "ci_ssh_key" {
  type        = string
  sensitive   = true
  description = "SSH public key for cloud-init user authentication"
}

variable "pve_api_url" {
  type        = string
  description = "Proxmox API endpoint URL"
}

variable "pve_api_token" {
  type        = string
  sensitive   = true
  description = "Proxmox API token ID"
}

variable "proxmox_insecure" {
  description = "Set true to skip TLS verification for Proxmox API (not recommended in production)"
  type        = bool
  default     = false
}

variable "proxmox_ssh_username" {
  description = "SSH username for Proxmox host (for file uploads)"
  type        = string
  default     = "root"
}

variable "proxmox_ssh_private_key" {
  description = "SSH private key for Proxmox host authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dns_servers" {
  description = "List of DNS servers for VMs"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "cloud_init_username" {
  description = "Username for cloud-init SSH access"
  type        = string
  default     = "ansible"
}
