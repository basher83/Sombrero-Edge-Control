# Terraform CLI & Operations Optimization Guide 🚀

## Overview

This guide documents various optimization techniques to speed up Terraform operations, reduce
redundant work, and improve the development experience.

## Plugin Caching

### Problem

By default, Terraform downloads provider plugins for every `terraform init`, even if they're
already present on your system. This wastes bandwidth and time.

### Solution

Configure a central plugin cache directory that Terraform will check before downloading.

#### Setup Steps

1. **Create the cache directory**:

   ```bash
   mkdir -p ~/.terraform.d/plugin-cache
   ```

1. **Create Terraform CLI configuration**:

   ```bash
   cat > ~/.terraformrc << 'EOF'
   plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
   EOF
   ```

1. **Verify it works**:

```bash
# First init will download to cache
mise run prod-init

# Second init will use cache (much faster!)
rm -rf infrastructure/environments/production/.terraform
mise run prod-init  # Notice how fast this is now
```

### Benefits

- First `init`: Downloads providers to cache
- Subsequent `init`: Uses cached providers (5-10x faster)
- Shared across all Terraform projects on your machine

## Parallelism Configuration

### Problem

Terraform defaults to 10 parallel resource operations, which can be slow for large infrastructures or high-latency APIs.

### Solution

Increase parallelism for faster operations.

#### Method 1: Environment Variables (Recommended)

Add to `.mise.local.toml`:

```toml
# Terraform CLI optimization
TF_CLI_ARGS_apply = "-parallelism=20"
TF_CLI_ARGS_plan = "-parallelism=20"
```

#### Method 2: Command Line

```bash
terraform plan -parallelism=20
terraform apply -parallelism=20
```

### Benefits

- Faster API operations
- Reduced total execution time
- Especially helpful with remote providers like Proxmox

## Environment Variable Automation

### TF_CLI_ARGS Pattern

Terraform respects `TF_CLI_ARGS_*` environment variables to automatically add arguments to commands.

#### Common Optimizations in `.mise.local.toml`

```toml
[env]
# Auto-apply parallelism
TF_CLI_ARGS_apply = "-parallelism=20"
TF_CLI_ARGS_plan = "-parallelism=20"

# Auto-approve for CI/CD (use with caution!)
# TF_CLI_ARGS_apply = "-auto-approve -parallelism=20"

# Backend configuration for init
TF_CLI_ARGS_init = "-backend-config=../../../shared/backend-config/backend.hcl -upgrade=false"

# Skip refresh during plan (when you know external changes haven't occurred)
# TF_CLI_ARGS_plan = "-refresh=false -parallelism=20"

# Compact plan output
TF_CLI_ARGS_plan = "-compact-warnings -parallelism=20"
```

### How mise.local.toml Works

- **mise** automatically loads environment variables from `.mise.local.toml`
- Variables are set before running any mise task
- Keeps sensitive/local configs out of version control via `.gitignore`
- Team members can have different optimization settings

## Quick Performance Wins

### 1. Skip Refresh When Iterating

```bash
# When you know infrastructure hasn't changed externally
terraform plan -refresh=false

# Or set in .mise.local.toml temporarily:
TF_CLI_ARGS_plan = "-refresh=false -parallelism=20"
```

**Impact**: 50% faster plans during development

### 2. Target Specific Resources

```bash
# Only plan/apply specific resources during development
terraform plan -target=module.jump_man
terraform apply -target=module.jump_man
```

**Impact**: 80-90% faster when working on single resources

### 3. Use -upgrade=false for init

```bash
# Skip checking for provider updates
terraform init -upgrade=false
```

**Impact**: Faster init when providers are already current

### 4. Compact Output

```bash
# Reduce output verbosity
terraform plan -compact-warnings
```

**Impact**: Cleaner output, easier to read

## Proxmox-Specific Optimizations

### 1. Connection Settings

```toml
# In .mise.local.toml
TF_VAR_proxmox_insecure = "true"  # Skip TLS verification (dev only!)
```

### 2. Reduce Agent Timeout

Already configured in our module:

```hcl
agent {
  enabled = true
  timeout = "5m"  # Reduced from default 15m
}
```

### 3. Use Local Network

- Connect to Proxmox via local IP (192.168.x.x) instead of public
- Reduces latency significantly

## Complete Optimization Setup Script

Create `scripts/setup-terraform-optimization.sh`:

```bash
#!/bin/bash
set -euo pipefail

echo "🚀 Setting up Terraform optimizations..."

# Create plugin cache directory
echo "📁 Creating plugin cache directory..."
mkdir -p ~/.terraform.d/plugin-cache

# Create Terraform RC file
echo "📝 Creating ~/.terraformrc..."
cat > ~/.terraformrc << 'EOF'
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
EOF

# Show current .mise.local.toml optimizations
echo "⚙️  Current mise.local.toml optimizations:"
grep -E "TF_CLI_ARGS|parallelism" .mise.local.toml 2>/dev/null || echo "No optimizations found"

echo "✅ Optimization setup complete!"
echo ""
echo "📊 To test performance improvements:"
echo "  1. Run: mise run prod-init"
echo "  2. Delete .terraform: rm -rf infrastructure/environments/production/.terraform"
echo "  3. Run again: mise run prod-init"
echo "  4. Notice the speed difference!"
```

## Performance Benchmarks

Typical improvements with optimizations:

| Operation                     | Before | After | Improvement |
| ----------------------------- | ------ | ----- | ----------- |
| terraform init (cold)         | 45s    | 45s   | -           |
| terraform init (cached)       | 45s    | 3s    | 93% faster  |
| terraform plan (with refresh) | 30s    | 20s   | 33% faster  |
| terraform plan (no refresh)   | 30s    | 8s    | 73% faster  |
| terraform apply               | 60s    | 40s   | 33% faster  |

## Troubleshooting

### Plugin Cache Not Working

```bash
# Verify cache directory exists
ls -la ~/.terraform.d/plugin-cache

# Check Terraform is reading config
terraform version -json | jq .terraform_cli_config
```

### Environment Variables Not Applied

```bash
# Verify mise is loading variables
mise env

# Check specific variable
echo $TF_CLI_ARGS_plan
```

### Parallelism Too High

If you see API rate limiting or connection errors, reduce parallelism:

```toml
TF_CLI_ARGS_plan = "-parallelism=10"  # Back to default
```

## Best Practices

1. **Development vs Production**:

   - Use aggressive optimizations in development
   - Be conservative in production (don't skip refresh, use default parallelism)

1. **Team Settings**:

   - Document optimization settings in this guide
   - Share `.mise.local.toml.example` with recommended settings
   - Let team members adjust based on their hardware/network

1. **CI/CD Pipeline**:
   - Use plugin caching in CI runners
   - Set appropriate parallelism for CI environment
   - Never use `-auto-approve` without proper guards

## Additional Resources

- [Terraform CLI Environment Variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables)
- [Terraform Performance](https://developer.hashicorp.com/terraform/internals/graph#walking-the-graph)
- [mise Environment Management](https://mise.jdx.dev/configuration.html#env-environment-variables)
