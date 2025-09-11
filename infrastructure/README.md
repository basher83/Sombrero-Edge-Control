# Infrastructure Configuration

**Jump Host Infrastructure with Cloud-Init Automation**

This directory contains all Terraform code for provisioning and managing the jump host infrastructure on Proxmox. The infrastructure features complete automation with cloud-init for hands-off deployment.

## 🚀 Automation Features

### Cloud-Init Integration

Our infrastructure leverages cloud-init to provide:

✅ **Complete Software Installation** - Docker, DevOps tools, dependencies
✅ **Network Configuration** - Static IP with reliable DNS (8.8.8.8, 8.8.4.4)
✅ **QEMU Guest Agent** - Seamless Proxmox integration
✅ **Service Configuration** - Docker and nftables enabled and configured
✅ **Security Setup** - SSH key authentication, sudo access
✅ **Documentation** - README deployed to jump host for reference

### What Gets Deployed

When you run `terraform apply`, the jump host VM is fully configured with:

- 🐳 **Docker CE** - Latest version with Compose plugin
- 🛠️ **DevOps Tools** - Git, tmux, curl, wget, jq, Python3
- 🔒 **Security** - nftables firewall, SSH key-only access
- 🌐 **Networking** - Static IP 192.168.10.250/24
- 📊 **Monitoring** - QEMU guest agent for Proxmox visibility
- 💾 **Storage** - 32GB disk with proper partitioning

### Technical Implementation

- **User Data**: Terraform manages SSH keys, network config, user accounts
- **Vendor Data**: Cloud-init handles software installation and configuration
- **Memory Ballooning**: Efficient resource usage with floating memory
- **Static Networking**: Fixed IP assignment for reliable access

## Directory Structure

- **environments/** - Environment-specific Terraform configurations
  - **production/** - Production jump host configuration
- **modules/** - Reusable Terraform modules
  - **vm/** - Generic VM provisioning module with cloud-init support
- **versions.tf** - Global Terraform version constraints

## State Management

This project uses local state management with `backend_override.tf` for development. For production deployments, consider using remote state (Terraform Cloud, S3, etc.).

## Usage

Each environment directory contains a complete Terraform configuration:

### Initialize Terraform

```bash
cd environments/staging
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Changes

```bash
terraform apply
```

## Jump Host

### Overview

The infrastructure includes a dedicated jump host VM ("jump-man") for DevOps operations, providing a centralized management point decoupled from developer laptops.

### Jump Host Features

- **Ubuntu 24.04 LTS** base OS with latest updates
- **Docker CE** with Compose plugin for containerized services
- **Essential DevOps tools**: git, tmux, curl, wget, jq, python3
- **Security**: nftables with permissive baseline (hardening via Ansible)
- **Static networking**: 192.168.10.250/24 with reliable DNS
- **Memory ballooning**: 2GB RAM with 1GB floating for efficiency
- **SSH access**: ansible user with ED25519 key authentication

### Deploying the Jump Host

```bash
cd infrastructure/environments/production
terraform init
terraform plan
terraform apply
```

### Accessing the Jump Host

After deployment:

```bash
# SSH to the jump host
ssh ansible@192.168.10.250

# Verify services
systemctl status qemu-guest-agent
docker --version
```

### Post-Deployment

Additional configuration will be applied via Ansible:

- Security hardening with stricter nftables rules
- Installation of Node.js, npm, mise, uv tools
- Custom DevOps tooling and configurations

## Modules

### VM Module

The VM module provides flexible VM provisioning for Proxmox with:

- Configurable CPU, memory, and storage
- Optional dual-network support
- Cloud-init integration with optional vendor_data
- Memory ballooning support
- Tagging and metadata

Usage:

```hcl
module "jump_man" {
  source = "../../modules/vm"

  vm_name         = "jump-man"
  vm_id           = 7000
  vm_ip_primary   = "192.168.10.250/24"
  vm_gateway      = "192.168.10.1"
  vm_node_name    = "lloyd"

  # Optional parameters
  memory          = 2048
  memory_floating = 1024  # Ballooning
  enable_vendor_data = true
  vendor_data_content = file("cloud-init.yaml")
}
```

## Variable Management

### Environment Variables

The project uses environment variables for sensitive configuration. Set these in `.mise.local.toml`:

| Variable | Type | Sensitive | Example |
|----------|------|-----------|----------|
| **TF_VAR_pve_api_url** | string | No | `https://192.168.10.2:8006/api2/json` |
| **TF_VAR_pve_api_token** | string | **Yes** | `terraform@pve!token=xxx` |
| **TF_VAR_ci_ssh_key** | string | No | `ssh-ed25519 AAAA...` (public key) |
| **TF_VAR_proxmox_insecure** | bool | No | `true` (for self-signed certs) |

Example `.mise.local.toml`:

```toml
[env]
TF_VAR_pve_api_token = "terraform@pve!token=your-token"
TF_VAR_pve_api_url = "https://192.168.10.2:8006/api2/json"
TF_VAR_ci_ssh_key = "ssh-ed25519 AAAA... ansible@jump-man"
TF_VAR_proxmox_insecure = "true"
```

## Outputs

Each environment produces outputs that can be used by other tools:

- VM IP addresses and hostnames
- Network information
- Cluster details

These outputs are used to generate Ansible inventories and other configuration files.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.73.2 |

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
