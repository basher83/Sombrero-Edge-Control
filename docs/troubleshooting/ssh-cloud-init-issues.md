# SSH and Cloud-Init Troubleshooting Guide

**Date**: 2025-08-31
**Status**: ✅ Resolved
**Affected Components**: SSH connectivity, cloud-init, 1Password SSH agent, Terraform VM module

## Problem Summary

SSH connectivity to the jump-man VM was failing with authentication errors,
despite Terraform reporting successful deployment. The core issue was a **configuration conflict**
in the Proxmox Terraform provider between `user_account` and `user_data_file_id` directives.

## Symptoms Observed

1. **SSH Authentication Failures**

   ```bash
   ansible@192.168.10.250: Permission denied (publickey)
   ```

2. **Cloud-init Processing Issues**

   ```text
   WARNING: Unhandled non-multipart (text/x-not-multipart) userdata
   ```

3. **Missing Essential Packages**

   - qemu-guest-agent not installed/running
   - jq, Docker, and other packages missing
   - Scripts from vendor-data not created

4. **1Password SSH Key Mismatch**
   - SSH agent offering different keys than configured in Terraform
   - `jumpman_ed25519` key not loaded in SSH agent

## Root Cause Analysis

### Primary Issue: Proxmox Provider Configuration Conflict

**Problem**: The Terraform VM module was using **both** `user_account` and `user_data_file_id` simultaneously in the initialization block.

According to the [bpg/proxmox provider documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm):

```
- user_account - (Optional) The user account configuration (conflicts with user_data_file_id).
- user_data_file_id - (Optional) The identifier for a file containing custom user data (conflicts with user_account).
```

**Impact**: This conflict caused cloud-init to fail processing the user-data properly, resulting in:

- Essential packages not being installed
- User account configuration issues
- SSH key authentication problems

### Secondary Issues

1. **1Password SSH Agent Configuration**

   - Incorrect vault names (`Devops` vs `DevOps`)
   - Wrong item name (`jump-man` vs `jumpman_ed25519`)

2. **SSH Options Parsing**
   - Invalid SSH option: `StrictHostKeyChecking=accept-new`
   - Caused SSH command failures in smoke tests

## Solution Implementation

### 1. Fixed Proxmox Provider Conflict

**File**: `infrastructure/modules/vm/main.tf`

**Before** (Conflicting configuration):

```hcl
initialization {
  user_data_file_id = var.enable_user_data ? proxmox_virtual_environment_file.user_data[0].id : null
  vendor_data_file_id = var.enable_vendor_data ? proxmox_virtual_environment_file.vendor_data[0].id : null

  user_account {
    username = var.cloud_init_username
    keys     = [var.ci_ssh_key]
  }
}
```

**After** (Resolved with conditional logic):

```hcl
initialization {
  user_data_file_id   = var.enable_user_data ? proxmox_virtual_environment_file.user_data[0].id : null
  vendor_data_file_id = var.enable_vendor_data ? proxmox_virtual_environment_file.vendor_data[0].id : null

  # Only use user_account when user_data is not enabled (they conflict)
  dynamic "user_account" {
    for_each = var.enable_user_data ? [] : [1]
    content {
      username = var.cloud_init_username
      keys     = [var.ci_ssh_key]
    }
  }
}
```

### 2. Enhanced VM Module with User-Data Support

**Added variables** in `infrastructure/modules/vm/variables.tf`:

```hcl
variable "enable_user_data" {
  description = "Enable user data for cloud-init (for packages and basic config)"
  type        = bool
  default     = false
}

variable "user_data_content" {
  description = "Content for cloud-init user data (YAML format)"
  type        = string
  default     = ""
}
```

**Added user-data file resource** in `infrastructure/modules/vm/main.tf`:

```hcl
resource "proxmox_virtual_environment_file" "user_data" {
  count = var.enable_user_data ? 1 : 0

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.vm_node_name

  source_raw {
    file_name = "${var.vm_name}-user.yaml"
    data      = var.user_data_content
  }
}
```

### 3. Created Dedicated User-Data Configuration

**File**: `infrastructure/environments/production/cloud-init.jump-man-user-data.yaml`

Handles essential packages and user configuration:

