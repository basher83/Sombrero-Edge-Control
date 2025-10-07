##################################
# Proxmox Provider Configuration
##################################
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

##################################
# VM Configuration
##################################
variable "vm_name" {
  type        = string
  default     = "jump-man"
  description = "Name of the VM"
}

variable "vm_id" {
  type        = number
  default     = "2001"
  description = "Unique VM ID in Proxmox, blank will auto assign"
}

variable "vm_node_name" {
  type        = string
  default     = ""
  description = "Proxmox node to deploy the VM on"
}
# [TODO]: add validation for node name to be present

variable "vm_bios" {
  type        = string
  default     = "ovmf"
  description = "ovmf is preferred or seabios"
}

##################################
# QEMU agent options
##################################
variable "vm_agent_enabled" {
  type        = string
  default     = "true"
  description = "QEMU agent enable/disable"
}

variable "vm_agent_timeout" {
  type        = string
  default     = "15m"
  description = "Time to wait for QEMU agent to initialize"
}

##################################
# Clone options
##################################
variable "vm_clone_vm_id" {
  type        = number
  default     = "2001"
  description = "Template VM ID to clone from"
}
# [TODO]: add validation for template id to be present

variable "vm_clone_node_name" {
  type        = string
  default     = ""
  description = "Proxmox node to deploy the VM on"
}
# [TODO]: add validation for node name to be present

variable "vm_clone_full" {
  type        = string
  default     = "true"
  description = "Conduct full clone of template vs linked clone"
}

##################################
# Primary disk configuration
##################################
variable "vm_disk_datastore" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox datastore for VM disk and cloud-init"
}

variable "vm_disk_interface" {
  type        = string
  default     = "scsi0"
  description = "Interface type for VM disk"
}

variable "vm_disk_size" {
  type        = number
  default     = 32
  description = "Disk size in GB"
}

variable "vm_disk_file_format" {
  type        = string
  default     = "raw"
  description = "Disk format"
}

variable "vm_disk_cache" {
  type        = string
  default     = "writeback"
  description = "Type of disk cache"
}

variable "vm_disk_iothread" {
  type        = string
  default     = "false"
  description = "Disk IO thread"
}

##################################
# EFI disk for UEFI boot
##################################
variable "vm_efi_disk_datastore_id" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox datastore for VM disk"
}

variable "vm_efi_disk_file_format" {
  type        = string
  default     = "raw"
  description = "EFI disk format type"
}

variable "vm_efi_disk_type" {
  type        = string
  default     = "4m"
  description = "EFI disk type"
}

variable "vm_efi_disk_pre_enrolled_keys" {
  type        = string
  default     = "false"
  description = "True for secure boot, false if not"
}

##################################
# Network Configuration - NIC
##################################
variable "vm_network_device_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Network bridge for VM"
}

variable "vm_network_device_firewall" {
  type        = string
  default     = "false"
  description = "Network firewall for VM"
}

variable "vm_network_device_mac_address" {
  type        = string
  default     = ""
  description = "MAC address (leave empty for auto-generation)"
}

##################################
# CPU Configuration
##################################
variable "vm_cpu_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores"
}

variable "vm_cpu_sockets" {
  type        = number
  default     = 1
  description = "Number of CPU sockets"
}

variable "vm_cpu_type" {
  type        = string
  default     = "host"
  description = "CPU type (host for best performance)"
}

##################################
# Memory Configuration - Set the same for balloning
##################################
variable "vm_memory_dedicated" {
  type        = number
  default     = 2048
  description = "Dedicated memory in MB"
}

variable "vm_memory_floating" {
  type        = number
  default     = 2048
  description = "Floating memory in MB for ballooning"
}

##################################
# Cloud-init Initialization
##################################
variable "vm_initialization_datastore_id" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox datastore for cloud-init"
}

variable "vm_initialization_interface" {
  type        = string
  default     = "ide0"
  description = "Interface type"
}

variable "vm_initialization_ip_config_ipv4_address" {
  type        = string
  default     = "192.168.10.250/24"
  description = "Static IP address with CIDR notation"
}

variable "vm_initialization_ip_config_ipv4_gateway" {
  type        = string
  default     = "192.168.10.1"
  description = "Default gateway"
}

variable "vm_initialization_user_account_username" {
  type        = string
  default     = "ansible"
  description = "Username for cloud-init SSH access"
}

variable "vm_initialization_user_account_keys" {
  type        = list(string)
  description = "List of SSH public keys for authentication"
  default     = []
}
