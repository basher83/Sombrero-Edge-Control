# Infisical Secret Scanning Setup Guide

This guide walks through setting up Infisical secret scanning for the Sombrero Edge Control repository from
initial setup to integration with pre-commit hooks and CI/CD pipelines.

## Prerequisites

- Infisical CLI installed (`brew install infisical/get-cli/infisical` on macOS)
- Git repository initialized
- mise installed for environment management

## Initial Setup

### 1. Initialize Infisical Project (Optional)

While not required for secret scanning, initializing an Infisical project enables advanced features like
secret management and environment synchronization:

```bash
infisical init
```

This command:

- Creates `.infisical.json` with project configuration
- Links your repository to an Infisical project (if using Infisical cloud/self-hosted)
- Enables features like secret injection and environment management

For standalone secret scanning, this step can be skipped.

#### Configuring Default Environment

If you're using Infisical for secret management (beyond just scanning), you can configure a default environment
to avoid specifying `--env` with every command:

```json
// .infisical.json
{
  "workspaceId": "63ee5410a45f7a1ed39ba118",
  "defaultEnvironment": "production",
  "gitBranchToEnvironmentMapping": null
}
```

#### Automatic Environment Mapping Based on Git Branch

For teams working across multiple environments, you can automatically map Git branches to Infisical environments:

```json
// .infisical.json
{
  "workspaceId": "63ee5410a45f7a1ed39ba118",
  "defaultEnvironment": "production",
  "gitBranchToEnvironmentMapping": {
    "main": "production",
    "develop": "development",
    "staging": "staging",
    "feature/*": "development"
  }
}
```

**How environment selection works:**

1. If `gitBranchToEnvironmentMapping` matches current branch → uses mapped environment
1. Else if `defaultEnvironment` is set → uses default environment
1. Else → requires explicit `--env` flag
1. Can always override with explicit `--env` flag

**Example usage:**

```bash
# On 'main' branch - automatically uses 'production' environment
infisical run -- terraform apply

# On 'develop' branch - automatically uses 'development' environment
infisical run -- terraform plan

# Override automatic selection
infisical run --env=staging -- terraform plan
```

For our jump host infrastructure, we typically work in production, so our configuration would be:

```json
{
  "workspaceId": "your-workspace-id",
  "defaultEnvironment": "production",
  "gitBranchToEnvironmentMapping": {
    "main": "production",
    "feature/*": "development"
  }
}
```

### 2. Configure Secret Scanning

The repository includes a pre-configured `.infisical-scan.toml` file with custom rules tailored for our infrastructure patterns:

```toml
# Key sections in our configuration:
[extend]
useDefault = true  # Extends Infisical's default detection rules

[[rules]]
# Custom rules for infrastructure-specific patterns:
# - Proxmox API tokens
# - SSH private keys
# - Terraform sensitive variables

[allowlist]
# Paths and patterns to ignore:
# - Documentation files
# - Example configuration files
# - Test files
# - This scan configuration itself
```

Key features of our configuration:

- **Proxmox API Token Detection**: Catches patterns like `terraform@pve!token=...`
- **Terraform Variable Detection**: Identifies `TF_VAR_*` environment variables containing sensitive values
- **Smart Allowlisting**: Excludes example files, documentation, and placeholder values

#### Important: Rule-Specific Allowlist Structure

When defining allowlists for specific rules in `.infisical-scan.toml`, the allowlist must be an inline object
property of the rule, NOT a separate array element:

**✅ Correct Structure:**

```toml
[[rules]]
id = "proxmox-api-token"
description = "Proxmox API Token Detection"
regex = '''...pattern...'''
# Allowlist is an inline object property of the rule
allowlist = {
    description = "Allow example Proxmox tokens in documentation",
    paths = [
        '''terraform\.tfvars\.example''',
        '''docs/.*'''
    ],
    regexes = [
        '''xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'''
    ]
}
```

**❌ Incorrect Structure (will cause errors):**

