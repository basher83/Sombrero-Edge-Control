---
description: Execute a task from the task management system
argument-hint: [Task file path]
---

# Execute Task

Implement a task from the task management system using the appropriate tools (Packer, Terraform, or Ansible).

## Task File

Task file path will be provided as argument, e.g., `docs/project/tasks/pipeline-separation/SEP-001-*.md`

- @$ARGUMENTS

## Task Types

The repository uses a structured task management system with two categories:

### SEP Tasks (Pipeline Separation)
- **Location**: `docs/project/tasks/pipeline-separation/SEP-*.md`
- **Purpose**: Refactor infrastructure pipeline for tool independence
- **Tools**: Packer, Terraform
- **Examples**: SEP-001 (minimal Packer), SEP-002 (simplify cloud-init)

### ANS Tasks (Ansible Configuration)
- **Location**: `docs/project/tasks/ansible-configuration/ANS-*.md`
- **Purpose**: Configuration management for the jump host
- **Tool**: Ansible
- **Examples**: ANS-001 (bootstrap), ANS-002 (Docker installation)

## Project Context

This is an Infrastructure-as-Code pipeline repository for deploying a jump host VM on Proxmox:

- **Target VM**: "jump-man" at 192.168.10.250
- **Node**: lloyd (Proxmox host)
- **Pipeline**: Packer → Terraform → Ansible (three-stage deployment)
- **Current Status**: Pipeline separation refactor in progress
- **Task Tracker**: See `docs/project/tasks/INDEX.md` for overall progress

## Tool-Specific Patterns

### Packer (SEP-001, etc.)
```bash
cd packer

# Validation
packer validate -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl

# Execution
packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl
```

### Terraform (SEP-002, SEP-004, etc.)
```bash
cd infrastructure/environments/production

# MANDATORY: Always run tflint first
tflint --init
tflint

# Planning and execution
terraform plan
terraform apply
```

### Ansible (ANS-001 to ANS-005)
```bash
cd ansible_collections/basher83/automation_server

# MANDATORY: Always run ansible-lint first
ansible-lint playbooks/<playbook>.yml
ansible-lint roles/<role>/

# Syntax check
ansible-playbook -i inventory/ansible_inventory.json playbooks/<playbook>.yml --syntax-check

# Execution
ansible-playbook -i inventory/ansible_inventory.json playbooks/<playbook>.yml
```

## Execution Process

### 1. Load Task
- Read the task file from @$ARGUMENTS
- Identify task type from ID (SEP = pipeline, ANS = Ansible)
- Review prerequisites and dependencies
- Check task status in `docs/project/tasks/INDEX.md`

### 2. Pre-flight Checks

**For SEP Tasks:**
- Verify tool availability: `packer version` or `terraform version`
- Check for required files (templates, variables, etc.)
- Review related documentation in `docs/planning/` or `docs/decisions/`

**For ANS Tasks:**
- Verify Ansible collection exists: `ls ansible_collections/basher83/automation_server/`
- Check inventory exists: `test -f ansible_inventory.json`
- Ensure dependencies from previous ANS tasks are complete

**All Tasks:**
- Use TodoWrite tool to create implementation checklist
- Break complex tasks into manageable steps

### 3. Implementation

**CRITICAL: No Hardcoded Values**
```yaml
# ❌ NEVER hardcode IPs or hostnames
vars:
  server: "192.168.10.250"  # BAD

# ✅ ALWAYS use variables or discovery
vars:
  server: "{{ vm_ip_address }}"  # GOOD
```

**Follow Task Structure:**
1. Complete all implementation steps in order
2. Run validation after each major change
3. Update task status to "🚧 In Progress" in the task file

### 4. Validation

**Tool-Specific Requirements:**

| Tool | Mandatory Validation | Command |
|------|---------------------|---------|
| Packer | Template validation | `packer validate` |
| Terraform | Linting | `tflint --init && tflint` |
| Ansible | Linting + Syntax | `ansible-lint && ansible-playbook --syntax-check` |

**Common Issues:**
- Terraform: Missing `tflint --init` causes plugin errors
- Ansible: Missing collection causes module not found
- All: Hardcoded IPs fail validation

### 5. Complete Task

1. Verify all success criteria from task file are met
2. Run final validation suite
3. Update task status in:
   - Task file header (Status: ✅ Complete)
   - `docs/project/tasks/INDEX.md` (update table and percentage)
4. Check if any dependent tasks are now unblocked
5. Report completion with summary of changes

## Directory Structure

```
.
├── packer/                                  # Packer templates (SEP-001)
│   ├── ubuntu-server-minimal.pkr.hcl
│   └── variables.pkrvars.hcl
├── infrastructure/
│   ├── modules/vm/                         # Reusable Terraform modules
│   └── environments/production/            # Production config (SEP-002, SEP-004)
│       ├── main.tf
│       └── cloud-init.jump-man.yaml
├── ansible_collections/basher83/
│   └── automation_server/                  # Ansible collection (ANS tasks)
│       ├── playbooks/
│       ├── roles/
│       └── inventory/
└── docs/project/tasks/                     # Task management system
    ├── INDEX.md                            # Task tracker
    ├── template.md                         # Task template
    ├── pipeline-separation/                # SEP tasks
    └── ansible-configuration/              # ANS tasks
```

## Quick Reference

### Status Indicators
- 🔄 Ready - Can start immediately
- ⏸️ Blocked - Waiting on dependencies
- 🚧 In Progress - Currently active
- ✅ Complete - Finished and validated
- ❌ Failed - Encountered issues

### Priority Levels
- P0 - Critical path, blocks other work
- P1 - Important functionality
- P2 - Nice to have, optimization

### Task ID Format
- SEP-XXX - Pipeline separation tasks
- ANS-XXX - Ansible configuration tasks

## Notes

- Always use the TodoWrite tool to track your implementation progress
- Update task status immediately when starting/completing work
- If blocked, document the reason in the task file
- Reference the task file throughout implementation to ensure all requirements are met
