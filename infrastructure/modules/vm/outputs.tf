locals {
  # Safely get ipv4_addresses with fallback to empty list
  raw_ipv4_addresses = try(
    proxmox_virtual_environment_vm.vm.ipv4_addresses,
    []
  )

  # Normalize to flat list - handles both flat arrays and nested structures
  vm_ipv4_flat = try(
    flatten(local.raw_ipv4_addresses),
    local.raw_ipv4_addresses,
    []
  )

  # Filter out localhost and empty addresses to get usable IPs
  vm_ipv4_non_lo = [
    for ip in local.vm_ipv4_flat : ip
    if ip != "" && ip != "127.0.0.1" && ip != null
  ]

  # Safely get primary and secondary IPs with explicit checks
  detected_primary_ip   = length(local.vm_ipv4_non_lo) > 0 ? local.vm_ipv4_non_lo[0] : null
  detected_secondary_ip = length(local.vm_ipv4_non_lo) > 1 ? local.vm_ipv4_non_lo[1] : null
}

output "vm_id" {
  description = "The VM's numeric identifier in Proxmox"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "The VM's display name in Proxmox"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "ipv4_addresses" {
  description = "All IPv4 addresses per network interface reported by the QEMU guest agent (empty list if the agent is disabled or not running)"
  value       = local.raw_ipv4_addresses
}

output "primary_ip" {
  description = "Primary IPv4 address - DEPRECATED: Use 'ipv4_addresses' output instead"
  value       = coalesce(local.detected_primary_ip, var.vm_ip_primary)
}

output "secondary_ip" {
  description = "Secondary IPv4 address - DEPRECATED: Use 'ipv4_addresses' output instead"
  value       = var.enable_dual_network ? coalesce(local.detected_secondary_ip, var.vm_ip_secondary) : null
}
