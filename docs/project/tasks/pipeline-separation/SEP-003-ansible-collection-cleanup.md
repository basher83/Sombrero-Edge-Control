---
Task: Ansible Collection Cleanup
Task ID: SEP-003
Priority: P0 (Critical)
Estimated Time: 2 hours
Dependencies: None
Status: 🔄 Ready
---

## Objective

Complete the migration to the Ansible collection structure (`ansible_collections/basher83/automation_server/`) and remove the duplicate legacy `ansible/` directory. This establishes a single source of truth for all configuration management and eliminates code duplication.

## Prerequisites

- [ ] Backup of existing Ansible directories
- [ ] Understanding of collection structure
- [ ] List of all playbooks and roles in use

## Implementation Steps

### 1. **Audit Current State**

```bash
# List all content in legacy directory
find ansible/ -type f -name "*.yml" -o -name "*.yaml" | sort

# List all content in collection
find ansible_collections/basher83/automation_server/ -type f -name "*.yml" -o -name "*.yaml" | sort

# Identify unique content in legacy directory
diff <(find ansible/ -type f -exec basename {} \; | sort) \
     <(find ansible_collections/ -type f -exec basename {} \; | sort)
```

### 2. **Migrate Missing Components**

Transfer any unique playbooks or roles from `ansible/` to collection:

```bash
# Example migration of missing roles
cp -r ansible/roles/missing_role ansible_collections/basher83/automation_server/roles/

# Example migration of inventory
cp ansible/inventory/* ansible_collections/basher83/automation_server/inventory/
```

### 3. **Update Collection Metadata**

Update `ansible_collections/basher83/automation_server/galaxy.yml`:

```yaml
namespace: basher83
name: automation_server
version: 1.0.0
readme: README.md
authors:
  - Infrastructure Team
description: Complete configuration management for jump-man server
license:
  - MIT
tags:
  - infrastructure
  - automation
  - jump-host
dependencies: {}
repository: https://github.com/basher83/Sombrero-Edge-Control
```

### 4. **Create Comprehensive Playbooks**

Ensure all configuration domains are covered:

```yaml
# ansible_collections/basher83/automation_server/playbooks/site.yml
---
- name: Complete Jump Host Configuration
  hosts: jump_hosts
  become: true

  tasks:
    - name: Run bootstrap configuration
      import_playbook: bootstrap.yml

    - name: Apply baseline configuration
      import_playbook: baseline.yml

    - name: Install Docker
      import_playbook: docker.yml

    - name: Apply security hardening
      import_playbook: security.yml

    - name: Install development tools
      import_playbook: development.yml
```

### 5. **Update Role Dependencies**

Ensure roles have proper dependencies in `meta/main.yml`:

```yaml
# Example: ansible_collections/basher83/automation_server/roles/docker/meta/main.yml
dependencies:
  - role: automation_server_base
```

### 6. **Create Dynamic Inventory**

Set up Terraform dynamic inventory:

```yaml
# ansible_collections/basher83/automation_server/inventory/terraform.yml
---
plugin: cloud.terraform.terraform_provider
project_path: ../../../infrastructure/environments/production
```

### 7. **Remove Legacy Directory**

After verification, remove the old structure:

```bash
# Final backup
tar -czf ansible-legacy-backup-$(date +%Y%m%d).tar.gz ansible/

# Remove legacy directory
rm -rf ansible/
```

### 8. **Update Documentation**

Update all references to old ansible paths:

```bash
# Find and update documentation
grep -r "ansible/" docs/ --include="*.md"
# Update paths to ansible_collections/basher83/automation_server/
```

## Success Criteria

- [ ] Single collection directory exists
- [ ] No duplicate `ansible/` directory
- [ ] All roles migrated to collection
- [ ] All playbooks accessible from collection
- [ ] Dynamic inventory configured
- [ ] Documentation updated with new paths
- [ ] Collection can be installed via `ansible-galaxy`

## Validation

### Structure Validation

```bash
# Verify collection structure
ansible-galaxy collection list | grep basher83.automation_server

# Validate collection metadata
ansible-galaxy collection validate ansible_collections/basher83/automation_server

# Check no legacy directory exists
test ! -d ansible/ && echo "Legacy directory removed successfully"
```

### Functionality Testing

```bash
# Test playbook execution from collection
cd ansible_collections/basher83/automation_server
ansible-playbook -i inventory/static.yml playbooks/site.yml --syntax-check

# Test individual roles
ansible-playbook -i inventory/static.yml playbooks/docker.yml --check

# Verify role paths
ansible-config dump | grep roles_path
```

Expected output:

- Collection validation passes
- Playbooks syntax check succeeds
- Roles are found and executable

## Notes

- This is a breaking change for existing automation
- Update all CI/CD pipelines to use new paths
- Consider creating a symlink during transition period if needed
- Document the collection installation process for new team members

## References

- [Ansible Collection Migration Guide](../../../planning/ansible-refactor/collection-structure-migration.md)
- [Pipeline Separation ADR](../../../decisions/20250118-pipeline-separation.md)
- [Ansible Collections Documentation](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
