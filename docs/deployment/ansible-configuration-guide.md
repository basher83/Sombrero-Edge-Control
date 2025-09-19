# Ansible Configuration Management Guide

## Overview

This guide documents how Ansible serves as the single source of truth for ALL configuration management in the Sombrero Edge Control pipeline, handling everything beyond basic SSH access provided by Terraform.

## Architecture Principles

### Single Source of Truth
- **Ansible owns**: All packages, services, configuration files, security policies
- **Terraform provides**: VM with SSH access only
- **Packer provides**: Minimal OS image

### Idempotent Operations
- All playbooks and roles must be safely re-runnable
- Use Ansible modules over shell commands
- Check for existing state before making changes

## Collection Structure

```
ansible_collections/basher83/automation_server/
├── galaxy.yml                    # Collection metadata
├── playbooks/
│   ├── site.yml                  # Master playbook
│   ├── bootstrap.yml             # Initial connectivity
│   ├── docker.yml                # Container runtime
│   ├── security.yml              # Hardening
│   ├── development.yml           # Dev tools
│   └── smoke-tests.yml           # Validation
├── roles/
│   ├── bootstrap/                # SSH and networking
│   ├── docker/                   # Docker CE installation
│   ├── docker_validation/        # Docker verification
│   ├── firewall/                 # nftables configuration
│   ├── security/                 # SSH hardening, fail2ban
│   ├── development_tools/        # mise, uv, nodejs
│   ├── vm_smoke_tests/          # Comprehensive testing
│   └── vm_lifecycle/            # Maintenance operations
├── inventory/
│   ├── terraform.yml             # Dynamic from Terraform
│   └── static.yml               # Fallback inventory
└── vars/
    ├── common.yml               # Shared variables
    └── production.yml           # Environment specific
```

## Playbook Hierarchy

### Master Playbook (site.yml)

```yaml
---
- name: Complete Jump Host Configuration
  hosts: jump_hosts
  gather_facts: true
  become: true

  tasks:
    - name: Phase 1 - Bootstrap
      import_playbook: bootstrap.yml
      tags: [bootstrap, phase1]

    - name: Phase 2 - Base Configuration
      block:
        - import_role:
            name: docker
          tags: [docker, containers]

        - import_role:
            name: firewall
          tags: [firewall, security]

    - name: Phase 3 - Security Hardening
      import_playbook: security.yml
      tags: [security, phase3]

    - name: Phase 4 - Development Tools
      import_playbook: development.yml
      tags: [development, phase4]

    - name: Phase 5 - Validation
      import_playbook: smoke-tests.yml
      tags: [validation, phase5]
```

### Bootstrap Playbook

Ensures basic connectivity and prerequisites:

```yaml
---
- name: Bootstrap Jump Host
  hosts: jump_hosts
  gather_facts: false  # Can't gather until Python installed
  become: true

  tasks:
    - name: Ensure Python installed
      raw: test -e /usr/bin/python3 || (apt-get update && apt-get install -y python3)
      changed_when: false

    - name: Gather facts after Python
      setup:

    - name: Configure hostname
      hostname:
        name: "{{ inventory_hostname }}"

    - name: Update APT cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
```

## Role Specifications

### Docker Role

**Purpose**: Install and configure Docker CE with security best practices

```yaml
# roles/docker/tasks/main.yml
---
- name: Install Docker prerequisites
  apt:
    name:
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
    state: present

- name: Add Docker GPG key
  apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present

- name: Add Docker repository
  apt_repository:
    repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
    state: present

- name: Install Docker CE
  apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-compose-plugin
    state: present

- name: Add ansible user to docker group
  user:
    name: ansible
    groups: docker
    append: yes

- name: Start and enable Docker
  systemd:
    name: docker
    state: started
    enabled: yes
```

### Security Role

**Purpose**: Apply security hardening and monitoring

```yaml
# roles/security/tasks/main.yml
---
- name: SSH Hardening
  import_tasks: ssh-hardening.yml

- name: Install fail2ban
  import_tasks: fail2ban.yml

- name: Kernel hardening
  import_tasks: kernel-hardening.yml

- name: Audit logging
  import_tasks: audit-logging.yml
```

