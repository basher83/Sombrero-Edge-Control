# Documentation

This directory contains comprehensive documentation for the Sombrero-Edge-Control project,
organized by functional areas for easy navigation.

## 📁 Directory Structure

### [deployment/](./deployment/)

Core deployment pipeline documentation and processes.

- **[pipeline-enhancements-summary.md](./deployment/pipeline-enhancements-summary.md)**
  - Summary of recent pipeline enhancements and improvements
- **[ci-cd-pipeline-workflow.md](./deployment/ci-cd-pipeline-workflow.md)**
  - Complete CI/CD pipeline workflow documentation
- **[deployment-checklist.md](./deployment/deployment-checklist.md)**
  - Step-by-step deployment checklist
- **[deployment-process.md](./deployment/deployment-process.md)**
  - General deployment process guide
- **[smoke-testing-implementation.md](./deployment/smoke-testing-implementation.md)**
  - Smoke testing procedures and implementation
- **[terraform-ansible-integration-guide.md](./deployment/terraform-ansible-integration-guide.md)**
  - Integration guide between Terraform and Ansible
- **[wsl-deployment-guide.md](./deployment/wsl-deployment-guide.md)**
  - Windows Subsystem for Linux deployment instructions

### [development/](./development/)

Development workflow, tooling, and local development setup.

- **[act-configuration.md](./development/act-configuration.md)** - GitHub Actions local testing with ACT
- **[ci-local-testing.md](./development/ci-local-testing.md)** - Local CI testing procedures
- **[code-formatting-and-linting.md](./development/code-formatting-and-linting.md)** - Code quality standards and tools
- **[megalinter-configuration.md](./development/megalinter-configuration.md)** - MegaLinter configuration and setup
- **[mise-configuration.md](./development/mise-configuration.md)** - Mise tool version manager setup

### [infrastructure/](./infrastructure/)

Infrastructure-specific configuration and optimization guides.

- **[infisical-setup.md](./infrastructure/infisical-setup.md)** - Infisical secrets management setup
- **[terraform-optimization.md](./infrastructure/terraform-optimization.md)** - Terraform performance optimization

### [decisions/](./decisions/)

Architectural Decision Records (ADRs) documenting important technical decisions.

- **[20240830-separate-files-terraform-injection.md](./decisions/20240830-separate-files-terraform-injection.md)**
  - Decision about separate files for Terraform injection
- **[20240831-docker-iptables-firewall.md](./decisions/20240831-docker-iptables-firewall.md)**
  - Docker iptables firewall configuration decision
- **[20241231-megalinter-configuration-optimization.md](./decisions/20241231-megalinter-configuration-optimization.md)**
  - MegaLinter configuration optimization decisions
- **[20250110-thoughts-directory-knowledge-management.md](./decisions/20250110-thoughts-directory-knowledge-management.md)**
  - Thoughts directory knowledge management strategy
- **[20250902-ansible-post-deployment-config.md](./decisions/20250902-ansible-post-deployment-config.md)**
  - Ansible post-deployment configuration approach
- **[20250902-documentation-reorganization.md](./decisions/20250902-documentation-reorganization.md)**
  - Documentation directory structure reorganization
- **[20250906-ansible-collection-scoring-system.md](./decisions/20250906-ansible-collection-scoring-system.md)**
  - Ansible collection scoring system design
- **[20250906-ansible-roles.md](./decisions/20250906-ansible-roles.md)**
  - Ansible roles architecture and implementation
- **[20250908-use-log4brains-to-manage-the-adrs.md](./decisions/20250908-use-log4brains-to-manage-the-adrs.md)**
  - Using Log4brains for ADR management
- **[20250908-use-markdown-architectural-decision-records.md](./decisions/20250908-use-markdown-architectural-decision-records.md)**
  - Markdown-based ADR system implementation
- **[20250910-ansible-collection-structure.md](./decisions/20250910-ansible-collection-structure.md)**
  - Ansible collection structure and organization
- **[20250910-renovate-configuration-enhancement.md](./decisions/20250910-renovate-configuration-enhancement.md)**
  - Renovate configuration enhancement decisions
- **[index.md](./decisions/index.md)** - Index of all architectural decisions
- **[README.md](./decisions/README.md)** - Decisions directory overview
- **[template.md](./decisions/template.md)** - Template for creating new ADRs

### [troubleshooting/](./troubleshooting/)

Troubleshooting guides and known issue resolutions.

- **[MEGALINTER_REMEDIATION.md](./troubleshooting/MEGALINTER_REMEDIATION.md)**
  - MegaLinter error remediation and fixes
