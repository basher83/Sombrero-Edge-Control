# Ansible Collection Research Strategy

## Overview

This document outlines the research-first approach for the Ansible refactor, leveraging the **ansible-research subagent** to discover, evaluate, and integrate existing Ansible collections before building custom roles.

## Why Research First?

Building custom Ansible roles without researching existing solutions leads to:

- **Reinventing the wheel** - Missing production-ready solutions
- **Missing best practices** - Not learning from community patterns
- **Technical debt** - Creating maintenance burden for solved problems
- **Quality issues** - Missing edge cases already handled by mature collections

## The ansible-research Subagent

### Capabilities

The ansible-research subagent specializes in:

- Discovering official and community Ansible collections on GitHub
- Evaluating collection quality using a 100-point scoring system
- Analyzing repository health, code quality, and community engagement
- Providing integration recommendations based on quality tiers

### Quality Scoring System

Collections are evaluated on four dimensions (25 points each):

1. **Repository Health** (25 points)
   - Activity level (commits, releases)
   - Star count and community interest
   - Release frequency and versioning

2. **Code Quality** (25 points)
   - Testing infrastructure (Molecule, CI/CD)
   - Documentation completeness
   - Code organization and standards

3. **Module Implementation** (25 points)
   - Idempotency patterns
   - Error handling
   - Input validation

4. **Community Engagement** (25 points)
   - Contributor count
   - Issue response times
   - Pull request activity

### Quality Tiers

- **Tier 1 (80-100 points)**: Production-ready, use directly
- **Tier 2 (60-79 points)**: Good quality, suitable with testing
- **Tier 3 (40-59 points)**: Use with caution, may need customization
- **Tier 4 (Below 40)**: Not recommended, build custom

## Research Process for Each Role

### Step 1: Discovery Phase

For each planned role, invoke the ansible-research subagent:

```bash
# Pattern: "discover [technology] ansible collections"
# Examples:
"discover proxmox ansible collections"
"discover docker ansible collections"
"discover terraform ansible collections"
```

### Step 2: Quality Assessment

For promising collections found:

```bash
# Pattern: "analyze [collection-name] collection"
# Examples:
"analyze community.docker collection"
"analyze community.general collection"
"analyze cloud.terraform collection"
```

### Step 3: Integration Decision

Based on quality scores, decide the approach:

| Score | Decision | Action |
|-------|----------|--------|
| 80-100 | Use directly | Add as dependency in requirements.yml |
| 60-79 | Use with caution | Test thoroughly, may fork if needed |
| 40-59 | Reference only | Study patterns, build custom |
| <40 | Avoid | Build custom from scratch |

### Step 4: Documentation

Document findings in each role's README:

```markdown
## Research Findings

### Collections Evaluated
- **community.docker** (Score: 85/100) - Production-ready Docker management
- **example.docker** (Score: 45/100) - Outdated, not maintained

### Decision
Using community.docker collection as dependency

### Reference Implementations
- [Link to good pattern example]
- [Link to module we're emulating]

### Custom Additions
- Additional validation for our use case
- Integration with our monitoring
```

## Role-Specific Research Strategies

### proxmox_validation

**Research Focus**:

- Proxmox API interaction patterns
- VM template validation approaches
- Resource availability checking

**Expected Collections**:

- `community.general` (contains proxmox modules)
- Third-party Proxmox-specific collections

**Key Questions**:

- How do existing collections handle API authentication?
- What validation patterns are used?
- Are there idempotency considerations?

### vm_smoke_tests

**Research Focus**:

- Testing and assertion patterns
- System validation approaches
- Service health checking

**Expected Collections**:

- `ansible.builtin` (core testing modules)
- `community.general` (extended testing)

**Key Questions**:

- What assertion modules are available?
- How to structure comprehensive tests?
- Best practices for test reporting?

### docker_validation

**Research Focus**:

- Docker service management
- Container lifecycle operations
- Docker Compose integration

**Expected Collections**:

- `community.docker` (official Docker collection)
- `community.general` (Docker modules)

