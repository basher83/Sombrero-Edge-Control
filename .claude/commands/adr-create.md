---
allowed-tools: Bash(date:*), Read, Write
description: Create a new Architectural Decision Record (ADR) following project conventions
argument-hint: [ADR title or decision topic]
---

# Create ADR

Create a new Architectural Decision Record (ADR) following the project's established conventions and format for @$ARGUMENTS

## Instructions

- **IMPORTANT: Always use the correct date format (YYYYMMDD) from `date +%Y%m%d`**
- **IMPORTANT: Follow the exact naming convention: `YYYYMMDD-descriptive-title.md`**
- **IMPORTANT: Use the simplified format from existing ADRs, not the full template**
- **IMPORTANT: Status should typically be "proposed" for new ADRs**

## Process

1. Get the current date for the filename
2. Review existing ADRs for format and style consistency in @docs/decisions/
3. Create the ADR with proper structure by copying @docs/decisions/template.md
4. Ensure tags are relevant to the decision

## Execute

- `date +%Y%m%d` to get the current date
- Review recent ADRs in @docs/decisions/ for format examples

## Template Structure

The ADR should follow this structure:

```markdown
# [Clear, Action-Oriented Title]

- Status: proposed
- Date: YYYY-MM-DD
- Tags: [relevant, tags, here]

## Context and Problem Statement

[2-3 sentences describing the context and problem]

## Decision Outcome

Chosen option: "[Selected approach]", because [brief justification].

### Positive Consequences

1. **[Benefit Category]**
   - Specific benefit 1
   - Specific benefit 2

2. **[Another Benefit Category]**
   - Specific benefit 3
   - Specific benefit 4

### Negative Consequences

1. **[Drawback Category]**
   - Specific drawback 1
   - Specific drawback 2

## Implementation Details

[Optional: Specific implementation notes, configuration examples, or technical details]

## Links

- [Related ADRs or documentation]
```

## Common ADR Topics in This Project

- Infrastructure decisions (Terraform, Ansible, Packer)
- Tool configurations (Renovate, MegaLinter, mise)
- Architecture patterns (module structure, deployment pipeline)
- Security and compliance decisions
- Development workflow improvements
