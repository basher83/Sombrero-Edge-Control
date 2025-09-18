# Ansible Role Specifications

## Overview

This document provides detailed specifications for each Ansible role in the refactored infrastructure pipeline. Each role follows Ansible best practices with clear interfaces, defaults, and dependencies.

## Role Development Process

### Research Phase (REQUIRED)

Before implementing any role, use the **ansible-research subagent** to discover and evaluate existing Ansible collections that may provide required functionality or serve as reference implementations.

#### Research Process

1. **Discovery**: Search for existing collections

   ```bash
   # Invoke ansible-research subagent
   # Example: "discover proxmox ansible collections"
   # Example: "analyze community.docker collection"
   ```

2. **Quality Assessment**: Evaluate found collections for:

   - Repository health (activity, releases, contributors)
   - Code quality (testing, CI/CD, documentation)
   - Module implementation patterns
   - Community engagement

3. **Integration Analysis**: Determine if we should:

   - Use existing collection as dependency
   - Fork and customize collection
   - Use as reference for our implementation
   - Build from scratch (only if no suitable options)

4. **Document Findings**: Record in role README:

   ```markdown
   ## Research Findings

   - Collections evaluated: [list]
   - Selected approach: [use/fork/reference/custom]
   - Rationale: [why this decision]
   - Reference implementations: [links to good examples]
   ```

### Implementation Phase

After research phase, proceed with role development following the specifications below.

## Role Structure Standard

Each role follows this structure:

```
role_name/
├── defaults/
│   └── main.yml       # Default variables (lowest precedence)
├── vars/
│   └── main.yml       # Role variables (high precedence)
├── tasks/
│   └── main.yml       # Main task list
├── handlers/
│   └── main.yml       # Handler definitions
├── templates/          # Jinja2 templates
├── files/             # Static files
├── meta/
│   └── main.yml       # Role metadata and dependencies
├── molecule/          # Testing scenarios
│   └── default/
│       ├── molecule.yml
│       └── converge.yml
└── README.md          # Role documentation
```

---

## 1. proxmox_validation

### Purpose

Validate Proxmox infrastructure readiness before deployment operations.

### Research Requirements

Use ansible-research subagent to:

- Search for: `"discover proxmox ansible collections"`
- Focus on: Official Proxmox collections and community.general modules
- Expected findings: `community.general.proxmox_*` modules, potential third-party collections

### Variables

```yaml
# defaults/main.yml
proxmox_api_url: "{{ lookup('env', 'TF_VAR_pve_api_url') }}"
proxmox_api_token: "{{ lookup('env', 'TF_VAR_pve_api_token') }}"
proxmox_node: "lloyd"
proxmox_verify_ssl: false
required_template_id: 1001
template_name_pattern: "ubuntu-.*-docker"
minimum_storage_gb: 50
minimum_memory_mb: 4096
```

### Tasks

```yaml
# tasks/main.yml
- name: Include validation tasks
  include_tasks: "{{ item }}"
  loop:
    - check_api_connectivity.yml
    - verify_node_resources.yml
    - validate_template.yml
    - check_network_configuration.yml
```

### Outputs

```yaml
# Registered variables available after role execution
proxmox_validation_results:
  api_accessible: true
  node_available: true
  template_exists: true
  template_id: 1001
  template_metadata:
    name: "ubuntu-server-numbat-docker"
    creation_date: "2025-01-02"
    size_gb: 32
  resources_adequate: true
```

### Error Handling

- Fail fast on API connectivity issues
- Provide clear error messages with remediation steps
- Set `proxmox_validation_failed` fact on any failure

---

## 2. vm_smoke_tests

### Purpose

Comprehensive validation of deployed VM functionality.

### Research Requirements

Use ansible-research subagent to:

- Search for: `"discover ansible testing collections"`
- Focus on: Testing patterns, assertion modules, validation approaches
- Expected findings: `ansible.builtin` testing modules, `community.general` validation patterns

### Variables

```yaml
# defaults/main.yml
smoke_test_categories:
  - infrastructure
  - services
  - security
  - packages
  - docker

smoke_test_timeout: 10
expected_hostname: "jump-man"
expected_services:
  - docker
  - ssh
  - qemu-guest-agent
required_packages:
  - git
  - tmux
  - curl
  - wget
  - jq
  - python3
```

### Task Organization

