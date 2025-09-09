# Local CI Testing Guide

This document provides a quick reference for running CI checks locally before pushing to GitHub.

## Overview

We use [act](https://github.com/nektos/act) to run GitHub Actions locally in Docker containers, providing:

- **Fast feedback** - Test changes without pushing to GitHub
- **Cost savings** - No GitHub Actions minutes consumed
- **Local debugging** - Fix issues before they hit CI

For detailed act configuration and setup, see [Act Configuration Documentation](./act-configuration.md).

## Quick Start

```bash
# First time setup
cp .env.act.example .env.act  # If needed
mise run act-list             # Verify act is working

# Before committing
mise run act-quick            # Fast validation (format + validate + lint)

# Before pushing
mise run act-ci              # Full CI pipeline

# Before creating PR
mise run act-pr              # Simulate pull request checks
```

## Common Workflows

### Testing Terraform Changes

```bash
# Quick validation
mise run act-quick

# Or individual checks
mise run act-format    # Check formatting
mise run act-validate  # Validate configuration
mise run act-lint      # Run TFLint
```

### Testing Documentation Updates

```bash
mise run act-docs      # Check if docs are in sync
```

### Testing Scripts

```bash
mise run act-shell     # Run ShellCheck on scripts
```

### Running Security Scans

```bash
mise run act-security  # Run Infisical + KICS scans
```

### Debugging CI Failures

```bash
mise run act-debug     # Verbose output for troubleshooting
mise run act-dry       # Preview what will run without executing
```

## Recommended Development Workflow

1. **Make changes** to Terraform, scripts, or documentation
1. **Quick check** with `mise run act-quick` (takes ~30 seconds)
1. **Fix any issues** locally
1. **Full validation** with `mise run act-ci` (takes ~2 minutes)
1. **Commit and push** with confidence

## Troubleshooting Quick Reference

| Issue                | Solution                                           |
| -------------------- | -------------------------------------------------- |
| Docker not running   | `docker info` to check, start Docker Desktop       |
| Act not found        | `mise install act`                                 |
| Image pull failures  | `docker pull catthehacker/ubuntu:act-latest`       |
| Permission issues    | Check Docker socket: `ls -la /var/run/docker.sock` |
| Apple Silicon issues | Already handled by `.actrc` configuration          |
| Need verbose output  | Use `mise run act-debug`                           |
| Want to preview only | Use `mise run act-dry`                             |

For detailed troubleshooting, see [Act Configuration - Troubleshooting](./act-configuration.md#troubleshooting).

## CI Job Reference

| Job                | Purpose                    | Mise Command            |
| ------------------ | -------------------------- | ----------------------- |
| terraform-format   | Check Terraform formatting | `mise run act-format`   |
| terraform-validate | Validate Terraform syntax  | `mise run act-validate` |
| tflint             | Terraform best practices   | `mise run act-lint`     |
| terraform-docs     | Documentation generation   | `mise run act-docs`     |
| shellcheck         | Shell script linting       | `mise run act-shell`    |
| secret-scan        | Infisical secret scanning  | Part of `act-security`  |
| kics-scan          | Infrastructure security    | Part of `act-security`  |
| **all checks**     | Complete CI pipeline       | `mise run act-ci`       |
| **quick checks**   | Format + Validate + Lint   | `mise run act-quick`    |

## Related Documentation

- [Act Configuration](./act-configuration.md) - Detailed act setup and configuration
- [Mise Configuration](../development/mise-configuration.md) - Task runner and tool management
- [GitHub Workflows](./.github/workflows/) - Actual workflow definitions
