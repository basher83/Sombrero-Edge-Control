# Examples Directory Index

This index provides a comprehensive catalog of all files in the examples directory with descriptions of their purpose and contents.

## Root Level Files

| File                       | Description                                                                           |
| -------------------------- | ------------------------------------------------------------------------------------- |
| [`README.md`](./README.md) | High-level overview and documentation of the examples directory structure and purpose |
| [`INDEX.md`](./INDEX.md)   | This file - comprehensive catalog of all example files with descriptions              |

---

## ansible-ansible-documentation/

Collection of official Ansible documentation examples and best practices.

### defaults/

Configuration files and templates demonstrating Ansible setup and documentation standards.

| File                                                                                | Description                                                                                        |
| ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| [`ansible.cfg`](./ansible-ansible-documentation/defaults/ansible.cfg)               | Comprehensive Ansible configuration file with all available options documented and commented       |
| [`DOCUMENTATION.yml`](./ansible-ansible-documentation/defaults/DOCUMENTATION.yml)   | Template for documenting Ansible modules with proper YAML structure and required fields            |
| [`hosts`](./ansible-ansible-documentation/defaults/hosts)                           | Default Ansible inventory file showing host grouping patterns and syntax examples                  |
| [`hosts.yaml`](./ansible-ansible-documentation/defaults/hosts.yaml)                 | YAML format inventory file example (empty template)                                                |
| [`hosts.yml`](./ansible-ansible-documentation/defaults/hosts.yml)                   | YAML format inventory file example (empty template)                                                |
| [`play.yml`](./ansible-ansible-documentation/defaults/play.yml)                     | Extensively commented playbook demonstrating advanced Ansible features, syntax, and best practices |
| [`plugin_filters.yml`](./ansible-ansible-documentation/defaults/plugin_filters.yml) | Configuration for filtering Ansible plugins, showing module rejection patterns                     |

### tips-tricks/

Practical examples and guidance for Ansible development patterns.

| File                                                                                           | Description                                                                                                          |
| ---------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| [`general-tips-tricks.md`](./ansible-ansible-documentation/tips-tricks/general-tips-tricks.md) | Comprehensive guide covering Ansible best practices, playbook design, inventory management, and execution strategies |
| [`group_by.yaml`](./ansible-ansible-documentation/tips-tricks/group_by.yaml)                   | Example demonstrating dynamic host grouping based on OS distribution using `group_by` module                         |
| [`group_hosts.yml`](./ansible-ansible-documentation/tips-tricks/group_hosts.yml)               | Follow-up example showing how to target dynamically created groups in subsequent plays                               |
| [`include_vars.yaml`](./ansible-ansible-documentation/tips-tricks/include_vars.yaml)           | Example of including OS-specific variables using `include_vars` module for cross-platform compatibility              |
| [`role-directory.md`](./ansible-ansible-documentation/tips-tricks/role-directory.md)           | Visual guide showing proper Ansible role directory structure with file organization patterns                         |
| [`sample-web-app.md`](./ansible-ansible-documentation/tips-tricks/sample-web-app.md)           | Complete sample setup for automating web services, including directory layout and organizational patterns            |

---

## sensu-sensu-go-install/

Monitoring system integration example demonstrating role argument specifications.

| File                                                                | Description                                                                                                                                          |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`argument_specs.yml`](./sensu-sensu-go-install/argument_specs.yml) | Complete argument specifications for Sensu Go installation role showing proper entry point documentation, parameter validation, and type definitions |

---

## File Categories

### Configuration Examples

- `ansible.cfg` - Complete Ansible configuration reference
- `hosts`, `hosts.yaml`, `hosts.yml` - Inventory file templates
- `plugin_filters.yml` - Plugin filtering configuration

### Documentation Templates

- `DOCUMENTATION.yml` - Module documentation template
- `argument_specs.yml` - Role argument specification template

### Best Practices Guides

- `general-tips-tricks.md` - Comprehensive Ansible best practices
- `role-directory.md` - Role structure visualization
- `sample-web-app.md` - Complete project organization example

### Working Code Examples

- `play.yml` - Extensively commented playbook
- `group_by.yaml` - Dynamic host grouping
- `group_hosts.yml` - Using dynamic groups
- `include_vars.yaml` - OS-specific variable inclusion

---

## Usage Patterns

### For Learning

- Start with `general-tips-tricks.md` for foundational concepts
- Review `play.yml` for comprehensive syntax examples
- Study `role-directory.md` for proper project structure

### For Reference

- Use `ansible.cfg` as configuration reference
- Copy `DOCUMENTATION.yml` for new module documentation
- Adapt `argument_specs.yml` for role parameter validation

### For Implementation

- Follow `sample-web-app.md` patterns for project organization
- Use dynamic grouping examples for multi-OS environments
- Apply best practices from tips-tricks files

---

## Related Documentation

For additional context, see:

- [Examples Directory README](./README.md) - Overview and contributing guidelines
- [Project Documentation](../docs/README.md) - Main project documentation
- [Development Standards](../docs/standards/) - Project coding standards
- [AI Documentation](../docs/ai_docs/) - AI-generated guides and patterns

---

_Last updated: Generated automatically - reflects current directory structure_
