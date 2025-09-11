# VM Module

Flexible Proxmox VM provisioning module with cloud-init support.

## Features

- **Resource Management**: Configurable CPU, memory, and storage
- **Memory Ballooning**: Optional floating memory for efficient resource usage
- **Networking**: Single or dual network interface support
- **Cloud-init**: Full support for user_data and optional vendor_data
- **QEMU Guest Agent**: Automatic configuration for Proxmox integration
- **Tagging**: Flexible tagging system for resource organization

## Usage

### Basic Example

```hcl
module "simple_vm" {
  source = "../../modules/vm"

  vm_name       = "my-server"
  vm_id         = 1001
  vm_node_name  = "proxmox-node"
  vm_ip_primary = "192.168.1.10/24"
  vm_gateway    = "192.168.1.1"
  vm_datastore  = "local-lvm"
  template_id   = 8024
  template_node = "proxmox-node"
  ci_ssh_key    = "ssh-ed25519 AAAA..."
}
```

### Advanced Example with Cloud-init

```hcl
module "jump_host" {
  source = "../../modules/vm"

  # Basic configuration
  vm_name      = "jump-man"
  vm_id        = 7000
  vm_node_name = "lloyd"

  # Network configuration
  vm_ip_primary       = "192.168.10.250/24"
  vm_gateway          = "192.168.10.1"
  enable_dual_network = false
  dns_servers         = ["8.8.8.8", "8.8.4.4"]

  # Resources
  vcpu            = 2
  vcpu_type       = "host"
  memory          = 2048
  memory_floating = 1024  # Enable memory ballooning
  vm_disk_size    = 32
  vm_datastore    = "local-lvm"

  # Cloud-init
  cloud_init_username = "ansible"
  ci_ssh_key          = var.ssh_public_key
  enable_vendor_data  = true
  vendor_data_content = file("${path.module}/cloud-init.yaml")

  # Template
  template_id   = 8024
  template_node = "lloyd"

  # Tags
  vm_tags = ["terraform", "jump", "production"]
}
```

## Key Features Explained

### Memory Ballooning

When `memory_floating` is set to a value > 0, the VM can release unused memory back to the host:
- `memory`: Dedicated memory that's always allocated
- `memory_floating`: Additional memory that can be reclaimed by the host when not in use

### Vendor Data

The module supports optional vendor_data for cloud-init:
- Set `enable_vendor_data = true` to enable
- Provide content via `vendor_data_content`
- Useful for software installation and configuration

### Dual Network Support

Configure two network interfaces:
- Set `enable_dual_network = true`
- Configure `vm_ip_secondary` and `vm_bridge_2`
- Useful for management/application network separation

### DHCP vs Static IP Configuration

This module currently uses static IP configuration by default. To enable DHCP support:

**Required Changes:**
1. Add a `use_dhcp` boolean variable to control the network mode
2. Modify the `initialization` block in `main.tf` to use dynamic blocks:
   ```hcl
   dynamic "ip_config" {
     for_each = var.use_dhcp ? [1] : []
     content {
       ipv4 { dhcp = true }
     }
   }
   ```
3. Make IP-related variables optional when DHCP is enabled
4. Consider adding a `dhcp_hostname` variable for DHCP hostname requests

**Note:** Static IPs are recommended for infrastructure VMs like jump hosts to ensure predictable access.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.73.2 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >= 0.73.2 |
## Modules

