# Ansible Role: Docker

A comprehensive Ansible role for installing, configuring, and managing Docker CE on Ubuntu/Debian systems. This role provides flexible installation modes, security hardening, and extensive validation capabilities.

## Research Phase Summary

Based on research of existing Ansible Docker collections:

1. **geerlingguy.docker** (v7.5.0+): Most mature and widely adopted Docker role
   - 4.8K+ stars, actively maintained
   - Comprehensive OS support
   - Production-proven with millions of downloads
   - Used as dependency for actual installation

2. **community.docker** (v3.13.0+): Official collection for Docker management
   - Provides Docker modules for container/image management
   - Used for validation and container operations
   - Maintained by Ansible community

3. **Design Decision**: This role wraps geerlingguy.docker for installation while adding:
   - Project-specific configurations
   - Enhanced security settings
   - Comprehensive validation suite
   - Resource management features

## Requirements

- Ubuntu 20.04, 22.04, or 24.04 LTS
- Ansible 2.15 or higher
- Python docker module (installed automatically)
- Minimum 512MB RAM
- Kernel version 3.10+

## Dependencies

This role depends on:

- `geerlingguy.docker` (for Docker installation)
- `community.docker` collection (for Docker management modules)

Install dependencies:

```bash
ansible-galaxy install -r requirements.yml
```

## Role Variables

### Installation Mode

```yaml
docker_installation_mode: "install"  # Options: install, validate
```

- `install`: Full Docker installation and configuration
- `validate`: Only validate existing Docker installation

### Core Configuration

```yaml
# Service management
docker_service_enabled: true
docker_service_state: "started"

# Docker daemon configuration
docker_daemon_options:
  log-driver: "json-file"
  log-opts:
    max-size: "10m"
    max-file: "3"
  storage-driver: "overlay2"
  iptables: true

# Data directory (default: /var/lib/docker)
docker_data_directory: "/var/lib/docker"
```

### User Management

```yaml
# WARNING: Users in docker group have root-equivalent access
docker_users_list: []  # List of users to add to docker group
# Example: ["deploy", "developer"]
```

### Security Configuration

```yaml
# User namespace remapping for enhanced isolation
docker_enable_user_namespace_remapping: false

# Seccomp profiles (enabled by default in Docker)
docker_enable_seccomp: true

# Docker socket permissions
docker_socket_permissions: "0660"

# Enable Docker Content Trust
docker_content_trust: false
```

### Resource Management

```yaml
# Automatic cleanup cron job
docker_enable_cleanup_cron: false
docker_cleanup_retention_hours: 72

# Log rotation
docker_configure_log_rotation: true
docker_log_max_size: "10m"
docker_log_max_files: "3"

# Memory limits configuration
docker_enable_memory_limits: false
```

### Network Configuration

```yaml
# Docker networks
docker_networks: []
# Example:
# docker_networks:
#   - name: app_network
#     driver: bridge
#     subnet: "172.20.0.0/16"

# Registry mirrors
docker_registry_mirrors: []
# Example: ["https://mirror.gcr.io"]

# Insecure registries
docker_insecure_registries: []
# Example: ["localhost:5000"]
```

### Debug and Validation

```yaml
# Debug mode for verbose output
docker_debug_mode: false

# Validation tests to run
docker_validation_tests:
  - hello_world_test
  - network_test
  - volume_test

# Export summary to file
docker_export_summary: false
```

## Example Playbook

### Basic Installation

```yaml
---
- hosts: docker_hosts
  become: true
  roles:
    - role: docker
      vars:
        docker_installation_mode: "install"
        docker_users_list:
          - "{{ ansible_user }}"
```

### Production Configuration with Security

```yaml
---
- hosts: production
  become: true
  roles:
    - role: docker
      vars:
        docker_installation_mode: "install"
        docker_enable_user_namespace_remapping: true
        docker_enable_cleanup_cron: true
        docker_daemon_options:
          log-driver: "json-file"
          log-opts:
            max-size: "10m"
            max-file: "5"
          storage-driver: "overlay2"
          live-restore: true
          userland-proxy: false
        docker_registry_mirrors:
          - "https://mirror.gcr.io"
        docker_users_list: []  # Don't add users to docker group in prod
```

### Validation Only Mode

```yaml
---
- hosts: docker_hosts
  become: true
  roles:
    - role: docker
      vars:
        docker_installation_mode: "validate"
        docker_debug_mode: true
```

## Security Considerations

### Docker Group Warning

⚠️ **CRITICAL**: Users added to the `docker` group have root-equivalent privileges. For production systems:

- Use `sudo` for Docker commands instead of adding users to docker group
- Consider using rootless Docker mode
- Implement proper RBAC with Docker Enterprise or Kubernetes

### Security Best Practices Implemented

1. **User Namespace Remapping**: Isolates container users from host
2. **Seccomp Profiles**: Restricts system calls available to containers
3. **No New Privileges**: Prevents privilege escalation
4. **AppArmor Integration**: Additional MAC layer (on supported systems)
5. **Content Trust**: Optional image signature verification
6. **Log Rotation**: Prevents disk exhaustion from container logs

## Task Organization

The role is organized into logical task groups:

1. **main.yml**: Orchestrates all tasks based on mode
2. **installation.yml**: Prerequisites and dependency setup
3. **configuration.yml**: Docker daemon configuration
4. **users.yml**: User and group management
5. **security.yml**: Security hardening tasks
6. **validation.yml**: Comprehensive validation suite
7. **resources.yml**: Resource management and cleanup
8. **firewall.yml**: Firewall compatibility configuration
9. **summary.yml**: Installation summary and reporting

## Validation Tests

The role includes comprehensive validation:

- Docker service status verification
- Docker version compatibility check
- Docker Compose plugin availability
- Socket permissions validation
- Network configuration testing
- Hello-world container test
- Custom validation suite execution

## Handlers

Available handlers:

- `restart docker`: Restart Docker service
- `reload docker`: Reload Docker configuration
- `reload systemd`: Reload systemd daemon
- `update grub`: Update GRUB for memory limits
- `reload ufw`: Reload UFW rules
- `reload firewalld`: Reload firewalld configuration

## Troubleshooting

### Common Issues

1. **Docker service fails to start**
   - Check logs: `journalctl -u docker.service`
   - Verify disk space: `df -h /var/lib/docker`
   - Check daemon.json syntax: `docker --validate`

2. **Permission denied on docker.sock**
   - Verify socket permissions
   - Check user group membership: `groups username`
   - Restart session after group changes

3. **Network conflicts**
   - Check existing bridge networks
   - Verify IP forwarding: `sysctl net.ipv4.ip_forward`
   - Review iptables rules: `iptables -L`

## Testing

Run molecule tests:

```bash
cd ansible/roles/docker
molecule test
```

Manual validation:

```bash
ansible-playbook -i inventory playbook.yml --tags docker_validate
```

## License

MIT

## Author Information

Created for the Sombrero-Edge-Control infrastructure project.

## Version History

- 1.0.0: Initial release with comprehensive Docker management
  - Full installation via geerlingguy.docker dependency
  - Security hardening options
  - Validation suite
  - Resource management features