### Development Tools Role

**Purpose**: Install modern development tooling

```yaml
# roles/development_tools/tasks/main.yml
---
- name: Install mise
  import_tasks: mise.yml

- name: Install Python tools (uv)
  import_tasks: python.yml

- name: Install Node.js
  import_tasks: nodejs.yml

- name: Configure shell environment
  import_tasks: shell-config.yml
```

## Inventory Management

### Dynamic Inventory from Terraform

```yaml
# inventory/terraform.yml
---
plugin: cloud.terraform.terraform_provider
project_path: ../../../infrastructure/environments/production
```

### Static Fallback Inventory

```yaml
# inventory/static.yml
---
all:
  children:
    jump_hosts:
      hosts:
        jump-man:
          ansible_host: 192.168.10.250
          ansible_user: ansible
          ansible_ssh_private_key_file: ~/.ssh/ansible
```

## Variable Management

### Common Variables

```yaml
# vars/common.yml
---
# Docker configuration
docker_version: "24.0"
docker_compose_version: "2.23.0"

# Security settings
ssh_port: 22
ssh_permit_root_login: "no"
ssh_password_authentication: "no"

# Development tools versions
mise_version: "latest"
nodejs_version: "20"
python_version: "3.11"
```

### Environment-Specific Variables

```yaml
# vars/production.yml
---
environment: production
backup_enabled: true
monitoring_enabled: true
security_level: hardened
```

## Execution Patterns

### Full Deployment

```bash
# Complete configuration
ansible-playbook -i inventory/terraform.yml playbooks/site.yml
```

### Targeted Deployment

```bash
# Just Docker
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --tags docker

# Just security hardening
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --tags security

# Skip validation
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --skip-tags validation
```

### Debug Mode

```bash
# Verbose output
ansible-playbook -vvv -i inventory/terraform.yml playbooks/site.yml

# Check mode (dry run)
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --check

# Step through tasks
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --step
```

## Testing Strategy

### Role Testing with Molecule

```yaml
# roles/docker/molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: ubuntu:24.04
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```

### Smoke Tests Role

```yaml
# roles/vm_smoke_tests/tasks/main.yml
---
- name: Test SSH connectivity
  ping:

- name: Test Docker service
  systemd:
    name: docker
    state: started
  check_mode: yes
  register: docker_status

- name: Test firewall rules
  command: nft list ruleset
  changed_when: false

- name: Generate test report
  template:
    src: test-report.j2
    dest: /tmp/smoke-test-report.txt
```

## Integration with Pipeline

### Receiving Inventory from Terraform

```bash
# Terraform generates inventory
terraform output -json ansible_inventory > inventory.json

# Ansible uses it
ansible-playbook -i inventory.json playbooks/site.yml
```

### Mise Task Integration

```toml
# .mise.toml
[tasks.deploy-ansible]
description = "Configure VM with Ansible"
run = """
cd ansible_collections/basher83/automation_server
ansible-playbook -i inventory/terraform.yml playbooks/site.yml
"""
depends = ["deploy-terraform"]
```

## Best Practices

### DO ✅
- Use Ansible modules over shell/command
- Make all operations idempotent
- Tag tasks for selective execution
- Use variables for versions and settings
- Implement comprehensive error handling
- Document role dependencies

### DON'T ❌
- Hardcode environment-specific values
- Use raw/shell unless absolutely necessary
- Skip validation steps
- Mix configuration with provisioning
- Ignore changed/failed states

## Troubleshooting

### Connection Issues

```bash
# Test connectivity
ansible -i inventory/terraform.yml jump_hosts -m ping

# Check SSH
ssh -vvv ansible@192.168.10.250
```

### Task Failures

```bash
# Run specific failed task
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --start-at-task="Install Docker CE"

# Get more details
ansible-playbook -vvv -i inventory/terraform.yml playbooks/site.yml
```

### Performance

```bash
# Profile playbook execution
ansible-playbook -i inventory/terraform.yml playbooks/site.yml --profile=tasks
```

---

*Document Version: 1.0*
*Last Updated: 2025-01-18*
*Status: Active*
