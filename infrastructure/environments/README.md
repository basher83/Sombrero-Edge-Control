# Environments

This directory contains the Terraform configuration for the production environment.

## Production

The production environment deploys the jump host VM ("jump-man") to the Proxmox cluster.

### Key Features:
- Ubuntu 24.04 LTS jump host
- Static IP: 192.168.10.250/24
- Docker CE and essential DevOps tools
- Memory ballooning for efficiency
- Cloud-init automated configuration

### Deployment:
```bash
cd production
terraform init
terraform plan
terraform apply
```

### Access:
```bash
ssh ansible@192.168.10.250
```

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.
## Providers

No providers.
## Modules

No modules.
## Resources

No resources.
## Inputs

No inputs.
## Outputs

No outputs.
<!-- END_TF_DOCS -->
