# Ansible-First Infrastructure Refactor

## Overview

This directory contains the comprehensive planning documentation for refactoring the Sombrero Edge Control deployment pipeline from shell-based operations to an Ansible role-first architecture.

## Documents

### Core Planning
1. **[refactor-plan.md](./refactor-plan.md)** - Complete implementation plan with phases, timeline, and success criteria
2. **[migration-strategy.md](./migration-strategy.md)** - Step-by-step migration from shell scripts to Ansible roles

### Technical Specifications
3. **[role-specifications.md](./role-specifications.md)** - Detailed specifications for each Ansible role
4. **[research-strategy.md](./research-strategy.md)** - Research-first approach using ansible-research subagent

### Implementation Details
5. **[mise-integration.md](./mise-integration.md)** - Tool management and task automation via mise
6. **[requirements-ansible.txt](./requirements-ansible.txt)** - Python dependencies for Ansible development

## Quick Start

### For Reviewers
1. Start with [refactor-plan.md](./refactor-plan.md) for the big picture
2. Review [research-strategy.md](./research-strategy.md) to understand the research-first approach
3. Check [role-specifications.md](./role-specifications.md) for implementation details

### For Implementers
1. Read [research-strategy.md](./research-strategy.md) before creating any role
2. Follow [mise-integration.md](./mise-integration.md) to set up development environment
3. Use [migration-strategy.md](./migration-strategy.md) for the transition plan

## Key Principles

1. **Research First**: Use ansible-research subagent before implementing any role
2. **Role-Based Architecture**: All operations as reusable Ansible roles
3. **Zero Direct SSH**: No SSH commands after environment setup
4. **Tool Consistency**: Use mise for tool management, uv for Python packages
5. **Incremental Migration**: Parallel operation during transition

## Timeline

- **Week 1** (Jan 6-8): Planning & Documentation ✅
- **Week 2** (Jan 9-15): Role Development
- **Week 3** (Jan 16-22): Playbook & Integration
- **Week 4** (Jan 23-25): Migration & Testing
- **Week 5** (Jan 26-31): Production Rollout

## Status

**Current Phase**: Planning & Documentation (Complete)
**Next Phase**: Role Development (Pending approval)

## Research-First Workflow

Before implementing any role:

```bash
# 1. Discover existing solutions
"Use ansible-research to discover [technology] ansible collections"

# 2. Evaluate quality (100-point scoring)
"Use ansible-research to analyze [collection-name] collection"

# 3. Make integration decision based on score:
# - 80-100: Use as dependency
# - 60-79: Test and possibly fork
# - 40-59: Reference for patterns
# - <40: Build custom

# 4. Document findings in role README
```

## Development Setup

```bash
# 1. Install mise tools
mise install

# 2. Setup Python environment for Ansible development
uv venv
source .venv/bin/activate
uv pip install -r docs/planning/ansible-refactor/requirements-ansible.txt

# 3. Verify setup
ansible --version
molecule --version
ansible-lint --version
```

## Success Criteria

- [ ] Zero SSH commands in operational runbooks
- [ ] All smoke tests converted to Ansible roles
- [ ] 100% idempotent operations
- [ ] Molecule tests for each role
- [ ] Performance maintained or improved
- [ ] Research completed for all roles

## Questions or Feedback?

Please review the planning documents and provide feedback on:
- Timeline feasibility
- Role specifications completeness
- Research approach
- Migration strategy risks
- Tool integration approach
