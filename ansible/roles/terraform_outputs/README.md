# Terraform Outputs Role

This role parses Terraform outputs and integrates them with Ansible inventory management for the Sombrero Edge Control infrastructure. It provides seamless integration between Terraform-provisioned infrastructure and Ansible automation workflows.

## Role Overview

This role implements comprehensive Terraform output parsing and integration across four key areas:

1. **Output Parsing** - Parse and validate Terraform outputs
2. **Inventory Generation** - Generate dynamic Ansible inventory from Terraform state
3. **Variable Integration** - Convert Terraform outputs to Ansible variables
4. **State Validation** - Validate Terraform state and output consistency

## Features

### Output Parsing
- JSON output parsing from Terraform
- Output validation and type checking
- Sensitive output handling
- Multi-workspace support
- Remote state backend support
- Output filtering and transformation

### Inventory Generation
- Dynamic Ansible inventory creation
- Host group organization
- Variable assignment to hosts and groups
- Inventory validation and testing
- Multiple inventory format support
- Inventory caching and optimization

### Variable Integration
- Terraform outputs to Ansible facts conversion
- Variable scoping and namespacing
- Type-safe variable mapping
- Custom variable transformation
- Variable validation and sanitization
- Environment-specific variable handling

### State Validation
- Terraform state consistency checking
- Output drift detection
- Resource state validation
- Cross-workspace state comparison
- State backup and recovery
- Integrity verification

## Usage

### Basic Output Parsing
```yaml
- name: Terraform Outputs Integration
  hosts: localhost
  roles:
    - role: terraform_outputs
      vars:
        terraform_project_path: "infrastructure/environments/production"
```

### Advanced Configuration
```yaml
- name: Comprehensive Terraform Integration
  hosts: localhost
  roles:
    - role: terraform_outputs
      vars:
        terraform_project_path: "infrastructure/environments/production"
        terraform_workspace: "production"
        parse_outputs:
          - vm_ip
          - vm_hostname
          - vm_id
          - ssh_user
          - network_config
        inventory_generation:
          enabled: true
          output_path: "ansible/inventory/terraform.yml"
          format: "yaml"  # yaml, json, ini
          group_by:
            - environment
            - vm_type
        variable_integration:
          namespace: "tf"
          convert_types: true
          validate_outputs: true
        state_validation:
          check_drift: true
          validate_resources: true
          backup_state: true
```

### Multi-Environment Support
```yaml
- name: Multi-Environment Terraform Integration
  hosts: localhost
  roles:
    - role: terraform_outputs
      vars:
        terraform_projects:
          - path: "infrastructure/environments/development"
            workspace: "development"
            environment: "dev"
          - path: "infrastructure/environments/staging"
            workspace: "staging"
            environment: "stage"
          - path: "infrastructure/environments/production"
            workspace: "production"
            environment: "prod"
        merge_outputs: true
        inventory_per_environment: true
```

## Variables

See `defaults/main.yml` for all configurable variables including:
- Terraform project configuration
- Output parsing settings
- Inventory generation options
- Variable integration settings
- State validation parameters

## Dependencies

- Terraform or OpenTofu CLI
- jq (for JSON processing)
- Python `json` module
- File system access for inventory generation

## Testing

This role includes comprehensive testing scenarios:

```bash
# Run terraform outputs tests
molecule test

# Test specific scenarios
molecule converge -s output-parsing
molecule converge -s inventory-generation
molecule converge -s state-validation
```

## Integration

Designed to integrate with:
- Terraform/OpenTofu infrastructure projects
- Ansible automation workflows
- CI/CD pipelines for infrastructure automation
- Dynamic inventory management systems
- Multi-environment deployment pipelines

## Security Considerations

- Sensitive output handling and masking
- State file access control
- Inventory file permissions
- Variable sanitization and validation
- Secure temporary file handling

## Performance Impact

- Optimized JSON parsing for large states
- Inventory caching for repeated access
- Efficient output filtering
- Minimal Terraform CLI invocations
- Parallel processing for multi-project scenarios
