# Ansible Role: Firewall

A comprehensive iptables-based firewall role with full Docker compatibility, designed to work seamlessly with Docker's automatic iptables management while providing host and container security.

## ⚠️ CRITICAL: Docker Compatibility

**This role is specifically designed to work with Docker's iptables management.**

Key Docker compatibility features:
- Never flushes all iptables rules (would break Docker networking)
- Preserves Docker's automatic chains (DOCKER, DOCKER-ISOLATION)
- Configures DOCKER-USER chain for container access control
- Detects Docker presence and adapts configuration automatically
- Provides clear warnings about Docker's firewall bypass behavior

### Important Docker Firewall Facts

1. **Docker bypasses host firewall rules**: Ports published with `-p` are accessible regardless of INPUT chain rules
2. **DOCKER-USER chain is your friend**: This chain is evaluated before Docker's rules and persists across Docker restarts
3. **Never use UFW with Docker**: UFW is incompatible with Docker's iptables management
4. **Never flush iptables with Docker running**: This will break all container networking

## Requirements

- Ubuntu 20.04, 22.04, or 24.04 LTS (Debian 11/12 also supported)
- Ansible 2.15 or higher
- Root or sudo privileges
- iptables (iptables-nft or iptables-legacy)

## Role Variables

### Rule Management Methods

This role supports two methods for managing firewall rules:

1. **Priority-based rules** (Recommended) - Numbered rule groups processed in order
2. **Legacy method** - Traditional individual rule application

```yaml
# Enable priority-based rule system (recommended)
firewall_use_priority_rules: true

# Define custom priority rules
firewall_rules_priority:
  250_my_app:
    description: "My application rules"
    enabled: true
    rules:
      - "-A INPUT -p tcp --dport 3000 -j ACCEPT"
      - "-A INPUT -p tcp --dport 3001 -j ACCEPT"
```

The priority system processes rules in numerical order (001-999), making rule ordering explicit and manageable.

### Docker Compatibility Settings

```yaml
# Automatically detected, but can be overridden
firewall_docker_compatibility: true
firewall_configure_docker_user_chain: true
firewall_preserve_docker_chains: true

# Docker-USER chain rules for container restrictions
firewall_docker_user_rules:
  - name: "Block external access to containers"
    interface: "eth0"
    action: "DROP"
    position: 1
  - name: "Allow HTTP to containers from external"
    interface: "eth0"
    port: 80
    protocol: tcp
    action: "ACCEPT"
    position: 2
```

### Basic Configuration

```yaml
# Firewall backend
firewall_backend: "iptables"  # iptables, iptables-nft, or iptables-legacy
firewall_enable: true

# Default policies (Docker manages FORWARD)
firewall_default_input_policy: "DROP"
firewall_default_forward_policy: "DROP"
firewall_default_output_policy: "ACCEPT"

# SSH configuration
firewall_ssh_enabled: true
firewall_ssh_port: 22
firewall_ssh_rate_limit: true
firewall_ssh_rate_limit_burst: 5
```

### Service Ports

```yaml
firewall_input_rules:
  - name: "SSH"
    port: 22
    protocol: tcp
    source: "0.0.0.0/0"
    state: "enabled"

  - name: "HTTP"
    port: 80
    protocol: tcp
    source: "0.0.0.0/0"
    state: "disabled"  # Enable as needed

  - name: "HTTPS"
    port: 443
    protocol: tcp
    source: "0.0.0.0/0"
    state: "disabled"  # Enable as needed
```

### Security Features

```yaml
# Connection tracking
firewall_allow_established: true
firewall_allow_related: true

# DDoS protection
firewall_syn_flood_protection: true
firewall_enable_rate_limiting: true
firewall_port_scan_protection: true

# Logging
firewall_enable_logging: true
firewall_log_dropped: true
```

## Example Playbooks

### Using Priority-Based Rules (Recommended)

```yaml
---
- hosts: docker_hosts
  become: true
  roles:
    - role: firewall
      vars:
        firewall_use_priority_rules: true
        firewall_rules_priority:
          # Override default SSH rules with stricter settings
          100_ssh:
            description: "Hardened SSH access"
            rules:
              - "-A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT"
              - "-A INPUT -p tcp --dport 22 -j DROP"

          # Add application-specific rules
          250_my_services:
            description: "Application services"
            rules:
              - "-A INPUT -p tcp --dport 8080 -j ACCEPT"
              - "-A INPUT -p tcp --dport 9090 -s 192.168.1.0/24 -j ACCEPT"

          # Enable web services
          200_web_services:
            enabled: true  # Overrides default disabled state
```

### Basic Setup with Docker

```yaml
---
- hosts: docker_hosts
  become: true
  roles:
    - role: docker      # Install Docker first
    - role: firewall    # Then configure firewall
      vars:
        firewall_docker_compatibility: true
        firewall_input_rules:
          - name: "SSH"
            port: 22
            protocol: tcp
            state: "enabled"
```

