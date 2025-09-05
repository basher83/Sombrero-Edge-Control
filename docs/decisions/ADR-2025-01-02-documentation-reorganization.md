# ADR-2025-01-02: Documentation Directory Structure Reorganization

![Status](https://img.shields.io/badge/Status-Accepted-green)
![Date](https://img.shields.io/badge/Date-2025--01--02-lightgrey)
![GitHub last commit](https://img.shields.io/github/last-commit/basher83/Sombrero-Edge-Control?path=docs%2Fdecisions%2FADR-2025-01-02-documentation-reorganization.md&display_timestamp=author&style=plastic&logo=github)

## Status

Proposed | **Accepted** | Superseded | Deprecated

## Context

The documentation directory (`docs/`) has grown significantly with 13+ documentation files, making it increasingly difficult to:

- Find relevant information quickly
- Maintain organization as new documents are added
- Understand the relationship between different types of documentation
- Onboard new team members who need to locate specific guides

The current flat structure was becoming unwieldy and didn't provide clear categorization for different user roles (developers, operations, project managers) or functional areas (deployment, development, infrastructure).

## Decision

Reorganize the documentation into logical subdirectories based on functional areas and user roles:

- `deployment/` - Core deployment pipeline and operational procedures
- `development/` - Development workflow, tooling, and local setup
- `infrastructure/` - Infrastructure-specific configuration and optimization
- `project/` - Project planning and management documentation
- `decisions/` - Architectural Decision Records (existing, preserved)
- `troubleshooting/` - Issue resolution guides (existing, preserved)

## Consequences

### Positive

- **Improved discoverability**: Team members can quickly find relevant documentation by functional area
- **Scalable structure**: Each subdirectory can grow independently without cluttering the main docs directory
- **Role-based organization**: Different user types (developers, ops, project managers) can navigate to relevant sections
- **Better maintenance**: Easier to maintain and update documentation within logical groupings
- **Enhanced README**: Comprehensive navigation guide helps new team members get oriented quickly
- **Clear separation of concerns**: Deployment, development, and infrastructure docs are logically separated

### Negative

- **Learning curve**: Team members need to adjust to the new structure and remember directory locations
- **Internal link updates**: Existing internal references needed updating to reflect new file locations
- **Initial disruption**: Short-term confusion during transition period

### Risks

- **Broken external links**: External references to documentation might break if not updated
- **Discovery issues**: Some team members might not find documentation if they don't check the README
- **Maintenance overhead**: Need to ensure new documentation follows the established directory structure

## Alternatives Considered

### Alternative 1: Flat Structure with Naming Convention

- Use consistent file naming prefixes (e.g., `deployment-`, `dev-`, `infra-`)
- Keep all files in the root docs directory
- **Why not chosen**: Doesn't provide visual separation, still results in cluttered directory listing, harder to browse related documents

### Alternative 2: Topic-Based Organization

- Organize by topics rather than functional areas (e.g., `packer/`, `terraform/`, `ansible/`, `ci-cd/`)
- **Why not chosen**: Mixes concerns across different user roles, harder for specific team members to find what they need, less intuitive for cross-cutting concerns

## Implementation

Key steps to implement this decision:

1. **Create directory structure**: `mkdir -p deployment development infrastructure project`
2. **Move files to appropriate directories**:
   - Deployment files → `deployment/`
   - Development tooling → `development/`
   - Infrastructure config → `infrastructure/`
   - Project planning → `project/`
3. **Update internal links**: Fix cross-references between moved documents
4. **Create comprehensive README**: Add navigation guide and directory overview
5. **Update external references**: Ensure any external links to docs are updated

### Files Moved:

**deployment/:**
- `pipeline-enhancements-summary.md`
- `ci-cd-pipeline-workflow.md`
- `deployment-checklist.md`
- `deployment-process.md`
- `smoke-testing-implementation.md`

**development/:**
- `act-configuration.md`
- `ci-local-testing.md`
- `code-formatting-and-linting.md`
- `mise-configuration.md`

**infrastructure/:**
- `infisical-setup.md`
- `terraform-optimization.md`

**project/:**
- `PRP/` (moved from root)

## References

- [Documentation README](../README.md) - Navigation guide for the new structure
- [CHANGELOG.md](../../CHANGELOG.md) - Version 1.1.0 release notes documenting this change
- [ADR Template](../ADR-TEMPLATE.md) - Template used for this ADR
