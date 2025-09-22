# Pipeline Operation Guide

## Overview

The pipeline consists of three independent stages that can be run individually or as a complete deployment:

1. **Stage 1: Packer** - Build minimal Ubuntu 24.04 golden image
2. **Stage 2: Terraform** - Provision VM using Packer template
3. **Stage 3: Ansible** - Configure VM with roles and playbooks

## Complete Pipeline Deployment

```bash
# Run all stages automatically
./scripts/deploy-pipeline.sh
```

## Individual Stage Execution

### Stage 1: Packer Only

```bash
./scripts/stage-1-packer.sh
```

### Stage 2: Terraform Only

```bash
# With specific template ID
./scripts/stage-2-terraform.sh 8025

# With default template ID (8025)
./scripts/stage-2-terraform.sh
```

### Stage 3: Ansible Only

```bash
# With specific inventory file
./scripts/stage-3-ansible.sh custom_inventory.json

# With default inventory
./scripts/stage-3-ansible.sh
```

## Validation

```bash
# Validate complete pipeline
./scripts/validate-pipeline.sh

# Individual validations
cd packer && packer validate ubuntu-server-minimal.pkr.hcl
cd infrastructure/environments/production && terraform validate
cd ansible_collections/basher83/automation_server && ansible-playbook --syntax-check playbooks/site.yml
```

## File Structure

```
scripts/
├── deploy-pipeline.sh      # Complete pipeline
├── stage-1-packer.sh       # Packer only
├── stage-2-terraform.sh    # Terraform only
├── stage-3-ansible.sh      # Ansible only
└── validate-pipeline.sh    # Validation

docs/deployment/
├── pipeline-handoffs.md    # Interface definitions
├── pipeline-rollback.md    # Rollback procedures
└── pipeline-operation.md   # This file
```

## Environment Variables

- `TEMPLATE_ID`: Packer template ID for Terraform stage
- Default: `8025` (Ubuntu 24.04 minimal)

## Output Files

- `infrastructure/environments/production/ansible_inventory.json` - Ansible inventory
- `ansible_collections/basher83/automation_server/inventory/ansible_inventory.json` - Copied inventory

## Troubleshooting

### Common Issues

1. **Template not found**: Run Stage 1 first or check Proxmox
2. **Terraform state issues**: Run `terraform plan` to preview changes
3. **Ansible connectivity**: Check inventory file and SSH access
4. **Permission errors**: Ensure scripts are executable

### Debug Mode

Add `set -x` to any script for verbose output:

```bash
#!/bin/bash
set -euo pipefail
set -x  # Add this line for debugging
```

## Performance

- **Target deployment time**: < 60 seconds (excluding Packer build)
- **Packer build time**: ~5-10 minutes (one-time)
- **Terraform apply**: ~30 seconds
- **Ansible playbook**: ~15 seconds