```toml
[[rules]]
id = "proxmox-api-token"
description = "Proxmox API Token Detection"
regex = '''...pattern...'''

# This separate array syntax is INCORRECT
[[rules.allowlist]]
id = "proxmox-api-token"
description = "Allow example Proxmox tokens in documentation"
paths = [...]
```

The key difference is that each rule's allowlist must be defined as an inline nested object (`allowlist = { ... }`),
not as a separate `[[rules.allowlist]]` section. This is a common configuration error that will prevent Infisical
from parsing the configuration correctly.

#### Editor Configuration for TOML Files

To prevent IDEs and editors from improperly auto-formatting `.infisical-scan.toml` (which can break the specific
TOML structure required by Infisical), add the following to your `.editorconfig` file:

```ini
# Infisical config - preserve structure
[.infisical-scan.toml]
indent_style = space
indent_size = 2
max_line_length = off
# Tell formatters to be gentle with this file
trim_trailing_whitespace = true
insert_final_newline = true
```

This configuration ensures:

- Consistent 2-space indentation (matching Infisical examples)
- No automatic line wrapping that might break regex patterns
- Preservation of the TOML structure that Infisical expects
- Clean file endings without trailing whitespace

Without this configuration, aggressive auto-formatters in VSCode, IntelliJ, or other editors might restructure
the TOML in ways that break Infisical's parser, particularly around multi-line strings and nested objects.

### 3. Create a Baseline

A baseline file records existing secrets that should be ignored in future scans (useful for legacy code or false positives):

```bash
# Run initial scan and save results as baseline
infisical scan --report-path=.infisical-baseline.json

# Review the baseline file and remove any actual secrets that need fixing
# The baseline should only contain false positives or accepted risks

# Future scans will ignore baseline findings
infisical scan --baseline-path=.infisical-baseline.json
```

Add the baseline to `.gitignore` if it contains sensitive information:

```bash
echo ".infisical-baseline.json" >> .gitignore
```

## Pre-commit Hook Integration

### 1. Install Pre-commit Framework

```bash
mise hooks-install
```

### 2. Configure Pre-commit Hook

The repository includes `.pre-commit-config.yaml` with Infisical integration:

```yaml
repos:
  - repo: local
    hooks:
      - id: infisical-scan
        name: Infisical Secret Scan
        entry: infisical scan git-changes --staged
        language: system
        pass_filenames: false
        verbose: true
```

### 3. Install the Hook

```bash
# Install the pre-commit hook
pre-commit install

# Test the hook manually
pre-commit run --all-files

# Or test only secret scanning
pre-commit run infisical-scan --all-files
```

Now Infisical will automatically scan staged changes before each commit.

## Integration with mise Environment Management

### Why mise + Infisical?

Our infrastructure uses mise for managing environment variables, particularly Terraform variables (`TF_VAR_*`).
This creates a security consideration:

1. **Sensitive Variables**: Variables like `TF_VAR_pve_api_token` contain secrets
1. **Local Configuration**: These are stored in `.mise.local.toml` (git-ignored)
1. **Secret Detection**: Infisical scans help ensure these patterns don't leak into committed files

### mise Configuration Structure

```toml
# .mise.local.toml (git-ignored)
[env]
TF_VAR_pve_api_url = "https://proxmox.example.com:8006/api2/json"
TF_VAR_pve_api_token = "terraform@pve!token=sensitive-token-here"
TF_VAR_ci_ssh_key = "ssh-ed25519 AAAAC3... ansible@jump-man"
```

### Security Best Practices

1. **Never commit `.mise.local.toml`** - Already in `.gitignore`
1. **Use variable references in code** - Reference `var.pve_api_token`, never hardcode values
1. **Document variable requirements** - Use `terraform.tfvars.example` for documentation
1. **Scan for patterns** - Our `.infisical-scan.toml` includes rules for `TF_VAR_*` patterns

## Running Secret Scans

### Manual Scanning

```bash
# Scan entire repository history
infisical scan

# Scan with verbose output
infisical scan --verbose

# Scan only uncommitted changes
infisical scan git-changes

# Scan staged changes (pre-commit)
infisical scan git-changes --staged

# Scan specific directory or file
infisical scan --no-git --source=./infrastructure

# Scan with custom config
infisical scan --config=./custom-scan.toml
```

