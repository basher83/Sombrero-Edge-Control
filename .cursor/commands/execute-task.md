---
description: Execute a task from the task management system
argument-hint: [Task file path]
---

# Execute Task

Implement a task from the task management system using Packer, Terraform, and Ansible tools for infrastructure automation.

## Core Development Philosophy

When executing tasks, follow these principles to maintain simplicity and focus:

### KISS (Keep It Simple, Silly)

- **Simplicity First**: Choose straightforward solutions over complex ones whenever possible
- **Single Responsibility**: Focus on the specific task objective, avoid scope creep
- **Progressive Enhancement**: Implement basic functionality first, then enhance if needed
- **Avoid Over-Engineering**: Don't add "nice-to-have" features during task execution

### YAGNI (You Aren't Gonna Need It)

- **Essential Only**: Implement only what the task requires, not what might be useful later
- **Avoid Speculation**: Don't add functionality "just in case" - stick to the task requirements
- **Infrastructure Focus**: Keep changes minimal and testable, focus on core pipeline separation
- **Defer Complexity**: Move advanced features to separate tasks if they aren't essential

## Task File

Task file path will be provided as argument, e.g., `docs/project/tasks/pipeline-separation/SEP-001-minimal-packer-template.md`

- @$ARGUMENTS

## Task Categories

This repository uses a structured task management system specifically for infrastructure automation and pipeline separation:

### Available Categories

- **SEP** - Pipeline separation and tool decoupling tasks
- **ANS** - Ansible configuration and role development
- **INF** - Infrastructure improvements and optimization
- **DOCS** - Documentation and guides
- **TEST** - Testing implementation and validation
- **SEC** - Security improvements and hardening

### Task Location

Tasks are organized by category in subdirectories:

- `docs/project/tasks/[category]/[PREFIX]-XXX-*.md`
- Example: `docs/project/tasks/pipeline-separation/SEP-001-minimal-packer-template.md`

## Project Context

This task system is specifically designed for the Sombrero-Edge-Control infrastructure automation project:

- **Task Tracker**: See `docs/project/tasks/INDEX.md` for overall progress and pipeline separation status
- **Template**: Use `docs/project/tasks/template.md` for creating new tasks
- **Status Tracking**: Tasks use standard status indicators (🔄 Ready, ⏸️ Blocked, 🚧 In Progress, ✅ Complete)
- **Focus Areas**: Pipeline separation (Packer/Terraform/Ansible decoupling), Ansible role development, infrastructure optimization

## Tech Stack Validation Patterns

### Packer (Image Building)

```bash
# Validation
packer validate ubuntu-server-minimal.pkr.hcl    # Validate Packer template
packer build -var-file=variables.pkrvars.hcl     # Build image
packer inspect ubuntu-server-minimal.pkr.hcl    # Inspect template details

# Testing
qm list | grep ubuntu-2404-minimal              # Verify template created in Proxmox
```

### Terraform (Infrastructure as Code)

```bash
# Validation
terraform validate                              # Validate configuration
terraform plan                                 # Preview changes
terraform apply                                # Apply infrastructure changes
tflint                                         # Lint Terraform code

# State management
terraform state list                           # List managed resources
terraform output -json                         # Export outputs for Ansible
```

### Ansible (Configuration Management)

```bash
# Validation
ansible-playbook --syntax-check playbooks/*.yml  # Check playbook syntax
ansible-lint roles/                             # Lint Ansible roles
ansible-playbook --check playbooks/*.yml        # Dry run playbooks

# Testing
molecule test                                  # Test Ansible roles with Molecule
ansible-playbook -i inventory.json playbooks/*.yml  # Execute playbooks
```

### Infrastructure Testing

```bash
# Packer/Terraform/Ansible Integration
cd packer && packer build ubuntu-server-minimal.pkr.hcl
cd ../infrastructure && terraform apply -var="template_id=8025"
cd ../ansible_collections/basher83/automation_server
ansible-playbook -i inventory.json playbooks/site.yml
```

## Execution Process

### 1. Load Task

- Read the task file from @$ARGUMENTS
- Identify task category from ID prefix (SEP, ANS, INF, DOCS, TEST, SEC)
- Review prerequisites and dependencies
- Check task status in `docs/project/tasks/INDEX.md`

### 2. Pre-flight Checks

**For Pipeline Separation Tasks (SEP):**

- Verify Packer/Terraform/Ansible environments are set up
- Check for required tools (packer, terraform, ansible)
- Ensure access to Proxmox cluster and credentials
- Review related ADRs and planning documents in `docs/decisions/` and `docs/planning/`

**For Ansible Configuration Tasks (ANS):**