No modules.
## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_file.user_data](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_file.vendor_data](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_vm.vm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ci_ssh_key"></a> [ci\_ssh\_key](#input\_ci\_ssh\_key) | SSH public key for cloud-init | `string` | n/a | yes |
| <a name="input_cloud_init_username"></a> [cloud\_init\_username](#input\_cloud\_init\_username) | Username for cloud-init | `string` | `"ansible"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers for the VM | `list(string)` | <pre>[<br/>  "8.8.8.8",<br/>  "8.8.4.4"<br/>]</pre> | no |
| <a name="input_enable_dual_network"></a> [enable\_dual\_network](#input\_enable\_dual\_network) | Enable dual network configuration with secondary NIC | `bool` | `true` | no |
| <a name="input_enable_user_data"></a> [enable\_user\_data](#input\_enable\_user\_data) | Enable user data for cloud-init (for packages and basic config) | `bool` | `false` | no |
| <a name="input_enable_vendor_data"></a> [enable\_vendor\_data](#input\_enable\_vendor\_data) | Enable vendor data for cloud-init | `bool` | `false` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | RAM in MB | `number` | `2048` | no |
| <a name="input_memory_floating"></a> [memory\_floating](#input\_memory\_floating) | Amount of floating memory in MB for ballooning (0 disables ballooning) | `number` | `0` | no |
| <a name="input_template_id"></a> [template\_id](#input\_template\_id) | Template VM ID to clone from | `number` | n/a | yes |
| <a name="input_template_node"></a> [template\_node](#input\_template\_node) | Source node where the template VM exists (e.g., 'lloyd') | `string` | n/a | yes |
| <a name="input_user_data_content"></a> [user\_data\_content](#input\_user\_data\_content) | Content for cloud-init user data (YAML format) | `string` | `""` | no |
| <a name="input_vcpu"></a> [vcpu](#input\_vcpu) | Number of vCPUs | `number` | `2` | no |
| <a name="input_vcpu_type"></a> [vcpu\_type](#input\_vcpu\_type) | CPU type (host, kvm64, etc.) | `string` | `"host"` | no |
| <a name="input_vendor_data_content"></a> [vendor\_data\_content](#input\_vendor\_data\_content) | Content for cloud-init vendor data | `string` | `""` | no |
| <a name="input_vm_bridge_1"></a> [vm\_bridge\_1](#input\_vm\_bridge\_1) | Primary network bridge | `string` | `"vmbr0"` | no |
| <a name="input_vm_bridge_2"></a> [vm\_bridge\_2](#input\_vm\_bridge\_2) | Secondary network bridge | `string` | `"vmbr1"` | no |
| <a name="input_vm_datastore"></a> [vm\_datastore](#input\_vm\_datastore) | Storage for VM disk | `string` | n/a | yes |
| <a name="input_vm_disk_size"></a> [vm\_disk\_size](#input\_vm\_disk\_size) | Disk size in GB | `number` | `32` | no |
| <a name="input_vm_gateway"></a> [vm\_gateway](#input\_vm\_gateway) | Default gateway for primary network | `string` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | Unique VM ID in Proxmox | `number` | n/a | yes |
| <a name="input_vm_ip_primary"></a> [vm\_ip\_primary](#input\_vm\_ip\_primary) | Primary IP address with CIDR | `string` | n/a | yes |
| <a name="input_vm_ip_secondary"></a> [vm\_ip\_secondary](#input\_vm\_ip\_secondary) | Secondary IP address with CIDR | `string` | `""` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the VM | `string` | n/a | yes |
| <a name="input_vm_node_name"></a> [vm\_node\_name](#input\_vm\_node\_name) | Proxmox node to place the VM on | `string` | n/a | yes |
| <a name="input_vm_tags"></a> [vm\_tags](#input\_vm\_tags) | List of tags to apply to the VM | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipv4_addresses"></a> [ipv4\_addresses](#output\_ipv4\_addresses) | All IPv4 addresses per network interface reported by the QEMU guest agent (empty list if the agent is disabled or not running) |
| <a name="output_primary_ip"></a> [primary\_ip](#output\_primary\_ip) | Primary IPv4 address - DEPRECATED: Use 'ipv4\_addresses' output instead |
| <a name="output_secondary_ip"></a> [secondary\_ip](#output\_secondary\_ip) | Secondary IPv4 address - DEPRECATED: Use 'ipv4\_addresses' output instead |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | The VM's numeric identifier in Proxmox |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | The VM's display name in Proxmox |
<!-- END_TF_DOCS -->