```yaml
# tasks/main.yml
- name: Run infrastructure tests
  include_tasks: infrastructure.yml
  when: "'infrastructure' in smoke_test_categories"

- name: Run service tests
  include_tasks: services.yml
  when: "'services' in smoke_test_categories"

- name: Run security tests
  include_tasks: security.yml
  when: "'security' in smoke_test_categories"

# tasks/infrastructure.yml
- name: Verify hostname
  command: hostname
  register: hostname_result
  failed_when: hostname_result.stdout != expected_hostname

- name: Check network configuration
  command: ip addr show
  register: network_config

- name: Validate IP address
  assert:
    that:
      - ansible_default_ipv4.address is defined
      - ansible_default_ipv4.gateway is defined
    fail_msg: "Network configuration incomplete"

- name: Test DNS resolution
  command: nslookup google.com
  register: dns_test
  failed_when: dns_test.rc != 0
```

### Reporting

```yaml
# Generate test report
smoke_test_report:
  timestamp: "{{ ansible_date_time.iso8601 }}"
  total_tests: 25
  passed: 24
  failed: 1
  categories:
    infrastructure:
      passed: 5
      failed: 0
    services:
      passed: 4
      failed: 1
      failures:
        - name: "cloud-init status"
          error: "Status: degraded"
```

---

## 3. docker_validation

### Purpose

Specialized validation of Docker installation and functionality.

### Research Requirements

Use ansible-research subagent to:

- Search for: `"analyze community.docker collection"`
- Focus on: Docker modules, container management patterns
- Expected findings: `community.docker` collection with comprehensive Docker support

### Variables

```yaml
# defaults/main.yml
docker_test_image: "hello-world"
docker_compose_required: true
docker_expected_version: "24.0"
docker_network_tests:
  - bridge
  - host
docker_storage_driver: "overlay2"
test_container_cleanup: true
```

### Tasks

```yaml
# tasks/main.yml
- name: Check Docker service status
  systemd:
    name: docker
    state: started
  register: docker_service

- name: Verify Docker version
  command: docker --version
  register: docker_version
  failed_when: docker_expected_version not in docker_version.stdout

- name: Test Docker functionality
  docker_container:
    name: smoke-test-container
    image: "{{ docker_test_image }}"
    state: started
    cleanup: "{{ test_container_cleanup }}"
  register: container_test

- name: Verify Docker Compose
  command: docker compose version
  register: compose_version
  when: docker_compose_required

- name: Check Docker networks
  docker_network_info:
    name: "{{ item }}"
  loop: "{{ docker_network_tests }}"
  register: network_results
```

---

## 4. vm_diagnostics

### Purpose

Troubleshooting and diagnostic operations for debugging issues.

### Research Requirements

Use ansible-research subagent to:

- Search for: `"discover ansible debugging collections"`
- Focus on: Log collection patterns, diagnostic modules, troubleshooting approaches
- Expected findings: Debug strategies from various collections

### Variables

```yaml
# defaults/main.yml
diagnostic_categories:
  - system
  - network
  - services
  - logs

log_collection_paths:
  - /var/log/cloud-init.log
  - /var/log/cloud-init-output.log
  - /var/log/syslog
  - /var/log/auth.log

diagnostic_output_dir: "/tmp/diagnostics"
compress_output: true
```

### Tasks

```yaml
# tasks/collect_logs.yml
- name: Create diagnostic output directory
  file:
    path: "{{ diagnostic_output_dir }}"
    state: directory
    mode: "0755"

- name: Collect system information
  shell: |
    echo "=== System Diagnostics ===" > {{ diagnostic_output_dir }}/system.txt
    uname -a >> {{ diagnostic_output_dir }}/system.txt
    uptime >> {{ diagnostic_output_dir }}/system.txt
    df -h >> {{ diagnostic_output_dir }}/system.txt
    free -h >> {{ diagnostic_output_dir }}/system.txt

- name: Collect service status
  shell: |
    systemctl status {{ item }} --no-pager -l
  loop:
    - docker
    - ssh
    - qemu-guest-agent
  register: service_status
  ignore_errors: true

- name: Collect network diagnostics
  include_tasks: network_debug.yml

- name: Archive diagnostic data
  archive:
    path: "{{ diagnostic_output_dir }}"
    dest: "/tmp/diagnostics-{{ ansible_date_time.epoch }}.tar.gz"
  when: compress_output
```

---

## 5. vm_lifecycle

### Purpose

Manage VM lifecycle operations including rollback and cleanup.

### Research Requirements

Use ansible-research subagent to:

- Search for: `"discover terraform ansible integration collections"`
- Focus on: Terraform state management, resource cleanup patterns
- Expected findings: Patterns for managing infrastructure state via Ansible

### Variables

