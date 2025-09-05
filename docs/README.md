# Documentation

This directory contains comprehensive documentation for the Sombrero-Edge-Control project, organized by functional areas for easy navigation.

## 📁 Directory Structure

### [deployment/](./deployment/)
Core deployment pipeline documentation and processes.

- **[pipeline-enhancements-summary.md](./deployment/pipeline-enhancements-summary.md)** - Summary of recent pipeline enhancements and improvements
- **[ci-cd-pipeline-workflow.md](./deployment/ci-cd-pipeline-workflow.md)** - Complete CI/CD pipeline workflow documentation
- **[deployment-checklist.md](./deployment/deployment-checklist.md)** - Step-by-step deployment checklist
- **[deployment-process.md](./deployment/deployment-process.md)** - General deployment process guide
- **[smoke-testing-implementation.md](./deployment/smoke-testing-implementation.md)** - Smoke testing procedures and implementation

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

- **[ADR-2024-08-30-separate-files-terraform-injection.md](./decisions/ADR-2024-08-30-separate-files-terraform-injection.md)** - Decision about separate files for Terraform injection
- **[ADR-2024-08-31-docker-iptables-firewall.md](./decisions/ADR-2024-08-31-docker-iptables-firewall.md)** - Docker iptables firewall configuration decision
- **[ADR-2025-01-02-ansible-post-deployment-config.md](./decisions/ADR-2025-01-02-ansible-post-deployment-config.md)** - Ansible post-deployment configuration approach
- **[ADR-2025-01-02-documentation-reorganization.md](./decisions/ADR-2025-01-02-documentation-reorganization.md)** - Documentation directory structure reorganization
- **[ADR-TEMPLATE.md](./decisions/ADR-TEMPLATE.md)** - Template for creating new ADRs

### [troubleshooting/](./troubleshooting/)
Troubleshooting guides and known issue resolutions.

- **[ssh-cloud-init-issues.md](./troubleshooting/ssh-cloud-init-issues.md)** - SSH and cloud-init related issues

### [project/](./project/)
Project planning, requirements, and management documentation.

- **[PRP/](./project/PRP/)** - Project Requirements and Planning
  - **[Project-PRP.md](./project/PRP/Project-PRP.md)** - Main project requirements document
  - **[PRP-CLAUDE.md](./project/PRP/PRP-CLAUDE.md)** - CLAUDE-specific project planning

## 🚀 Quick Start

For new team members or those setting up the project:

1. **Deployment**: Start with [deployment-process.md](./deployment/deployment-process.md) and [deployment-checklist.md](./deployment/deployment-checklist.md)
2. **Development Setup**: Review [mise-configuration.md](./development/mise-configuration.md) and [code-formatting-and-linting.md](./development/code-formatting-and-linting.md)
3. **CI/CD**: Check [ci-cd-pipeline-workflow.md](./deployment/ci-cd-pipeline-workflow.md) and [act-configuration.md](./development/act-configuration.md)
4. **Infrastructure**: See [infisical-setup.md](./infrastructure/infisical-setup.md) and [terraform-optimization.md](./infrastructure/terraform-optimization.md)

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

**Last updated**: Document structure reorganized for better organization and maintainability.
