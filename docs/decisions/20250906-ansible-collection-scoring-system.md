# Lightweight YAML-Based Scoring System for Ansible Collections

- Status: accepted
- Date: 2025-09-06
- Tags: ansible, scoring, evaluation, yaml

## Context and Problem Statement

The ansible-research subagent needs to evaluate Ansible collections objectively for the infrastructure refactor. The original scoring system had significant bias towards large, popular projects, penalizing high-quality specialized collections simply due to lower star counts and fewer contributors.

For example, a specialized Proxmox collection with excellent code quality would score poorly (55/100) compared to a large community collection (95/100), despite potentially being the better choice for our specific needs.

## Decision Outcome

Chosen option: "Lightweight YAML-based scoring system", because we needed to eliminate bias through category-aware evaluation while keeping the implementation simple and maintainable.

### Positive Consequences

- **Immediate value**: Already implemented and solving the bias problem
- **Low maintenance**: ~36 hours over 3 years vs ~300 hours for full repository
- **Simple integration**: Subagent reads YAML directly, no dependencies
- **Transparency**: All scoring criteria clearly visible in YAML
- **Fair evaluation**: Specialized collections can achieve Tier 1 status (80+ points)
- **Easy modification**: Adjust thresholds by editing YAML files

### Negative Consequences

- **Limited reusability**: Project-specific, requires manual copying to share
- **No programmatic API**: Can't be called from external tools
- **No automated testing**: Manual verification of scoring accuracy
- **No version management**: No semantic versioning for the scoring system
- **Limited features**: No CLI tool, caching, or historical tracking

## Considered Options

### Full Python Repository

**Description**: Separate repository with Python package, CLI tool, tests, and CI/CD

- Good, because: Reusable, testable, versioned, community-shareable
- Good, because: Professional development practices
- Bad, because: 10x maintenance burden (300 vs 36 hours over 3 years)
- Bad, because: Significant upfront investment (40-60 hours)
- Bad, because: Overengineering for current needs

### No Formal Scoring System

**Description**: Continue with subjective evaluation

- Good, because: No development time required
- Good, because: Maximum flexibility in evaluation
- Bad, because: Perpetuates bias against specialized collections
- Bad, because: Inconsistent evaluation criteria
- Bad, because: No transparency in decision-making

## Links

- Implementation: `.claude/scoring-system/`
- Subagent: `.claude/agents/ansible-research.md`
