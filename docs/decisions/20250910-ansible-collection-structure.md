# Adopt Ansible Collection Structure

- Status: proposed
- Date: 2025-09-10
- Tags: ansible, collections, linting, architecture

## Context and Problem Statement

The current Ansible codebase uses a traditional directory structure that ansible-lint cannot fully validate. According to Ansible best practices, playbooks and roles should be organized within a collection structure to enforce better compliance, improve modularity, and enable comprehensive linting.

## Decision Outcome

Chosen option: "Migrate to Ansible Collection Structure", because it provides complete ansible-lint compliance, better code organization, and aligns with modern Ansible development practices.

### Positive Consequences

1. **Full Linting Compliance**
   - ansible-lint can properly validate collection structure
   - Automatic detection of role dependencies
   - Enforcement of naming conventions
   - Cleaner validation reports

2. **Improved Code Organization**
   - Self-contained, distributable unit
   - Clear namespace (sombrero.edge_control)
   - Versioned releases possible
   - Plugin development support

3. **Better Testing & CI/CD**
   - Standardized test structure
   - Molecule tests per role
   - Collection-level testing
   - Simplified CI/CD pipelines

### Negative Consequences

1. **Migration Effort**
   - Requires restructuring entire Ansible codebase
   - All playbooks need FQCN updates
   - Team training required

2. **Short-term Disruption**
   - Parallel structures during migration
   - CI/CD pipeline updates needed
   - Documentation updates required

## Implementation Details

### Collection Structure

```
ansible_collections/
└── sombrero/
    └── edge_control/
        ├── galaxy.yml          # Collection metadata
        ├── meta/runtime.yml    # Runtime requirements
        ├── roles/              # All roles
        ├── playbooks/          # All playbooks
        ├── plugins/            # Custom plugins
        └── tests/              # Test suites
```

### Key Changes Required

1. **Namespace Introduction**: All roles referenced as `sombrero.edge_control.role_name`
2. **Galaxy Metadata**: Define collection version, dependencies, and requirements
3. **FQCN Usage**: Update all playbook role references to use Fully Qualified Collection Names
4. **Directory Migration**: Move from `ansible/` to `ansible_collections/sombrero/edge_control/`

### Migration Phases

1. **Phase 1**: Create parallel structure and galaxy.yml
2. **Phase 2**: Migrate roles and update imports
3. **Phase 3**: Validate with ansible-lint and testing
4. **Phase 4**: Cut over and archive old structure

## Links

- Planning document: docs/planning/ansible-refactor/collection-structure-migration.md
- Related ADR: 20250906-ansible-roles.md (Ansible Role-First Architecture)
- Ansible Collection Documentation: <https://docs.ansible.com/ansible-core/devel/dev_guide/developing_collections.html>
