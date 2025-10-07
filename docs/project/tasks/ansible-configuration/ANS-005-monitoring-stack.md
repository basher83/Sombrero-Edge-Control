---
Task: Netdata Monitoring Setup
Task ID: ANS-005
Priority: P1 (Important)
Estimated Time: 1 hour
Dependencies: ANS-001
Status: ✅ Complete
Last Updated: 2025-09-22
Implementation Date: 2025-09-22
---

## Objective

Deploy Netdata real-time monitoring agent on the jump host for comprehensive system and
Docker container monitoring. Netdata provides an all-in-one monitoring solution with
automatic metrics collection, real-time dashboards, alerts, and zero configuration
required. Based on research findings (score: 85/100), the official Netdata Ansible
repository is the recommended approach for Ubuntu 24.04 deployment.

## Research Summary

**Selected Solution**: Official Netdata Ansible Repository (Score: 85/100)

- **Repository**: <https://github.com/netdata/ansible>
- **Maintenance**: Recently updated (December 2024)
- **Ubuntu 24.04**: Supported (tested on Ubuntu 18, 20, 22)
- **Docker Monitoring**: Automatic container detection via cgroups
- **Research Report**: `.claude/research-reports/ansible-research-20250922-213639.md`

## Prerequisites

- [ ] ANS-001 completed (Bootstrap roles implemented)
- [ ] VM accessible via Ansible
- [ ] Understanding of monitoring requirements
- [ ] Network access to Netdata package repository

## Implementation Steps

### 1. **Add Netdata Ansible Collection**

Create/Update `ansible_collections/basher83/automation_server/requirements.yml`:

```yaml
---
collections:
  - name: community.general
    version: ">=7.0.0"

roles:
  - src: https://github.com/netdata/ansible.git
    name: netdata.ansible
    version: master
```

Install the requirements:

```bash
cd ansible_collections/basher83/automation_server
ansible-galaxy install -r requirements.yml
```

### 2. **Create Netdata Configuration Role**

Create `ansible_collections/basher83/automation_server/roles/netdata/defaults/main.yml`:

```yaml
---
# Netdata configuration
netdata_enabled: true
netdata_start_on_boot: true

# Web interface configuration
netdata_bind_to: "0.0.0.0"
netdata_port: 19999
netdata_allow_connections_from: "*"

# Performance settings
netdata_history: 3600 # Seconds of history to keep
netdata_update_every: 1 # Update interval in seconds

# Docker monitoring
netdata_monitor_docker: true
netdata_docker_socket: "/var/run/docker.sock"

# Security settings
netdata_ssl_enabled: false # Enable in production with proper certs
netdata_ssl_port: 19998

# Cloud integration (optional)
netdata_claim_token: "" # Set if using Netdata Cloud
netdata_claim_rooms: "" # Room ID for Netdata Cloud

# Alert configuration
netdata_alarm_notify_configs:
  email:
    enabled: false
    to: "admin@example.com"
  slack:
    enabled: false
    webhook_url: ""
    channel: "#alerts"

# System optimizations for Ubuntu 24.04
netdata_system_optimizations:
  - name: "vm.swappiness"
    value: "10"
  - name: "kernel.mm.ksm.run"
    value: "1"

# Firewall rules
netdata_firewall_rules:
  - port: 19999
    protocol: tcp
    comment: "Netdata web interface"
```

### 3. **Create Netdata Tasks**

Create `ansible_collections/basher83/automation_server/roles/netdata/tasks/main.yml`:

