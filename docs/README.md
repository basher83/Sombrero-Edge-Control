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
- **[mise-configuration.md](./development/mise-configuration.md)** - Mise tool version manager setup

### [infrastructure/](./infrastructure/)

Infrastructure-specific configuration and optimization guides.

- **[infisical-setup.md](./infrastructure/infisical-setup.md)** - Infisical secrets management setup
- **[terraform-optimization.md](./infrastructure/terraform-optimization.md)** - Terraform performance optimization

### [decisions/](./decisions/)

Architectural Decision Records (ADRs) documenting important technical decisions.

- **[ADR-2024-08-30-separate-files-terraform-injection.md](./decisions/ADR-2024-08-30-separate-files-terraform-injection.md)**
  - Decision about separate files for Terraform injection
- **[ADR-2024-08-31-docker-iptables-firewall.md](./decisions/ADR-2024-08-31-docker-iptables-firewall.md)**
  - Docker iptables firewall configuration decision
- **[ADR-2025-01-02-ansible-post-deployment-config.md](./decisions/ADR-2025-01-02-ansible-post-deployment-config.md)**

  - Ansible post-deployment configuration approach

- **[ADR-2025-01-02-documentation-reorganization.md](./decisions/ADR-2025-01-02-documentation-reorganization.md)**
  - Documentation directory structure reorganization
- **[ADR-TEMPLATE.md](./decisions/ADR-TEMPLATE.md)** - Template for creating new ADRs

### [troubleshooting/](./troubleshooting/)

Troubleshooting guides and known issue resolutions.

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
- **[tooling-migrations/](./planning/tooling-migrations/)** - Tooling migration planning and documentation
  - **[README.md](./planning/tooling-migrations/README.md)** - Overview of tooling migrations
  - **[MEGALINTER_MIGRATION.md](./planning/tooling-migrations/MEGALINTER_MIGRATION.md)**
    - MegaLinter migration guide and implementation
- **[architecture-decisions/](./planning/architecture-decisions/)** - Architecture decision records and planning
  - **[ADR-2025-01-06-ansible-roles.md](./planning/architecture-decisions/ADR-2025-01-06-ansible-roles.md)**
    - Ansible roles architecture decision

### [ai_docs/](./ai_docs/)

AI and automation tooling documentation.

- **[archon-tools.md](./ai_docs/archon-tools.md)** - Archon AI tools configuration and usage

### [project/](./project/)

Project planning, requirements, and management documentation.

- **[PRP/](./project/PRP/)** - Project Requirements and Planning
  - **[Project-PRP.md](./project/PRP/Project-PRP.md)** - Main project requirements document
  - **[PRP-CLAUDE.md](./project/PRP/PRP-CLAUDE.md)** - CLAUDE-specific project planning

## 🚀 Quick Start

For new team members or those setting up the project:

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

**Last updated**: 2025-09-08
