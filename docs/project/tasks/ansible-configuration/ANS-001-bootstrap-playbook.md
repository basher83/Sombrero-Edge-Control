---
Task: Bootstrap Playbook for Initial Connectivity
Task ID: ANS-001
Priority: P1 (Important)
Estimated Time: 1 hour
Dependencies: SEP-003
Status: ⏸️ Blocked
---

## Objective

Create a bootstrap playbook that establishes initial connectivity and prepares the VM for full configuration. This playbook ensures Python is installed, sets up the ansible user properly, and verifies network connectivity before proceeding with complex configuration tasks.

## Prerequisites

- [ ] SEP-003 completed (Ansible collection structure ready)
- [ ] VM provisioned with minimal cloud-init
- [ ] SSH access to VM as ansible user
- [ ] Ansible collection structure in place

## Implementation Steps

### 1. **Create Bootstrap Role**

Create `ansible_collections/basher83/automation_server/roles/bootstrap/tasks/main.yml`:

```yaml
---
- name: Wait for system to become reachable
  wait_for_connection:
    delay: 10
    timeout: 300

- name: Install Python for Ansible
  raw: |
    if ! command -v python3 &> /dev/null; then
      apt-get update
      apt-get install -y python3 python3-apt
    fi
  changed_when: false

- name: Gather facts after Python installation
  setup:

- name: Ensure ansible user exists
  user:
    name: ansible
    groups: sudo
    shell: /bin/bash
    create_home: yes
    state: present

- name: Configure sudo for ansible user
  lineinfile:
    path: /etc/sudoers.d/ansible
    line: 'ansible ALL=(ALL) NOPASSWD:ALL'
    create: yes
    validate: 'visudo -cf %s'

- name: Set hostname
  hostname:
    name: jump-man

- name: Update /etc/hosts
  lineinfile:
    path: /etc/hosts
    line: "127.0.1.1 jump-man"
    state: present

- name: Verify network connectivity
  uri:
    url: https://api.github.com
    method: GET
    status_code: 200
    timeout: 10
  register: github_check
  failed_when: false

- name: Report connectivity status
  debug:
    msg: "External connectivity: {{ 'OK' if github_check.status == 200 else 'FAILED' }}"

- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Install essential packages
  apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - software-properties-common
    state: present

- name: Set timezone
  timezone:
    name: UTC

- name: Enable systemd-resolved
  systemd:
    name: systemd-resolved
    enabled: yes
    state: started

- name: Configure DNS
  copy:
    content: |
      [Resolve]
      DNS=1.1.1.1 1.0.0.1
      FallbackDNS=8.8.8.8 8.8.4.4
      DNSStubListener=no
    dest: /etc/systemd/resolved.conf
  notify: restart systemd-resolved

- name: Ensure resolv.conf points to systemd-resolved
  file:
    src: /run/systemd/resolve/resolv.conf
    dest: /etc/resolv.conf
    state: link

- name: Create directory structure
  file:
    path: "{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - /opt/scripts
    - /opt/configs
    - /var/log/ansible

- name: Save bootstrap completion marker
  file:
    path: /var/lib/ansible_bootstrap_complete
    state: touch
    modification_time: preserve
    access_time: preserve
```

Create `ansible_collections/basher83/automation_server/roles/bootstrap/handlers/main.yml`:

```yaml
---
- name: restart systemd-resolved
  systemd:
    name: systemd-resolved
    state: restarted
```

### 2. **Create Bootstrap Check Role**

Create `ansible_collections/basher83/automation_server/roles/bootstrap_check/tasks/main.yml`:

```yaml
---
- name: Check if bootstrap is needed
  stat:
    path: /var/lib/ansible_bootstrap_complete
  register: bootstrap_marker

- name: Run bootstrap if needed
  include_role:
    name: bootstrap
  when: not bootstrap_marker.stat.exists
```

### 3. **Integrate with Main Playbook**

Update `ansible_collections/basher83/automation_server/playbooks/site.yml`:

