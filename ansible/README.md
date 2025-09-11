# Ansible Configuration

This directory contains Ansible playbooks and configuration for post-deployment configuration of the jump-man VM.

## Directory Structure

```
ansible/
├── playbooks/           # Ansible playbooks
│   ├── site.yml        # Main playbook
│   ├── jump-man.yml    # Jump host specific configuration
│   └── hardening.yml   # Security hardening playbook
├── roles/              # Ansible roles
│   ├── docker/         # Docker installation and configuration
│   ├── security/       # Security hardening
│   └── monitoring/     # Monitoring setup
├── inventory/          # Inventory files
│   ├── hosts.yml       # Static inventory (generated from Terraform)
│   └── dynamic.py      # Dynamic inventory script
├── group_vars/         # Group variables
│   └── all.yml        # Variables for all hosts
├── host_vars/          # Host-specific variables
│   └── jump-man.yml   # Jump host variables
├── collections/        # Ansible collections
└── ansible.cfg         # Ansible configuration
```

## Purpose

As documented in [ADR-2025-09-02](../docs/decisions/20250902-ansible-post-deployment-config.md), Ansible handles post-deployment configuration that cloud-init cannot manage effectively:

- Complex software configurations
- Multi-step installations
- Service configurations requiring templates
- Security hardening
- Monitoring setup
- Docker and container management

## Integration with Terraform

Terraform handles infrastructure provisioning and outputs necessary information for Ansible:

1. **VM Creation**: Terraform creates the VM with basic cloud-init
2. **Inventory Generation**: Terraform outputs create Ansible inventory
3. **Ansible Execution**: Post-deployment playbooks configure the system

### Terraform Outputs Used

- `vm_ip`: IP address for Ansible to connect
- `vm_hostname`: Hostname for inventory
- `ssh_user`: User for Ansible connection (typically 'ansible')

## Quick Start

### 1. After Terraform Apply

```bash
# Generate inventory from Terraform outputs
terraform output -json > ansible/inventory/terraform-outputs.json

# Convert to Ansible inventory
python ansible/inventory/generate_inventory.py
```

### 2. Run Initial Configuration

```bash
cd ansible

# Run main playbook
ansible-playbook -i inventory/hosts.yml playbooks/site.yml

# Or specific playbook
ansible-playbook -i inventory/hosts.yml playbooks/jump-man.yml
```

### 3. Run Security Hardening

```bash
ansible-playbook -i inventory/hosts.yml playbooks/hardening.yml
```

## Playbooks

### site.yml

Main playbook that includes all configuration:

- Base system configuration
- Docker installation
- Security settings
- Monitoring setup

### jump-man.yml

Jump host specific configuration:

- Docker CE installation
- Developer tools
- Vault integration
- SSH hardening

### hardening.yml

Security hardening based on CIS benchmarks:

- Firewall configuration (iptables)
- SSH hardening
- Kernel parameters
- Audit logging

## Variables

### Required Variables

Set in `group_vars/all.yml` or pass via `-e`:

```yaml
# Docker configuration
docker_version: "latest"
docker_compose_version: "2.23.0"

# Security settings
enable_firewall: true
ssh_port: 22
allowed_ssh_ips: []

# Monitoring
enable_monitoring: false
prometheus_port: 9090
```

### Sensitive Variables

Store in vault files or pass at runtime:

```bash
# Create vault file
ansible-vault create group_vars/all/vault.yml

# Edit vault file
ansible-vault edit group_vars/all/vault.yml

# Run with vault
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --ask-vault-pass
```

## Mise Integration

Ansible tasks are integrated with mise:

```bash
# Run Ansible playbooks
mise run ansible-playbook site        # Main configuration
mise run ansible-playbook hardening   # Security hardening
mise run ansible-check                # Check mode (dry run)
mise run ansible-inventory            # Show inventory
```

## Testing

### Check Mode

Run in check mode to see what would change:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check
```

### Diff Mode

Show differences for file changes:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --diff
```

## Troubleshooting

### Connection Issues

```bash
# Test connection
ansible all -i inventory/hosts.yml -m ping

# Verbose mode
ansible-playbook -i inventory/hosts.yml playbooks/site.yml -vvv
```

### SSH Key Issues

Ensure SSH key is loaded:

```bash
ssh-add ~/.ssh/jump-man-key
ssh-add -l  # List loaded keys
```

### Inventory Issues

Verify inventory is correct:

```bash
ansible-inventory -i inventory/hosts.yml --list
ansible-inventory -i inventory/hosts.yml --graph
```

## Future Enhancements

- [ ] Dynamic inventory from Proxmox API
- [ ] Ansible AWX/Tower integration
- [ ] Automated testing with Molecule
- [ ] Integration with GitHub Actions
- [ ] Secrets management with HashiCorp Vault
