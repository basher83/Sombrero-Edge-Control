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

# Enhanced Ansible inventory output with golden image integration
output "ansible_inventory" {
  value = yamlencode({
    all = {
      hosts = {
        "jump-man" = {
          ansible_host                 = module.jump_man.primary_ip
          ansible_user                 = var.cloud_init_username
          ansible_ssh_private_key_file = "~/.ssh/jump-man-key"
          ansible_python_interpreter   = "/usr/bin/python3"
          # Golden image metadata
          template_id     = local.selected_template_id
          template_source = local.template_source
          vm_id           = module.jump_man.vm_id
        }
      }
      vars = {
        ansible_connection      = "ssh"
        ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
        golden_image_built      = local.template_source == "packer-golden-image"
      }
      children = {
        jump_hosts = {
          hosts = ["jump-man"]
          vars = {
            # Golden image pre-installed components
            docker_install = false
            nvm_install    = false
            mise_install   = false
            uv_install     = false
            # Post-deployment configuration
            enable_monitoring = false
            enable_vault      = true
            ssh_password_auth = false
          }
        }
        docker_hosts = {
          hosts = ["jump-man"]
          vars = {
            docker_version         = "pre-installed"
            docker_compose_install = false
            docker_users           = [var.cloud_init_username]
          }
        }
        development_hosts = {
          hosts = ["jump-man"]
          vars = {
            nvm_version  = "pre-installed"
            mise_version = "pre-installed"
            uv_version   = "pre-installed"
            node_version = "lts"
          }
        }
      }
    }
  })
  description = "Enhanced Ansible inventory with golden image metadata"
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
