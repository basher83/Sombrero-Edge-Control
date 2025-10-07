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

    <!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.73.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [proxmox_virtual_environment_vm.jump_man](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Skip TLS verification for Proxmox API (not recommended in production) | `bool` | `false` | no |
| <a name="input_pve_api_token"></a> [pve\_api\_token](#input\_pve\_api\_token) | Proxmox API token in format 'user@pam!tokenid=uuid' | `string` | n/a | yes |
| <a name="input_pve_api_url"></a> [pve\_api\_url](#input\_pve\_api\_url) | Proxmox API endpoint URL (e.g., https://proxmox.example.com:8006/api2/json) | `string` | n/a | yes |
| <a name="input_vm_agent_enabled"></a> [vm\_agent\_enabled](#input\_vm\_agent\_enabled) | QEMU agent enable/disable | `string` | `"true"` | no |
| <a name="input_vm_agent_timeout"></a> [vm\_agent\_timeout](#input\_vm\_agent\_timeout) | Time to wait for QEMU agent to initialize | `string` | `"15m"` | no |
| <a name="input_vm_bios"></a> [vm\_bios](#input\_vm\_bios) | ovmf is preferred or seabios | `string` | `"ovmf"` | no |
| <a name="input_vm_clone_full"></a> [vm\_clone\_full](#input\_vm\_clone\_full) | Conduct full clone of template vs linked clone | `string` | `"true"` | no |
| <a name="input_vm_clone_node_name"></a> [vm\_clone\_node\_name](#input\_vm\_clone\_node\_name) | Proxmox node to deploy the VM on | `string` | `""` | no |
| <a name="input_vm_clone_vm_id"></a> [vm\_clone\_vm\_id](#input\_vm\_clone\_vm\_id) | Template VM ID to clone from | `number` | `"2001"` | no |
| <a name="input_vm_cpu_cores"></a> [vm\_cpu\_cores](#input\_vm\_cpu\_cores) | Number of CPU cores | `number` | `2` | no |
| <a name="input_vm_cpu_sockets"></a> [vm\_cpu\_sockets](#input\_vm\_cpu\_sockets) | Number of CPU sockets | `number` | `1` | no |
| <a name="input_vm_cpu_type"></a> [vm\_cpu\_type](#input\_vm\_cpu\_type) | CPU type (host for best performance) | `string` | `"host"` | no |
| <a name="input_vm_disk_cache"></a> [vm\_disk\_cache](#input\_vm\_disk\_cache) | Type of disk cache | `string` | `"writeback"` | no |
| <a name="input_vm_disk_datastore"></a> [vm\_disk\_datastore](#input\_vm\_disk\_datastore) | Proxmox datastore for VM disk and cloud-init | `string` | `"local-lvm"` | no |
| <a name="input_vm_disk_file_format"></a> [vm\_disk\_file\_format](#input\_vm\_disk\_file\_format) | Disk format | `string` | `"raw"` | no |
| <a name="input_vm_disk_interface"></a> [vm\_disk\_interface](#input\_vm\_disk\_interface) | Interface type for VM disk | `string` | `"scsi0"` | no |
| <a name="input_vm_disk_iothread"></a> [vm\_disk\_iothread](#input\_vm\_disk\_iothread) | Disk IO thread | `string` | `"false"` | no |
| <a name="input_vm_disk_size"></a> [vm\_disk\_size](#input\_vm\_disk\_size) | Disk size in GB | `number` | `32` | no |
| <a name="input_vm_efi_disk_datastore_id"></a> [vm\_efi\_disk\_datastore\_id](#input\_vm\_efi\_disk\_datastore\_id) | Proxmox datastore for VM disk | `string` | `"local-lvm"` | no |
| <a name="input_vm_efi_disk_file_format"></a> [vm\_efi\_disk\_file\_format](#input\_vm\_efi\_disk\_file\_format) | EFI disk format type | `string` | `"raw"` | no |
| <a name="input_vm_efi_disk_pre_enrolled_keys"></a> [vm\_efi\_disk\_pre\_enrolled\_keys](#input\_vm\_efi\_disk\_pre\_enrolled\_keys) | True for secure boot, false if not | `string` | `"false"` | no |
| <a name="input_vm_efi_disk_type"></a> [vm\_efi\_disk\_type](#input\_vm\_efi\_disk\_type) | EFI disk type | `string` | `"4m"` | no |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | Unique VM ID in Proxmox, blank will auto assign | `number` | `"2001"` | no |
| <a name="input_vm_initialization_datastore_id"></a> [vm\_initialization\_datastore\_id](#input\_vm\_initialization\_datastore\_id) | Proxmox datastore for cloud-init | `string` | `"local-lvm"` | no |
| <a name="input_vm_initialization_interface"></a> [vm\_initialization\_interface](#input\_vm\_initialization\_interface) | Interface type | `string` | `"ide0"` | no |
| <a name="input_vm_initialization_ip_config_ipv4_address"></a> [vm\_initialization\_ip\_config\_ipv4\_address](#input\_vm\_initialization\_ip\_config\_ipv4\_address) | Static IP address with CIDR notation | `string` | `"192.168.10.250/24"` | no |
| <a name="input_vm_initialization_ip_config_ipv4_gateway"></a> [vm\_initialization\_ip\_config\_ipv4\_gateway](#input\_vm\_initialization\_ip\_config\_ipv4\_gateway) | Default gateway | `string` | `"192.168.10.1"` | no |
| <a name="input_vm_initialization_user_account_keys"></a> [vm\_initialization\_user\_account\_keys](#input\_vm\_initialization\_user\_account\_keys) | List of SSH public keys for authentication | `list(string)` | `[]` | no |
| <a name="input_vm_initialization_user_account_username"></a> [vm\_initialization\_user\_account\_username](#input\_vm\_initialization\_user\_account\_username) | Username for cloud-init SSH access | `string` | `"ansible"` | no |
| <a name="input_vm_memory_dedicated"></a> [vm\_memory\_dedicated](#input\_vm\_memory\_dedicated) | Dedicated memory in MB | `number` | `2048` | no |
| <a name="input_vm_memory_floating"></a> [vm\_memory\_floating](#input\_vm\_memory\_floating) | Floating memory in MB for ballooning | `number` | `2048` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the VM | `string` | `"jump-man"` | no |
| <a name="input_vm_network_device_bridge"></a> [vm\_network\_device\_bridge](#input\_vm\_network\_device\_bridge) | Network bridge for VM | `string` | `"vmbr0"` | no |
| <a name="input_vm_network_device_firewall"></a> [vm\_network\_device\_firewall](#input\_vm\_network\_device\_firewall) | Network firewall for VM | `string` | `"false"` | no |
| <a name="input_vm_network_device_mac_address"></a> [vm\_network\_device\_mac\_address](#input\_vm\_network\_device\_mac\_address) | MAC address (leave empty for auto-generation) | `string` | `""` | no |
| <a name="input_vm_node_name"></a> [vm\_node\_name](#input\_vm\_node\_name) | Proxmox node to deploy the VM on | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_inventory"></a> [ansible\_inventory](#output\_ansible\_inventory) | Ansible inventory in JSON format |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | SSH command to connect to the VM |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | Proxmox VM ID |
| <a name="output_vm_ip"></a> [vm\_ip](#output\_vm\_ip) | VM IP address (without CIDR) |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | VM name |
<!-- END_TF_DOCS -->