```yaml
---
- name: Install Netdata repository and agent
  block:
    - name: Add Netdata repository
      ansible.builtin.include_role:
        name: netdata.ansible.install_netdata_repository
      tags:
        - netdata
        - repository

    - name: Install Netdata agent
      ansible.builtin.include_role:
        name: netdata.ansible.install_netdata_agent
      tags:
        - netdata
        - agent

- name: Configure Netdata for Docker monitoring
  when: netdata_monitor_docker | bool
  block:
    - name: Ensure ansible user is in docker group
      ansible.builtin.user:
        name: ansible
        groups: docker
        append: yes
      notify: restart netdata

    - name: Configure Docker plugin
      ansible.builtin.lineinfile:
        path: /etc/netdata/netdata.conf
        regexp: '^.*\[plugin:cgroups\]'
        line: "[plugin:cgroups]"
        create: yes
      notify: restart netdata

    - name: Enable Docker container names
      ansible.builtin.lineinfile:
        path: /etc/netdata/netdata.conf
        regexp: "^.*use unified cgroups"
        line: "    use unified cgroups = yes"
        insertafter: '\[plugin:cgroups\]'
      notify: restart netdata

- name: Configure Netdata web interface
  ansible.builtin.blockinfile:
    path: /etc/netdata/netdata.conf
    block: |
      [web]
          bind to = {{ netdata_bind_to }}:{{ netdata_port }}
          allow connections from = {{ netdata_allow_connections_from }}
    marker: "# {mark} ANSIBLE MANAGED BLOCK - web interface"
  notify: restart netdata

- name: Configure performance settings
  ansible.builtin.blockinfile:
    path: /etc/netdata/netdata.conf
    block: |
      [global]
          history = {{ netdata_history }}
          update every = {{ netdata_update_every }}
    marker: "# {mark} ANSIBLE MANAGED BLOCK - performance"
  notify: restart netdata

- name: Configure firewall for Netdata
  ansible.builtin.include_tasks: firewall.yml
  when: netdata_firewall_rules is defined

- name: Ensure Netdata is running
  ansible.builtin.systemd:
    name: netdata
    state: started
    enabled: "{{ netdata_start_on_boot }}"
    daemon_reload: yes

- name: Wait for Netdata to be ready
  ansible.builtin.uri:
    url: "http://localhost:{{ netdata_port }}/api/v1/info"
    status_code: 200
  register: result
  until: result.status == 200
  retries: 30
  delay: 5

- name: Display access information
  ansible.builtin.debug:
    msg:
      - "Netdata monitoring deployed successfully!"
      - "Web Dashboard: http://{{ ansible_default_ipv4.address }}:{{ netdata_port }}"
      - "API Endpoint: http://{{ ansible_default_ipv4.address }}:{{ netdata_port }}/api/v1/info"
      - "Docker Monitoring: {{ 'Enabled' if netdata_monitor_docker else 'Disabled' }}"
```

### 4. **Create Firewall Tasks**

Create `ansible_collections/basher83/automation_server/roles/netdata/tasks/firewall.yml`:

```yaml
---
- name: Configure firewall for Netdata
  when: netdata_firewall_rules is defined and netdata_firewall_rules | length > 0
  block:
    - name: Allow Netdata web interface through firewall
      community.general.ufw:
        rule: allow
        port: "{{ item.port | string }}"
        proto: "{{ item.protocol | default('tcp') }}"
        comment: "{{ item.comment | default('Netdata monitoring') }}"
      loop: "{{ netdata_firewall_rules }}"
      when: ansible_os_family == "Debian"

    - name: Configure nftables for Netdata (if nftables is primary)
      ansible.builtin.lineinfile:
        path: /etc/nftables.conf
        regexp: ".*tcp dport {{ item.port }}.*"
        line: '    tcp dport {{ item.port }} accept comment "{{ item.comment | default(''Netdata monitoring'') }}"'
        insertafter: "chain input {"
      loop: "{{ netdata_firewall_rules }}"
      notify: reload nftables
      when: "'nftables' in ansible_facts.packages"
```

### 5. **Create Handlers**

Create `ansible_collections/basher83/automation_server/roles/netdata/handlers/main.yml`:

```yaml
---
- name: restart netdata
  ansible.builtin.systemd:
    name: netdata
    state: restarted
    daemon_reload: yes
  become: true

- name: reload nftables
  ansible.builtin.systemd:
    name: nftables
    state: reloaded
  become: true
  when: "'nftables' in ansible_facts.packages"
```

### 6. **Create Netdata Playbook**

Create `ansible_collections/basher83/automation_server/playbooks/monitoring.yml`:

```yaml
---
- name: Deploy Netdata Monitoring
  hosts: jump_hosts
  become: true
  gather_facts: yes

  pre_tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"

  roles:
    - role: netdata
      tags:
        - monitoring
        - netdata

  post_tasks:
    - name: Verify Netdata installation
      ansible.builtin.command: netdata -V
      register: netdata_version
      changed_when: false

    - name: Check Netdata plugins
      ansible.builtin.command: ls /usr/libexec/netdata/plugins.d/
      register: netdata_plugins
      changed_when: false

    - name: Display Netdata information
      ansible.builtin.debug:
        msg:
          - "Netdata Version: {{ netdata_version.stdout }}"
          - "Available Plugins: {{ netdata_plugins.stdout_lines | join(', ') }}"
          - "Access Dashboard: http://{{ ansible_default_ipv4.address }}:19999"
```

### 7. **Create Validation Playbook**

Create `ansible_collections/basher83/automation_server/playbooks/test-netdata.yml`:

