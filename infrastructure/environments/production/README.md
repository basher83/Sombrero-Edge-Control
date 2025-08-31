# Vault Production Environment 🔐

**Fully Automated Vault Infrastructure with Cloud-Init Magic!**

This directory contains the Terraform configuration for deploying a production-ready Vault cluster to Proxmox with **complete automation**. The infrastructure is 100% self-provisioning, including automatic Vault installation, configuration, and service setup.

## 🚀 Automation Features

### What Gets Automatically Installed

When you run `terraform apply`, each VM automatically gets:

✅ **System Updates** - Latest security patches
✅ **QEMU Guest Agent** - For proper Terraform destroy operations
✅ **DNS Configuration** - Reliable internet connectivity (8.8.8.8, 8.8.4.4)
✅ **HashiCorp Repository** - Official APT repository added
✅ **Vault Binary** - Latest Vault from HashiCorp (currently v1.20.2)
✅ **Vault Configuration** - Pre-configured `/etc/vault.d/vault.hcl`
✅ **Vault Directories** - Data and logs directories with proper permissions
✅ **Systemd Service** - Vault service configured and enabled
✅ **Environment Variables** - Vault CLI environment setup
✅ **Helper Scripts** - Documentation and cluster initialization helpers

### The Magic Behind the Scenes

Our enhanced cloud-init configuration (`vendor-data.yaml`) automatically:

1. **Installs Dependencies**: curl, unzip, jq, ca-certificates, gnupg, lsb-release
2. **Adds HashiCorp Repository**: Official GPG key and APT repository
3. **Installs Vault**: Latest version from HashiCorp repository
4. **Creates Vault User**: System user with proper home directory
5. **Sets Up Directories**: `/etc/vault.d/`, `/opt/vault/data/`, `/opt/vault/logs/`
6. **Configures Service**: Systemd service with security hardening
7. **Sets Permissions**: Proper file ownership and security settings
8. **Enables QEMU Agent**: For seamless Terraform lifecycle management
9. **Reboots System**: Clean startup with all services enabled

### Ready-to-Use Features

After deployment, each VM has:
- 📍 **Vault Binary**: `/usr/bin/vault`
- ⚙️ **Configuration**: `/etc/vault.d/vault.hcl`
- 💾 **Data Storage**: `/opt/vault/data/`
- 📝 **Logging**: `/opt/vault/logs/`
- 🔧 **Service Management**: `systemctl start vault`
- 🌐 **Environment**: `VAULT_ADDR` pre-configured
- 📚 **Documentation**: `/opt/vault/README.md`

## Architecture

The production environment deploys a 4-VM Vault cluster:

- **1x Master Vault** (vault-master): Auto-unseal provider with Transit engine
  - 2 vCPU, 4GB RAM, 40GB SSD
  - Provides auto-unseal service to production nodes

- **3x Production Vault Nodes** (vault-prod-1/2/3): Raft cluster members
  - 4 vCPU, 8GB RAM, 100GB SSD each
  - High availability configuration with Raft consensus

## Scalr Integration

This environment is configured for Scalr VCS-driven workflow:

- **Workspace**: `vault-production`
- **Backend**: Remote state managed by Scalr
- **Auto-apply**: Disabled (manual approval required)
- **Trigger paths**:
  - `infrastructure/environments/production/`
  - `infrastructure/modules/`

## Configuration

### Required Variables (Set in Scalr Workspace)

```hcl
pve_api_url       = "https://your-proxmox-host:8006/api2/json"
pve_api_token     = "user@pam!token-id=token-secret"
ci_ssh_key        = "ssh-ed25519 AAAA... your-key"
```

### Optional Variables

```hcl
vault_network_subnet = "192.168.10"  # Default network subnet
template_id         = 8000           # Ubuntu 22.04 template
vm_datastore        = "local-lvm"    # Storage location
vm_bridge_1         = "vmbr0"        # Network bridge
```

