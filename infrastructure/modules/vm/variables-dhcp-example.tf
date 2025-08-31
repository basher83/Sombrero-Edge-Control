# Example of variables to add for DHCP support

variable "use_dhcp" {
  description = "Use DHCP instead of static IP assignment"
  type        = bool
  default     = false
}

variable "dhcp_hostname" {
  description = "Hostname to request from DHCP server"
  type        = string
  default     = ""
}
