# Proxmox Provider Configuration
variable "pve_api_url" {
  type        = string
  description = "Proxmox API endpoint URL (e.g., https://proxmox.example.com:8006/api2/json)"
}

variable "pve_api_token" {
  type        = string
  sensitive   = true
  description = "Proxmox API token in format 'user@pam!tokenid=uuid'"
}

variable "proxmox_insecure" {
  type        = bool
  default     = false
  description = "Skip TLS verification for Proxmox API (not recommended in production)"
}

# VM Configuration
variable "vm_name" {
  type        = string
  default     = "jump-man"
  description = "Name of the jump host VM"
}

variable "vm_id" {
  type        = number
  default     = 7000
  description = "Unique VM ID in Proxmox"
}

variable "proxmox_node" {
  type        = string
  default     = "lloyd"
  description = "Proxmox node to deploy the VM on"
}

variable "template_id" {
  type        = number
  default     = 8024
  description = "Template VM ID to clone from (jumpman24 template)"
}

# Resource Allocation
variable "vm_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores"
}

variable "vm_cpu_type" {
  type        = string
  default     = "host"
  description = "CPU type (host for best performance)"
}

variable "vm_memory" {
  type        = number
  default     = 2048
  description = "Dedicated memory in MB"
}

variable "vm_memory_floating" {
  type        = number
  default     = 1024
  description = "Floating memory in MB for ballooning"
}

variable "vm_disk_size" {
  type        = number
  default     = 32
  description = "Disk size in GB"
}

# Storage Configuration
variable "vm_datastore" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox datastore for VM disk and cloud-init"
}

# Network Configuration
variable "vm_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Network bridge for VM"
}

variable "vm_ip_address" {
  type        = string
  default     = "192.168.10.250/24"
  description = "Static IP address with CIDR notation"
}

variable "vm_gateway" {
  type        = string
  default     = "192.168.10.1"
  description = "Default gateway"
}

variable "vm_mac_address" {
  type        = string
  default     = ""
  description = "MAC address (leave empty for auto-generation)"
}

# Cloud-init Configuration
variable "ci_username" {
  type        = string
  default     = "ansible"
  description = "Username for cloud-init SSH access"
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "List of SSH public keys for authentication"
  default     = []
}
