# VM Smoke Tests Role

This role performs comprehensive smoke testing and health validation for VMs
in the Sombrero Edge Control infrastructure. It replaces direct SSH commands with
idempotent Ansible tasks for system validation.

## Research Background

Based on comprehensive research of Ansible collections for VM testing:

### Primary Collections Used

- **community.general v11.3.0** (Score: 88/100) - Comprehensive system validation and service testing
- **ansible.builtin** (Score: 75/100) - Core validation modules with stable APIs
- **ansible.posix v3.0.0** (Score: 82/100) - POSIX system validation and security checks
- **community.docker** (Score: 81/100) - Docker container and service validation

### Collection Quality Assessment

Research conducted using ansible-research subagent with 100-point scoring system evaluating:

- Repository health and maintenance activity
- Community engagement and contributor base
- Documentation quality and completeness
- API stability and backwards compatibility

## Role Overview

This role implements a multi-phase testing approach:

1. **Phase 1**: Basic system health (CPU, memory, disk, network)
1. **Phase 2**: Service validation (systemd services, Docker containers)
1. **Phase 3**: Application-specific health checks (HTTP endpoints, security)
1. **Phase 4**: Performance and resource utilization validation

## Features

### System Health Checks

- CPU load and utilization monitoring
- Memory availability validation
- Disk space and filesystem health
- Network connectivity testing

### Service Validation

- Systemd service status verification
- Port availability testing
- Docker container health checks
- Process validation

### Application Testing

- HTTP endpoint health checks
- API availability testing
- Database connectivity validation
- Custom application-specific tests

### Security Validation

- SSH configuration verification
- User account validation
- Firewall status checking
- File permission validation

### Performance Monitoring

- Resource utilization thresholds
- Response time validation
- Service availability metrics
- System load assessment

## Usage

### Basic Usage

```yaml
- name: VM Smoke Tests
  hosts: all
  roles:
    - role: vm_smoke_tests
```

### Advanced Configuration

```yaml
- name: VM Smoke Tests with Custom Settings
  hosts: jump_hosts
  roles:
    - role: vm_smoke_tests
      vars:
        smoke_test_phases:
          - system_health
          - service_validation
          - application_health
          - security_validation
        max_load_average: 2.0
        min_memory_percent: 15
        min_disk_percent: 10
        expected_services:
          - docker
          - ssh
          - nginx
        health_check_endpoints:
          - url: "http://localhost:8080/health"
            expected_status: 200
          - url: "http://localhost:9090/metrics"
            expected_status: 200
```

## Variables

See `defaults/main.yml` for all configurable variables including:

- System resource thresholds
- Expected services list
- Health check endpoints
- Test timeout values
- Failure handling options

## Dependencies

- community.general >= 8.0.0
- ansible.posix >= 1.5.0
- community.docker (if Docker validation enabled)

## Testing

This role includes Molecule tests for validation:

```bash
# Run tests
molecule test

# Test specific scenario
molecule converge -s default
```

## Integration

Designed to integrate with:

- Proxmox VM deployment workflows
- Docker container orchestration
- Infrastructure monitoring systems
- CI/CD deployment pipelines

## Migration Notes

This role replaces the following shell-based operations:

- Direct SSH system health checks
- Manual service status verification
- Shell-based disk space monitoring
- Direct HTTP endpoint testing

All operations are now idempotent, properly error-handled, and provide structured output for
integration with monitoring systems.
