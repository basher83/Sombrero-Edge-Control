# Ansible Collection Migration Guide

**Purpose**: Step-by-step technical guide for migrating from traditional Ansible structure to collection format  
**Estimated Time**: 2-4 weeks  
**Risk Level**: Medium (mitigated by parallel structure approach)

## Pre-Migration Checklist

- [ ] Back up current ansible/ directory
- [ ] Document all current playbook entry points
- [ ] List all external dependencies (requirements.yml)
- [ ] Identify custom filters/plugins if any
- [ ] Review current ansible-lint warnings
- [ ] Set up test environment

## Step 1: Create Collection Structure

```bash
# Create the collection directory structure
mkdir -p ansible_collections/sombrero/edge_control/{docs,meta,plugins,roles,playbooks,tests}
mkdir -p ansible_collections/sombrero/edge_control/plugins/{modules,filter,lookup,inventory}
mkdir -p ansible_collections/sombrero/edge_control/tests/{unit,integration}
```

## Step 2: Create Collection Metadata

### Create `ansible_collections/sombrero/edge_control/galaxy.yml`

```yaml
namespace: sombrero
name: edge_control
version: 1.0.0
readme: README.md
authors:
  - Sombrero Edge Control Team <team@example.com>
description: >-
  Ansible collection for managing jump host infrastructure on Proxmox,
  including Docker setup, security hardening, and development tools.
license:
  - GPL-3.0-or-later
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

### Create `ansible_collections/sombrero/edge_control/meta/runtime.yml`

```yaml
requires_ansible: ">=2.19.0"
action_groups:
  edge_control:
    - docker
    - docker_validation
    - firewall
    - development_tools
    - jump_host_base
    - security_hardening
    - smoke_test
```

## Step 3: Migrate Roles

```bash
# Copy roles to collection structure
cp -r ansible/roles/* ansible_collections/sombrero/edge_control/roles/

# Update role metadata to include collection namespace
for role in ansible_collections/sombrero/edge_control/roles/*/; do
  if [ -f "$role/meta/main.yml" ]; then
    # Add collection info to role metadata
    echo "Updating role metadata for $(basename $role)"
  fi
done
```

### Update Role Dependencies

**Before** (in `ansible/roles/docker/meta/main.yml`):

```yaml
dependencies:
  - role: firewall
```

**After** (in collection):

```yaml
dependencies:
  - role: sombrero.edge_control.firewall
```

## Step 4: Migrate Playbooks

### Copy and Update Playbooks

```bash
# Copy playbooks
cp ansible/playbooks/*.yml ansible_collections/sombrero/edge_control/playbooks/
```

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

**Updated** (collection version):

```yaml
- name: Post-deployment configuration
  hosts: jump_hosts
  collections:
    - sombrero.edge_control
  roles:
    - sombrero.edge_control.docker
    - sombrero.edge_control.docker_validation
    - sombrero.edge_control.development_tools  # Note: hyphen changed to underscore
    - sombrero.edge_control.firewall
```

## Step 5: Update Inventory and Variables

```bash
# Copy inventory structure
cp -r ansible/inventory ansible_collections/sombrero/edge_control/
cp -r ansible/group_vars ansible_collections/sombrero/edge_control/
cp -r ansible/host_vars ansible_collections/sombrero/edge_control/
```

## Step 6: Configure ansible.cfg

Create/update `ansible.cfg`:

```ini
[defaults]
collections_paths = ./ansible_collections:~/.ansible/collections:/usr/share/ansible/collections
roles_path = ./ansible_collections/sombrero/edge_control/roles
inventory = ./ansible_collections/sombrero/edge_control/inventory/hosts.yml

[galaxy]
server_list = release_galaxy

[galaxy_server.release_galaxy]
url = https://galaxy.ansible.com
```

## Step 7: Update ansible-lint Configuration

Create/update `.ansible-lint`:

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
  - ansible/  # Exclude old structure during migration

use_default_rules: true
enable_list:
  - fqcn  # Enforce fully qualified collection names
  - no-same-owner

skip_list: []

warn_list:
  - experimental  # Warn on experimental features

# Collection-specific settings
collections_path:
  - ./ansible_collections

# Define FQCN mapping for migration
fqcn:
  - sombrero.edge_control
```

## Step 8: Test Migration

### Run ansible-lint

```bash
# Test the collection structure
ansible-lint ansible_collections/sombrero/edge_control/playbooks/*.yml

# Run specific role tests
ansible-lint ansible_collections/sombrero/edge_control/roles/docker/
```

### Test Playbook Execution

```bash
# Test in check mode first
ansible-playbook -i ansible_collections/sombrero/edge_control/inventory/hosts.yml \
  ansible_collections/sombrero/edge_control/playbooks/post-deploy.yml \
  --check --diff

# Run smoke tests
ansible-playbook -i ansible_collections/sombrero/edge_control/inventory/hosts.yml \
  ansible_collections/sombrero/edge_control/playbooks/smoke-test.yml
```

## Step 9: Update CI/CD

### Update GitHub Actions

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
          path: "ansible_collections/sombrero/edge_control"
```

### Update mise tasks

```toml
# .mise.toml updates
[tasks.ansible-lint]
run = "ansible-lint ansible_collections/sombrero/edge_control/"
description = "Lint Ansible collection"

[tasks.ansible-test]
run = "ansible-playbook -i ansible_collections/sombrero/edge_control/inventory/hosts.yml ansible_collections/sombrero/edge_control/playbooks/site.yml --check"
description = "Test Ansible playbooks in check mode"
```

## Step 10: Update Terraform Integration

Update Terraform provisioners to use collection paths:

```hcl
provisioner "local-exec" {
  command = "ansible-playbook -i ansible_collections/sombrero/edge_control/inventory/hosts.yml ansible_collections/sombrero/edge_control/playbooks/post-deploy.yml"
}
```

## Step 11: Documentation Updates

1. Update main README.md with new structure
2. Create ansible_collections/sombrero/edge_control/README.md
3. Update CLAUDE.md with new paths
4. Document FQCN usage for team

## Step 12: Cutover

1. **Final Testing**: Run full deployment in test environment
2. **Team Communication**: Notify team of structure change
3. **Archive Old Structure**:

   ```bash
   mv ansible ansible.old
   ```

4. **Update Default Paths**: Make collection structure primary
5. **Monitor**: Watch for any issues in first production runs

## Rollback Plan

If issues arise:

```bash
# Quick rollback
mv ansible.old ansible
mv ansible_collections ansible_collections.backup

# Update ansible.cfg to point back to original paths
```

## Post-Migration Validation

- [ ] All playbooks execute successfully
- [ ] ansible-lint shows zero errors
- [ ] CI/CD pipelines pass
- [ ] Terraform integration works
- [ ] Documentation updated
- [ ] Team trained on new structure

## Common Issues and Solutions

### Issue: "Role not found"

**Solution**: Ensure FQCN is used: `sombrero.edge_control.role_name`

### Issue: "Collection not found"

**Solution**: Check `collections_paths` in ansible.cfg

### Issue: Variables not loading

**Solution**: Verify group_vars/host_vars are in collection path

### Issue: Inventory not found

**Solution**: Update ansible.cfg inventory path or use -i flag

## Benefits After Migration

1. ✅ Full ansible-lint compliance
2. ✅ Portable, versioned collection
3. ✅ Better dependency management
4. ✅ Standardized structure
5. ✅ Ready for Ansible Galaxy publishing
6. ✅ Improved CI/CD integration
7. ✅ Professional code organization