### Docker with Container Restrictions

```yaml
---
- hosts: production
  become: true
  roles:
    - role: firewall
      vars:
        # Block all external access to containers except specific ports
        firewall_docker_user_rules:
          - name: "Block all external to containers"
            interface: "{{ ansible_default_ipv4.interface }}"
            action: "DROP"
            position: 1
          - name: "Allow HTTP"
            interface: "{{ ansible_default_ipv4.interface }}"
            port: 80
            protocol: tcp
            action: "ACCEPT"
            position: 2
          - name: "Allow HTTPS"
            interface: "{{ ansible_default_ipv4.interface }}"
            port: 443
            protocol: tcp
            action: "ACCEPT"
            position: 3
```

### High Security Configuration

```yaml
---
- hosts: secure_hosts
  become: true
  roles:
    - role: firewall
      vars:
        firewall_default_input_policy: "DROP"
        firewall_ssh_source_ips:
          - "10.0.0.0/8"
          - "192.168.1.0/24"
        firewall_syn_flood_protection: true
        firewall_port_scan_protection: true
        firewall_enable_logging: true
        firewall_drop_invalid: true
```

## Docker-Specific Usage

### Understanding DOCKER-USER Chain

The DOCKER-USER chain is evaluated **before** Docker's automatic rules. This is the ONLY reliable place to add restrictions for container traffic.

```bash
# View current DOCKER-USER rules
iptables -L DOCKER-USER -n -v

# Manual example: Block all external access
iptables -I DOCKER-USER -i eth0 -j DROP

# Manual example: Allow specific port
iptables -I DOCKER-USER -i eth0 -p tcp --dport 80 -j ACCEPT
```

### Common Docker Scenarios

1. **Public Web Server**: Allow only HTTP/HTTPS from external
2. **Internal Services**: Block all external, allow from trusted networks
3. **Development**: Allow all (default Docker behavior)
4. **Database Containers**: Never expose externally, internal only

## Troubleshooting

### Docker Networking Issues

If Docker networking breaks after firewall configuration:

```bash
# Check Docker chains exist
iptables -L DOCKER -n
iptables -L DOCKER-USER -n

# Emergency fix - restore Docker chains
systemctl restart docker

# View current rules
iptables -S
```

### SSH Lockout Prevention

The role includes SSH rate limiting. If locked out:

1. Wait 60 seconds for rate limit to reset
2. Use console access to disable rate limiting
3. Adjust `firewall_ssh_rate_limit_burst` if needed

### Validation

Run the validation tasks to ensure everything works:

```bash
ansible-playbook -i inventory site.yml --tags firewall_validate
```

## File Locations

- Rules saved to: `/etc/iptables/rules.v4`
- Backups: `/etc/iptables/backups/`
- Docker notes: `/etc/iptables/docker-firewall-notes.txt`
- Validation report: `/tmp/firewall-validation-report.txt`

## Security Considerations

### Docker Security Model

1. **Published Ports Bypass Firewall**: When you run `docker run -p 80:80`, port 80 is accessible from anywhere, regardless of INPUT rules
2. **Use DOCKER-USER Chain**: This is the only reliable way to restrict container access
3. **Internal Container Communication**: Containers can communicate freely unless you configure Docker network policies
4. **Bridge Network**: Default docker0 bridge is 172.17.0.0/16

### Best Practices

1. Never expose database containers with `-p`
2. Use Docker networks for internal communication
3. Implement DOCKER-USER rules for production
4. Regular rule audits with validation playbook
5. Keep backups before major changes

## Testing

Test the role without applying changes:

```bash
ansible-playbook -i inventory test-firewall.yml --check
```

Test Docker compatibility:

```bash
# After applying firewall
docker run --rm hello-world
docker run --rm -p 8080:80 nginx:alpine
curl localhost:8080  # Should work
```

## Common Issues

### Issue: Docker containers unreachable

**Solution**: Check DOCKER-USER chain isn't blocking traffic:
```bash
iptables -L DOCKER-USER -n -v
```

### Issue: iptables rules lost on reboot

**Solution**: Ensure netfilter-persistent is enabled:
```bash
systemctl enable netfilter-persistent
```

### Issue: UFW conflicts

**Solution**: Uninstall UFW when using Docker:
```bash
apt-get remove --purge ufw
```

## License

MIT

## Author Information

Created for the Sombrero-Edge-Control infrastructure project.

## Version History

- 1.0.0: Initial release with full Docker compatibility
  - DOCKER-USER chain management
  - Docker detection and adaptation
  - Comprehensive security features
  - iptables persistence

## References

- [Docker and iptables](https://docs.docker.com/network/packet-filtering-firewalls/)
- [ADR-2024-08-31: Docker iptables compatibility](../../docs/decisions/ADR-2024-08-31-docker-iptables-firewall.md)
