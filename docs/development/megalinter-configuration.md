# MegaLinter Configuration Guide

This document covers MegaLinter setup, configuration, and optimizations for the Sombrero-Edge-Control project.

## Overview

[MegaLinter](https://megalinter.io/) is a unified linting tool that aggregates multiple linters for code quality across multiple languages and formats. This project uses MegaLinter to ensure consistent code quality for:

- **Terraform**: `tflint`, `terraform validate`, `terraform fmt`
- **Ansible**: `ansible-lint`
- **YAML**: `yamllint`
- **Markdown**: `markdownlint`
- **Shell**: `shellcheck`
- **Security**: `terrascan`, `kics`

## Configuration Files

### Core Configuration

- **`.mega-linter.yml`** - Main MegaLinter configuration
- **`.github/linters/.tflint.hcl`** - Terraform linting rules
- **`.github/linters/.terrascan.toml`** - Security scanning config
- **`.github/linters/.ansible-lint`** - Ansible linting config
- **`.github/workflows/mega-linter.yml`** - CI/CD pipeline

### Local Testing Scripts

- **`scripts/diagnose-megalinter.sh`** - Performance diagnostics
- **`scripts/test-megalinter.sh`** - Local validation testing
- **`scripts/fix-markdown-issues.sh`** - Markdown formatting helper

## Integration with CI

MegaLinter is configured to **complement** rather than duplicate your existing CI workflow:

### CI Workflow (Primary)
- **Trigger**: Every push and PR
- **Purpose**: Fast, focused quality checks
- **Tools**: Individual linters (TFLint, ShellCheck, yamllint, etc.)
- **Speed**: ~3-5 minutes

### MegaLinter (Secondary)
- **Trigger**: Weekly schedule + manual runs
- **Purpose**: Comprehensive multi-language linting
- **Tools**: 50+ linters in one unified system
- **Speed**: ~8-15 minutes (with optimizations)

### When to Use Each

| Scenario | Use CI Workflow | Use MegaLinter |
|----------|----------------|----------------|
| **Everyday commits** | ✅ Primary gate | ❌ Too slow |
| **Code reviews** | ✅ Fast feedback | ❌ Not triggered |
| **Weekly health check** | ❌ Too frequent | ✅ Comprehensive |
| **New linter testing** | ❌ Limited scope | ✅ All linters |
| **Manual deep dive** | ❌ Individual tools | ✅ Unified report |

## Local Usage

### Quick Commands

```bash
# Fast validation (format, validate, lint)
mise run act-quick

# Full CI pipeline simulation
mise run act-ci

# Individual linter checks
mise run act-format    # Terraform formatting
mise run act-validate  # Terraform validation
mise run act-lint      # Terraform linting
mise run act-docs      # Documentation generation
mise run act-shell     # Shell script linting
mise run act-security  # Security scanning
```

### Diagnostic Tools

```bash
# Performance analysis
./scripts/diagnose-megalinter.sh

# Local testing with timeout
timeout 300 ./scripts/test-megalinter.sh
```

### Manual GitHub Actions Triggers

```bash
# Trigger MegaLinter manually via GitHub CLI
gh workflow run "MegaLinter"

# Or trigger via GitHub web interface:
# Actions → MegaLinter → "Run workflow"
```

### Scheduled Runs

MegaLinter runs automatically every **Monday at 2 AM UTC** for comprehensive weekly code quality checks.

## Optimizations Applied

### Performance Summary

```
Before: 20 minutes, always runs all linters
After: 10-15 minutes with intelligent optimization

Fast Mode (dev branches): ~8-10 minutes (skips slow linters)
Full Mode (main): ~12-15 minutes (comprehensive linting)
```

### CI/CD Performance Improvements

#### Timeout Management

- **Overall Timeout**: Reduced from 20min → 15min (main branch) / 10min (dev branches)
- **Individual Linter Timeouts**: Prevent hanging with per-linter timeout limits
- **Smart Timeout Allocation**: Faster timeouts for development workflow

#### Conditional Fast Mode

- **Development Branches**: Skip slow linters (`TERRAFORM_TERRASCAN`, `MARKDOWN_MARKDOWN_LINK_CHECK`)
- **Main Branch**: Full comprehensive linting for production quality
- **Smart Job Naming**: CI shows "Fast Mode" vs "Full" status clearly

#### Performance Monitoring

- **Elapsed Time Reporting**: Added timing metrics for each linter
- **Performance Diagnostics**: `./scripts/diagnose-megalinter.sh` for analysis
- **Resource Optimization**: Parallel processing and memory management

#### Smart Path Filtering

- **File Change Detection**: Only runs relevant linters based on changed files
- **Efficient CI Triggers**: Reduces unnecessary linting on unrelated changes
- **Language-Specific Filtering**: Terraform changes trigger Terraform linters only

### Configuration Optimizations

1. **Plugin Caching**: Added Terraform plugin cache configuration
2. **Security Rules**: Configured terrascan for infrastructure security
3. **Markdown Standards**: Enforced 120-character line limits
4. **Code Block Formatting**: Required language specifiers

### File Structure Improvements

1. **Linter Rules**: Organized in `.github/linters/` directory
2. **Backup System**: Automatic backups during fixes
3. **Error Reduction**: Fixed 44+ markdown issues across 5 files

## Known Gotchas

### Common Issues

1. **Terrascan Installation**: Must use `mise install terrascan` if not available
2. **Container Architecture**: Apple Silicon requires `linux/amd64` specification
3. **Plugin Cache**: Ensure `~/.terraform.d/plugin-cache` directory exists
4. **Environment Variables**: `TF_VAR_*` variables must be available in shell

### Performance Considerations

1. **Large Files**: Very large files may exceed timeout limits
2. **Network Issues**: Plugin downloads can be slow on poor connections
3. **Memory Usage**: Large repositories may require more RAM
4. **Cache Conflicts**: Clear caches if experiencing unusual errors

### Markdown Formatting

1. **Ordered Lists**: Use `1.` for all items (not continuation numbering)
2. **Code Blocks**: Always specify language (e.g., `bash, `yaml)
3. **Line Length**: 120 characters maximum for readability
4. **Table Formatting**: Proper spacing and alignment required

## Troubleshooting

### Local Testing Issues

```bash
# Check Docker status
docker info

# Verify mise tools
mise list

# Test individual components
mise run act-format
```

### CI/CD Pipeline Issues

- **Timeout Errors**: Check file sizes and network connectivity
- **Memory Issues**: Reduce parallelism or file scope
- **Plugin Errors**: Clear Terraform cache and retry
- **Permission Issues**: Ensure proper Docker socket permissions

### Configuration Problems

```bash
# Validate configuration
mega-linter-runner --config .mega-linter.yml --help

# Test specific file
mega-linter-runner --files "infrastructure/main.tf"
```

## Quick Reference

### Status Commands

```bash
# Check current status
mise run act-dry      # Preview without execution
mise run act-debug    # Maximum verbosity
```

### File Types Supported

- `.tf` - Terraform configuration
- `.hcl` - HashiCorp Configuration Language
- `.yaml` / `.yml` - YAML files
- `.md` - Markdown documentation
- `.sh` - Shell scripts
- `.json` - JSON configuration

### Exit Codes

- `0` - All checks passed
- `1` - Linting errors found
- `2` - Configuration error
- `3` - Runtime error

## Related Documentation

- [CI Local Testing](./ci-local-testing.md) - Local CI simulation
- [Code Formatting and Linting](./code-formatting-and-linting.md) - Code quality standards
- [Mise Configuration](./mise-configuration.md) - Tool version management
- [Act Configuration](./act-configuration.md) - GitHub Actions local testing

## Maintenance

### Regular Tasks

1. **Update Tools**: `mise install` after configuration changes
2. **Clear Caches**: `mise run clean` periodically
3. **Validate Config**: Test after MegaLinter updates
4. **Review Rules**: Update linter configurations as needed

### Configuration Updates

- Keep `.mega-linter.yml` in sync with project needs
- Update linter rules in `.github/linters/` as standards evolve
- Test configuration changes locally before committing
- Document any custom rules or exceptions
