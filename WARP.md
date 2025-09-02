# WARP.md
This file provides guidance to WARP (warp.dev) when working with code in this repository.

**Last updated**: 2025-01-02

## 🚀 Quickstart

Essential commands to get productive immediately:

```bash
# Setup environment and validate toolchain
eval "$(mise env -s bash)"           # Load tool versions and environment
cd infrastructure/environments/production
terraform init                       # Initialize Terraform

# Validate and format
mise run check                       # Format, lint, and validate production
mise run full-check                  # Complete validation with security scan

# Deploy infrastructure
terraform plan                       # Review changes
terraform apply                      # Deploy jump-man VM

# Verify deployment
mise run smoke-test                  # Run infrastructure smoke tests
ssh ansible@192.168.10.250         # Access jump host
```

## 🛠 Essential Commands

### Environment Setup

```bash
# Load tools and environment variables
eval "$(mise env -s bash)"          # Load mise-managed tools and env vars

# Initialize project (first time only)
mise run setup                      # Install hooks, docs, security scan baseline

# Environment variables via .mise.local.toml:
# TF_VAR_pve_api_token, TF_VAR_pve_api_url, TF_VAR_ci_ssh_key
```

### Development Workflow

```bash
# Format and validation
mise run fmt                        # Format Terraform files
mise run lint-all                   # All linters (shell, YAML, Markdown, TF)
mise run prod-validate              # Validate Terraform configuration

# Documentation
mise run docs                       # Generate Terraform documentation
mise run docs-check                 # Verify docs are up-to-date
```

### Infrastructure Operations

```bash
# Initialize and plan (production environment)
cd infrastructure/environments/production
mise run prod-init                  # Initialize Terraform
mise run prod-plan                  # Plan changes
mise run prod-apply                 # Apply changes

# State management
terraform state list                # List managed resources
terraform providers                 # Show provider requirements
terraform plan -detailed-exitcode   # Check for drift (exit code 2 = changes)
```

### Testing and Validation

```bash
# Smoke testing
mise run smoke-test                 # Full infrastructure validation
mise run smoke-test-quick           # Quick SSH connectivity test
mise run smoke-test-docker          # Docker functionality test

# Security scanning
mise run infisical-scan             # Secret scanning with baseline
mise run security-kics              # Infrastructure security scan
```

### Deployment Tracking

```bash
# Enhanced deployment tracking (see deployments/README.md)
mise run deployment-start           # Create timestamped deployment checklist
mise run deployment-metrics         # View deployment analytics
mise run deployment-trends          # Analyze deployment patterns
```

## 🏗 Architecture Overview

### Module Structure

```
infrastructure/
├── modules/vm/              # Reusable Proxmox VM module
├── environments/production/ # Production jump host configuration
└── versions.tf             # Global Terraform version constraints
```

The infrastructure uses a **modular Terraform design**:

- **VM Module** ([`infrastructure/modules/vm/`](infrastructure/modules/vm/)): Reusable Proxmox VM provisioning with cloud-init support, memory ballooning, and dual-network capability
- **Production Environment** ([`infrastructure/environments/production/`](infrastructure/environments/production/)): Instantiates the VM module for jump-man with Ubuntu 22.04 template

### Key Configuration

- **Target**: Single jump host VM (jump-man) on Proxmox node "lloyd"
- **Networking**: Static IP 192.168.10.250/24 with gateway 192.168.10.1
- **Resources**: 2 vCPUs, 2GB RAM + 1GB floating, 32GB disk
- **Provisioning**: Cloud-init with Docker CE, development tools, SSH keys
- **Template**: Ubuntu 22.04 LTS (Proxmox template ID: 8000)

### State Management

- **Backend**: Local state by default, with override capability via `backend_override.tf`
- **Single Environment**: Production-focused with single VM deployment
- **No Workspaces**: Uses directory-based environment isolation

## ⚙️ Configuration Patterns

### Environment Variables

Managed via mise in `.mise.local.toml`:

```toml
[env]
TF_VAR_pve_api_token = "terraform@pve!token=your-token-here"
TF_VAR_pve_api_url = "https://your-proxmox:8006/api2/json"
TF_VAR_ci_ssh_key = "ssh-ed25519 YOUR-PUBLIC-KEY ansible@jump-man"
TF_VAR_proxmox_insecure = "true"  # Only for self-signed certs
```

### Cloud-init Configuration

