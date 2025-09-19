---
Task: Security Hardening with nftables and SSH
Task ID: ANS-003
Priority: P1 (Important)
Estimated Time: 3 hours
Dependencies: ANS-001
Status: ⏸️ Blocked
---

## Objective

Implement comprehensive security hardening for the jump host including nftables firewall configuration, SSH hardening, fail2ban setup, and security best practices. This ensures the jump host is properly secured as the central management point for infrastructure operations.

## Prerequisites

- [ ] ANS-001 completed (Bootstrap playbook)
- [ ] VM accessible via Ansible
- [ ] Understanding of current network requirements
- [ ] List of allowed source IPs for SSH

## Implementation Steps

### 1. **Create Security Hardening Role**

```bash
cd ansible_collections/basher83/automation_server/roles
ansible-galaxy role init security_hardening
```

### 2. **Define Security Variables**

Create `roles/security_hardening/defaults/main.yml`:

```yaml
---
# SSH Configuration
ssh_port: 22
ssh_permit_root_login: "no"
ssh_password_authentication: "no"
ssh_pubkey_authentication: "yes"
ssh_permit_empty_passwords: "no"
ssh_challenge_response_authentication: "no"
ssh_gss_api_authentication: "no"
ssh_x11_forwarding: "no"
ssh_max_auth_tries: 3
ssh_max_sessions: 10
ssh_client_alive_interval: 300
ssh_client_alive_count_max: 2
ssh_allowed_users:
  - ansible

# Firewall Configuration
firewall_allowed_tcp_ports:
  - 22    # SSH
  - 80    # HTTP (for future services)
  - 443   # HTTPS (for future services)

firewall_allowed_udp_ports: []

firewall_allowed_networks:
  - "192.168.10.0/24"  # Local network

# Fail2ban Configuration
fail2ban_enabled: true
fail2ban_bantime: 3600
fail2ban_findtime: 600
fail2ban_maxretry: 5

# System Hardening
kernel_hardening_enabled: true
disable_unused_filesystems: true
secure_shared_memory: true
```

### 3. **Create SSH Hardening Tasks**

Create `roles/security_hardening/tasks/ssh.yml`:

```yaml
---
- name: Backup original SSH configuration
  copy:
    src: /etc/ssh/sshd_config
    dest: /etc/ssh/sshd_config.backup
    remote_src: yes
    force: no

- name: Configure SSH daemon
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: "^#?{{ item.key }}"
    line: "{{ item.key }} {{ item.value }}"
    state: present
    validate: 'sshd -t -f %s'
  loop:
    - { key: 'Port', value: "{{ ssh_port }}" }
    - { key: 'PermitRootLogin', value: "{{ ssh_permit_root_login }}" }
    - { key: 'PasswordAuthentication', value: "{{ ssh_password_authentication }}" }
    - { key: 'PubkeyAuthentication', value: "{{ ssh_pubkey_authentication }}" }
    - { key: 'PermitEmptyPasswords', value: "{{ ssh_permit_empty_passwords }}" }
    - { key: 'ChallengeResponseAuthentication', value: "{{ ssh_challenge_response_authentication }}" }
    - { key: 'GSSAPIAuthentication', value: "{{ ssh_gss_api_authentication }}" }
    - { key: 'X11Forwarding', value: "{{ ssh_x11_forwarding }}" }
    - { key: 'MaxAuthTries', value: "{{ ssh_max_auth_tries }}" }
    - { key: 'MaxSessions', value: "{{ ssh_max_sessions }}" }
    - { key: 'ClientAliveInterval', value: "{{ ssh_client_alive_interval }}" }
    - { key: 'ClientAliveCountMax', value: "{{ ssh_client_alive_count_max }}" }
  notify: restart sshd

- name: Configure allowed SSH users
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?AllowUsers'
    line: "AllowUsers {{ ssh_allowed_users | join(' ') }}"
    state: present
  when: ssh_allowed_users | length > 0
  notify: restart sshd
```

### 4. **Create Firewall Tasks**

Create `roles/security_hardening/tasks/firewall.yml`:

```yaml
---
- name: Install nftables
  apt:
    name:
      - nftables
      - netfilter-persistent
    state: present

- name: Create nftables configuration
  template:
    src: nftables.conf.j2
    dest: /etc/nftables.conf
    owner: root
    group: root
    mode: '0644'
  notify: reload nftables

- name: Enable and start nftables
  systemd:
    name: nftables
    enabled: yes
    state: started

- name: Save nftables rules
  command: nft list ruleset > /etc/nftables.conf
  changed_when: false
```

Create `roles/security_hardening/templates/nftables.conf.j2`:

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow established connections
        ct state established,related accept

        # Allow loopback
        iif lo accept

        # Allow ICMP
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        # Allow SSH from specific networks
{% for network in firewall_allowed_networks %}
        ip saddr {{ network }} tcp dport {{ ssh_port }} accept
{% endfor %}

        # Allow configured TCP ports
{% for port in firewall_allowed_tcp_ports %}
        tcp dport {{ port }} accept
{% endfor %}

        # Allow configured UDP ports
{% for port in firewall_allowed_udp_ports %}
        udp dport {{ port }} accept
{% endfor %}

        # Log dropped packets
        limit rate 5/minute log prefix "nftables-dropped: " level info
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

### 5. **Create Fail2ban Tasks**

Create `roles/security_hardening/tasks/fail2ban.yml`:

```yaml
---
- name: Install fail2ban
  apt:
    name: fail2ban
    state: present

- name: Configure fail2ban defaults
  template:
    src: jail.local.j2
    dest: /etc/fail2ban/jail.local
    owner: root
    group: root
    mode: '0644'
  notify: restart fail2ban

- name: Create fail2ban SSH jail
  template:
    src: sshd.local.j2
    dest: /etc/fail2ban/jail.d/sshd.local
    owner: root
    group: root
    mode: '0644'
  notify: restart fail2ban

- name: Enable and start fail2ban
  systemd:
    name: fail2ban
    enabled: yes
    state: started
```

### 6. **Create System Hardening Tasks**

Create `roles/security_hardening/tasks/system.yml`:

```yaml
---
- name: Configure kernel parameters
  sysctl:
    name: "{{ item.key }}"
    value: "{{ item.value }}"
    state: present
    sysctl_file: /etc/sysctl.d/99-hardening.conf
    reload: yes
  loop:
    - { key: 'net.ipv4.tcp_syncookies', value: '1' }
    - { key: 'net.ipv4.ip_forward', value: '0' }
    - { key: 'net.ipv4.conf.all.rp_filter', value: '1' }
    - { key: 'net.ipv4.conf.all.accept_redirects', value: '0' }
    - { key: 'net.ipv4.conf.all.send_redirects', value: '0' }
    - { key: 'net.ipv4.conf.all.accept_source_route', value: '0' }
    - { key: 'net.ipv4.icmp_echo_ignore_broadcasts', value: '1' }
    - { key: 'net.ipv4.icmp_ignore_bogus_error_responses', value: '1' }
    - { key: 'kernel.randomize_va_space', value: '2' }
  when: kernel_hardening_enabled

- name: Disable unused kernel modules
  copy:
    content: |
      # Disable rare filesystems
      install cramfs /bin/true
      install freevxfs /bin/true
      install jffs2 /bin/true
      install hfs /bin/true
      install hfsplus /bin/true
      install udf /bin/true
    dest: /etc/modprobe.d/blacklist-filesystems.conf
    owner: root
    group: root
    mode: '0644'
  when: disable_unused_filesystems

- name: Secure shared memory
  mount:
    path: /run/shm
    src: tmpfs
    fstype: tmpfs
    opts: defaults,noexec,nosuid,nodev
    state: mounted
  when: secure_shared_memory

- name: Set file permissions on sensitive files
  file:
    path: "{{ item.path }}"
    owner: "{{ item.owner | default('root') }}"
    group: "{{ item.group | default('root') }}"
    mode: "{{ item.mode }}"
  loop:
    - { path: '/etc/ssh/sshd_config', mode: '0600' }
    - { path: '/etc/cron.allow', mode: '0600' }
    - { path: '/etc/at.allow', mode: '0600' }
    - { path: '/etc/sudo.conf', mode: '0600' }
```

### 7. **Create Main Task File**

Create `roles/security_hardening/tasks/main.yml`:

```yaml
---
- name: Apply SSH hardening
  include_tasks: ssh.yml
  tags: [security, ssh]

- name: Configure firewall
  include_tasks: firewall.yml
  tags: [security, firewall]

- name: Setup fail2ban
  include_tasks: fail2ban.yml
  tags: [security, fail2ban]
  when: fail2ban_enabled

- name: Apply system hardening
  include_tasks: system.yml
  tags: [security, system]

- name: Create security audit log
  lineinfile:
    path: /var/log/ansible-security.log
    line: "Security hardening applied: {{ ansible_date_time.iso8601 }}"
    create: yes
    owner: root
    group: root
    mode: '0644'
```

### 8. **Create Handlers**

Create `roles/security_hardening/handlers/main.yml`:

```yaml
---
- name: restart sshd
  systemd:
    name: sshd
    state: restarted

- name: reload nftables
  systemd:
    name: nftables
    state: reloaded

- name: restart fail2ban
  systemd:
    name: fail2ban
    state: restarted
```

## Success Criteria

- [ ] Ansible-lint passes with no errors
- [ ] SSH hardened with key-only authentication
- [ ] nftables firewall configured and active
- [ ] fail2ban protecting against brute force
- [ ] Kernel parameters hardened
- [ ] Sensitive file permissions secured
- [ ] All security services running
- [ ] Can still access VM via SSH

## Validation

### Test Security Configuration

```bash
cd ansible_collections/basher83/automation_server

# MANDATORY: Run ansible-lint first
ansible-lint playbooks/security.yml
ansible-lint roles/security_hardening/
# Must pass production linting rules

# Check syntax
ansible-playbook -i inventory/ansible_inventory.json playbooks/security.yml --syntax-check

# Apply security hardening
ansible-playbook -i inventory/ansible_inventory.json playbooks/security.yml

# Verify SSH configuration
ssh ansible@192.168.10.250 "sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication'"

# Check firewall rules
ssh ansible@192.168.10.250 "sudo nft list ruleset"

# Verify fail2ban status
ssh ansible@192.168.10.250 "sudo fail2ban-client status"

# Test connection is still working
ansible -i inventory/ansible_inventory.json jump_hosts -m ping
```

Expected output:

- SSH configuration shows secure settings
- Firewall rules are active
- fail2ban is running with SSH jail
- Ansible can still connect

## Notes

- Test thoroughly in development before production
- Keep firewall rules minimal but sufficient
- Document any custom security requirements
- Consider implementing auditd for compliance
- Regular security updates are essential

## References

- [SSH Hardening Guide](https://www.ssh.com/academy/ssh/sshd_config)
- [nftables Documentation](https://wiki.nftables.org/)
- [fail2ban Documentation](https://www.fail2ban.org/)
- [CIS Ubuntu Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux)