### CI/CD Integration

Add to GitHub Actions workflow:

```yaml
- name: Secret Scanning
  uses: guillaumervls/infisical-scan@v1
  with:
    report-format: sarif
    report-path: infisical-results.sarif

- name: Upload SARIF results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: infisical-results.sarif
```

## Common Patterns and Solutions

### False Positives

If Infisical flags example or documentation files:

1. **Add to allowlist paths** in `.infisical-scan.toml`:

   ```toml
   paths = [
       '''docs/.*\.md''',
       '''.*\.example'''
   ]
   ```

1. **Add regex patterns** for placeholder values:

   ```toml
   regexes = [
       '''your-token-here''',
       '''xxxxxxxx'''
   ]
   ```

1. **Use baseline** for accepted risks:

   ```bash
   infisical scan --baseline-path=.infisical-baseline.json
   ```

### Proxmox-Specific Patterns

Our configuration detects Proxmox API tokens with this pattern:

```toml
regex = '''(terraform@pve|proxmox).*?[!=:]\\s*[\"']?([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})[\"']?'''
```

This catches:

- `terraform@pve!token=uuid-format-token`
- `proxmox_api_token = "uuid-format-token"`
- Environment variables with Proxmox tokens

### Terraform Variable Patterns

Detects sensitive Terraform environment variables:

```toml
regex = '''(TF_VAR_[a-z_]+(?:token|key|password|secret))\\s*=\\s*[\"']([^\"']+)[\"']'''
```

This catches:

- `TF_VAR_pve_api_token="..."`
- `TF_VAR_ssh_key="..."`
- `TF_VAR_db_password="..."`

## Troubleshooting

### Issue: Scan takes too long

**Solution**: Limit scan scope

```bash
# Scan only recent commits
infisical scan --log-opts="--since=1.week"

# Skip large files
infisical scan --max-target-megabytes=10
```

### Issue: Too many false positives

**Solution**: Refine configuration

1. Review and update `.infisical-scan.toml`
1. Add specific paths to allowlist
1. Create baseline for accepted findings

### Issue: Pre-commit hook blocks valid commits

**Solution**: Temporary bypass (use sparingly)

```bash
# Skip hooks for emergency fix
git commit --no-verify -m "Emergency fix"

# Better: Update configuration to handle the pattern
```

### Issue: Configuration not being read

**Solution**: Check file location and naming

```bash
# Verify config file exists with correct name (dot prefix)
ls -la .infisical-scan.toml

# Test with explicit config path
infisical scan --config=./.infisical-scan.toml
```

## Best Practices Summary

1. **Layer Security**: Combine secret scanning with other security measures
1. **Scan Early**: Use pre-commit hooks to catch secrets before they enter history
1. **Automate**: Integrate scanning into CI/CD pipelines
1. **Educate**: Ensure team understands what patterns trigger detection
1. **Review Regularly**: Periodically review scan configuration and baselines
1. **Respond Quickly**: If a secret is detected, rotate it immediately
1. **Use mise**: Leverage mise for local environment management, keeping secrets out of code

## Additional Resources

- [Infisical Documentation](https://infisical.com/docs/cli/overview)
- [Infisical Secret Scanning](https://infisical.com/docs/cli/scanning-overview)
- [mise Documentation](https://mise.jdx.dev/)
- [Pre-commit Framework](https://pre-commit.com/)

## Quick Reference Card

```bash
# Daily Development
infisical scan git-changes          # Check uncommitted changes
git add . && git commit             # Pre-commit hook runs automatically

# Periodic Checks
infisical scan --verbose            # Full repository scan
infisical scan --report-format=json --report-path=scan-results.json

# Configuration Management
cat .infisical-scan.toml           # View current rules
infisical scan --config=custom.toml # Test custom configuration

# Environment Setup
mise env                            # Load TF_VAR_* variables
terraform plan                      # Use loaded variables
```
