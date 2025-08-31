# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Terraform-based Infrastructure-as-Code repository for deploying a centralized jump host VM ("jump-man") to Proxmox using cloud-init automation. The VM serves as a secure DevOps management point with Docker, development tools, and SSH key-only authentication.

## Common Commands

### Terraform Operations

```bash
# Initialize Terraform (required before other operations)
mise run prod-init
# OR directly:
cd infrastructure/environments/production && terraform init

# Format all Terraform files
mise run fmt

# Validate Terraform configuration
mise run prod-validate

# Plan infrastructure changes
mise run prod-plan

# Apply infrastructure changes
mise run prod-apply

# Check formatting without changes
mise run fmt-check
```

### Development Workflow

```bash
# Initial project setup (hooks, docs, secrets scanning)
mise run setup

# Run all validation checks (format, lint, validate)
mise run check

# Complete validation including docs and security
mise run full-check

# CI pipeline checks (non-mutating)
mise run ci-check

# Clean Terraform cache and temporary files
mise run clean
```

### Documentation and Linting

```bash
# Generate Terraform documentation
mise run docs
# OR directly:
./scripts/generate-docs.sh

# Check if documentation is up-to-date
mise run docs-check

# Run TFLint on production code
mise run lint-prod

# Run all linters (shell, YAML, Markdown, Terraform)
mise run lint-all

# Format YAML files
mise run yaml-fmt
```

### Secret Scanning (Infisical)

```bash
# Initialize Infisical configuration
mise run infisical-init

# Scan for secrets using baseline
mise run infisical-scan

# Update baseline for false positives
mise run infisical-baseline-update
```

### Pre-commit Hooks

```bash
# Install git pre-commit hooks
mise run hooks-install
# OR:
pre-commit install

# Manually run all hooks
mise run hooks-run
# OR:
pre-commit run --all-files
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

1. **Environment Variables**: Managed via mise in `.mise.local.toml`:
   - `TF_VAR_pve_api_token`: Proxmox API authentication
   - `TF_VAR_pve_api_url`: Proxmox API endpoint
   - `TF_VAR_ci_ssh_key`: SSH public key for cloud-init
   - `TF_VAR_proxmox_insecure`: TLS verification setting

2. **VM Specifications**:
   - Static IP: 192.168.10.250/24
   - Node: lloyd (Proxmox host)
   - Template: Ubuntu 22.04 LTS (ID: 8000)
   - Resources: 2 vCPUs, 2GB RAM + 1GB floating, 32GB disk

3. **Cloud-init Provisioning**: Automated installation of Docker CE, development tools, and basic security configuration

## Tool Requirements

Managed by mise (see `.mise.toml`):
- Terraform 1.13.0
- terraform-docs 0.20.0
- tflint 0.58.1
- pre-commit 4.3.0
- yamllint 1.37.1
- shellcheck 0.11.0
- markdownlint-cli2 0.18.1
