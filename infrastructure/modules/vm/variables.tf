# --- VM Module Variables ---
variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_id" {
  description = "Unique VM ID in Proxmox"
  type        = number
}

variable "vm_node_name" {
  description = "Proxmox node to place the VM on"
  type        = string
}

variable "vm_tags" {
  description = "List of tags to apply to the VM"
  type        = list(string)
  default     = []
}

variable "template_id" {
  description = "Template VM ID to clone from"
  type        = number
}

variable "template_node" {
  description = "Source node where the template VM exists (e.g., 'lloyd')"
  type        = string
}

variable "vcpu" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "vcpu_type" {
  description = "CPU type (host, kvm64, etc.)"
  type        = string
  default     = "host"
}

variable "memory" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "vm_datastore" {
  description = "Storage for VM disk"
  type        = string
}

variable "vm_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 32
}

variable "vm_bridge_1" {
  description = "Primary network bridge"
  type        = string
  default     = "vmbr0"
}

variable "vm_bridge_2" {
  description = "Secondary network bridge"
  type        = string
  default     = "vmbr1"
}

variable "vm_ip_primary" {
  description = "Primary IP address with CIDR"
  type        = string
}

variable "vm_gateway" {
  description = "Default gateway for primary network"
  type        = string
}

variable "vm_ip_secondary" {
  description = "Secondary IP address with CIDR"
  type        = string
  default     = ""
}

variable "enable_dual_network" {
  description = "Enable dual network configuration with secondary NIC"
  type        = bool
  default     = true
}

variable "cloud_init_username" {
  description = "Username for cloud-init"
  type        = string
  default     = "ansible"
}

variable "ci_ssh_key" {
  description = "SSH public key for cloud-init"
  type        = string
}

variable "dns_servers" {
  description = "List of DNS servers for the VM"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "enable_vendor_data" {
  description = "Enable vendor data for cloud-init"
  type        = bool
  default     = false
}

variable "vendor_data_content" {
  description = "Content for cloud-init vendor data"
  type        = string
  default     = ""
}

variable "memory_floating" {
  description = "Amount of floating memory in MB for ballooning (0 disables ballooning)"
  type        = number
  default     = 0
}

variable "enable_user_data" {
  description = "Enable user data for cloud-init (for packages and basic config)"
  type        = bool
  default     = false
}

variable "user_data_content" {
  description = "Content for cloud-init user data (YAML format)"
  type        = string
  default     = ""
}
