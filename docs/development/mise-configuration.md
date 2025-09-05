# Mise Configuration Guide

This document provides comprehensive guidance on configuring and using [mise](https://mise.jdx.dev/) (formerly rtx) for this project.

## Overview

Mise is a polyglot tool version manager and task runner that replaces tools like asdf, nvm, pyenv, and Make. It provides:

- Consistent tool versions across environments
- Task automation and orchestration
- Environment variable management
- Team-wide reproducible development environments

## Configuration Files

### `.mise.toml` (Shared Configuration)

The main configuration file checked into version control. Contains:

- Tool version specifications
- Shared task definitions
- Common environment variables

Location: `/Users/basher8383/dev/infra-as-code/Sombrero-Edge-Control/.mise.toml`

### `.mise.local.toml` (Local Configuration)

Personal configuration file (gitignored) for:

- Sensitive environment variables (API tokens, keys)
- Local overrides
- Personal preferences

Location: `/Users/basher8383/dev/infra-as-code/Sombrero-Edge-Control/.mise.local.toml`

## Setting Up Local Configuration

### Initial Setup

1. **Copy the example configuration** (if available):
   ```bash
   cp .mise.local.toml.example .mise.local.toml
   ```

2. **Or create a new `.mise.local.toml`**:
   ```toml
   [env]
   # Terraform variables
   TF_VAR_pve_api_token = "terraform@pve!scalr=your-token-here"
   TF_VAR_pve_api_url = "https://192.168.10.2:8006/api2/json"
   TF_VAR_ci_ssh_key = "ssh-ed25519 YOUR-PUBLIC-KEY-HERE"
   TF_VAR_proxmox_insecure = "true"
   TF_VAR_proxmox_ssh_username = "root"

   # Terraform CLI optimization
   TF_CLI_ARGS_apply = "-parallelism=20"
   TF_CLI_ARGS_plan = "-parallelism=20"
   ```

### Required Environment Variables

#### Proxmox Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `TF_VAR_pve_api_token` | Proxmox API token for Terraform | `terraform@pve!scalr=token-id` |
| `TF_VAR_pve_api_url` | Proxmox API endpoint URL | `https://192.168.10.2:8006/api2/json` |
| `TF_VAR_ci_ssh_key` | SSH public key for VM access | `ssh-ed25519 AAAA...` |
| `TF_VAR_proxmox_insecure` | Skip TLS verification (dev only) | `true` or `false` |
| `TF_VAR_proxmox_ssh_username` | SSH user for Proxmox operations | `root` |

#### Optional Performance Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `TF_CLI_ARGS_apply` | Terraform apply arguments | `-parallelism=20` |
| `TF_CLI_ARGS_plan` | Terraform plan arguments | `-parallelism=20` |

#### Infisical Settings (Optional)

| Variable | Description |
|----------|-------------|
| `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` | Infisical client ID for secret management |
| `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET` | Infisical client secret |

## Tool Management

### Installed Tools

The project manages these tools via mise:

```toml
[tools]
terraform = "1.13.0"
terraform-docs = "0.20.0"
tflint = "0.58.1"
pre-commit = "4.3.0"
yamllint = "1.37.1"
shellcheck = "0.11.0"
markdownlint-cli2 = "0.18.1"
act = "latest"  # GitHub Actions local runner
```

### Installing Tools

```bash
# Install all tools defined in .mise.toml
mise install

# Install specific tool
mise install terraform

# Update tools to latest versions
mise up
```

## Task Runner Commands

### Infrastructure Management

```bash
# Production environment
mise run prod-init      # Initialize Terraform
mise run prod-plan      # Plan changes
mise run prod-apply     # Apply changes
mise run prod-destroy   # Destroy infrastructure
mise run prod-validate  # Validate configuration
```

### Code Quality

```bash
# Formatting
mise run fmt            # Format Terraform files
mise run fmt-check      # Check formatting
mise run yaml-fmt       # Format YAML files

# Linting
mise run lint-prod      # Lint production code
mise run lint-all       # Run all linters
mise run shellcheck     # Check shell scripts

# Documentation
mise run docs           # Generate Terraform docs
mise run docs-check     # Check if docs are up-to-date
```

### CI/CD

```bash
# Local CI testing with act
mise run act-list       # List available workflows
mise run act-ci         # Run full CI pipeline
mise run act-quick      # Quick checks (format, validate, lint)
mise run act-debug      # Debug mode with verbose output

# CI validation
mise run ci-check       # Run all CI checks locally
mise run full-check     # Complete validation suite
```

### Security Scanning

```bash
# Infisical secret scanning
mise run infisical-init             # Initialize Infisical
mise run infisical-scan             # Scan for secrets
mise run infisical-baseline-update  # Update baseline

# KICS infrastructure scanning
mise run security-kics              # Interactive KICS scan
mise run security-kics-ci           # CI mode KICS scan
```

### Development Workflow

```bash
# Initial setup
mise run setup          # Complete project setup
mise run hooks-install  # Install git hooks

# Cleanup
mise run clean          # Clean Terraform cache

# Validation
mise run check          # Run all validation checks
```

## Creating Custom Tasks

### Basic Task Structure

Add to `.mise.toml`:

```toml
[tasks.my-task]
description = "Description of what this task does"
run = "command to execute"
```

### Complex Tasks

```toml
[tasks.complex-task]
description = "Multi-line task example"
run = """
echo "Step 1: Preparing..."
terraform init
echo "Step 2: Planning..."
terraform plan -out=plan.out
echo "Task complete!"
"""
```

### Task with Dependencies

```toml
[tasks.dependent-task]
description = "Task that runs other tasks first"
depends = ["fmt", "lint-prod", "docs"]
run = "echo 'All dependencies complete!'"
```

### Task with Environment Variables

```toml
[tasks.env-task]
description = "Task with custom environment"
env = { CUSTOM_VAR = "value", DEBUG = "true" }
run = "echo $CUSTOM_VAR"
```

## Troubleshooting

### Common Issues

1. **Missing environment variables**
   ```bash
   # Check current environment
   mise env

   # Verify specific variable
   echo $TF_VAR_pve_api_token
   ```

2. **Tools not found**
   ```bash
   # Reinstall tools
   mise install

   # Verify installation
   mise list
   ```

3. **Task not found**
   ```bash
   # List all available tasks
   mise tasks

   # Run with verbose output
   mise run --verbose task-name
   ```

4. **Permission issues**
   ```bash
   # Ensure mise is activated
   eval "$(mise activate bash)"  # or zsh/fish
   ```

### Debugging

```bash
# Show mise configuration
mise config

# Show current environment
mise env

# List installed tools
mise list

# Show task details
mise tasks --verbose
```

## Best Practices

### 1. Security

- **Never commit** `.mise.local.toml` with secrets
- Use environment variables for sensitive data
- Rotate tokens and keys regularly
- Use read-only tokens where possible

### 2. Organization

- Group related tasks with descriptive prefixes (`prod-`, `act-`, etc.)
- Provide clear descriptions for all tasks
- Document complex tasks inline with comments

### 3. Performance

- Use parallelism flags for Terraform operations
- Cache tool downloads with `mise cache`
- Reuse containers in act for faster CI

### 4. Team Collaboration

- Document all required variables in README
- Provide `.mise.local.toml.example` template
- Keep `.mise.toml` tasks generic and portable
- Use consistent naming conventions

## Integration with Other Tools

### Shell Integration

Add to your shell RC file:

```bash
# Bash (~/.bashrc)
eval "$(mise activate bash)"

# Zsh (~/.zshrc)
eval "$(mise activate zsh)"

# Fish (~/.config/fish/config.fish)
mise activate fish | source
```

### IDE Integration

- **VS Code**: Install "mise" extension
- **IntelliJ**: Configure external tools
- **Vim/Neovim**: Use mise shims in PATH

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Setup mise
  uses: jdx/mise-action@v2
  with:
    version: latest

- name: Install tools
  run: mise install

- name: Run tasks
  run: mise run ci-check
```

## Advanced Configuration

### Aliases

Create command shortcuts:

```toml
[alias]
tf = "terraform"
tfdocs = "terraform-docs"
validate = ["fmt-check", "lint-prod", "prod-validate"]
```

### Hooks

Pre/post command hooks:

```toml
[hooks]
pre_install = "echo 'Installing tools...'"
post_install = "echo 'Tools installed successfully!'"
```

### Python Virtual Environments

```toml
[tools]
python = "3.11"

[tasks.venv]
description = "Create Python virtual environment"
run = """
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
"""
```

## Migration from Other Tools

### From Make

```makefile
# Makefile
fmt:
    terraform fmt -recursive

# Becomes in .mise.toml:
[tasks.fmt]
run = "terraform fmt -recursive"
```

### From npm scripts

```json
// package.json
"scripts": {
  "lint": "eslint ."
}

// Becomes in .mise.toml:
[tasks.lint]
run = "eslint ."
```

## Resources

- [Mise Documentation](https://mise.jdx.dev/)
- [Mise GitHub Repository](https://github.com/jdx/mise)
- [Task Runner Examples](https://mise.jdx.dev/tasks.html)
- [Environment Management](https://mise.jdx.dev/environments.html)