- Verify Ansible environment and collections are available
- Check for required roles and dependencies
- Ensure inventory and playbook access
- Review Ansible documentation in `docs/ai_docs/`

**For All Task Types:**

- Use TodoWrite tool to create implementation checklist
- Break complex tasks into manageable steps
- Verify access to required systems and permissions
- Check for any blocking dependencies in `docs/project/tasks/INDEX.md`

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

**KISS/YAGNI Implementation Guidelines:**

- **Stick to the Plan**: Follow the task implementation steps exactly, avoid adding extra features
- **Simple Solutions**: Choose the most straightforward approach that meets the requirements
- **No Scope Creep**: If you discover additional functionality needed, create a separate task for it
- **Essential Features Only**: Don't implement "nice-to-have" features during task execution
- **Progressive Enhancement**: Implement basic functionality first, then enhance only if required

**Follow Task Structure:**

1. Complete all implementation steps in order
2. Run validation after each major change
3. Update task status to "🚧 In Progress" in the task file
4. **Resist Temptation**: If you find yourself adding "just one more thing", stop and create a new task instead

### 4. Validation

**Tech Stack Validation:**

Validation commands should be customized for the infrastructure automation tech stack:

| Tech Stack  | Common Validation Commands                           | Notes                                  |
| ----------- | ---------------------------------------------------- | -------------------------------------- |
| Packer      | `packer validate`, `packer build`, `packer inspect`  | Image building and template validation |
| Terraform   | `terraform validate`, `terraform plan`, `tflint`     | Infrastructure as Code validation      |
| Ansible     | `ansible-playbook --syntax-check`, `ansible-lint`    | Configuration management validation    |
| Integration | `terraform output -json`, `ansible-playbook --check` | Cross-tool validation and dry runs     |

**KISS/YAGNI Validation Approach:**

- **Focus on Essentials**: Run only the validation commands specified in the task
- **Don't Over-Validate**: Avoid adding extra validation steps unless they're critical
- **Simple Success Criteria**: Verify the task objective is met, not perfection
- **Progressive Testing**: Test basic functionality first, then edge cases if needed

**Common Issues:**

- **Build failures**: Check for missing dependencies or syntax errors
- **Test failures**: Verify test setup and mock data
- **Linting errors**: Follow project coding standards
- **Environment issues**: Ensure proper configuration and credentials
- **Scope creep**: If you find yourself doing more than the task requires, stop and reassess

### 5. Complete Task

1. Verify all success criteria from task file are met
2. Run final validation suite
3. Update task status in:
   - Task file header (Status: ✅ Complete)
   - `docs/project/tasks/INDEX.md` (update table and percentage)
4. Check if any dependent tasks are now unblocked
5. Report completion with summary of changes

### KISS/YAGNI Decision Framework

**During Implementation, Ask Yourself:**

1. **Is this part of the original task?**

   - If no → Stop and create a new task for additional work
   - If yes → Proceed with simplest possible solution

2. **Can I achieve this with existing tools?**

   - If yes → Use them (don't reinvent the wheel)
   - If no → Choose the simplest tool that meets the need

3. **What is the minimal viable implementation?**

   - Focus on core functionality that meets the success criteria
   - Add complexity only if the basic solution fails
   - Prefer straightforward solutions over elegant complex ones

4. **Should this be a separate task?**
   - If it will take more than 30 minutes → Create a new task
   - If it's not in the original scope → Create a new task
   - If it's a "nice-to-have" → Definitely create a new task

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

- SEP-XXX - Pipeline separation and tool decoupling tasks
- ANS-XXX - Ansible configuration and role development
- INF-XXX - Infrastructure improvements and optimization
- DOCS-XXX - Documentation and guides
- TEST-XXX - Testing implementation and validation
- SEC-XXX - Security improvements and hardening

## Notes

- Always use the TodoWrite tool to track your implementation progress
- Update task status immediately when starting/completing work
- If blocked, document the reason in the task file
- Reference the task file throughout implementation to ensure all requirements are met

## KISS/YAGNI Implementation Reminders

- **Stick to the task**: Focus only on what's specified in the task file
- **Simple solutions**: Choose the most straightforward approach that works
- **No scope creep**: If you discover additional work needed, create separate tasks
- **Essential functionality**: Don't implement features "just in case"
- **Progressive enhancement**: Start simple, enhance only if required by success criteria
- **Use existing tools**: Don't reinvent the wheel - leverage Packer, Terraform, Ansible as designed
- **Infrastructure focus**: Keep changes minimal and testable, avoid over-engineering

**If you find yourself thinking "this would be nice to add" or "I should make this more robust" - STOP and create a separate task instead.**