```yaml
---
- name: Validate Netdata Monitoring
  hosts: jump_hosts
  gather_facts: yes

  tasks:
    - name: Check Netdata service status
      ansible.builtin.systemd:
        name: netdata
      register: netdata_service
      failed_when: netdata_service.status.ActiveState != "active"

    - name: Test Netdata API endpoint
      ansible.builtin.uri:
        url: "http://localhost:19999/api/v1/info"
        status_code: 200
      register: api_response

    - name: Check Docker metrics collection
      ansible.builtin.uri:
        url: "http://localhost:19999/api/v1/data?chart=cgroup_docker"
        status_code: [200, 404] # 404 if no containers running
      register: docker_metrics

    - name: Verify system metrics
      ansible.builtin.uri:
        url: "http://localhost:19999/api/v1/data?chart=system.cpu"
        status_code: 200
      register: cpu_metrics

    - name: Display validation results
      ansible.builtin.debug:
        msg:
          - "Netdata Service: {{ netdata_service.status.ActiveState }}"
          - "API Status: {{ 'OK' if api_response.status == 200 else 'FAILED' }}"
          - "Docker Monitoring: {{ 'Available' if docker_metrics.status == 200 else 'No containers' }}"
          - "System Metrics: {{ 'Collecting' if cpu_metrics.status == 200 else 'FAILED' }}"

    - name: Assert all checks passed
      ansible.builtin.assert:
        that:
          - netdata_service.status.ActiveState == "active"
          - api_response.status == 200
          - cpu_metrics.status == 200
        fail_msg: "Netdata validation failed"
        success_msg: "All Netdata checks passed"
```

### 8. **Integration with site.yml**

Update `ansible_collections/basher83/automation_server/playbooks/site.yml` to include monitoring:

```yaml
# Add to the tasks section:
- name: Deploy monitoring solution
  import_playbook: monitoring.yml
  tags:
    - monitoring
    - netdata
```

## Success Criteria

- [ ] Netdata agent installed and running
- [ ] Web dashboard accessible on port 19999
- [ ] System metrics being collected
- [ ] Docker container metrics visible (if containers running)
- [ ] API endpoints responding correctly
- [ ] Service enabled for automatic startup
- [ ] Firewall rules configured for web access
- [ ] All validation tests passing

## Validation

### Test Deployment

```bash
cd ansible_collections/basher83/automation_server

# Install requirements
ansible-galaxy install -r requirements.yml

# Run ansible-lint
ansible-lint playbooks/monitoring.yml
ansible-lint roles/netdata/

# Check syntax
ansible-playbook -i inventory/ansible_inventory.json playbooks/monitoring.yml --syntax-check

# Deploy Netdata
ansible-playbook -i inventory/ansible_inventory.json playbooks/monitoring.yml

# Run validation tests
ansible-playbook -i inventory/ansible_inventory.json playbooks/test-netdata.yml

# Manual verification
curl http://192.168.10.250:19999/api/v1/info | jq .
```

### Access Dashboard

Open browser to: `http://192.168.10.250:19999`

Features available:

- Real-time system metrics (1-second granularity)
- Docker container monitoring
- Network interface statistics
- Disk I/O metrics
- Process monitoring
- No configuration required
- Historical data retention (1 hour by default)

## Notes

- Netdata provides zero-configuration monitoring out of the box
- Docker monitoring works automatically via cgroups
- Much simpler than Prometheus/Grafana stack (1 agent vs 4 containers)
- Real-time updates without polling delays
- Lower resource usage than traditional monitoring stacks
- Can be integrated with Netdata Cloud for centralized monitoring
- Supports over 2000 metrics collectors without configuration

## Benefits Over Prometheus/Grafana

1. **Simplicity**: Single agent vs complex multi-container stack
1. **Performance**: 1-second granularity with minimal overhead
1. **Zero Config**: Works immediately after installation
1. **Docker Native**: Automatic container detection and naming
1. **Resource Efficient**: ~2% CPU, 50MB RAM typical usage
1. **Real-time**: Live streaming metrics, not polling-based

## References

- [Official Netdata Ansible Repository](https://github.com/netdata/ansible)
- [Netdata Documentation](https://learn.netdata.cloud/)
- [Docker Monitoring Guide](https://learn.netdata.cloud/docs/data-collection/container-and-vm-monitoring/docker)
- [Ubuntu 24.04 Installation](https://learn.netdata.cloud/docs/installing/linux-package-managers#ubuntu)
- [Research Report](./.claude/research-reports/ansible-research-20250922-213639.md)
