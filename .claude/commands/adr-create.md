---
allowed-tools: Bash(date:*), Read, Write
description: Create a new Architectural Decision Record (ADR) following project conventions
argument-hint: [ADR title or decision topic]
---

# Create ADR

Create a new Architectural Decision Record (ADR) following the project's established conventions and format for @$ARGUMENTS

## Instructions

- **IMPORTANT: Always use the correct date format (YYYYMMDD) from `date +%Y%m%d`**
- **IMPORTANT: Follow the exact naming convention: `<YYYYMMDD>-<descriptive-title>.md`**
- **IMPORTANT: Status should typically be "proposed" for new ADRs**

## Process

1. Get the current date for the filename
2. Review existing ADRs for format and style consistency in @docs/project-management/decisions/
3. Create the ADR with proper structure by copying @docs/project-management/decisions/template.md
4. Ensure tags are relevant to the decision
5. Update the INDEX.md file with the new ADR

## Execute

- !`date +%Y%m%d` to get the current date
- Review @docs/project-management/decisions/template.md for the exact format and optional sections
- Review recent ADRs in @docs/project-management/decisions/ for format examples

## Common ADR Topics in This Project

- Infrastructure decisions (Terraform, Ansible, Packer)
- Tool configurations (Renovate, MegaLinter, mise)
- Architecture patterns (module structure, deployment pipeline)
- Security and compliance decisions
- Development workflow improvements
