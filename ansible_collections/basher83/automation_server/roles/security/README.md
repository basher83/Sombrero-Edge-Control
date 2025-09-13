# Ansible Role: Security Hardening

Comprehensive security hardening role for Ubuntu servers following CIS benchmarks and security best practices.

## Overview

This role implements multiple layers of security hardening including:

- SSH configuration hardening
- Kernel parameter tuning (sysctl)
- Fail2ban intrusion prevention
- Audit logging with auditd
- System hardening (passwords, permissions, services)
- AppArmor mandatory access control
- Automatic security updates

## Requirements

- Ubuntu 20.04 LTS or later (22.04, 24.04)
- Ansible 2.9 or higher
- Root or sudo privileges
- Python 3.x on target host

## Role Variables

### Core Settings

```yaml
# CIS Benchmark Compliance
security_cis_level: 1           # 1 (basic) or 2 (advanced)
security_cis_profile: "server"  # 'server' or 'workstation'

# Feature Toggles
security_kernel_hardening_enabled: true
security_fail2ban_enabled: true
security_auditd_enabled: true
security_password_quality_enabled: true
security_automatic_updates_enabled: true
security_apparmor_enabled: true
security_file_permissions_enabled: true
security_process_accounting_enabled: true
security_validation_enabled: true
security_generate_report: true
```

### SSH Configuration

```yaml
security_ssh_port: 22
security_ssh_permit_root_login: "no"
security_ssh_password_authentication: "no"
security_ssh_pubkey_authentication: "yes"
security_ssh_max_auth_tries: 3
security_ssh_client_alive_interval: 300
security_ssh_allow_users:
  - ansible
security_ssh_allowed_ciphers: "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com"
```

### Fail2ban Configuration

```yaml
security_fail2ban_bantime: 3600      # 1 hour
security_fail2ban_findtime: 600      # 10 minutes
security_fail2ban_maxretry: 5
security_fail2ban_ignoreip: "127.0.0.1/8 ::1"
security_fail2ban_jails:
  - name: sshd
    enabled: true
    port: 22
    maxretry: 3
    bantime: 7200
```

### Kernel Hardening (sysctl)

```yaml
security_sysctl_settings:
  net.ipv4.ip_forward: 0
  net.ipv4.tcp_syncookies: 1
  kernel.randomize_va_space: 2
  fs.suid_dumpable: 0
  # ... many more parameters
```

### Password Policy

```yaml
security_password_min_length: 14
security_password_min_class: 3
security_login_defs_pass_max_days: 90
security_login_defs_pass_min_days: 7
security_login_defs_pass_warn_age: 14
```

## Dependencies

None. This role is self-contained.

## Example Playbook

### Basic Usage

```yaml
---
- hosts: jump_hosts
  become: true
  roles:
    - role: security
      vars:
        security_ssh_allow_users:
          - ansible
          - admin
        security_ssh_port: 2222
```

### Advanced Usage with Custom Settings

```yaml
---
- hosts: production_servers
  become: true
  roles:
    - role: security
      vars:
        security_cis_level: 2
        security_cis_profile: "server"
        security_ssh_port: 22
        security_ssh_allow_users:
          - ansible
          - devops
        security_fail2ban_enabled: true
        security_fail2ban_bantime: 7200
        security_fail2ban_jails:
          - name: sshd
            enabled: true
            port: 22
            maxretry: 2
            bantime: 86400
          - name: sshd-ddos
            enabled: true
            port: 22
            maxretry: 10
            bantime: 3600
        security_automatic_updates_enabled: true
        security_kernel_hardening_enabled: true
        security_auditd_enabled: true
        security_generate_report: true
        security_report_path: "/var/log/security-audit.txt"
```

### Minimal Hardening

```yaml
---
- hosts: development
  become: true
  roles:
    - role: security
      vars:
        security_fail2ban_enabled: false
        security_auditd_enabled: false
        security_automatic_updates_enabled: false
```

## Security Features

### 1. SSH Hardening

- Disables root login
- Enforces key-based authentication
- Configures secure ciphers and algorithms
- Sets connection limits and timeouts
- Creates login banner

