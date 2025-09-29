# Act Configuration Guide

This document describes the act configuration for running GitHub Actions locally in the Sombrero-Edge-Control repository.

## Overview

[Act](https://github.com/nektos/act) runs GitHub Actions workflows locally using Docker
containers, providing immediate feedback without pushing to GitHub. This saves time,
reduces CI minutes usage, and enables local debugging of workflow issues.

## Configuration Files

### `.actrc` - Main Configuration

Location: `/.actrc`

This file contains the default configuration for act:

```bash
# Platform images - using medium-sized images for better tool compatibility
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P ubuntu-24.04=catthehacker/ubuntu:act-24.04
-P ubuntu-20.04=catthehacker/ubuntu:act-20.04

# Use Docker host network for better connectivity
--network host

# Reuse containers for faster subsequent runs
--reuse

# Container architecture (for Apple Silicon compatibility)
--container-architecture linux/amd64

# Bind working directory
--bind

# Use local .env file if it exists
--env-file .env.act

# Default workflow event
--eventpath .github/workflows/event.json
```

#### Configuration Details

- **Platform Images**: Using `catthehacker/ubuntu` images which include most common CI tools
- **Network Mode**: Host network allows containers to access external services
- **Container Reuse**: Speeds up repeated runs by keeping containers alive
- **Architecture**: Ensures compatibility on Apple Silicon Macs
- **Bind Mode**: Maintains file permissions between host and container

### `.env.act` - Environment Variables

Location: `/.env.act` (gitignored)

Template for environment-specific variables:

```bash
# GitHub token for actions that need it (optional)
# GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx

# Disable update checks and comments
DISABLE_KICS_COMMENTS=true
INFISICAL_DISABLE_UPDATE_CHECK=true

# Any additional environment variables
# CUSTOM_VAR=value
```

**Note**: This file is gitignored. Create it locally from the template.

### `.github/workflows/event.json` - Event Payload

Location: `/.github/workflows/event.json`

Defines the event context for workflow execution:

```json
{
  "push": {
    "ref": "refs/heads/main",
    "repository": {
      "name": "Sombrero-Edge-Control",
      "full_name": "basher83/Sombrero-Edge-Control",
      "owner": {
        "name": "basher83",
        "login": "basher83"
      }
    }
  },
  "pull_request": {
    "number": 1,
    "title": "Test PR",
    "head": {
      "ref": "feature-branch"
    },
    "base": {
      "ref": "main"
    }
  }
}
```

## Available Workflows

Act can run any workflow defined in `.github/workflows/`:

### CI Pipeline (`ci.yml`)

Main quality and security checks:

| Job ID               | Description                      | Mise Command            |
| -------------------- | -------------------------------- | ----------------------- |
| `terraform-format`   | Check Terraform formatting       | `mise run act-format`   |
| `terraform-validate` | Validate Terraform configuration | `mise run act-validate` |
| `tflint`             | Terraform linting                | `mise run act-lint`     |
| `terraform-docs`     | Documentation generation check   | `mise run act-docs`     |
| `yaml-lint`          | YAML file linting                | -                       |
| `shellcheck`         | Shell script linting             | `mise run act-shell`    |
| `markdown-lint`      | Markdown linting                 | -                       |
| `secret-scan`        | Infisical secret scanning        | Part of `act-security`  |
| `kics-scan`          | Infrastructure security scan     | Part of `act-security`  |

### Other Workflows

- **documentation.yml**: Terraform documentation generation
- **use-sync-labels.yml**: GitHub label synchronization

## Mise Integration

All act commands are integrated with mise for consistency:

### Quick Reference

```bash
# Essential commands
mise run act-list      # List all workflows and jobs
mise run act-ci        # Run full CI pipeline
mise run act-quick     # Fast validation (format + validate + lint)

# Individual checks
mise run act-format    # Terraform format check
mise run act-validate  # Terraform validation
mise run act-lint      # TFLint
mise run act-docs      # Documentation check
mise run act-shell     # ShellCheck
mise run act-security  # Security scans

# Special modes
mise run act-pr        # Simulate pull request
mise run act-debug     # Verbose debugging
mise run act-dry       # Preview without execution
```

## Direct Act Usage

For advanced use cases, you can invoke act directly:

### Basic Commands

```bash
# List all jobs
act -l

# Run default event (push)
act

# Run specific event
act pull_request
act workflow_dispatch
act schedule

# Run specific job
act push --job terraform-format

# Run multiple jobs
act push --job terraform-format --job terraform-validate
```

### Advanced Options

```bash
# Use different workflow file
act -W .github/workflows/documentation.yml

# Override platform
act -P ubuntu-latest=ubuntu:24.04

# Pass secrets
act -s GITHUB_TOKEN=$GITHUB_TOKEN
act --secret-file .secrets

# Debugging
act --verbose              # Verbose output
act --debug               # Debug logging
act --dryrun              # Preview execution
act --list                # List workflows

# Container options
act --container-options "--memory 4g"
act --container-options "--cpus 2"
```

## Workflow Testing Strategy

### Development Workflow

1. **Initial Check**: After making changes

   ```bash
   mise run act-quick  # Fast validation
   ```

1. **Full Validation**: Before committing

   ```bash
   mise run act-ci    # Complete CI pipeline
   ```

1. **PR Simulation**: Before creating PR

   ```bash
   mise run act-pr    # Test PR-specific checks
   ```

1. **Debug Issues**: When failures occur

   ```bash
   mise run act-debug  # Verbose output
   ```

### Testing Specific Changes

- **Terraform changes**: `mise run act-format && mise run act-validate && mise run act-lint`
- **Documentation**: `mise run act-docs`
- **Scripts**: `mise run act-shell`
- **Security**: `mise run act-security`

## Docker Image Selection

Act uses Docker images that simulate GitHub Actions runners:

### Available Images

| Image Type | Size   | Use Case           | Tools Included             |
| ---------- | ------ | ------------------ | -------------------------- |
| Micro      | ~200MB | Minimal workflows  | Basic shell tools          |
| Medium     | ~500MB | Standard workflows | Common CI tools            |
| Large      | ~17GB  | Complex workflows  | Full GitHub runner toolkit |

### Current Configuration

We use `catthehacker/ubuntu:act-*` images (medium-sized):

- Good balance of size and functionality
- Includes most common CI tools
- Faster pull and startup times
- Compatible with our workflows

## Troubleshooting

### Common Issues and Solutions

#### 1. Docker Not Running

```bash
# Check Docker status
docker info

# Start Docker Desktop (macOS)
open -a Docker
```

#### 2. Image Pull Failures

```bash
# Manually pull the image
docker pull catthehacker/ubuntu:act-latest

# Clear Docker cache if needed
docker system prune -a
```

#### 3. Permission Errors

```bash
# Check Docker socket permissions
ls -la /var/run/docker.sock

# Add user to docker group (Linux)
sudo usermod -aG docker $USER
```

#### 4. Apple Silicon Issues

The `.actrc` includes `--container-architecture linux/amd64` for compatibility.

If you still have issues:

```bash
# Force platform in command
act --container-architecture linux/amd64
```

#### 5. Network Connectivity

```bash
# Test with different network modes
act --network bridge  # Isolated network
act --network host    # Host network (current default)
```

#### 6. Container Resource Issues

```bash
# Increase resources
act --container-options "--memory 8g --cpus 4"
```

### Debugging Workflows

#### Interactive Debugging

```bash
# Get shell access to debug
act push --job terraform-format -s
```

#### Verbose Logging

```bash
# Maximum verbosity
mise run act-debug

# Or directly
act push --verbose --debug
```

#### Step-by-Step Execution

```bash
# Preview what will run
mise run act-dry
```

## Performance Optimization

### Speed Improvements

1. **Container Reuse**: Already enabled via `--reuse`
1. **Local Caching**: Act caches in `~/.cache/act/`
1. **Parallel Jobs**: Run multiple terminals for different jobs
1. **Selective Testing**: Test only relevant jobs

### Resource Management

```bash
# Check container usage
docker ps -a | grep act

# Clean up old containers
docker container prune

# Monitor resource usage
docker stats
```

## CI/CD Parity

Ensuring local tests match GitHub Actions:

### Environment Variables

Act inherits from your shell environment. With mise active:

- All `TF_VAR_*` variables are available
- Tool versions match exactly
- Configuration is consistent

### File System

Using `--bind` ensures:

- Correct file permissions
- Symlinks work properly
- Git operations function

### Network Access

Host network mode provides:

- External API access
- Package downloads
- Docker daemon access

## Security Considerations

### Best Practices

1. **Secrets Management**

   - Never commit `.env.act`
   - Use environment variables for sensitive data
   - Rotate tokens regularly

1. **Container Isolation**

   - Containers run with limited privileges
   - Network isolation available if needed
   - Resource limits prevent system impact

1. **Code Review**
   - Review workflow files before running
   - Understand what actions do
   - Verify third-party actions

### Sensitive Variables

```bash
# Pass secrets securely
act -s GITHUB_TOKEN  # Prompts for input

# Or via environment
export GITHUB_TOKEN=xxx
act

# Never do this (appears in history)
act -s GITHUB_TOKEN=xxx
```

## Integration with Development Tools

### VS Code

1. Install "GitHub Actions" extension
1. Use integrated terminal for act commands
1. Set up tasks.json:

   ```json
   {
     "version": "2.0.0",
     "tasks": [
       {
         "label": "Act: Quick CI",
         "type": "shell",
         "command": "mise run act-quick"
       }
     ]
   }
   ```

### Shell Aliases

Add to your shell RC file:

```bash
alias act-quick='mise run act-quick'
alias act-ci='mise run act-ci'
alias act-debug='mise run act-debug'
```

### Git Hooks

Create `.git/hooks/pre-push`:

```bash
#!/bin/bash
echo "Running local CI checks..."
mise run act-quick
```

## Maintenance

### Updating Act

```bash
# Update via mise
mise up act

# Or manually
brew upgrade act  # macOS
```

### Updating Docker Images

```bash
# Pull latest images
docker pull catthehacker/ubuntu:act-latest

# Remove old images
docker image prune
```

### Configuration Updates

When workflows change:

1. Test with `act --dryrun`
1. Update mise tasks if needed
1. Document any new requirements

## Additional Resources

- [Act Documentation](https://nektosact.com)
- [Act GitHub Repository](https://github.com/nektos/act)
- [Act User Guide](https://nektosact.com/usage/index.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com)

## Quick Start Checklist

- [ ] Docker Desktop/daemon installed and running
- [ ] Act installed (`mise install act`)
- [ ] `.actrc` configuration present
- [ ] `.env.act` created (from template)
- [ ] Test with `mise run act-list`
- [ ] Run first workflow with `mise run act-quick`