```yaml
---
- name: Complete Jump Host Configuration
  hosts: jump_hosts

  pre_tasks:
    - name: Bootstrap if needed
      include_role:
        name: bootstrap_check

  tasks:
    - name: Apply baseline configuration
      import_playbook: baseline.yml

    - name: Install Docker
      import_playbook: docker.yml

    - name: Apply security hardening
      import_playbook: security.yml

    - name: Install development tools
      import_playbook: development.yml
```

### 4. **Create Inventory Defaults**

Create `ansible_collections/basher83/automation_server/inventory/group_vars/jump_hosts.yml`:

```yaml
---
# Bootstrap defaults for jump hosts
ansible_user: ansible
ansible_become: yes
ansible_become_method: sudo
ansible_python_interpreter: /usr/bin/python3

# Connection settings
ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_ssh_pipelining: yes

# NOTE: Host key checking is disabled for initial bootstrap convenience.
# TODO: Re-enable strict host key checking for production use by removing the above line
# and ensuring known_hosts is properly populated.

# Performance tuning
ansible_facts_parallel: yes
```

### 5. **Create Bootstrap Test Playbook**

Create `ansible_collections/basher83/automation_server/playbooks/test-bootstrap.yml`:

```yaml
---
- name: Test Bootstrap Completion
  hosts: jump_hosts
  gather_facts: yes

  tasks:
    - name: Check Python version
      command: python3 --version
      register: python_version

    - name: Check ansible user
      command: id ansible
      register: ansible_user

    - name: Check sudo access
      become: yes
      command: whoami
      register: sudo_check

    - name: Check hostname
      command: hostname
      register: hostname_check

    - name: Check DNS resolution
      command: getent hosts github.com
      register: dns_check

    - name: Display test results
      debug:
        msg:
          - "Python: {{ python_version.stdout }}"
          - "User: {{ ansible_user.stdout }}"
          - "Sudo: {{ sudo_check.stdout }}"
          - "Hostname: {{ hostname_check.stdout }}"
          - "DNS: {{ 'OK' if dns_check.rc == 0 else 'FAILED' }}"

    - name: Assert all checks passed
      assert:
        that:
          - python_version.rc == 0
          - ansible_user.rc == 0
          - sudo_check.stdout == "root"
          - hostname_check.stdout == "jump-man"
          - dns_check.rc == 0
        fail_msg: "Bootstrap validation failed"
        success_msg: "All bootstrap checks passed"
```

## Success Criteria

- [ ] Bootstrap role runs without errors
- [ ] Bootstrap check role conditionally includes bootstrap when needed
- [ ] Python3 installed and functional
- [ ] Ansible user configured with sudo access
- [ ] Network connectivity verified
- [ ] DNS resolution working
- [ ] Essential packages installed
- [ ] Bootstrap marker file created
- [ ] Idempotent - can run multiple times safely

## Validation

### Test Bootstrap

```bash
cd ansible_collections/basher83/automation_server

# MANDATORY: Run ansible-lint first
ansible-lint roles/bootstrap/ roles/bootstrap_check/
# Must pass production linting rules

# Check syntax
ansible-playbook -i inventory/ansible_inventory.json playbooks/site.yml --syntax-check

# Run bootstrap via site.yml (will include bootstrap_check role)
ansible-playbook -i inventory/ansible_inventory.json playbooks/site.yml --tags bootstrap_check

# Verify bootstrap
ansible-playbook -i inventory/ansible_inventory.json playbooks/test-bootstrap.yml

# Check idempotency (run again, should skip bootstrap)
ansible-playbook -i inventory/ansible_inventory.json playbooks/site.yml --tags bootstrap_check
# Should show no changes for bootstrap tasks
```

Expected output:

- First run: Multiple changes
- Second run: No changes (idempotent)
- All test checks pass

## Notes

- Bootstrap must be idempotent for reliability
- Uses `raw` module for initial Python installation
- Creates marker file to skip on subsequent runs
- Essential for fresh VMs from minimal templates
- Consider adding retry logic for network operations

## References

- [Ansible Bootstrap Documentation](https://docs.ansible.com/ansible/latest/user_guide/intro_installation.html)
- [Pipeline Separation ADR](../../../decisions/20250118-pipeline-separation.md)
- [Ansible Collection Structure](../../../planning/ansible-refactor/collection-structure-migration.md)
