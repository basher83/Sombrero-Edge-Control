# --- Outputs for Jump Host Production Environment ---

# Jump Host outputs
output "jump_host" {
  value = {
    name           = module.jump_man.vm_name
    id             = module.jump_man.vm_id
    ipv4_addresses = module.jump_man.ipv4_addresses
    primary_ip     = module.jump_man.primary_ip
    ssh_command    = "ssh ansible@${module.jump_man.primary_ip}"
  }
  description = "Jump host (jump-man) VM details"
}

# Network configuration for reference
output "network_configuration" {
  value = {
    jump_host_ip = "192.168.10.250"
    gateway      = "192.168.10.1"
    dns_servers  = var.dns_servers
  }
  description = "Network configuration for the jump host"
}

# Ansible inventory output for jump host
output "ansible_inventory" {
  value = yamlencode({
    all = {
      hosts = {
        (module.jump_man.vm_name) = {
          ansible_host = module.jump_man.primary_ip
          ansible_user = "ansible"
          role         = "jump"
        }
      }
    }
  })
  description = "Ansible inventory in YAML format for jump host"
}
