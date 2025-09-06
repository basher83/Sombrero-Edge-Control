Proxmox Validation
==================

This role validates Proxmox infrastructure readiness before deployment operations.

## Research Findings

### Collections Evaluated
- **community.proxmox** (Score: 85/100) - Production-ready Proxmox management collection
  - 29 comprehensive modules for all Proxmox operations
  - Active development with recent commits
  - Well-structured testing infrastructure
- **community.general** (Score: 95/100) - Proxmox modules migrated to community.proxmox

### Decision
Using community.proxmox collection as dependency - Production-ready with comprehensive module coverage.

### Reference Implementations
- [community.proxmox documentation](https://docs.ansible.com/ansible/latest/collections/community/proxmox/)
- [Proxmox API documentation](https://pve.proxmox.com/pve-docs/api-viewer/)

### Custom Additions
- Enhanced validation for template metadata
- Resource availability thresholds specific to our requirements
- Network configuration verification for our environment

Requirements
------------

### Collections
```yaml
collections:
  - name: community.proxmox
    version: ">=3.0.0"
```

### Python Dependencies
```
proxmoxer>=1.3.1
requests
```

Role Variables
--------------

```yaml
# defaults/main.yml
proxmox_api_url: "{{ lookup('env', 'TF_VAR_pve_api_url') }}"
proxmox_api_token_id: "{{ lookup('env', 'TF_VAR_pve_api_token_id') | default('terraform@pve!token') }}"
proxmox_api_token_secret: "{{ lookup('env', 'TF_VAR_pve_api_token') }}"
proxmox_node: "lloyd"
proxmox_verify_ssl: false
required_template_id: 1001
template_name_pattern: "ubuntu-.*-docker"
minimum_storage_gb: 50
minimum_memory_mb: 4096
minimum_cpu_cores: 2
```

Dependencies
------------

None directly, but requires community.proxmox collection to be installed.

Example Playbook
----------------

```yaml
- hosts: localhost
  gather_facts: no
  roles:
    - role: proxmox_validation
      vars:
        proxmox_node: "lloyd"
        required_template_id: 1001
```

License
-------

MIT

Author Information
------------------

Created as part of the Ansible-first infrastructure refactor for Sombrero Edge Control project.
