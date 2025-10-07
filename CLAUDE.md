# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Packer, Terraform and Ansible-based Infrastructure-as-Code pipeline repository for
deploying a centralized jump host VM ("jump-man") on Proxmox. The VM serves as a secure DevOps
management point with Docker, development tools, and SSH key-only authentication.

## Common Commands

All project commands are managed via mise tasks defined in `.mise.toml`. Use `mise tasks`
to see all available commands with descriptions.

### Quick Reference

```bash
# View all available tasks
mise tasks

# Most common operations:
mise run setup           # Initial project setup
mise run check          # Quick validation (format, lint, validate)
mise run prod-plan      # Plan Terraform changes
mise run prod-apply     # Apply Terraform changes
mise run deploy-full    # Complete deployment pipeline (Packer → Terraform → Ansible)
mise run smoke-test     # Run smoke tests

# For detailed task definitions, parameters, and the complete list of 100+ tasks, see .mise.toml
```

## Architecture and Structure

### Module Architecture

The infrastructure uses a modular Terraform design:

- **Main Module** (`infrastructure/modules/vm/`): Reusable VM provisioning module with:

  - Static IP networking configuration
  - Cloud-init user data and vendor data support
  - Memory ballooning configuration
  - Multi-bridge networking capability
  - Proxmox provider (telmate/proxmox)

- **Production Environment** (`infrastructure/environments/production/`):
  - Instantiates the VM module for jump-man
  - Cloud-init configuration in `cloud-init.jump-man.yaml`
  - Backend state management (local by default, with override capability)

### Key Configuration Patterns

1. **Environment Variables**: Managed via mise in `.mise.local.toml` (see `.mise.local.toml.example`
   for template with all available variables and documentation)

1. **VM Specifications**:

   - Static IP: 192.168.10.250/24
   - Node: lloyd (Proxmox host)
   - Template: Ubuntu 24.04 LTS (ID: 8024)
   - Resources: 2 vCPUs, 2GB RAM + 1GB floating, 32GB disk

1. **Cloud-init Provisioning**: Automated installation of Docker CE, development tools, and basic security configuration

## Tool Requirements

Managed by mise (see `.mise.toml`):

- Terraform 1.13.0
- terraform-docs 0.20.0
- tflint 0.58.1
- pre-commit 4.3.0
- yamllint 1.37.1
- shellcheck 0.11.0
- markdownlint-cli2 0.18.1
