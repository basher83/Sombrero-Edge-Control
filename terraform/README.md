# Terraform - Jump Host Infrastructure

Simplified Terraform configuration for provisioning the jump-man VM on Proxmox.

## Purpose

Stage 2 of the infrastructure pipeline: Provision VM infrastructure from a Packer-built template.

**Pipeline Flow:**

1. **Packer** → Creates golden image template (ID: 8024)
2. **Terraform** → Provisions VM from template with networking (this stage)
3. **Ansible** → Configures software and services

## Quick Start

```bash
# 1. Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 2. Initialize Terraform
terraform init

# 3. Plan deployment
terraform plan

# 4. Apply configuration
terraform apply

# 5. Generate Ansible inventory
terraform output -json ansible_inventory > ../ansible_collections/basher83/automation_server/inventory/inventory.json
```

## Files

- `main.tf` - VM resource definition
- `variables.tf` - Input variables with defaults
- `outputs.tf` - Outputs including Ansible inventory
- `providers.tf` - Proxmox provider configuration
- `versions.tf` - Version requirements
- `terraform.tfvars.example` - Example configuration

## Key Features

- **Simple**: Direct VM resource, no unnecessary modules
- **Template-based**: Uses pre-built template ID 8024
- **Static networking**: Fixed IP 192.168.10.250/24
- **Clean handoff**: Generates inventory.json for Ansible
- **Minimal cloud-init**: SSH access only

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `template_id` | 8024 | Packer-built template ID |
| `vm_name` | jump-man | VM name |
| `vm_ip_address` | 192.168.10.250/24 | Static IP with CIDR |
| `proxmox_node` | lloyd | Target Proxmox node |

## Outputs

- `vm_id` - Proxmox VM ID
- `vm_name` - VM name
- `vm_ip` - IP address without CIDR
- `ssh_command` - SSH connection command
- `ansible_inventory` - Complete inventory JSON for Ansible

## Integration with mise

```bash
# Using mise tasks
mise run terraform-init
mise run terraform-plan
mise run terraform-apply
```

## Notes

- Template ID 8024 must exist on the Proxmox node
- SSH keys should be configured in terraform.tfvars
- Inventory file is auto-generated as inventory.json
- All software configuration handled by Ansible (stage 3)
