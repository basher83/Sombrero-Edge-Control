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

# Complete Ansible inventory output in JSON format
output "ansible_inventory" {
  value = jsonencode({
    all = {
      children = {
        jump_hosts = {
          hosts = {
            "jump-man" = {
              # Connection details
              ansible_host                 = module.jump_man.primary_ip
              ansible_user                 = var.cloud_init_username
              ansible_ssh_private_key_file = "~/.ssh/ansible"
              ansible_python_interpreter   = "/usr/bin/python3"

              # VM metadata
              vm_id           = module.jump_man.vm_id
              proxmox_node    = "lloyd"
              template_id     = local.selected_template_id
              template_source = local.template_source

              # Network configuration
              ip_address  = module.jump_man.primary_ip
              gateway     = var.vm_gateway
              dns_servers = var.dns_servers

              # Resource allocation
              cores     = module.jump_man.vcpu
              memory    = module.jump_man.memory
              disk_size = module.jump_man.vm_disk_size

              # Tags for role selection
              tags = ["docker", "development", "monitoring"]
            }
          }
        }
      }
      vars = {
        # Global variables for all hosts
        ansible_connection      = "ssh"
        ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
        deployment_environment  = "production"
      }
    }
  })
  description = "Complete Ansible inventory for configuration management"
}

# Helper outputs for common operations
output "vm_ssh_command" {
  description = "SSH command to connect to VM"
  value       = "ssh ${var.cloud_init_username}@${module.jump_man.primary_ip}"
}

output "ansible_ping_command" {
  description = "Command to test Ansible connectivity"
  value       = "ansible -i \"{\\\"all\\\": {\\\"children\\\": {\\\"jump_hosts\\\": {\\\"hosts\\\": {\\\"jump-man\\\": {\\\"ansible_host\\\": \\\"${module.jump_man.primary_ip}\\\", \\\"ansible_user\\\": \\\"${var.cloud_init_username}\\\"}}}}}}\" jump_hosts -m ping"
}

output "ansible_playbook_command" {
  description = "Command to run configuration playbook"
  value       = "ansible-playbook -i ansible_inventory.json playbooks/site.yml"
}

# Deployment metadata for pipeline tracking
output "deployment_metadata" {
  value = {
    deployment_time = timestamp()
    template_id     = local.selected_template_id
    template_source = local.template_source
    vm_configuration = {
      name       = module.jump_man.vm_name
      ip_address = module.jump_man.primary_ip
      vm_id      = module.jump_man.vm_id
    }
    golden_image_features = {
      docker_preinstalled = true
      nvm_preinstalled    = true
      mise_preinstalled   = true
      uv_preinstalled     = true
      development_ready   = true
    }
  }
  description = "Deployment metadata for tracking and analytics"
}
