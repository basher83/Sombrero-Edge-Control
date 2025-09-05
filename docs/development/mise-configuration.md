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

#### MCP (Model Context Protocol) Settings (Optional)

For projects using MCP tools like Proxmox integration, configuration is typically stored in separate JSON files:

```json
{
    "proxmox": {
        "host": "192.168.30.30",
        "port": 8006,
        "verify_ssl": false,
        "service": "PVE"
    },
    "auth": {
        "user": "api-user@pve",
        "token_name": "homarr",
        "token_value": "your-token-here"
    }
}
```

> **Note**: Keep MCP configuration files out of version control and reference them via environment variables in `.mise.local.toml` when needed.

## Tool Management

### Installed Tools

The project manages these tools via mise:

```toml
[tools]
# Core tools
terraform = "1.13.1"    # Pin to Terraform >=1.10 for Ephemeral Resources support
packer = "1.14.1"
ansible-core = "2.19.1"

terraform-docs = "0.20.0" # Documentation generation
tflint = "0.59.1"         # Terraform linting

# File search and manipulation
rg = "14.1.1"  # ripgrep - fast search
fd = "10.2.0"  # Modern find alternative
eza = "0.23.0" # Modern ls alternative

# Security and verification
cosign = "2.5.3"     # Container signing and verification
pre-commit = "4.3.0" # Git hook framework

# Linting and formatting tools
yamllint = "1.37.1"          # YAML linting
yamlfmt = "0.17.2"           # YAML formatting
shellcheck = "0.11.0"        # Shell script linting
markdownlint-cli2 = "0.18.1" # Markdown linting
act = "0.2.81"               # GitHub Actions local runner
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

### Deployment Workflow

```bash
# Deployment tracking and checklists
mise run deployment-start              # Initialize deployment checklist
mise run deployment-phase-planning     # Mark planning phase start
mise run deployment-phase-execution    # Mark execution phase start
mise run deployment-phase-validation   # Mark validation phase start
mise run deployment-finish             # Complete deployment

# Full deployment pipeline
mise run deploy-full                   # Complete Packer → Terraform → Ansible
mise run deploy-full-tracked          # Full pipeline with tracking
mise run deploy-init                  # Initialize deployment outputs
mise run deploy-packer               # Build VM template with Packer
mise run deploy-terraform            # Deploy infrastructure with Terraform
mise run deploy-ansible              # Configure VM with Ansible

# Deployment analytics
mise run deployment-metrics          # Generate metrics dashboard
mise run deployment-metrics-full     # Detailed performance analysis
mise run deployment-trends           # Analyze deployment patterns
mise run deployment-history          # Show recent deployments

# Testing and validation
mise run smoke-test                  # Full smoke test suite
mise run smoke-test-quick           # Quick SSH connectivity test
mise run smoke-test-docker          # Test Docker functionality

# Issue tracking and documentation
mise run deployment-add-issue       # Add issue to current deployment checklist
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

### Task with Custom Shell

```toml
[tasks.bash-specific]
description = "Task requiring bash features"
shell = "bash -c"
run = """
# Use bash-specific features
if [[ "$PWD" == *"/production"* ]]; then
    ENVIRONMENT="production"
elif [[ "$PWD" == *"/staging"* ]]; then
    ENVIRONMENT="staging"
else
    ENVIRONMENT="development"
fi

echo "Detected environment: $ENVIRONMENT"
"""
```

## Shell Configuration

### Default Shell Behavior

By default, mise executes tasks using `sh -c` on Unix systems, which is POSIX-compliant but doesn't support bash-specific features like:

- Double bracket conditions `[[ ]]`
- Parameter expansion like `${var//pattern/replacement}`
- Bash arrays
- Process substitution `<(command)`

### Configuring Shell for Tasks

For tasks that require bash-specific syntax, specify the shell explicitly:

```toml
[tasks.bash-task]
description = "Task requiring bash features"
shell = "bash -c"
run = """
if [[ -n "$HOME" ]]; then
    echo "Home directory: ${HOME}"
fi
"""
```

### Alternative: Using Shebang

You can also use a shebang to specify the interpreter:

```toml
[tasks.deployment-start]
description = "Initialize deployment with bash features"
run = """
#!/usr/bin/env bash
set -e

# Bash-specific syntax works here
if [[ "$PWD" == *"/staging"* ]]; then
    ENVIRONMENT="staging"
else
    ENVIRONMENT="production"
fi

echo "Environment: $ENVIRONMENT"
"""
```

### Shell Options

Tasks run with different shells have different behaviors:

| Shell | Error Handling | Features | Use Case |
|-------|----------------|----------|----------|
| `sh -c` (default) | `set -e` enabled | POSIX only | Simple, portable tasks |
| `bash -c` | `set -e` enabled | Full bash | Complex scripting, conditionals |
| `zsh -c` | `set -e` enabled | Zsh extensions | Zsh-specific features |
| Custom shell | Varies | Any interpreter | Python, Node.js, Ruby scripts |

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

5. **Shell syntax errors** (`[[: not found`, `Bad substitution`)
   ```bash
   # Error indicates bash syntax in sh shell
   # Fix: Add shell specification to the task
   ```

   **Problem**: Task contains bash-specific syntax but runs with default `sh`

   **Solution**: Add `shell = "bash -c"` to task configuration:
   ```toml
   [tasks.problematic-task]
   description = "Task with bash syntax"
   shell = "bash -c"  # Add this line
   run = """
   if [[ -n "$VAR" ]]; then  # This requires bash
       echo "Variable set"
   fi
   """
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

### 5. Shell Selection

- Use default `sh` for simple, portable tasks
- Specify `shell = "bash -c"` for tasks using bash features
- Add shebang (`#!/usr/bin/env bash`) for complex scripts
- Test tasks across different environments to ensure compatibility

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