## 🚀 Quick Start Guide

### Option 1: Via Scalr (Recommended)

1. **Configure Variables**: Set required variables in Scalr workspace:
   - `pve_api_url`: Your Proxmox API endpoint
   - `pve_api_token`: API token with VM privileges
   - `ci_ssh_key`: Your SSH public key

2. **Deploy**: Push changes to VCS → Scalr auto-triggers → Review plan → Apply

3. **Wait**: ~3-5 minutes for complete deployment (cloud-init takes time!)

4. **Verify**: SSH to any VM and check: `vault version`

### Option 2: Local Development

```bash
# 1. Set up local variables
cp terraform.tfvars.example terraform.tfvars.local
vim terraform.tfvars.local  # Add your actual values

# 2. Deploy infrastructure
terraform init
terraform plan -var-file=terraform.tfvars.local
terraform apply -var-file=terraform.tfvars.local

# 3. Wait for cloud-init (3-5 minutes)
# 4. Test SSH and Vault installation
ssh ansible@192.168.10.30 "vault version"
```

## 🔧 Post-Deployment

### Verify Installation

```bash
# Check Vault installation on any VM
ssh ansible@192.168.10.30
vault version                    # Should show v1.20.2+
sudo systemctl status vault      # Should be enabled
ls -la /etc/vault.d/            # Config directory
ls -la /opt/vault/              # Data and logs
```

### Start Vault Service

```bash
# Vault is installed but not started (needs initialization first)
sudo systemctl start vault
vault status  # Should show "Vault is sealed"
```

### Next Steps

1. **Initialize Vault**: `vault operator init`
2. **Unseal Vault**: `vault operator unseal` (x3)
3. **Configure Authentication**: Set up auth methods
4. **Set up Auto-Unseal**: Configure transit engine on master
5. **Form Raft Cluster**: Join production nodes

## Deployment

## Network Configuration

| VM | IP Address | Role | Ports |
|---|---|---|---|
| vault-master | 192.168.10.30 | Auto-unseal Provider | 8200 (API) |
| vault-prod-1 | 192.168.10.31 | Production Node 1 | 8200 (API), 8201 (Raft) |
| vault-prod-2 | 192.168.10.32 | Production Node 2 | 8200 (API), 8201 (Raft) |
| vault-prod-3 | 192.168.10.33 | Production Node 3 | 8200 (API), 8201 (Raft) |

## High Availability

VMs are distributed across Proxmox nodes for fault tolerance:
- vault-master: lloyd
- vault-prod-1: holly
- vault-prod-2: mable
- vault-prod-3: lloyd

## Outputs

After deployment, Terraform provides:
- Individual VM details (IPs, IDs, node assignments)
- Vault API endpoints
- Ansible inventory for configuration management
- Cluster resource summary

## 🔍 Troubleshooting

### VM Not Accessible via SSH

```bash
# 1. Check if VM is running
ssh proxmox-node "qm status <VM-ID>"

# 2. VMs need 3-5 minutes for cloud-init to complete
# Check cloud-init status from VM console or wait longer

# 3. Clear old SSH host keys if recreating VMs
ssh-keygen -R 192.168.10.30
```

### Vault Not Installed

```bash
# Check if correct vendor-data was processed
ssh ansible@192.168.10.30 "sudo head -20 /var/lib/cloud/instance/vendor-data.txt"

# Should show enhanced cloud-config, not just qemu-guest-agent
# If only shows basic config, vendor-data.yaml needs to be updated on that Proxmox node
```

### Cloud-Init Issues

```bash
# Check cloud-init logs
ssh ansible@192.168.10.30 "sudo tail -50 /var/log/cloud-init.log"
ssh ansible@192.168.10.30 "sudo tail -50 /var/log/cloud-init-output.log"

# Check cloud-init status
ssh ansible@192.168.10.30 "cloud-init status"
```

### QEMU Guest Agent Not Working