- **User Data**: [`cloud-init.jump-man-user-data.yaml`](infrastructure/environments/production/cloud-init.jump-man-user-data.yaml) - Basic user setup and SSH keys
- **Vendor Data**: [`cloud-init.jump-man.yaml`](infrastructure/environments/production/cloud-init.jump-man.yaml) - Docker installation and system configuration

## 🔄 Project Workflows

### Development Process

```bash
# Create feature branch
git --no-pager checkout -b feat/vm-improvements

# Validate changes
mise run check                      # Format, lint, validate
pre-commit run --all-files         # Run all quality checks

# Create PR with plan
cd infrastructure/environments/production
terraform plan > /tmp/tfplan.txt   # Save plan output
gh pr create --title "VM improvements" --body "$(cat /tmp/tfplan.txt)"
```

### Deployment Process

See [deployments/README.md](deployments/README.md) for the complete **Enhanced Deployment System** with automated tracking and analytics:

```bash
mise run deployment-start           # Create deployment checklist with metadata
# Follow checklist, update with ✅/❌/🔄/⏭️ status
mise run deployment-finish          # Complete with metrics
```

### Rollback Strategy

```bash
# Revert to previous infrastructure state
git --no-pager revert <commit-hash>
cd infrastructure/environments/production
terraform plan                     # Verify rollback plan
terraform apply                    # Apply rollback
```

## 🤖 AI Agent Integration

**If you are an AI agent, read [`CLAUDE.md`](CLAUDE.md) first.** This WARP.md summarizes commands and architecture; CLAUDE.md defines interaction rules, task management with Archon MCP, and coding standards.

Key AI agent guidelines:
- Use `read_any_files` instead of terminal commands for file content
- Use `rg` (ripgrep) and `fd` for search operations
- Always use `git --no-pager` for git operations
- Use mise for tool and environment management
- Follow Archon task management workflow before coding

## 📋 Repository Conventions

### Tool Requirements

Managed by [mise](https://mise.jdx.dev/) (see [`.mise.toml`](.mise.toml)):
- Terraform 1.13.0 (supports Ephemeral Resources)
- terraform-docs, tflint, pre-commit
- rg (ripgrep), fd (find alternative), eza (ls alternative)
- Security: infisical, yamllint, shellcheck, markdownlint

### Code Quality

- **Pre-commit Hooks**: Terraform format, validation, linting, security scans
- **Secrets Scanning**: Infisical with baseline for false positive management
- **Documentation**: Auto-generated with terraform-docs
- **Security**: KICS infrastructure security scanning

### File Conventions

- **Empty Directories**: Use `.keep` files with purpose comments
- **Editor Config**: Respects [`.editorconfig`](.editorconfig) for consistent formatting
- **Search Operations**: Use `rg` and `fd` instead of `grep` and `find`
- **Environment Management**: Use mise for tools and environment variables (no direnv)

## 🔧 Troubleshooting

### Common Issues

```bash
# SSH connectivity issues
./scripts/restart-vm-ssh.sh        # Restart VM with key management
mise run smoke-test-quick          # Test SSH connectivity

# Cloud-init problems
ssh ansible@192.168.10.250 'sudo cloud-init status --wait'
ssh ansible@192.168.10.250 'sudo journalctl -u cloud-init'

# Terraform state issues
terraform refresh                   # Sync state with real infrastructure
terraform plan -detailed-exitcode  # Check for configuration drift
```

### Useful Scripts

Located in [`scripts/`](scripts/):
- [`smoke-test.sh`](scripts/smoke-test.sh): Comprehensive infrastructure validation
- [`restart-vm-ssh.sh`](scripts/restart-vm-ssh.sh): Safe VM restart with SSH key handling
- [`generate-docs.sh`](scripts/generate-docs.sh): Update all Terraform documentation
- [`find-tags.sh`](scripts/find-tags.sh): Find TODO/FIXME tags in code

### Log Locations

```bash
# Deployment analytics
mise run deployment-metrics        # View success rates, timing patterns
ls deployments/checklists/         # Individual deployment records

# Infrastructure validation
mise run smoke-test 2>&1 | tee logs/smoke-test-$(date +%Y%m%d).log
```

## 📚 Key Documentation

- [README.md](README.md): Project overview and quick start
- [CLAUDE.md](CLAUDE.md): AI agent interaction rules and Archon workflows
- [deployments/](deployments/): Enhanced deployment tracking system
- [docs/](docs/): Process documentation and guides
- [infrastructure/README.md](infrastructure/README.md): Terraform-specific documentation

---

*This repository deploys a centralized Ubuntu 22.04 jump host (jump-man) for DevOps operations using Terraform and Proxmox with comprehensive automation, tracking, and validation.*
