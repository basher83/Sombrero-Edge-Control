# VM Information Outputs
output "vm_id" {
  value       = proxmox_virtual_environment_vm.jump_man.vm_id
  description = "Proxmox VM ID"
}

output "vm_name" {
  value       = proxmox_virtual_environment_vm.jump_man.name
  description = "VM name"
}

output "vm_ip" {
  value       = split("/", var.vm_ip_address)[0]
  description = "VM IP address (without CIDR)"
}

output "ssh_command" {
  value       = "ssh ${var.ci_username}@${split("/", var.vm_ip_address)[0]}"
  description = "SSH command to connect to the VM"
}

# Ansible Inventory JSON Output
output "ansible_inventory" {
  value = jsonencode({
    all = {
      children = {
        jump_hosts = {
          hosts = {
            "${var.vm_name}" = {
              # Connection details
              ansible_host                 = split("/", var.vm_ip_address)[0]
              ansible_user                 = var.ci_username
              ansible_ssh_private_key_file = "~/.ssh/ansible"
              ansible_python_interpreter   = "/usr/bin/python3"

              # VM metadata
              vm_id        = proxmox_virtual_environment_vm.jump_man.vm_id
              proxmox_node = var.proxmox_node
              template_id  = var.template_id

              # Network configuration
              ip_address = split("/", var.vm_ip_address)[0]
              gateway    = var.vm_gateway

              # Resource allocation
              cpu_cores       = var.vm_cores
              memory_mb       = var.vm_memory
              memory_floating = var.vm_memory_floating
              disk_size_gb    = var.vm_disk_size

              # Tags for grouping
              tags = ["jump", "production", "terraform"]
            }
          }
        }
      }
    }
  })
  description = "Ansible inventory in JSON format"
}

# Write inventory to file for easy consumption
resource "local_file" "ansible_inventory" {
  content = jsonencode(jsondecode(jsonencode({
    all = {
      children = {
        jump_hosts = {
          hosts = {
            "${var.vm_name}" = {
              ansible_host                 = split("/", var.vm_ip_address)[0]
              ansible_user                 = var.ci_username
              ansible_ssh_private_key_file = "~/.ssh/ansible"
              ansible_python_interpreter   = "/usr/bin/python3"
              vm_id                        = proxmox_virtual_environment_vm.jump_man.vm_id
              proxmox_node                 = var.proxmox_node
              template_id                  = var.template_id
              ip_address                   = split("/", var.vm_ip_address)[0]
              gateway                      = var.vm_gateway
              cpu_cores                    = var.vm_cores
              memory_mb                    = var.vm_memory
              memory_floating              = var.vm_memory_floating
              disk_size_gb                 = var.vm_disk_size
              tags                         = ["jump", "production", "terraform"]
            }
          }
        }
      }
    }
  })))
  filename = "${path.module}/inventory.json"
}
