# Terraform Modules

Reusable Terraform modules for infrastructure provisioning.

## Available Modules

### VM Module

A flexible Proxmox VM provisioning module with cloud-init support.

**Features:**

- Dynamic VM creation with customizable resources
- Optional dual-network configuration
- Cloud-init integration (user_data and vendor_data)
- Memory ballooning support
- QEMU guest agent configuration
- Flexible tagging system

**Usage Example:**

```hcl
module "my_vm" {
  source = "./modules/vm"

  # Required parameters
  vm_name       = "my-server"
  vm_id         = 1001
  vm_node_name  = "proxmox-node"
  vm_ip_primary = "192.168.1.10/24"
  vm_gateway    = "192.168.1.1"

  # Optional configurations
  vcpu            = 2
  memory          = 2048
  memory_floating = 1024  # Enable ballooning
  vm_disk_size    = 32

  # Cloud-init
  cloud_init_username = "ansible"
  ci_ssh_key         = "ssh-ed25519 AAAA..."
  enable_vendor_data = true
  vendor_data_content = file("cloud-init.yaml")

  # Networking
  enable_dual_network = false
  dns_servers        = ["8.8.8.8", "8.8.4.4"]

  # Tags
  vm_tags = ["terraform", "production"]
}
```

**Key Variables:**

- `enable_vendor_data`: Makes vendor_data optional (default: false)
- `memory_floating`: Enables memory ballooning when > 0
- `enable_dual_network`: Configures second network interface

For complete documentation, see [VM Module README](vm/README.md).

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- END_TF_DOCS -->