```bash
# Test from Proxmox node
ssh proxmox-node "qm agent <VM-ID> ping"

# If no response, check service inside VM
ssh ansible@192.168.10.30 "sudo systemctl status qemu-guest-agent"
```

## 🔧 Technical Details

### Cloud-Init Configuration

Our infrastructure uses a sophisticated cloud-init setup:

- **User Data**: Handled by Terraform (SSH keys, network, user account)
- **Vendor Data**: Enhanced snippet (`/var/lib/vz/snippets/vendor-data.yaml`) on all Proxmox nodes
- **DNS Configuration**: Added via Terraform for reliable connectivity
- **Multi-Node Support**: Vendor-data distributed to lloyd, holly, mable

### Vendor-Data Snippet Location

```bash
# Snippet must exist on each Proxmox node where VMs are created
/var/lib/vz/snippets/vendor-data.yaml   # On lloyd, holly, mable
```

### Cloud-Init Processing Flow

1. **VM Creation**: Terraform creates VM with vendor-data reference
2. **First Boot**: Cloud-init processes user-data + vendor-data
3. **Package Updates**: System updates and HashiCorp repo added
4. **Vault Installation**: Official Vault package installed
5. **Configuration**: Vault config, directories, service setup
6. **Reboot**: System reboots with all services enabled
7. **Ready**: VM fully configured and accessible

### Important File Locations

```
/etc/vault.d/vault.hcl          # Main Vault configuration
/opt/vault/data/                # Vault data directory
/opt/vault/logs/                # Vault logs directory
/opt/vault/README.md            # Auto-generated documentation
/usr/bin/vault                  # Vault binary
/etc/systemd/system/vault.service  # Vault systemd service (if custom)
/var/log/cloud-init.log         # Cloud-init processing logs
/var/log/cloud-init-output.log  # Cloud-init command output
```

## Security Notes

- All sensitive variables should be configured in Scalr workspace
- Never commit terraform.tfvars with actual values
- Use terraform.tfvars.example as a template
- Enable TLS for all Vault communications
- Configure firewall rules to restrict access to Vault ports

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.73.2 |
## Providers

No providers.
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_jump_man"></a> [jump\_man](#module\_jump\_man) | ../../modules/vm | n/a |
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ci_ssh_key"></a> [ci\_ssh\_key](#input\_ci\_ssh\_key) | SSH public key for cloud-init user authentication | `string` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers for VMs | `list(string)` | <pre>[<br/>  "8.8.8.8",<br/>  "8.8.4.4"<br/>]</pre> | no |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Set true to skip TLS verification for Proxmox API (not recommended in production) | `bool` | `false` | no |
| <a name="input_pve_api_token"></a> [pve\_api\_token](#input\_pve\_api\_token) | Proxmox API token ID | `string` | n/a | yes |
| <a name="input_pve_api_url"></a> [pve\_api\_url](#input\_pve\_api\_url) | Proxmox API endpoint URL | `string` | n/a | yes |
| <a name="input_template_id"></a> [template\_id](#input\_template\_id) | Template ID for VM cloning | `number` | `8000` | no |
| <a name="input_template_node"></a> [template\_node](#input\_template\_node) | Node where the template VM exists | `string` | `"lloyd"` | no |
| <a name="input_vm_bridge_1"></a> [vm\_bridge\_1](#input\_vm\_bridge\_1) | Primary network bridge for VMs | `string` | `"vmbr0"` | no |
| <a name="input_vm_datastore"></a> [vm\_datastore](#input\_vm\_datastore) | Proxmox datastore for VM disks | `string` | `"local-lvm"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_inventory"></a> [ansible\_inventory](#output\_ansible\_inventory) | Ansible inventory in YAML format for jump host |
| <a name="output_jump_host"></a> [jump\_host](#output\_jump\_host) | Jump host (jump-man) VM details |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Network configuration for the jump host |
<!-- END_TF_DOCS -->
