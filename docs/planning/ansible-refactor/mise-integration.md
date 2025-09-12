# Mise Integration for Ansible Refactor

## Overview

This document outlines how mise will be used to manage tools and tasks for the Ansible-first refactor, maintaining 
consistency with the project's existing tool management approach.

**Reference**:
[ansible-template-mise](https://github.com/chronicc/ansible-template)
[Ansible-mise](https://blog.devops.dev/how-to-use-mise-in-an-ansible-team-project-63d3d9c98193)

## Tool Management Strategy

### Core Ansible Tools (via mise)

```toml
# .mise.toml [tools] section
ansible-core = "2.19.1"  # Already present - the only Ansible tool available via mise
```

### Python Package Management (via uv)

For Python-specific tools that aren't available through mise:

```bash
# Create virtual environment
uv venv

# Activate environment
source .venv/bin/activate

# Install Python packages (option 1: individual)
uv pip install molecule[docker]>=4.0
uv pip install pytest-testinfra
uv pip install ansible-lint>=6.22.2

# Or install from requirements file (option 2: recommended)
uv pip install -r docs/planning/ansible-refactor/requirements-ansible.txt
```

## Task Definitions

### Development Setup Tasks

```toml
[tasks.ansible-dev-setup]
description = "Complete Ansible development environment setup"
run = """
# Install mise-managed tools
mise install

# Setup Python environment for Molecule
if [ ! -d .venv ]; then
  uv venv
fi
source .venv/bin/activate
uv pip install -r docs/planning/ansible-refactor/requirements-ansible.txt
echo "✅ Ansible development environment ready"
"""

[tasks.ansible-lint]
description = "Lint Ansible roles and playbooks"
run = """
source .venv/bin/activate
ansible-lint ansible/playbooks/
ansible-lint ansible/roles/
"""

[tasks.molecule-init]
description = "Initialize Molecule for a role"
run = """
source .venv/bin/activate
cd ansible/roles/${ROLE:?Role name required}
molecule init scenario
"""
```

### Testing Tasks

```toml
[tasks.molecule-test]
description = "Run Molecule tests for an Ansible role"
run = """
source .venv/bin/activate
cd ansible/roles/${ROLE:?Role name required}
molecule test
"""

[tasks.molecule-converge]
description = "Run Molecule converge for development"
run = """
source .venv/bin/activate
cd ansible/roles/${ROLE:?Role name required}
molecule converge
"""

[tasks.molecule-verify]
description = "Run Molecule verification only"
run = """
source .venv/bin/activate
cd ansible/roles/${ROLE:?Role name required}
molecule verify
"""
```

### Operational Tasks

```toml
[tasks.validate-infrastructure]
description = "Validate Proxmox infrastructure readiness"
depends = ["ansible-core"]
run = "ansible-playbook -i localhost, ansible/playbooks/validate-infrastructure.yml"

[tasks.smoke-test-ansible]
description = "Run smoke tests using Ansible roles"
depends = ["ansible-core"]
run = "ansible-playbook -i ansible/inventory/production ansible/playbooks/smoke-test.yml"

[tasks.diagnose]
description = "Run diagnostic playbook for troubleshooting"
depends = ["ansible-core"]
run = "ansible-playbook -i ansible/inventory/production ansible/playbooks/diagnose.yml"

[tasks.rollback]
description = "Execute safe rollback procedures"
depends = ["ansible-core"]
run = """
echo "⚠️  This will destroy the VM. Continue? (yes/no)"
read confirm
if [ "$confirm" = "yes" ]; then
  ansible-playbook -i ansible/inventory/production ansible/playbooks/rollback.yml
fi
"""
```

### Migration Support Tasks

```toml
[tasks.smoke-test-legacy]
description = "Legacy shell-based smoke tests (deprecated)"
run = "./scripts/smoke-test.sh"

[tasks.smoke-test]
description = "Smart smoke test runner (uses feature flag)"
run = """
if [ "${USE_ANSIBLE_ROLES:-false}" = "true" ]; then
  echo "🎭 Running Ansible-based smoke tests..."
  mise run smoke-test-ansible
else
  echo "🐚 Running legacy shell-based smoke tests..."
  mise run smoke-test-legacy
fi
"""

[tasks.migration-status]
description = "Check migration progress"
run = """
echo "📊 Ansible Migration Status"
echo "=========================="
echo ""
echo "Feature Flag: USE_ANSIBLE_ROLES=${USE_ANSIBLE_ROLES:-false}"
echo ""
echo "Tools Installed:"
mise ls | grep ansible
echo ""
echo "Roles Created:"
ls -la ansible/roles/ 2>/dev/null || echo "No roles directory yet"
echo ""
echo "Playbooks Created:"
ls -la ansible/playbooks/*.yml 2>/dev/null || echo "No new playbooks yet"
"""
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/ansible-tests.yml
name: Ansible Tests

on:
  pull_request:
    paths:
      - 'ansible/**'
      - '.mise.toml'

jobs:
  molecule:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup mise
        uses: mise-plugins/mise-action@v1

      - name: Install tools
        run: mise install

      - name: Setup Python environment
        run: |
          mise run ansible-dev-setup

      - name: Run Molecule tests
        run: |
          for role in ansible/roles/*/; do
            if [ -d "$role/molecule" ]; then
              ROLE=$(basename $role) mise run molecule-test
            fi
          done
```

## Environment Variables

### Development

```toml
# .mise.local.toml
[env]
USE_ANSIBLE_ROLES = "true"  # Enable Ansible roles
ANSIBLE_VERBOSITY = "1"      # Increase verbosity for debugging
MOLECULE_DEBUG = "false"     # Enable Molecule debugging
```

### Production

```toml
# .mise.local.toml (production)
[env]
USE_ANSIBLE_ROLES = "true"  # After migration complete
ANSIBLE_HOST_KEY_CHECKING = "false"  # For automated deployments
ANSIBLE_TIMEOUT = "30"
```

## Directory Structure

```
.
├── .mise.toml              # Project tool configuration
├── .mise.local.toml        # Local overrides (gitignored)
├── .venv/                  # Python virtual environment (gitignored)
├── requirements-dev.txt    # Python development dependencies
└── ansible/
    ├── ansible.cfg         # Ansible configuration
    ├── roles/
    │   └── */
    │       └── molecule/  # Molecule tests
    └── playbooks/
```

## Best Practices

1. **Tool Versions**: Always pin tool versions in `.mise.toml` for consistency
2. **Python Packages**: Use `uv` for Python package management, not system pip
3. **Task Dependencies**: Use `depends` in mise tasks to ensure tools are available
4. **Environment Isolation**: Keep Python packages in `.venv` to avoid conflicts
5. **Documentation**: Add `description` to all mise tasks for clarity

## Migration Checklist

- [ ] Create `ansible-dev-setup` task
- [ ] Add molecule testing tasks
- [ ] Update smoke test tasks with feature flag
- [ ] Create migration status task
- [ ] Document in README
- [ ] Update CI/CD workflows
- [ ] Train team on new mise tasks

## Common Commands

```bash
# Initial setup
mise run ansible-dev-setup

# Run tests
ROLE=vm_smoke_tests mise run molecule-test

# Check what's available
mise tasks | grep ansible

# Run linting
mise run ansible-lint

# Check migration progress
mise run migration-status
```

## Troubleshooting

### Issue: Molecule not found

```bash
# Ensure virtual environment is activated
source .venv/bin/activate
which molecule
```

### Issue: Ansible version mismatch

```bash
# Check mise installation
mise ls | grep ansible
mise install ansible-core
```

### Issue: Task not found

```bash
# List all available tasks
mise tasks

# Check task definition
mise tasks --verbose
```

## Next Steps

1. Review and approve mise integration approach
2. Update `.mise.toml` with new tools
3. Test all tasks in development environment
4. Document in main README
5. Create team training materials
