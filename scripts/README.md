# Scripts Directory

Utility scripts for managing the Sombrero Edge Control jump host infrastructure.

## Available Scripts

### 🔍 `find-tags.sh`

**Purpose**: Find TODO, FIXME, BUG, and other tags in code and documentation
**Usage**:

```bash
./scripts/find-tags.sh          # Find all tags
./scripts/find-tags.sh TODO     # Find only TODO tags
./scripts/find-tags.sh FIXME    # Find only FIXME tags
```

### 📋 `generate-ansible-inventory.sh`

**Purpose**: Generate Ansible inventory files from Terraform outputs
**Usage**:

```bash
./scripts/generate-ansible-inventory.sh              # Use production environment
./scripts/generate-ansible-inventory.sh staging     # Use staging environment
```

**Output**: Creates inventory files in `ansible/inventories/`

### 🚀 `run-megalinter-local.sh`

**Purpose**: Run MegaLinter locally for fast pre-commit quality checks
**Features**: Uses efrecon/mega-linter-runner (fast, no Node.js deps, GHCR registry)
**Usage**:

```bash
./scripts/run-megalinter-local.sh              # Basic run
./scripts/run-megalinter-local.sh --fix        # Apply auto-fixes
./scripts/run-megalinter-local.sh --verbose    # Detailed output
```

**Output**: Generates reports in `report/` directory

### 📚 `generate-docs.sh`

**Purpose**: Generate Terraform documentation for all modules and environments
**Requirements**: `terraform-docs` (install via `mise install terraform-docs`)
**Usage**:

```bash
./scripts/generate-docs.sh
```

**Output**: Updates README.md files with Terraform documentation

### 🔄 `restart-vm-ssh.sh`

**Purpose**: Restart jump-man VM with automatic SSH key management
**Features**: Handles host key updates, connectivity testing, health checks
**Usage**:

```bash
./scripts/restart-vm-ssh.sh                     # Use defaults (192.168.10.250, ansible)
VM_IP=192.168.10.100 ./scripts/restart-vm-ssh.sh    # Custom IP
VM_USER=root ./scripts/restart-vm-ssh.sh             # Custom user
MAX_WAIT_TIME=600 ./scripts/restart-vm-ssh.sh        # 10-minute timeout
```

### 🧪 `smoke-test.sh`

**Purpose**: Comprehensive infrastructure validation for jump host
**Tests**: SSH, networking, services, packages, Docker, security
**Usage**:

```bash
./scripts/smoke-test.sh                                      # Use defaults
JUMP_HOST_IP=192.168.10.100 ./scripts/smoke-test.sh         # Custom IP
JUMP_HOST_USER=root ./scripts/smoke-test.sh                 # Custom user
```

**Via mise**: `mise run smoke-test`

## Quick Reference

| Task                     | Command                                                          |
| ------------------------ | ---------------------------------------------------------------- |
| Deploy infrastructure    | `terraform apply` (in `infrastructure/environments/production/`) |
| Run full validation      | `mise run smoke-test`                                            |
| Quick connectivity test  | `mise run smoke-test-quick`                                      |
| Restart VM safely        | `./scripts/restart-vm-ssh.sh`                                    |
| Generate docs            | `./scripts/generate-docs.sh`                                     |
| Create Ansible inventory | `./scripts/generate-ansible-inventory.sh`                        |
| Find code TODOs          | `./scripts/find-tags.sh`                                         |

## Environment Variables

| Variable         | Default          | Description                  |
| ---------------- | ---------------- | ---------------------------- |
| `VM_IP`          | `192.168.10.250` | Jump host IP address         |
| `VM_USER`        | `ansible`        | SSH user for VM access       |
| `JUMP_HOST_IP`   | `192.168.10.250` | Target IP for smoke tests    |
| `JUMP_HOST_USER` | `ansible`        | SSH user for smoke tests     |
| `MAX_WAIT_TIME`  | `300`            | VM restart timeout (seconds) |

## Common Workflows

### After Infrastructure Changes

```bash
cd infrastructure/environments/production
terraform apply
./scripts/smoke-test.sh
```

### After VM Recreation

```bash
./scripts/restart-vm-ssh.sh
mise run smoke-test
```

### Documentation Update

```bash
./scripts/generate-docs.sh
git add . && git commit -m "docs: update Terraform documentation"
```

### Pre-deployment Check

```bash
./scripts/find-tags.sh
./scripts/generate-ansible-inventory.sh
mise run smoke-test
```

---

**💡 Tip**: All scripts include help text and error handling. Run with `-h` or `--help` for detailed usage information where supported.