```yaml
# defaults/main.yml
lifecycle_operation: "rollback" # rollback, cleanup, reset
confirm_destructive_operations: true
preserve_data: false
cleanup_artifacts:
  - terraform_state
  - ansible_facts_cache
  - ssh_known_hosts
```

### Tasks

```yaml
# tasks/rollback.yml
- name: Confirm rollback operation
  pause:
    prompt: "Confirm VM destruction (yes/no)"
  register: rollback_confirmed
  when: confirm_destructive_operations

- name: Gather VM information
  delegate_to: localhost
  terraform:
    project_path: "{{ terraform_project_path }}"
    state: present
  register: terraform_state

- name: Execute Terraform destroy
  delegate_to: localhost
  terraform:
    project_path: "{{ terraform_project_path }}"
    state: absent
    targets:
      - module.jump_man
  when: rollback_confirmed.user_input | default('no') == 'yes'

- name: Clean up SSH known hosts
  lineinfile:
    path: ~/.ssh/known_hosts
    regexp: "{{ ansible_host }}"
    state: absent
  delegate_to: localhost

- name: Clear Ansible facts cache
  file:
    path: "{{ ansible_facts_cache_dir }}/{{ inventory_hostname }}"
    state: absent
  delegate_to: localhost
```

---

## 6. terraform_outputs

### Purpose

Parse Terraform outputs and integrate with Ansible inventory.

### Research Requirements

Use ansible-research subagent to:

- Search for: `"discover terraform inventory ansible collections"`
- Focus on: Dynamic inventory patterns, Terraform state parsing
- Expected findings: `cloud.terraform` collection, inventory plugin patterns

### Variables

```yaml
# defaults/main.yml
terraform_project_path: "infrastructure/environments/production"
terraform_state_file: "terraform.tfstate"
parse_outputs:
  - vm_ip
  - vm_hostname
  - vm_id
  - ssh_user
inventory_output_path: "ansible/inventory/terraform.yml"
```

### Tasks

```yaml
# tasks/main.yml
- name: Read Terraform state
  delegate_to: localhost
  command: terraform output -json
  args:
    chdir: "{{ terraform_project_path }}"
  register: terraform_outputs

- name: Parse Terraform outputs
  set_fact:
    tf_outputs: "{{ terraform_outputs.stdout | from_json }}"

- name: Generate Ansible inventory
  template:
    src: inventory.yml.j2
    dest: "{{ inventory_output_path }}"
  delegate_to: localhost

- name: Validate inventory
  command: ansible-inventory -i {{ inventory_output_path }} --list
  delegate_to: localhost
  register: inventory_validation
```

---

## Testing Strategy

### Molecule Testing

Each role includes Molecule tests:

```yaml
# molecule/default/molecule.yml
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
  inventory:
    host_vars:
      instance:
        ansible_host: 192.168.10.250
verifier:
  name: ansible
```

### Test Scenarios

1. **Default**: Basic functionality
2. **Failure**: Error handling and recovery
3. **Idempotency**: Multiple runs produce same result
4. **Performance**: Execution time benchmarks

---

## Common Variables (Group Vars)

```yaml
# ansible/group_vars/all.yml
ansible_python_interpreter: /usr/bin/python3
ansible_connection_timeout: 30
ansible_command_timeout: 60

# ansible/group_vars/jump_hosts.yml
jump_host_role: "devops"
environment: "production"
backup_enabled: true
monitoring_enabled: false
```

---

## Dependencies Between Roles

```yaml
# meta/main.yml example for vm_smoke_tests
dependencies:
  - role: terraform_outputs
    when: inventory_source == "terraform"
```

---

## Error Handling Standards

All roles implement:

1. **Graceful Failures**: Clear error messages with context
2. **Fact Registration**: Set `role_name_failed` on errors
3. **Rollback Capability**: Undo changes on failure where possible
4. **Logging**: Detailed output for debugging

---

## Performance Considerations

1. **Fact Gathering**: Minimize with `gather_facts: false` where possible
2. **Parallel Execution**: Use `strategy: free` for independent tasks
3. **Caching**: Implement fact caching for repeated runs
4. **Conditional Execution**: Skip unnecessary tasks with `when` clauses

---

## Documentation Requirements

Each role must include:

1. **README.md**: Usage examples and variable documentation
2. **CHANGELOG.md**: Version history
3. **LICENSE**: Licensing information
4. **requirements.yml**: External dependencies

---

## Next Steps

1. Review and approve specifications
2. Create role scaffolding using `ansible-galaxy init`
3. Implement core functionality
4. Add Molecule tests
5. Document usage patterns
