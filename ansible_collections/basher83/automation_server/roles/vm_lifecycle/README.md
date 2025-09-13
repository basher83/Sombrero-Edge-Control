# VM Lifecycle Role

This role manages VM lifecycle operations including rollback, cleanup, and reset operations for the Sombrero Edge Control infrastructure. It provides systematic approaches to infrastructure state management and recovery operations.

## Role Overview

This role implements comprehensive VM lifecycle management across four key areas:

1. **Rollback Operations** - Safe VM destruction and state restoration
2. **Cleanup Operations** - Resource cleanup and artifact removal
3. **Reset Operations** - VM reset to known good state
4. **State Management** - Infrastructure state validation and management

## Features

### Rollback Operations

- Safe VM destruction with confirmation prompts
- Terraform state management and cleanup
- SSH known_hosts cleanup
- Ansible facts cache cleanup
- Backup and restore capabilities
- Rollback to previous infrastructure states

### Cleanup Operations

- Terraform artifact cleanup
- Ansible cache cleanup
- SSH configuration cleanup
- Log and temporary file cleanup
- Resource deallocation
- Network resource cleanup

### Reset Operations

- VM reset to clean state
- Configuration reset to defaults
- Service restart and reconfiguration
- Cloud-init re-execution
- Package and configuration restoration

### State Management

- Terraform state validation
- Infrastructure state backup
- State restoration capabilities
- Drift detection and correction
- Resource inventory management
- State synchronization

## Usage

### Basic Rollback Operation

```yaml
- name: VM Lifecycle Management
  hosts: localhost
  roles:
    - role: vm_lifecycle
      vars:
        lifecycle_operation: "rollback"
        terraform_project_path: "infrastructure/environments/production"
```

### Advanced Configuration

```yaml
- name: Comprehensive VM Lifecycle Management
  hosts: localhost
  roles:
    - role: vm_lifecycle
      vars:
        lifecycle_operation: "rollback"  # rollback, cleanup, reset, validate
        confirm_destructive_operations: true
        preserve_data: false
        backup_before_operation: true
        terraform_project_path: "infrastructure/environments/production"
        cleanup_artifacts:
          - terraform_state
          - ansible_facts_cache
          - ssh_known_hosts
          - temporary_files
          - log_files
        rollback_targets:
          - module.jump_man
          - module.networking
        preserve_resources:
          - data_volumes
          - network_security_groups
```

### State Management Operations

```yaml
- name: Infrastructure State Management
  hosts: localhost
  roles:
    - role: vm_lifecycle
      vars:
        lifecycle_operation: "validate"
        state_management:
          backup_state: true
          validate_drift: true
          auto_correct_drift: false
          state_backup_location: "/tmp/terraform-backups"
        validation_checks:
          - terraform_state_integrity
          - resource_existence
          - configuration_drift
          - network_connectivity
```

## Variables

See `defaults/main.yml` for all configurable variables including:

- Lifecycle operation settings
- Terraform project configuration
- Cleanup and preservation options
- Backup and restore settings
- Safety and confirmation settings

## Dependencies

- Terraform/OpenTofu CLI
- Ansible facts gathering
- SSH client configuration
- File system access for state management

## Safety Features

- Confirmation prompts for destructive operations
- Backup creation before major operations
- Rollback capability for failed operations
- State validation before and after operations
- Resource preservation options
- Dry-run mode for testing

## Testing

This role includes comprehensive testing scenarios:

```bash
# Run lifecycle tests
molecule test

# Test specific operations
molecule converge -s rollback-test
molecule converge -s cleanup-test
molecule converge -s reset-test
```

## Integration

Designed to integrate with:

- Terraform/OpenTofu infrastructure projects
- Ansible automation workflows
- CI/CD pipelines for infrastructure management
- Monitoring and alerting systems
- Backup and recovery systems

## Security Considerations

- Confirmation requirements for destructive operations
- State backup and recovery capabilities
- Resource preservation safeguards
- Access control and permission validation
- Audit logging of lifecycle operations

## Performance Impact

- Operations designed for safety over speed
- Backup operations may take time for large states
- Validation checks add operation overhead
- Network operations may be time-sensitive
- Resource cleanup optimized for thoroughness
