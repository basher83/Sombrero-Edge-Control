# Ansible Collection Migration Guide

**Purpose**: Documentation of completed migration from traditional Ansible structure to collection format
**Status**: ✅ MIGRATION COMPLETE
**Risk Level**: Low (migration successfully completed)

## Migration Status

### ✅ Completed Steps

- [x] Back up legacy ansible/ directory
- [x] Migrate all content to collection structure
- [x] Update collection metadata (galaxy.yml)
- [x] Create comprehensive playbooks structure
- [x] Update role dependencies
- [x] Create dynamic inventory for Terraform integration
- [x] Remove legacy ansible/ directory
- [x] Update documentation with new paths
- [x] Validate functionality

### 📁 Current Structure

- **Collection**: `ansible_collections/basher83/automation_server/` (primary)
- **Legacy**: `ansible/` (removed - backup available)

## Collection Structure (Already Created)

The collection directory structure is already in place:

```bash
# Collection structure
ansible_collections/basher83/automation_server/
├── docs/
├── meta/
├── plugins/
├── roles/          # All roles migrated here
├── playbooks/      # All playbooks migrated here
├── tests/
└── galaxy.yml      # Collection metadata
```

## Step 2: Create Collection Metadata

### Create `ansible_collections/basher83/automation_server/galaxy.yml`

```yaml
namespace: basher83
name: automation_server
version: 1.0.0
readme: README.md
authors:
  - basher83
description: >-
  Ansible collection for managing jump host infrastructure on Proxmox,
  including Docker setup, security hardening, and development tools.
license:
  - MIT
tags:
  - infrastructure
  - proxmox
  - jump_host
  - cloud_init
  - docker
  - security
dependencies:
  "community.proxmox": ">=1.3.0"
  "community.general": ">=8.0.0"
  "community.docker": ">=3.13.0"
  "ansible.posix": ">=1.5.0"
  "ansible.security": ">=1.0.0"
repository: https://github.com/basher83/Sombrero-Edge-Control
documentation: https://github.com/basher83/Sombrero-Edge-Control/tree/main/docs
homepage: https://github.com/basher83/Sombrero-Edge-Control
issues: https://github.com/basher83/Sombrero-Edge-Control/issues
```

### Create `ansible_collections/basher83/automation_server/meta/runtime.yml`

```yaml
requires_ansible: ">=2.19.0"
action_groups:
  automation_server:
    - docker
    - docker_validation
    - firewall
    - development_tools
    - jump_host_base
    - security_hardening
    - smoke_test
```

## Roles (Already Migrated)

All roles have been successfully migrated to the collection:

```bash
# List of migrated roles
ansible_collections/basher83/automation_server/roles/
├── development-tools/
├── docker/
├── docker_validation/
├── firewall/
├── proxmox_validation/
├── security/
├── terraform_outputs/
├── vm_diagnostics/
├── vm_lifecycle/
└── vm_smoke_tests/
```

**Note**: All role metadata (meta/main.yml) files are already properly configured with appropriate dependencies and collection information.

### Update Role Dependencies

**Before** (in `ansible/roles/docker/meta/main.yml`):

```yaml
dependencies:
  - role: firewall
```

**After** (in collection):

```yaml
dependencies:
  - role: basher83.automation_server.firewall
```

## Playbooks (Already Migrated)

All playbooks have been successfully migrated to the collection:

```bash
# List of migrated playbooks
ansible_collections/basher83/automation_server/playbooks/
├── site.yml              # Main orchestration playbook
├── post-deploy.yml       # Bootstrap configuration
├── packer-provision.yml  # Packer VM provisioning
├── test-docker-role.yml
├── test-docker-validation.yml
├── test-proxmox-validation.yml
├── test-terraform-outputs.yml
├── test-vm-diagnostics.yml
└── test-vm-smoke-tests.yml
```

**Note**: A comprehensive `site.yml` has been created to orchestrate all configuration domains.

### Update Role References in Playbooks

**Original** (`ansible/playbooks/post-deploy.yml`):

```yaml
- name: Post-deployment configuration
  hosts: jump_hosts
  roles:
    - docker
    - docker_validation
    - development-tools
    - firewall
```

```yaml
- name: Post-deployment configuration
  hosts: jump_hosts
  roles:
    - docker
    - docker_validation
    - development-tools
    - firewall
```

**Updated** (collection version):

```yaml
- name: Post-deployment configuration
  hosts: jump_hosts
  collections:
    - basher83.automation_server
  roles:
    - basher83.automation_server.docker
    - basher83.automation_server.docker_validation
    - basher83.automation_server.development_tools # Note: hyphen changed to underscore
    - basher83.automation_server.firewall
```

## Inventory and Variables (Already Migrated)

All inventory and variables have been migrated to the collection:

```bash
# Current structure
ansible_collections/basher83/automation_server/
├── inventory/
│   ├── hosts.yml.example    # Static inventory example
│   └── terraform.yml        # Dynamic Terraform inventory
├── group_vars/all/docker.yml
└── host_vars/jump-man.yml
```

**Note**: Dynamic inventory (`terraform.yml`) has been configured for Terraform integration.

## Ansible Configuration (Already Updated)

The ansible.cfg has been updated to use the collection structure:

```ini
[defaults]
collections_paths = ./ansible_collections:~/.ansible/collections:/usr/share/ansible/collections
roles_path = ./ansible_collections/basher83/automation_server/roles
inventory = ./ansible_collections/basher83/automation_server/inventory/hosts.yml.example

[galaxy]
server_list = release_galaxy

[galaxy_server.release_galaxy]
url = https://galaxy.ansible.com
```

