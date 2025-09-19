# Task Management System Documentation

## Overview

This task management system provides structured tracking for the Sombrero-Edge-Control pipeline separation refactor and ongoing infrastructure development. It ensures clear visibility of work items, dependencies, and progress across the three-stage pipeline (Packer, Terraform, Ansible).

## Purpose

The task system addresses several critical needs:

- **Visibility**: Clear understanding of what needs to be done and current progress
- **Dependencies**: Explicit tracking of task relationships and blockers
- **Prioritization**: P0/P1/P2 classification for resource allocation
- **Validation**: Success criteria and validation steps for each task
- **Documentation**: Detailed implementation guidance for complex tasks

## Directory Structure

```text
docs/project/tasks/
├── README.md                    # This file - system documentation
├── INDEX.md                     # Active task tracker and progress dashboard
├── template.md                  # Task file template
├── pipeline-separation/         # Pipeline refactoring tasks
│   └── SEP-XXX-*.md            # Separation tasks
└── ansible-configuration/       # Ansible setup tasks
    └── ANS-XXX-*.md            # Ansible tasks
```

## How to Use This System

### 1. Check Current Status

Review `INDEX.md` for:

- Overall project progress percentage
- Current phase and priorities
- Task dependencies and blockers
- Critical path for completion

### 2. Select a Task

Choose tasks marked as 🔄 Ready that match your expertise:

- **SEP** tasks: Pipeline separation and refactoring
- **ANS** tasks: Ansible configuration and roles

### 3. Follow Task Structure

Each task file contains:

- Clear objective and success criteria
- Step-by-step implementation guide
- Validation commands
- Dependencies and prerequisites

## Task File Format

All task files follow the structure defined in [`template.md`](template.md).

See the template file for the exact format and all required sections.

## Status Indicators

- 🔄 **Ready**: Task can be started immediately
- ⏸️ **Blocked**: Waiting on dependencies to complete
- 🚧 **In Progress**: Currently being worked on
- ✅ **Complete**: Task finished and validated
- ❌ **Failed**: Task encountered issues, needs revision

## Priority Levels

- **P0 (Critical)**: Must complete for pipeline to function
- **P1 (Important)**: Significant functionality or improvement
- **P2 (Nice to Have)**: Optimization or enhancement

## Task Categories

### Pipeline Separation (SEP)

Tasks related to achieving tool independence:

- Packer minimalization
- Terraform simplification
- Ansible consolidation
- Pipeline integration

### Ansible Configuration (ANS)

Tasks for configuration management:

- Playbook development
- Role creation
- Testing and validation

## Creating New Tasks

### 1. Determine Task Category

- **SEP**: Pipeline separation and tool decoupling
- **ANS**: Ansible roles and configuration
- Add new categories as needed

### 2. Assign Task ID

Use sequential numbering:

- SEP-001, SEP-002, etc.
- ANS-001, ANS-002, etc.

### 3. Use the Template

Copy `template.md` and fill in all sections:

- Keep descriptions concise and actionable
- Include specific commands and file paths
- Define clear success criteria
- **IMPORTANT**: Run `date +"%Y-%m-%d"` to get current date for Created/Updated fields
- Update the "Updated" field whenever status changes

### 4. Update INDEX.md

Add your task to the appropriate phase table and update:

- Task counts and time estimates
- Dependency graph if needed
- Overall completion percentage

## Best Practices

### Task Sizing

- **Small** (1-2 hours): Single file changes, simple configurations
- **Medium** (3-4 hours): Multi-file changes, new features
- **Large** (5+ hours): Consider breaking into subtasks

### Dependencies

- List explicit task IDs that must complete first
- Use "None" for tasks that can start immediately
- Update blocked tasks when dependencies complete

### Validation

- Include specific commands to verify success
- Reference test files or playbooks
- Document expected output

### Documentation

- Link to relevant ADRs and guides
- Reference external documentation
- Include troubleshooting tips

## Workflow Example

```bash
# 1. Check current status
cat docs/project/tasks/INDEX.md | grep "Ready"

# 2. Select a task
cat docs/project/tasks/pipeline-separation/SEP-001-*.md

# 3. Complete the work
cd packer
packer build ubuntu-minimal.pkr.hcl

# 4. Validate completion
packer validate ubuntu-minimal.pkr.hcl

# 5. Update task status in INDEX.md
# Change status from 🔄 Ready to ✅ Complete
```

## Integration Points

This task system integrates with:

- **[ROADMAP.md](../../ROADMAP.md)**: High-level project phases
- **[Architecture Decisions](../../decisions/)**: Technical choices and rationale
- **[Planning Documents](../../planning/)**: Detailed refactoring strategies
- **[Deployment Guides](../../deployment/)**: Implementation procedures

## Maintenance

- Review task status weekly
- Archive completed phases to `completed/` subdirectory
- Update time estimates based on actual completion
- Add lessons learned to task notes

---

_For current task status and active work items, see [INDEX.md](INDEX.md)_
