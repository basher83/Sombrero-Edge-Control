---
Task: Simplify Cloud-init to SSH Only
Task ID: SEP-002
Priority: P0 (Critical)
Estimated Time: 1 hour
Dependencies: None
Status: 🔄 Ready
---

## Objective

Simplify the cloud-init configuration to provide only minimal SSH access for the ansible user. Remove all package installations, script executions, and configuration management from cloud-init, delegating these responsibilities to Ansible.

## Prerequisites

- [ ] Access to infrastructure code
- [ ] Understanding of current cloud-init configuration
- [ ] Backup of existing cloud-init files

## Implementation Steps

### 1. **Backup Current Configuration**

```bash
cd infrastructure/environments/production
cp cloud-init.jump-man.yaml cloud-init.jump-man.yaml.backup
```

### 2. **Create Minimal Cloud-init Configuration**

Replace `infrastructure/environments/production/cloud-init.jump-man.yaml`:

```yaml
#cloud-config
hostname: jump-man
manage_etc_hosts: true
preserve_hostname: false

# Create ansible user with SSH access only
users:
  - name: ansible
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_authorized_key}

# Minimal network configuration
write_files:
  - path: /etc/netplan/99-static.yaml
    content: |
      network:
        version: 2
        ethernets:
          ens18:
            addresses: [192.168.10.250/24]
            gateway4: 192.168.10.1
            nameservers:
              addresses: [1.1.1.1, 1.0.0.1]

# Apply network configuration
runcmd:
  - netplan apply

# Remove all package installations
# Remove all script downloads and executions
# Remove firewall configuration
# Remove Docker installation
```

### 3. **Remove Script References**

Delete external script files no longer needed:

```bash
cd infrastructure/environments/production
rm -f scripts/docker-install.sh
rm -f scripts/firewall-setup.sh
rm -f scripts/tools-install.sh
```

### 4. **Update Terraform Module**

Modify `infrastructure/modules/vm/main.tf` to use simplified cloud-init:

```hcl
resource "proxmox_vm_qemu" "vm" {
  # ... existing configuration ...

  # Simplified cloud-init
  ciuser  = "ansible"
  sshkeys = var.ssh_authorized_keys

  # Remove vendor data references
  # cicustom = "vendor=local:snippets/vendor-data.yaml"
}
```

### 5. **Update Variable Descriptions**

Update `infrastructure/modules/vm/variables.tf`:

```hcl
variable "cloud_init_user_data" {
  description = "Minimal cloud-init for SSH access only"
  type        = string
  default     = null
}
```

## Success Criteria

- [ ] Cloud-init file < 50 lines
- [ ] Only creates ansible user with SSH key
- [ ] Sets static IP address
- [ ] No package installations in cloud-init
- [ ] No script downloads or executions
- [ ] VM boots with SSH access available
- [ ] Ansible can connect to VM

## Validation

### Configuration Validation

```bash
# Validate YAML syntax
yamllint infrastructure/environments/production/cloud-init.jump-man.yaml

# Check file size and complexity
wc -l infrastructure/environments/production/cloud-init.jump-man.yaml
# Should be < 50 lines

# MANDATORY: Validate Terraform configuration
cd infrastructure/environments/production
tflint --init
tflint
```

### Deployment Testing

```bash
# Deploy with minimal cloud-init
cd infrastructure/environments/production

# MANDATORY: Initialize and run tflint first
tflint --init
tflint

# Only proceed if tflint passes
terraform plan
terraform apply

# Test SSH access
ssh ansible@192.168.10.250 "whoami"
# Output: ansible

# Verify no packages installed
ssh ansible@192.168.10.250 "docker --version"
# Should fail - command not found

# Test Ansible connectivity
ansible -i inventory.json jump_hosts -m ping
```

Expected output:

- SSH connection succeeds
- No Docker or other tools installed
- Ansible can connect and run commands

## Notes

- This change requires Ansible to handle all configuration
- Ensure ANS-001 (Bootstrap Playbook) is ready before production deployment
- Keep backup configuration for emergency rollback
- Document that all software installation now happens via Ansible

## References

- [Pipeline Separation ADR](../../../decisions/20250118-pipeline-separation.md)
- [Current cloud-init configuration](../../../../infrastructure/environments/production/cloud-init.jump-man.yaml)
- [Terraform VM Module](../../../../infrastructure/modules/vm/main.tf)