- **[ssh-cloud-init-issues.md](./troubleshooting/ssh-cloud-init-issues.md)**
  - SSH and cloud-init related issues
- **[terraform-proxmox-ssh-issues.md](./troubleshooting/terraform-proxmox-ssh-issues.md)**
  - Terraform and Proxmox SSH connectivity issues

### [planning/](./planning/)

Project planning, architecture decisions, and strategic documentation.

- **[README.md](./planning/README.md)** - Overview of planning documentation
- **[ansible-refactor/](./planning/ansible-refactor/)** - Ansible refactoring and modernization planning
  - **[README.md](./planning/ansible-refactor/README.md)** - Ansible refactor project overview
  - **[migration-strategy.md](./planning/ansible-refactor/migration-strategy.md)**
    - Strategy for migrating existing Ansible configurations
  - **[mise-integration.md](./planning/ansible-refactor/mise-integration.md)**
    - Mise tool integration for Ansible development
  - **[refactor-plan.md](./planning/ansible-refactor/refactor-plan.md)**
    - Detailed refactoring implementation plan
  - **[requirements-ansible.txt](./planning/ansible-refactor/requirements-ansible.txt)**
    - Ansible-specific requirements and dependencies
  - **[research-strategy.md](./planning/ansible-refactor/research-strategy.md)**
    - Research approach for Ansible improvements
  - **[role-specifications.md](./planning/ansible-refactor/role-specifications.md)**
    - Detailed specifications for Ansible roles
- **[thoughts-system-adaptation.md](./planning/thoughts-system-adaptation.md)**
  - Thoughts system adaptation and knowledge management
- **[tooling-migrations/](./planning/tooling-migrations/)** - Tooling migration planning and documentation
  - **[README.md](./planning/tooling-migrations/README.md)** - Overview of tooling migrations
  - **[MEGALINTER_MIGRATION.md](./planning/tooling-migrations/MEGALINTER_MIGRATION.md)**
    - MegaLinter migration guide and implementation

### [ai_docs/](./ai_docs/)

AI and automation tooling documentation.

- **[archon-tools.md](./ai_docs/archon-tools.md)** - Archon AI tools configuration and usage

### [project/](./project/)

Project planning, requirements, and management documentation.

- **[PRP/](./project/PRP/)** - Project Requirements and Planning
  - **[Project-PRP.md](./project/PRP/Project-PRP.md)** - Main project requirements document
  - **[PRP-CLAUDE.md](./project/PRP/PRP-CLAUDE.md)** - CLAUDE-specific project planning

### [standards/](./standards/)

Coding standards, documentation guidelines, and quality assurance standards.

- **[ansible-standards.md](./standards/ansible-standards.md)** - Ansible coding and structure standards
- **[documentation-standards.md](./standards/documentation-standards.md)** - Documentation writing and formatting standards
- **[git-standards.md](./standards/git-standards.md)** - Git workflow and commit standards
- **[iac-documentation-standards.md](./standards/iac-documentation-standards.md)** - Infrastructure as Code documentation standards
- **[iac-smoke-testing-theory.md](./standards/iac-smoke-testing-theory.md)** - Infrastructure smoke testing theory and standards
- **[linting-standard.md](./standards/linting-standard.md)** - Code linting and formatting standards

## 🚀 Quick Start

For new team members or those setting up the project:

1. **Standards**: Review [standards/](./standards/) for coding guidelines and best practices
1. **Deployment**: Start with [deployment-process.md](./deployment/deployment-process.md) and [deployment-checklist.md](./deployment/deployment-checklist.md)
1. **Development Setup**: Review [mise-configuration.md](./development/mise-configuration.md) and [code-formatting-and-linting.md](./development/code-formatting-and-linting.md)
1. **CI/CD**: Check [ci-cd-pipeline-workflow.md](./deployment/ci-cd-pipeline-workflow.md) and [act-configuration.md](./development/act-configuration.md)
1. **Infrastructure**: See [infisical-setup.md](./infrastructure/infisical-setup.md) and [terraform-optimization.md](./infrastructure/terraform-optimization.md)

## 📝 Contributing to Documentation

- Use the existing directory structure when adding new documentation
- Follow the naming conventions established in each directory
- Update this README when adding new documents or directories
- For architectural decisions, create ADRs in the [decisions/](./decisions/) directory

## 🔍 Finding Information

- **Deployment issues**: Check [troubleshooting/](./troubleshooting/) first
- **Technical decisions**: Look in [decisions/](./decisions/) for ADRs
- **Setup problems**: Review relevant docs in [development/](./development/) or [infrastructure/](./infrastructure/)
- **Process questions**: Start with [deployment/](./deployment/) documentation

---

**Last updated**: 2025-09-11
