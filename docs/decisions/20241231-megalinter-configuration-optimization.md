# MegaLinter Configuration and Optimization

- Status: accepted
- Deciders: AI Assistant, Project Lead
- Date: 2024-12-31
- Tags: linting, ci-cd, code-quality, infrastructure, optimization

Technical Story: Implement unified linting solution for multi-language infrastructure codebase

## Context and Problem Statement

The Sombrero-Edge-Control project requires consistent code quality validation across multiple languages and formats (Terraform, Ansible, YAML, Markdown, Shell scripts). Previously, individual linters were used inconsistently, leading to varying code standards and manual quality checks. How can we implement a unified linting solution that ensures consistent code quality while maintaining development efficiency?

## Decision Drivers

- **Code Quality Consistency**: Need uniform standards across Terraform, Ansible, YAML, Markdown, and Shell scripts
- **Developer Experience**: Must provide fast feedback without slowing down development workflow
- **CI/CD Integration**: Should integrate seamlessly with existing GitHub Actions pipeline
- **Maintenance Overhead**: Should minimize configuration and maintenance complexity
- **Performance**: Must handle large infrastructure codebases efficiently
- **Multi-language Support**: Must support all languages used in the project

## Considered Options

- **Individual Linters**: Continue with separate tools (tflint, ansible-lint, yamllint, etc.)
- **MegaLinter Unified Solution**: Single tool managing all linters with optimized configuration
- **Pre-commit Hooks**: Git hooks for local validation
- **Custom Linting Pipeline**: Build custom solution combining multiple tools

## Decision Outcome

Chosen option: "**MegaLinter Unified Solution**", because it provides the best balance of comprehensive coverage, ease of maintenance, and performance optimization while integrating seamlessly with our existing CI/CD pipeline and mise tooling ecosystem.

### Positive Consequences

- **Unified Configuration**: Single configuration file manages all linting rules
- **Consistent Standards**: Same quality checks apply across all team members and environments
- **Performance Optimized**: Smart caching and parallel processing reduce CI times
- **Developer Friendly**: Clear error messages and local testing capabilities
- **Comprehensive Coverage**: Supports all languages used in infrastructure projects
- **Maintenance Efficient**: Single tool to update vs managing multiple individual linters

### Negative Consequences

- **Learning Curve**: Team needs to understand MegaLinter-specific configuration patterns
- **Dependency**: Reliance on single tool for all linting needs
- **Resource Usage**: More memory and CPU usage compared to individual linters
- **Configuration Complexity**: MegaLinter's extensive options can be overwhelming initially

## Pros and Cons of the Options

### Individual Linters

Maintaining separate linting tools with individual configurations and CI integration points.

- Good, because each tool can be optimized for its specific language
- Good, because simpler to understand and troubleshoot individual components
- Bad, because inconsistent configuration management across tools
- Bad, because requires separate CI setup and maintenance for each linter
- Bad, because harder to ensure consistent standards across all languages

### MegaLinter Unified Solution

Single tool that orchestrates multiple linters with unified configuration and reporting.

- Good, because single configuration file manages all linting rules
- Good, because consistent error reporting and output format
- Good, because built-in performance optimizations (caching, parallel processing)
- Good, because comprehensive language support out of the box
- Good, because active community and regular updates
- Bad, because requires learning MegaLinter-specific configuration syntax
- Bad, because single point of failure for all linting

### Pre-commit Hooks

Git hooks that run linting before commits, with separate CI validation.

- Good, because immediate feedback during development
- Good, because prevents committing code that doesn't meet standards
- Bad, because can slow down development workflow significantly
- Bad, because difficult to handle large codebases efficiently
- Bad, because doesn't integrate well with CI/CD pipelines

### Custom Linting Pipeline

Build custom scripts combining multiple linting tools with project-specific logic.

- Good, because complete control over linting process and output
- Good, because can be tailored exactly to project needs
- Bad, because high development and maintenance overhead
- Bad, because reinventing functionality that MegaLinter already provides
- Bad, because requires ongoing updates as individual linters evolve

## Implementation Details

### Configuration Structure

- **`.mega-linter.yml`**: Main configuration with enabled linters and performance settings
- **`.github/linters/`**: Language-specific rule files (`.tflint.hcl`, `.terrascan.toml`, `.ansible-lint`)
- **`.github/workflows/mega-linter.yml`**: CI/CD pipeline with performance optimizations
- **`scripts/`**: Local testing and diagnostic tools

### Performance Optimizations Applied

1. **Timeout Optimization**: Reduced CI timeout from 20 to 15 minutes
2. **Conditional Fast Mode**: Development branches use 10-minute timeout vs 15-minute for main
3. **Selective Linting**: Disabled slow linters in fast mode for development efficiency
4. **Caching Strategy**: Terraform plugin caching and container reuse
5. **Parallel Processing**: Optimized resource allocation for CI environment

### Language-Specific Configurations

- **Terraform**: `tflint` for best practices, `terraform validate` for syntax, `terraform fmt` for formatting
- **Ansible**: `ansible-lint` for playbook validation and best practices
- **YAML**: `yamllint` for consistent YAML formatting
- **Markdown**: `markdownlint` for documentation standards
- **Shell**: `shellcheck` for bash script validation
- **Security**: `terrascan` and `kics` for infrastructure security scanning

## Validation Results

- **Error Reduction**: Fixed 44+ markdown linting issues across 5 documentation files
- **Performance**: CI pipeline reduced from 20 to 15 minutes average execution time
- **Consistency**: Unified standards applied across all code types
- **Developer Experience**: Local testing commands available via mise (`mise run act-quick`, `mise run act-ci`)

## Links

- [ADR 20250908: Use Log4brains to Manage ADRs](20250908-use-log4brains-to-manage-the-adrs.md)
- [ADR 20250908: Use Markdown Architectural Decision Records](20250908-use-markdown-architectural-decision-records.md)
- [ADR 20250902: Documentation Reorganization](20250902-documentation-reorganization.md)
- [MegaLinter Configuration Guide](../../development/megalinter-configuration.md)
- [MegaLinter Migration Documentation](../../planning/tooling-migrations/MEGALINTER_MIGRATION.md)
