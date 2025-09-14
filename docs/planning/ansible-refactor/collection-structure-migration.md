# Ansible Collection Structure Migration Plan

**Status**: 🔵 Proposed
**Date**: 2025-09-10
**Author**: Development Team
**Impact**: High - Restructures entire Ansible codebase

## Executive Summary

Migrate the current Ansible directory structure to a proper Ansible Collection format to enforce better compliance with
ansible-lint, improve code organization, and align with Ansible best practices.

## Current State

```text
ansible/
├── playbooks/
├── roles/
├── inventory/
├── group_vars/
├── host_vars/
└── requirements.yml
```

## Proposed Collection Structure

```text
ansible_collections/
└── basher83/
    └── automation_server/
        ├── docs/
        ├── galaxy.yml
        ├── meta/
        │   └── runtime.yml
        ├── plugins/
        │   ├── modules/
        │   ├── filter/
        │   ├── lookup/
        │   └── inventory/
        ├── roles/
        │   ├── docker/
        │   ├── docker_validation/
        │   ├── development-tools/
        │   ├── firewall/
        │   ├── automation_server_base/
        │   ├── security_hardening/
        │   └── smoke_test/
        ├── playbooks/
        │   ├── site.yml
        │   ├── post-deploy.yml
        │   └── packer-provision.yml
        ├── tests/
        │   ├── unit/
        │   └── integration/
        └── README.md
```

## Benefits

### 1. **Enhanced Linting Compliance**

- ansible-lint properly validates collection structure
- Automatic detection of role dependencies
- Better enforcement of naming conventions
- Cleaner separation of concerns

### 2. **Improved Modularity**

- Self-contained, distributable unit
- Versioned releases possible
- Can be published to Ansible Galaxy (private or public)
- Clear namespace: `basher83.automation_server`

### 3. **Better Testing**

- Standardized test structure
- Molecule tests can be integrated per role
- Collection-level testing possible
- CI/CD improvements

### 4. **Professional Standards**

- Aligns with Ansible community best practices
- Easier onboarding for new team members
- Better documentation structure
- Plugin development support

## Migration Strategy

### Phase 1: Preparation (Week 1)

1. Create collection structure alongside existing
2. Set up galaxy.yml with metadata
3. Configure runtime.yml for Python/Ansible requirements
4. Update .ansible-lint configuration

### Phase 2: Migration (Week 2)

1. Move roles to collection structure
2. Update playbook imports to use FQCN (Fully Qualified Collection Names)
3. Migrate inventory structure
4. Update variable references

### Phase 3: Validation (Week 3)

1. Run comprehensive ansible-lint checks
2. Execute all playbooks in test environment
3. Validate Terraform → Ansible integration
4. Update CI/CD pipelines

### Phase 4: Cutover (Week 4)

1. Archive old ansible/ directory
2. Update all documentation
3. Update mise tasks
4. Deploy to production

## Technical Requirements

### galaxy.yml Content

```yaml
namespace: basher83
name: automation_server
version: 1.0.0
readme: README.md
authors:
  - basher83
description: Ansible collection for managing jump host infrastructure
license:
  - MIT
tags:
  - infrastructure
  - proxmox
  - jump_host
  - cloud_init
dependencies:
  community.proxmox: ">=1.3.0"
  community.general: ">=8.0.0"
  community.docker: ">=3.13.0"
  ansible.posix: ">=1.5.0"
repository: https://github.com/basher83/Sombrero-Edge-Control
```

### Playbook Updates Required

**Before:**

```yaml
- name: Configure jump host
  hosts: jump_hosts
  roles:
    - docker
    - firewall
```

**After:**

```yaml
- name: Configure jump host
  hosts: jump_hosts
  roles:
    - basher83.automation_server.docker
    - basher83.automation_server.firewall
```

## Impact Analysis

### Positive Impacts

- ✅ 100% ansible-lint compliance achievable
- ✅ Reduced technical debt
- ✅ Improved maintainability
- ✅ Better testing coverage
- ✅ Professional structure

### Risks & Mitigations

- ⚠️ **Risk**: Breaking existing automation
  - **Mitigation**: Parallel structure during migration
- ⚠️ **Risk**: Learning curve for team
  - **Mitigation**: Documentation and training
- ⚠️ **Risk**: CI/CD pipeline updates needed
  - **Mitigation**: Staged rollout with validation

## Success Criteria

1. ✓ Zero ansible-lint errors or warnings
2. ✓ All existing playbooks functional
3. ✓ Terraform integration maintained
4. ✓ CI/CD pipelines updated and passing
5. ✓ Documentation complete
6. ✓ Team trained on new structure

## Implementation Checklist

- [x] Create ADR for architectural decision
- [x] Set up collection directory structure
- [x] Create galaxy.yml and meta files
- [x] Migrate first role (docker) as proof of concept
- [ ] Update ansible-lint configuration
- [ ] Create migration script for automation
- [ ] Update mise tasks for new structure
- [ ] Test in development environment
- [ ] Update CI/CD workflows
- [ ] Document new structure in README
- [ ] Train team on collection usage
- [ ] Execute production cutover

## References

- [Ansible Collection Structure](https://docs.ansible.com/ansible-core/devel/dev_guide/developing_collections_structure.html)
- [Ansible-lint Usage Guide](https://ansible.readthedocs.io/projects/lint/usage/)
- [Galaxy Collection Format](https://docs.ansible.com/ansible/latest/dev_guide/collections_galaxy_meta.html)

## Next Steps

1. Review and approve this proposal
2. Create formal ADR
3. Begin Phase 1 implementation
4. Set up tracking for migration progress
