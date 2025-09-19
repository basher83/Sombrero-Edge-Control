---
Task: Terraform Inventory Output Enhancement
Task ID: SEP-004
Priority: P0 (Critical)
Estimated Time: 1 hour
Dependencies: SEP-002
Status: ⏸️ Blocked
---

## Objective

Enhance Terraform outputs to generate a complete Ansible inventory in JSON format, enabling clean handoff between infrastructure provisioning and configuration management. The inventory should include all necessary connection details and metadata for Ansible to configure the VM.

## Prerequisites

- [ ] SEP-002 completed (simplified cloud-init)
- [ ] Understanding of Ansible inventory format
- [ ] Access to Terraform configuration

## Implementation Steps

### 1. **Define Comprehensive Output Structure**

Update `infrastructure/environments/production/outputs.tf`:

```hcl
output "ansible_inventory" {
  description = "Complete Ansible inventory for configuration management"
  value = {
    all = {
      children = {
        jump_hosts = {
          hosts = {
            "jump-man" = {
              # Connection details
              ansible_host = proxmox_vm_qemu.jump-man.default_ipv4_address
              ansible_user = "ansible"
              ansible_ssh_private_key_file = "~/.ssh/ansible"
              ansible_python_interpreter = "/usr/bin/python3"

              # VM metadata
              vm_id = proxmox_vm_qemu.jump-man.vmid
              proxmox_node = var.proxmox_node
              template_id = var.template_id

              # Network configuration
              ip_address = var.vm_ip_address
              gateway = var.vm_gateway
              dns_servers = var.dns_servers

              # Resource allocation
              cores = var.vm_cores
              memory = var.vm_memory
              disk_size = var.vm_disk_size

              # Tags for role selection
              tags = ["docker", "development", "monitoring"]
            }
          }
        }
      }
      vars = {
        # Global variables for all hosts
        ansible_connection = "ssh"
        ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
        deployment_environment = "production"
      }
    }
  }
  sensitive = false
}

output "ansible_inventory_file" {
  description = "Path to write Ansible inventory"
  value = "${path.module}/ansible_inventory.json"
}
```

### 2. **Add Helper Outputs**

Create additional outputs for common use cases:

```hcl
output "vm_ssh_command" {
  description = "SSH command to connect to VM"
  value = "ssh ansible@${proxmox_vm_qemu.jump-man.default_ipv4_address}"
}

output "ansible_ping_command" {
  description = "Command to test Ansible connectivity"
  value = "ansible -i ansible_inventory.json jump_hosts -m ping"
}

output "ansible_playbook_command" {
  description = "Command to run configuration playbook"
  value = "ansible-playbook -i ansible_inventory.json playbooks/site.yml"
}
```

### 3. **Create Inventory Export Script**

Add `infrastructure/environments/production/export-inventory.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Export Terraform output to Ansible inventory
terraform output -json ansible_inventory > ansible_inventory.json

# Validate JSON format
python3 -m json.tool ansible_inventory.json > /dev/null || {
    echo "Error: Invalid JSON in inventory"
    exit 1
}

# Copy to Ansible collection location
ANSIBLE_DIR="../../../ansible_collections/basher83/automation_server"
cp ansible_inventory.json "${ANSIBLE_DIR}/inventory/"

echo "Inventory exported to:"
echo "  - $(pwd)/ansible_inventory.json"
echo "  - ${ANSIBLE_DIR}/inventory/ansible_inventory.json"
```

### 4. **Update Terraform Variables**

Ensure all necessary variables are defined in `variables.tf`:

```hcl
variable "dns_servers" {
  description = "DNS servers for the VM"
  type        = list(string)
  default     = ["1.1.1.1", "1.0.0.1"]
}

variable "deployment_tags" {
  description = "Tags for Ansible role selection"
  type        = list(string)
  default     = ["docker", "development", "monitoring"]
}
```

### 5. **Create Validation Module**

Add inventory validation to Terraform:

```hcl
# infrastructure/environments/production/inventory-validation.tf
resource "null_resource" "validate_inventory" {
  depends_on = [proxmox_vm_qemu.jump-man]

  provisioner "local-exec" {
    command = "terraform output -json ansible_inventory | python3 -m json.tool > /dev/null"
  }
}
```

## Success Criteria

- [ ] Terraform generates valid JSON inventory
- [ ] Inventory includes all connection details
- [ ] Inventory includes VM metadata
- [ ] Ansible can parse the inventory
- [ ] Ansible can connect using inventory
- [ ] Helper outputs provide useful commands

## Validation

### Terraform Output Testing

```bash
cd infrastructure/environments/production

# MANDATORY: Initialize and run tflint first
tflint --init
tflint

# Generate inventory
terraform output -json ansible_inventory > ansible_inventory.json

# Validate JSON structure
python3 -c "import json; json.load(open('ansible_inventory.json'))"

# Check required fields
jq '.all.children.jump_hosts.hosts["jump-man"].ansible_host' ansible_inventory.json
# Should output: "192.168.10.250"
```

### Ansible Testing

```bash
# Test inventory parsing
ansible-inventory -i ansible_inventory.json --list

# Test connectivity
ansible -i ansible_inventory.json jump_hosts -m ping

# Test with playbook
ansible-playbook -i ansible_inventory.json --syntax-check playbooks/site.yml
```

Expected output:

- Valid JSON with all required fields
- Ansible successfully parses inventory
- Ping module returns SUCCESS

## Notes

- The inventory format must be compatible with Ansible 2.9+
- Consider encrypting sensitive values with Ansible Vault
- The inventory can be extended with additional groups and variables
- This enables fully automated handoff from Terraform to Ansible

## References

- [Ansible Inventory Documentation](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
- [Terraform Output Documentation](https://www.terraform.io/docs/language/values/outputs.html)
- [Pipeline Separation ADR](../../../decisions/20250118-pipeline-separation.md)
