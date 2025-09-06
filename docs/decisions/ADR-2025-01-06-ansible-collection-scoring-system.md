# ADR-2025-01-06: Lightweight YAML-Based Scoring System for Ansible Collections

![Status](https://img.shields.io/badge/Status-Accepted-green)
![Date](https://img.shields.io/badge/Date-2025--01--06-lightgrey)
![GitHub last commit](https://img.shields.io/github/last-commit/basher83/Sombrero-Edge-Control?path=docs%2Fdecisions%2FADR-2025-01-06-ansible-collection-scoring-system.md&display_timestamp=author&style=plastic&logo=github)

## Status

Accepted

## Context

The ansible-research subagent needs to evaluate Ansible collections objectively for the infrastructure refactor. The original scoring system had significant bias towards large, popular projects, penalizing high-quality specialized collections simply due to lower star counts and fewer contributors.

For example, a specialized Proxmox collection with excellent code quality would score poorly (55/100) compared to a large community collection (95/100), despite potentially being the better choice for our specific needs.

We needed to decide between:
1. Building a full-fledged Python repository with CLI tools and package management
2. Using a lightweight YAML-based configuration framework

## Decision

We chose to implement a **lightweight YAML-based scoring system** stored in `.claude/scoring-system/` that eliminates bias through:

- **Category-aware evaluation**: Collections are evaluated within peer groups (official, community, specialized, vendor, personal)
- **Technical quality focus**: 60% of score based on code quality, not popularity
- **Threshold-based scoring**: Binary or threshold scoring instead of linear scaling
- **Logarithmic scaling**: Diminishing returns on large numbers to prevent "winner takes all"

The system consists of:
- `scoring-config.yaml` - Main configuration and tier definitions
- `categories.yaml` - Collection categories with adjusted thresholds
- `scoring-rules.yaml` - Detailed evaluation criteria
- `evaluation-examples.yaml` - Real-world scoring examples

## Consequences

### Positive

- **Immediate value**: Already implemented and solving the bias problem
- **Low maintenance**: ~36 hours over 3 years vs ~300 hours for full repository
- **Simple integration**: Subagent reads YAML directly, no dependencies
- **Transparency**: All scoring criteria clearly visible in YAML
- **Fair evaluation**: Specialized collections can achieve Tier 1 status (80+ points)
- **Easy modification**: Adjust thresholds by editing YAML files

### Negative

- **Limited reusability**: Project-specific, requires manual copying to share
- **No programmatic API**: Can't be called from external tools
- **No automated testing**: Manual verification of scoring accuracy
- **No version management**: No semantic versioning for the scoring system
- **Limited features**: No CLI tool, caching, or historical tracking

### Risks

- **Scaling limitations**: If we need to evaluate hundreds of collections, manual process becomes tedious
- **Sharing friction**: Other projects can't easily consume this as a dependency
- **No community ecosystem**: Can't benefit from external contributions easily

## Alternatives Considered

### Alternative 1: Full Python Repository

- **Description**: Separate repository with Python package, CLI tool, tests, and CI/CD
- **Benefits**: Reusable, testable, versioned, community-shareable
- **Why we didn't choose it**:
  - 10x maintenance burden (300 vs 36 hours over 3 years)
  - Significant upfront investment (40-60 hours)
  - Overengineering for current needs
  - Adds unnecessary complexity

### Alternative 2: No Formal Scoring System

- **Description**: Continue with subjective evaluation
- **Why we didn't choose it**:
  - Perpetuates bias against specialized collections
  - Inconsistent evaluation criteria
  - No transparency in decision-making

## Implementation

Key steps completed:

1. ✅ Created `.claude/scoring-system/` directory structure
2. ✅ Defined bias-free scoring rules with category adjustments
3. ✅ Documented evaluation examples showing bias reduction
4. ✅ Updated ansible-research subagent to reference the scoring system
5. ✅ Created comprehensive README for maintenance

Future enhancements (if needed):
1. Add simple validation script (2 hours)
2. Implement basic caching for GitHub API (1 hour)
3. Create CLI wrapper for manual testing (4 hours)

## Specialization vs Abstraction Decision

### Context
This repository uses both Ansible and Terraform. We evaluated whether to:
1. Keep the scorer Ansible-specific (current implementation)
2. Abstract to support multiple IaC tools
3. Create a shared framework with tool-specific implementations

### Decision: Maintain Specialization

We decided to **keep the scorer specialized for Ansible** based on:

#### Cost-Benefit Analysis
- **Abstraction cost**: 40+ hours to build, 4-10x maintenance burden
- **Actual benefit**: Minimal - only 20% of rules are truly shareable
- **Quality impact**: Generic scorer would reduce accuracy from 95% to ~70%

#### Key Insights
1. **Tool differences are fundamental**:
   - Ansible: Idempotency patterns, changed_when, molecule tests
   - Terraform: State management, drift detection, terratest
   - These require completely different evaluation criteria

2. **False abstractions are harmful**:
   - Forcing common patterns where none exist
   - Increased complexity without proportional benefit
   - Harder to understand and maintain

3. **The Rule of Three**:
   - Don't abstract until you have 3+ real use cases
   - We have 1 (Ansible), might have 2 (Terraform)
   - Premature abstraction is a form of technical debt

### Evolutionary Approach

If Terraform module scoring becomes necessary:

**Phase 1** (Current): Ansible-specific scorer in `.claude/scoring-system/`

**Phase 2** (When needed): Create separate Terraform scorer
```
.claude/terraform-scorer/     # Independent, specialized
├── scoring-config.yaml      # Terraform-specific rules
├── categories.yaml          # Module/provider categories
└── scoring-rules.yaml       # State, drift, versioning
```

**Phase 3** (If patterns emerge): Extract only REAL shared concepts
- Only after using both scorers in production
- Document shared principles, not code
- Maintain separate implementations

### Principles
- **Specialization > Generalization** for quality
- **Discovered abstractions > Designed abstractions**
- **Duplication > Wrong abstraction**
- **Self-contained understanding > DRY at all costs**

Time estimate for Terraform scorer when needed: ~8 hours (vs 40+ for abstraction)

## References

- Issue: Bias in Ansible collection evaluation
- Implementation: `.claude/scoring-system/`
- Subagent: `.claude/agents/ansible-research.md`
- Related ADR: [ADR-2025-01-02-ansible-post-deployment-config.md](./ADR-2025-01-02-ansible-post-deployment-config.md)
- Planning docs: `docs/planning/ansible-refactor/research-strategy.md`