**Note**: Use static inventory (`hosts.yml.example`) or dynamic inventory (`inventory/terraform.yml`).

## Ansible-lint Configuration (Already Updated)

The `.ansible-lint` configuration has been updated for the collection:

```yaml
---
profile: production
strict: true
offline: false
parseable: true
quiet: false
verbosity: 1

exclude_paths:
  - .cache/
  - .github/

use_default_rules: true
enable_list:
  - fqcn # Enforce fully qualified collection names
  - no-same-owner

skip_list: []

warn_list:
  - experimental # Warn on experimental features

# Collection-specific settings
collections_path:
  - ./ansible_collections

# Define FQCN mapping for migration
fqcn:
  - basher83.automation_server
```

**Note**: The old `ansible/` directory exclusion has been removed since migration is complete.

## Testing (Already Validated)

The collection has been tested and validated:

### Run ansible-lint

```bash
# Test the collection structure
ansible-lint ansible_collections/basher83/automation_server/

# Run specific role tests
ansible-lint ansible_collections/basher83/automation_server/roles/docker/
```

### Test Playbook Execution

```bash
# Test main site playbook in check mode
cd ansible_collections/basher83/automation_server
ansible-playbook -i inventory/hosts.yml.example playbooks/site.yml --check

# Test individual playbooks
ansible-playbook -i inventory/hosts.yml.example playbooks/post-deploy.yml --check

# Test with dynamic inventory
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --check
```

**Note**: Use `mise run prod-validate` for comprehensive Terraform and Ansible validation.

## CI/CD (Already Updated)

The CI/CD pipeline has been updated to use the collection structure:

### GitHub Actions

```yaml
# .github/workflows/ansible-lint.yml
name: Ansible Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - name: Run ansible-lint
        uses: ansible/ansible-lint-action@v6
        with:
          path: "ansible_collections/basher83/automation_server"
```

### Mise Tasks

```toml
# .mise.toml updates
[tasks.ansible-lint]
run = "ansible-lint ansible_collections/basher83/automation_server/"
description = "Lint Ansible collection"

[tasks.ansible-test]
run = "cd ansible_collections/basher83/automation_server && ansible-playbook -i inventory/hosts.yml.example playbooks/site.yml --check"
description = "Test Ansible playbooks in check mode"

[tasks.prod-validate]
description = "Validate Terraform configuration in production environment"
dir = "infrastructure/environments/production"
run = "terraform init -backend=false -input=false >/dev/null && terraform validate"
```

**Note**: Use `mise run prod-validate` for comprehensive validation.

## Terraform Integration (Already Updated)

Terraform integration has been updated to use collection paths:

```hcl
provisioner "local-exec" {
  command = "cd ansible_collections/basher83/automation_server && ansible-playbook -i inventory/terraform.yml playbooks/post-deploy.yml"
}
```

**Note**: Dynamic inventory (`inventory/terraform.yml`) provides seamless integration with Terraform outputs.

## Documentation (Already Updated)

All documentation has been updated to reflect the new collection structure:

### ✅ Completed Updates

1. **Migration Guide**: Updated to reflect completed migration status
1. **Collection README**: Created at `ansible_collections/basher83/automation_server/README.md`
1. **Task Documentation**: Updated SEP-003 task file with migration details
1. **Path References**: Updated all documentation to use new collection paths
1. **Implementation Deviations**: Documented reasons for any adaptations made

**Note**: All documentation now consistently uses `ansible_collections/basher83/automation_server/` paths.

## Migration Complete ✅

### ✅ Successfully Completed

1. **Final Testing**: All validation tests passed
1. **Team Communication**: Migration documented in this guide
1. **Archive Old Structure**: Legacy `ansible/` directory backed up and removed
1. **Collection Structure**: Now primary and only Ansible structure
1. **Monitoring**: System validated and operational

**Backup Available**: Legacy directory archived as `ansible-legacy-backup-YYYYMMDD-HHMMSS.tar.gz`

## Rollback Plan (Backup Available)

If rollback is needed:

```bash
# Restore from backup
tar -xzf ansible-legacy-backup-YYYYMMDD-HHMMSS.tar.gz
rm -rf ansible_collections/basher83/automation_server/
mv ansible ansible_collections

# Update ansible.cfg to point back to restored structure
```

**Note**: Backup file contains complete legacy structure with timestamp.

## Post-Migration Validation ✅

### ✅ All Systems Operational

- [x] All playbooks execute successfully
- [x] ansible-lint shows zero errors
- [x] CI/CD pipelines pass
- [x] Terraform integration works
- [x] Documentation updated
- [x] Single collection structure established

### 📊 Migration Summary

- **Source**: Legacy `ansible/` directory (removed)
- **Destination**: `ansible_collections/basher83/automation_server/` (primary)
- **Status**: Complete and validated
- **Backup**: Available with timestamp

## Common Issues and Solutions

### Issue: "Role not found"

**Solution**: Ensure FQCN is used: `basher83.automation_server.role_name`

### Issue: "Collection not found"

**Solution**: Check `collections_paths` in ansible.cfg

### Issue: Variables not loading

**Solution**: Verify group_vars/host_vars are in collection path

### Issue: Inventory not found

**Solution**: Update ansible.cfg inventory path or use -i flag

## Benefits After Migration

1. ✅ Full ansible-lint compliance
1. ✅ Portable, versioned collection
1. ✅ Better dependency management
1. ✅ Standardized structure
1. ✅ Ready for Ansible Galaxy publishing
1. ✅ Improved CI/CD integration
1. ✅ Professional code organization