```yaml
#cloud-config
hostname: jump-man
manage_etc_hosts: true
timezone: UTC

package_update: true
package_upgrade: true

packages:
  - qemu-guest-agent
  - wget
  - gpg
  - curl
  - unzip
  - jq
  - net-tools
  - ca-certificates
  - gnupg
  - lsb-release
  - software-properties-common
  - iptables
  - git
  - tmux
  - python3

users:
  - default
  - name: ${cloud_init_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ci_ssh_key}

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
```

### 4. Fixed 1Password SSH Agent Configuration

**File**: `~/.config/1Password/ssh/agent.toml`

**Corrections made**:

- Fixed vault name: `Devops` → `DevOps`
- Fixed item name: `jump-man` → `jumpman_ed25519`
- Fixed vault reference: `Personal` → `Private`

### 5. Fixed SSH Options in Smoke Test

**File**: `scripts/smoke-test.sh`

**Before**:

```bash
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"
```

**After**:

```bash
SSH_OPTS="-o ConnectTimeout=10"
```

## Implementation Steps Taken

1. **Identified the conflict** using bpg/proxmox provider documentation
1. **Updated VM module** to support conditional user_account usage
1. **Created separate user-data file** for essential packages
1. **Split responsibilities**:
   - **User-data**: Essential packages, user accounts, basic services
   - **Vendor-data**: Advanced configuration, Docker installation, scripts
1. **Fixed 1Password SSH configuration** for proper key loading
1. **Recreated VM** to apply new cloud-init configuration
1. **Verified resolution** with smoke tests

## Verification Results

### ✅ Successfully Resolved

- **SSH Connectivity**: Working with proper key authentication
- **Essential Packages**: All 15 packages installed correctly
- **QEMU Guest Agent**: Active and functional
- **User Account**: `ansible` user with proper sudo access
- **Network Configuration**: Static IP, DNS, gateway working
- **Infrastructure Tests**: All basic smoke tests passing

### ⏳ Remaining Issues (Secondary)

- **Vendor-data Processing**: Docker installation still not working
- **Advanced Configuration**: Some scripts not executing from vendor-data

## Lessons Learned

1. **Always check provider documentation** for configuration conflicts
1. **Separate concerns** between user-data (essential) and vendor-data (advanced)
1. **Test cloud-init configurations** incrementally
1. **Use conditional blocks** in Terraform for mutually exclusive options
1. **Validate 1Password SSH configuration** matches actual vault/item names

## Prevention Measures

1. **Added validation** in VM module for conflicting configurations
1. **Documented user-data vs user-account conflict** in module README
1. **Implemented proper error handling** in smoke tests
1. **Created troubleshooting documentation** (this document)

## Related Files

- `infrastructure/modules/vm/main.tf` - VM module with fixed configuration
- `infrastructure/modules/vm/variables.tf` - Added user-data variables
- `infrastructure/environments/production/main.tf` - Updated to use both user-data and vendor-data
- `infrastructure/environments/production/cloud-init.jump-man-user-data.yaml` - Essential packages and user config
- `infrastructure/environments/production/cloud-init.jump-man.yaml` - Advanced configuration (vendor-data)
- `~/.config/1Password/ssh/agent.toml` - Fixed SSH agent configuration
- `scripts/smoke-test.sh` - Fixed SSH options

## Commands for Future Reference

```bash
# Validate Terraform configuration
cd infrastructure/environments/production
terraform validate
terraform plan

# Recreate VM when cloud-init changes
terraform destroy -target=module.jump_man.proxmox_virtual_environment_vm.vm -auto-approve
terraform apply -auto-approve

# Test SSH connectivity
ssh -o ConnectTimeout=10 ansible@192.168.10.250 hostname

# Check cloud-init status
ssh ansible@192.168.10.250 'cloud-init status --long'

# Run smoke tests
mise run smoke-test

# Update SSH known_hosts after VM recreation
ssh-keygen -R 192.168.10.250
ssh-keyscan -t ed25519 192.168.10.250 >> ~/.ssh/known_hosts
```

## References

- [bpg/proxmox provider documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm)
- [Cloud-init documentation](https://cloud-init.readthedocs.io/)
- [1Password SSH Agent documentation](https://developer.1password.com/docs/ssh/agent/)
