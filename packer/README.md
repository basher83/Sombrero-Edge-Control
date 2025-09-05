# Packer VM Template Builder

This directory contains Packer configurations for building Proxmox VM templates with pre-configured software and settings.

## Overview

The Packer template creates an Ubuntu 24.04 LTS (Numbat) VM template with:
- Docker CE pre-installed
- Cloud-init support
- 2GB swap configuration
- QEMU Guest Agent
- SSH key authentication setup
- Ansible user pre-configured

## Directory Structure

```
packer/
├── ubuntu-server-numbat-docker.pkr.hcl  # Main Packer template
├── variables.pkrvars.hcl.example        # Example variables file
├── files/
│   └── 99-pve.cfg                      # Cloud-init datasource configuration
└── http/
    └── user-data                       # Ubuntu autoinstall configuration
```

## Prerequisites

1. **Proxmox API Access**: Valid API token with VM creation permissions
2. **Ubuntu ISO**: Upload Ubuntu 24.04 Server ISO to Proxmox storage
3. **Network Access**: Packer needs access to Proxmox API and VM network
4. **SSH Key**: For passwordless authentication to the created template

## Configuration

### 1. Create Variables File

Copy the example and customize:

```bash
cp variables.pkrvars.hcl.example variables.pkrvars.hcl
```

Edit `variables.pkrvars.hcl`:

```hcl
proxmox_api_url          = "https://proxmox.example.com:8006/api2/json"
proxmox_api_token_id     = "packer@pve!packer-token"
proxmox_api_token_secret = "your-secret-token-here"
proxmox_node_name        = "lloyd"
instance_username        = "ansible"
instance_password        = "temporary-password"
```

### 2. Update HTTP Directory

The `http/` directory contains the Ubuntu autoinstall configuration:

```bash
# Ensure the HTTP server can serve the autoinstall config
cp http.example/user-data http/user-data

# Add your SSH public key to http/user-data
# Look for the ssh_authorized_keys section and add your key
```

## Building the Template

### Using Mise Tasks

```bash
# Initialize Packer plugins
mise run packer-init

# Validate the template
mise run packer-validate

# Build the VM template
mise run packer-build

# Debug build if needed
mise run packer-build-debug
```

### Direct Packer Commands

```bash
cd packer

# Initialize plugins
packer init .

# Validate configuration
packer validate ubuntu-server-numbat-docker.pkr.hcl

# Build the template
packer build ubuntu-server-numbat-docker.pkr.hcl
```

## Template Details

### VM Specifications

- **VM ID**: 1001
- **Name**: ubuntu-server-numbat
- **OS**: Ubuntu 24.04 LTS
- **CPU**: 1 core
- **RAM**: 2048 MB
- **Disk**: 20GB (virtio, raw format)
- **Network**: virtio on vmbr0
- **Features**: QEMU Guest Agent, Cloud-init

### Installed Software

The template includes:
- Docker CE (latest stable)
- Docker Compose
- QEMU Guest Agent
- Cloud-init
- Basic system utilities

### Cloud-init Configuration

The template is configured for Proxmox cloud-init integration:
- Datasources: ConfigDrive, NoCloud
- Network configuration via cloud-init
- User data injection support
- SSH key management

## Post-Build Usage

### 1. Clone VM from Template

In Proxmox or via Terraform:

```hcl
resource "proxmox_virtual_environment_vm" "example" {
  clone {
    vm_id = 1001  # The template ID
  }
  # ... additional configuration
}
```

### 2. Configure with Cloud-init

The template supports cloud-init for:
- Setting hostname
- Configuring network interfaces
- Adding SSH keys
- Running first-boot scripts

### 3. Post-Deployment with Ansible

After VM creation, use Ansible for additional configuration:

```bash
# From the ansible directory
ansible-playbook -i inventory/hosts.yml playbooks/jump-man.yml
```

## Customization

### Modifying the Template

1. **Change Ubuntu Version**: Update the ISO file path in the template
2. **Add Software**: Modify provisioner sections to install additional packages
3. **Adjust Resources**: Change CPU, memory, or disk settings
4. **Network Configuration**: Modify network adapter settings

### Adding New Provisioners

Add provisioners to the build section:

```hcl
provisioner "shell" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y your-package"
  ]
}
```

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Verify Proxmox API URL and credentials
   - Check network connectivity
   - Ensure API token has correct permissions

2. **ISO Not Found**
   - Verify ISO is uploaded to specified storage pool
   - Check ISO filename matches template configuration

3. **SSH Connection Timeout**
   - Ensure SSH key is correctly added to autoinstall
   - Check network configuration allows SSH access
   - Verify cloud-init completed successfully

4. **Build Hangs**
   - Check Proxmox console for boot issues
   - Verify autoinstall configuration is valid
   - Use debug mode: `mise run packer-build-debug`

### Debug Commands

```bash
# View Packer debug output
PACKER_LOG=1 packer build ubuntu-server-numbat-docker.pkr.hcl

# Check template on Proxmox
qm config 1001

# Verify cloud-init status in VM
cloud-init status --long
```

## Integration with Infrastructure Pipeline

### Complete Pipeline

```mermaid
graph LR
    A[Packer Build] --> B[VM Template]
    B --> C[Terraform Deploy]
    C --> D[Cloud-init Bootstrap]
    D --> E[Ansible Configure]
```

1. **Packer**: Creates golden image with base software
2. **Terraform**: Clones template and provisions infrastructure
3. **Cloud-init**: Performs initial VM configuration
4. **Ansible**: Handles complex post-deployment setup

### When to Use Each Tool

- **Packer**: Base OS, universal software, system settings
- **Cloud-init**: Instance-specific settings, network config, SSH keys
- **Ansible**: Application deployment, security hardening, ongoing management

## Maintenance

### Updating Templates

1. Regular updates for security patches:
   ```bash
   # Rebuild template monthly
   mise run packer-build
   ```

2. Version management:
   - Tag template builds with dates
   - Keep previous template for rollback
   - Document changes in build notes

### Template Versioning

Consider using VM ID ranges:
- 1000-1099: Ubuntu 22.04 templates
- 1100-1199: Ubuntu 24.04 templates
- 1200-1299: Rocky/Alma Linux templates

## Resources

- [Packer Documentation](https://www.packer.io/docs)
- [Proxmox Provider for Packer](https://www.packer.io/plugins/builders/proxmox)
- [Ubuntu Autoinstall](https://ubuntu.com/server/docs/install/autoinstall)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
