# MegaLinter Migration Guide

## Overview

This document outlines the migration from individual linting tools to MegaLinter for centralized code quality management in Sombrero Edge Control.

## What Changed

### Before: Individual Linters

- **Terraform**: `terraform fmt`, `terraform validate`, `tflint`
- **YAML**: `yamllint`
- **Shell Scripts**: `shellcheck`
- **Markdown**: `markdownlint-cli2`
- **Ansible**: `ansible-lint`

### After: MegaLinter

- **Single Tool**: MegaLinter orchestrates all linting tools
- **Centralized Config**: `.mega-linter.yml` manages all settings
- **Unified Reports**: SARIF output for GitHub Security tab
- **Auto-fixes**: Optional automatic fixing of issues

## File Structure

```
.github/
  linters/
    .markdownlint.json           # Markdown linting rules
    .markdown-link-check.json    # Link checking configuration
    .yamllint.yaml              # YAML linting rules
    .ansible-lint               # Ansible linting configuration
    .tflint.hcl                 # Terraform linting rules
    .terrascan.toml             # Infrastructure security rules

.mega-linter.yml               # Central MegaLinter configuration
.github/workflows/mega-linter.yml  # GitHub Actions workflow
scripts/test-megalinter.sh     # Local testing script
```

## Configuration Files

### Central Configuration (`.mega-linter.yml`)

- Enables/disables specific linters
- Sets global include/exclude patterns
- Configures reporting and auto-fix behavior
- References rule files in `.github/linters/`

### Linter-Specific Rules

- **Markdown**: Migrated from `markdownlint-cli2.jsonc`
- **YAML**: Standard rules with IaC-friendly settings
- **Ansible**: Production profile with custom skip/warn lists
- **Terraform**: TFLint with AWS ruleset
- **Security**: Terrascan for infrastructure scanning

## Usage

### Local Testing

```bash
# Test MegaLinter locally before pushing
./scripts/test-megalinter.sh

# Or use mega-linter-runner directly
npx mega-linter-runner --flavor terraform
```

### GitHub Actions

The MegaLinter workflow runs automatically on:

- Pull requests affecting lintable files
- Pushes to `main` and `develop` branches

### Reports

- **SARIF Reports**: Uploaded to GitHub Security tab
- **JSON Reports**: Available as workflow artifacts
- **Console Output**: Real-time feedback in CI logs

## Migration Benefits

### 🎯 Consolidation

- **Single Tool**: No more managing multiple linting tools
- **Unified Config**: One configuration file for all rules
- **Consistent Output**: Standardized reporting format

### 🚀 Performance

- **Parallel Execution**: All linters run simultaneously
- **Smart Filtering**: Only runs on relevant file changes
- **Caching**: Faster subsequent runs

### 📊 Enhanced Reporting

- **Security Integration**: SARIF reports in GitHub Security tab
- **Auto-fixes**: Optional automatic fixing of issues
- **Detailed Metrics**: Comprehensive linting statistics

### 🔧 Maintainability

- **Centralized Rules**: All configurations in one place
- **Version Pinning**: Consistent tool versions
- **Documentation**: Self-documenting configuration

## Troubleshooting

### Common Issues

1. **Docker Not Running**

   ```bash
   # Ensure Docker is running
   docker info
   ```

2. **Permission Issues**

   ```bash
   # Make script executable
   chmod +x scripts/test-megalinter.sh
   ```

3. **Missing Dependencies**
   ```bash
   # Install mega-linter-runner
   npm install -g mega-linter-runner
   ```

### Configuration Validation

Test your configuration locally before pushing:

```bash
# Quick validation
mega-linter-runner --help

# Full test run
./scripts/test-megalinter.sh
```

## Next Steps

1. **Test Locally**: Run `./scripts/test-megalinter.sh` to validate setup
2. **Update CI**: The new workflow will replace individual linter jobs
3. **Monitor Results**: Check GitHub Actions and Security tab for reports
4. **Fine-tune Rules**: Adjust configurations based on findings

## Related Documentation

- [Linting Standards](../standards/linting-standard.md) - Detailed MegaLinter setup
- [CI/CD Pipeline](../deployment/ci-cd-pipeline-workflow.md) - Updated CI workflow
- [MegaLinter Documentation](https://megalinter.io/) - Official documentation

---

_This migration consolidates 7+ individual linting tools into a single, efficient MegaLinter setup while maintaining all existing functionality and improving developer experience._