### 2. Kernel Hardening

- Disables IP forwarding
- Enables SYN flood protection
- Configures ASLR (Address Space Layout Randomization)
- Restricts kernel pointer exposure
- Sets network security parameters

### 3. Fail2ban Protection

- Monitors SSH attempts
- Configurable ban times and thresholds
- DDoS protection
- Email notifications
- Persistent ban database

### 4. Audit Logging

- Tracks authentication events
- Monitors privileged commands
- File integrity monitoring
- System call auditing
- Kernel module loading tracking

### 5. System Hardening

- Password quality enforcement
- Account lockout policies
- Automatic security updates
- Service minimization
- File permission enforcement
- AppArmor profiles

## Files Created/Modified

### Configuration Files

- `/etc/ssh/sshd_config` - SSH daemon configuration
- `/etc/sysctl.d/99-security-hardening.conf` - Kernel parameters
- `/etc/fail2ban/jail.local` - Fail2ban configuration
- `/etc/audit/auditd.conf` - Audit daemon settings
- `/etc/audit/rules.d/security-hardening.rules` - Audit rules
- `/etc/security/pwquality.conf` - Password quality rules
- `/etc/login.defs` - Login definitions

### Log Files

- `/var/log/auth.log` - Authentication logs
- `/var/log/audit/audit.log` - Audit logs
- `/var/log/fail2ban.log` - Fail2ban activity
- `/var/log/security-hardening-report.txt` - Security report

## Validation

The role includes comprehensive validation tasks that check:

- SSH configuration syntax
- Service status (SSH, fail2ban, auditd)
- Kernel parameter application
- File permissions
- AppArmor status
- Automatic updates configuration

Run validation separately:

```bash
ansible-playbook -i inventory site.yml --tags validation
```

## Tags

- `security` - Run all security tasks
- `ssh` - SSH hardening only
- `kernel` - Kernel hardening only
- `fail2ban` - Fail2ban configuration only
- `audit` - Audit configuration only
- `system` - System hardening only
- `validation` - Run validation checks
- `report` - Generate security report

Example:

```bash
# Only configure SSH and fail2ban
ansible-playbook -i inventory site.yml --tags ssh,fail2ban

# Run validation only
ansible-playbook -i inventory site.yml --tags validation
```

## Security Report

A comprehensive security report is generated at `/var/log/security-hardening-report.txt` containing:

- Configuration summary
- Applied settings
- Validation results
- CIS compliance status
- Recommendations

## Compatibility

### Docker Compatibility

This role detects Docker presence and adjusts firewall rules accordingly to maintain container networking.

### Cloud Environments

Tested on:

- AWS EC2
- DigitalOcean Droplets
- Proxmox VMs
- VMware vSphere
- Bare metal servers

## Testing

### Local Testing with Molecule

```bash
cd ansible/roles/security
molecule test
```

### Manual Testing

```bash
# Dry run
ansible-playbook -i inventory site.yml --check

# Verbose output
ansible-playbook -i inventory site.yml -vvv

# Specific host
ansible-playbook -i inventory site.yml --limit jump-man
```

## Troubleshooting

### SSH Access Issues

If locked out after hardening:

1. Use console access
2. Check `/etc/ssh/sshd_config.backup.*`
3. Restore: `cp /etc/ssh/sshd_config.backup.<timestamp> /etc/ssh/sshd_config`
4. Restart SSH: `systemctl restart sshd`

### Fail2ban False Positives

Whitelist IPs:

```yaml
security_fail2ban_ignoreip: "127.0.0.1/8 ::1 192.168.1.0/24"
```

### Performance Impact

If experiencing performance issues:

- Reduce audit rules
- Disable process accounting
- Adjust fail2ban findtime/bantime

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## License

MIT

## Author

DevOps Team - Sombrero Edge Control

## References

- [CIS Ubuntu Linux 22.04 LTS Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [OWASP Security Guidelines](https://owasp.org/)
- [fail2ban Documentation](https://www.fail2ban.org/)
- [auditd Documentation](https://linux.die.net/man/8/auditd)