**Key Questions**:

- How mature is community.docker?
- What's the module coverage?
- Integration with Docker Compose?

### vm_diagnostics

**Research Focus**:

- Log collection patterns
- System information gathering
- Troubleshooting automation

**Expected Collections**:

- Various collections with diagnostic patterns
- Logging and monitoring collections

**Key Questions**:

- How to efficiently collect logs?
- Patterns for system diagnostics?
- Error reporting best practices?

### vm_lifecycle

**Research Focus**:

- Infrastructure state management
- Terraform integration patterns
- Cleanup and rollback procedures

**Expected Collections**:

- `cloud.terraform` (Terraform integration)
- Infrastructure management collections

**Key Questions**:

- How to manage Terraform state from Ansible?
- Rollback patterns and safety?
- State synchronization approaches?

### terraform_outputs

**Research Focus**:

- Dynamic inventory generation
- Terraform state parsing
- Inventory plugin patterns

**Expected Collections**:

- `cloud.terraform` (inventory plugin)
- Dynamic inventory collections

**Key Questions**:

- Best practices for dynamic inventory?
- How to handle complex Terraform outputs?
- Caching strategies?

## Research Workflow Example

Here's a complete example for the docker_validation role:

```bash
# 1. Initial discovery
"Use ansible-research to discover docker ansible collections"

# Output: Found community.docker (85/100), ansible.docker (deprecated), example.docker (45/100)

# 2. Deep analysis of top candidate
"Use ansible-research to analyze community.docker collection"

# Output:
# - Repository Health: 22/25 (very active)
# - Code Quality: 23/25 (excellent tests, docs)
# - Implementation: 20/25 (good patterns)
# - Community: 20/25 (active maintainers)
# Total: 85/100 - Tier 1 (Production Ready)

# 3. Decision: Use community.docker as dependency

# 4. Implementation:
# - Add to requirements.yml
# - Create thin wrapper role
# - Add our specific validations
```

## Benefits of Research-First Approach

1. **Time Savings**: Don't rebuild existing solutions
2. **Quality**: Leverage battle-tested code
3. **Learning**: Understand community patterns
4. **Maintenance**: Reduce custom code burden
5. **Standards**: Follow established practices

## Red Flags to Watch For

When researching collections, avoid those with:

- No commits in 6+ months
- Single maintainer/contributor
- No testing infrastructure
- Poor or missing documentation
- Unresponsive to issues (>90 days)
- No releases or tags
- Security vulnerabilities

## Integration Patterns

### Pattern 1: Direct Dependency

For Tier 1 collections (80-100 points):

```yaml
# requirements.yml
collections:
  - name: community.docker
    version: ">=3.0.0"
```

### Pattern 2: Fork and Customize

For Tier 2 collections needing modifications:

```bash
# Fork to organization
# Add customizations
# Reference fork in requirements.yml
```

### Pattern 3: Reference Implementation

For lower tier collections:

```bash
# Study the code
# Extract patterns
# Build custom with improvements
# Credit original in documentation
```

## Tracking Research Results

Create a research summary document:

```markdown
# docs/planning/ansible-refactor/research-results.md

## Research Summary

| Role | Collections Evaluated | Selected | Score | Strategy |
|------|----------------------|----------|-------|----------|
| proxmox_validation | community.general | custom | 65/100 | Reference |
| docker_validation | community.docker | community.docker | 85/100 | Dependency |
| vm_smoke_tests | ansible.builtin | ansible.builtin | 95/100 | Dependency |

## Detailed Findings
[Complete research reports from ansible-research subagent]
```

## Success Metrics

Research is successful when:

- [ ] All roles have been researched before implementation
- [ ] Quality scores documented for all evaluated collections
- [ ] Integration decisions justified based on scores
- [ ] Reference implementations identified
- [ ] Dependencies properly managed

## Next Steps

1. Begin research for each role using ansible-research subagent
2. Document findings in research-results.md
3. Update role specifications with research outcomes
4. Proceed with implementation based on research
5. Credit and reference sources appropriately
