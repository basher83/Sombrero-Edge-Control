---
description: Create a new task in the task management system
argument-hint: [Task category] [Task description]
---

# Create Task

Create a new task in the task management system by copying the template and filling out the details based on the provided context.

## Core Development Philosophy

When creating tasks, follow these principles to maintain simplicity and focus:

### KISS (Keep It Simple, Silly)

- **Simplicity First**: Choose straightforward solutions over complex ones whenever possible
- **Single Responsibility**: Each task should have one clear purpose and objective
- **Break Down Complexity**: If a task seems complex, break it into smaller, focused tasks
- **Clear Implementation**: Keep implementation steps concise and actionable

### YAGNI (You Aren't Gonna Need It)

- **Essential Only**: Implement features only when they are needed, not when you anticipate they might be useful
- **Avoid Speculation**: Don't add functionality "just in case" - wait until there's a clear requirement
- **MVP Focus**: For MVP projects, focus on core functionality that validates the hypothesis
- **Progressive Enhancement**: Add complexity only after proving simpler solutions won't work

## Process

### 1. Determine Task Details

- **Category**: @1
- **Description**: @2
- **ID**: Use a one up sequential number for the chosen category by reviewing current tasks in @tasks/INDEX.md
- **Priority**: Assign one of the following priority levels based on your assesment of the task's importance: P0 (critical), P1 (important), or P2 (nice-to-have)

### 2. Create Task File

Copy the template and create a new task file:

```bash
# Example: Create a new pipeline separation task
mkdir -p docs/project/tasks/pipeline-separation
cp docs/project/tasks/template.md \
   docs/project/tasks/pipeline-separation/SEP-006-new-task.md
```

### 3. Fill Out Task Template

Edit the new task file with:

- **Task ID**: FEAT-001 (or appropriate category/ID)
- **Description**: Brief, specific description
- **Objective**: What needs to be accomplished and why (focus on essential functionality)
- **Prerequisites**: Any conditions that must be met first
- **Implementation Steps**: Detailed step-by-step instructions (keep simple and focused)
- **Success Criteria**: Measurable validation points (avoid over-engineering)
- **Validation**: Commands to verify completion (use existing tools when possible)
- **Dependencies**: Any task IDs this depends on

### 4. Update Task Tracker

Add the new task to `docs/project/tasks/INDEX.md`:

- Add to appropriate phase table
- Update task count and completion percentage
- Add to dependency graph if needed
- Update time estimates

## Task Categories

### SEP (Pipeline Separation)

- Packer template simplification and minimalization
- Terraform configuration decoupling from Packer
- Ansible role separation and consolidation
- Pipeline integration and handoffs between tools

### ANS (Ansible Configuration)

- Ansible playbook and role development
- Configuration management improvements
- Infrastructure automation enhancements
- Ansible collection management

### INF (Infrastructure)

- Infrastructure optimization and improvements
- Tool upgrades and modernization
- Performance enhancements
- Resource efficiency improvements

### DOCS (Documentation)

- Architecture decision records (ADRs)
- Implementation guides and procedures
- Infrastructure documentation
- Deployment and operational guides

### TEST (Testing)

- Infrastructure testing implementation
- Ansible role testing with Molecule
- Integration testing between tools
- Validation and verification procedures

### SEC (Security)

- Infrastructure security hardening
- Ansible role security improvements
- Network and access security
- Security audit and compliance fixes

## Best Practices

### Task Sizing & Complexity

- **Keep tasks small**: Aim for 1-4 hours of work per task (KISS principle)
- **Single responsibility**: Each task should have one clear objective
- **Break down complexity**: If a task exceeds 4 hours, split it into smaller tasks
- **MVP focus**: For learning/validation projects, prioritize essential functionality

### Implementation Guidance

- **Be specific**: Include concrete steps and validation criteria
- **Clear success criteria**: Define what "done" looks like
- **Include validation commands**: Specify exact commands to verify completion
- **Avoid over-engineering**: Don't add "nice-to-have" features to core tasks
- **Update dependencies**: Mark tasks as blocked by dependencies if needed

### Quality Assurance

- **Testable tasks**: Ensure each task can be validated independently
- **Clear validation**: Define specific commands or tests to verify completion
- **Documentation**: Include links to relevant docs or ADRs when needed
- **Progressive enhancement**: Add complexity only after basic functionality works

## KISS/YAGNI Task Creation Guidelines

### Decision Framework

Before creating a task, apply these principles:

1. **Essential vs. Nice-to-Have**: Is this functionality required for pipeline separation or can it wait?
2. **Simple vs. Complex**: Can I achieve the objective with existing Packer/Terraform/Ansible tools?
3. **Existing Tools**: Can I use standard Ansible roles or Terraform modules rather than building from scratch?
4. **Task Size**: Can this be completed in 1-4 hours, or should it be broken down?

### Task Complexity Assessment

- **✅ Good Task**: "Create minimal Packer template with Ubuntu base OS only"
- **❌ Over-Engineered**: "Implement complex multi-stage Packer build with custom kernel compilation and proprietary software installation"

## Example Task Creation

For a typical infrastructure automation task:

```bash
# 1. Create task file
cp template.md pipeline-separation/SEP-006-performance-validation.md

# 2. Edit with specific details
# Task: Performance Validation
# Priority: P2
# Implementation Steps:
# - Benchmark current Packer build times
# - Test Terraform deployment speed
# - Validate Ansible playbook execution time
# - Compare against success criteria
# - Document performance improvements
# Validation: time packer build && terraform plan && ansible-playbook --check
```
