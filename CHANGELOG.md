# Changelog

All notable changes to the Jump Host Infrastructure project will be documented in this file.

---

_This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
format and [Semantic Versioning](https://semver.org/spec/v2.0.0.html)._

## [Unreleased]

### Added

- **Ansible Collection Migration**: Comprehensive migration strategy and documentation for transitioning to Ansible collections structure
- **Ansible Development Tools**: Added ansible-dev-tools, uv, python 3.12, and antsibull-changelog
  to mise.toml for enhanced Ansible development workflow
- **Ansible Collection Structure**: Complete basher83.automation_server collection with 10 migrated roles,
  8 playbooks, inventory, and CI/CD configuration
- **Docker Role Enhancements**: Complete refactoring with log rotation, error handling, and Molecule testing framework
- **Docker Log Rotation**: Implemented json-file driver configuration with max-size and max-file limits
- **Molecule Testing**: Added complete test framework for Docker role validation
- **ADR System**: Architectural Decision Records for tracking important technical decisions
- **MegaLinter Integration**: Enhanced linting and code quality checks with MegaLinter runner script
- **Claude Code Commands**: ADR creation slash command and other Claude Code integrations
- **Thoughts Directory**: Knowledge management system for tracking project insights and decisions
- **Renovate Configuration**: Enhanced dependency management with Renovate bot configuration
- **Terraform Docs Validation**: Pre-commit hooks for automatic Terraform documentation generation
- **CI/CD Enhancements**: Thoughts directory protection system and improved workflow configurations

### Changed

- **Docker Role Structure**: Applied FQCN (Fully Qualified Collection Names) throughout all tasks
- **Variable Management**: Moved all Docker role variables from vars/ to defaults/ for proper precedence
- **Error Handling**: Added comprehensive block/rescue/always patterns with backup and rollback mechanisms
- **MegaLinter Configuration**: Optimized performance with fast mode and non-blocking errors
- **Documentation Structure**: Added comprehensive guides for Ansible collection migration
- **Namespace References**: Updated all documentation from 'sombrero.edge_control' to 'basher83.automation_server' namespace
- **CI Workflows**: Simplified and fixed workflow syntax issues

### Fixed

- **Docker Role Variables**: Added all missing variable definitions preventing role execution
- **Docker Socket Permissions**: Fixed validation logic with proper stat check and octal format comparison
- **User Namespace Remapping**: Implemented dockremap user creation and verification
- **Network and Volume Tests**: Added missing validation implementations
- **Registry Validation**: Enhanced with proper connectivity testing
- **Handler Syntax**: Updated all handlers to use FQCN format
- **CI/CD Issues**: Resolved MegaLinter workflow failures and duplicate workflow files
- **Terraform Configuration**: Removed duplicate version requirements
- **DevContainer**: Improved structure and property ordering

### Documentation

- **Ansible Collection Migration Guide**: Comprehensive guide for transitioning to collection-based architecture
- **Namespace Decision Documentation**: Added namespace-decision.md documenting the basher83.automation_server
  namespace choice and rationale
- **ADRs**: Multiple architectural decision records for Ansible collections, Renovate, and MegaLinter
- **Thoughts System**: Knowledge management documentation and adaptation strategy
- **MegaLinter Fixes**: Quick reference guide for resolving MegaLinter issues

## [1.1.0] - 2025-09-02

### Added

- **Golden Image Pipeline**: Complete Packer → Terraform → Ansible workflow with golden image approach
- **Documentation Reorganization**: Logical directory structure with deployment/, development/,
  infrastructure/, project/ subdirectories
- **Industry Best Practices**: Added supporting references and cross-references to industry standards
- **Performance Improvements**: 90% faster deployments (30 seconds vs. 5-10 minutes) using pre-built golden images
- **Enhanced Tool Integration**: nvm, mise, uv, Docker CE with Compose/Buildx plugins pre-installed
- **Comprehensive Documentation**: Pipeline enhancement summary, CI/CD workflow, deployment processes,
  and troubleshooting guides
- **Security Hardening**: SSH security, unattended upgrades, and compliance-ready configurations
- **Dynamic Template Selection**: Automatic selection of latest Packer-built golden images with fallback mechanism
- **Mise Task Automation**: Complete pipeline automation with deploy-packer, deploy-terraform, deploy-ansible tasks

### Changed

- **Documentation Structure**: Reorganized from flat structure to logical subdirectories for better maintainability
- **Deployment Architecture**: Shifted from runtime installation to golden image approach for immutable infrastructure
- **Ansible Integration**: Optimized for post-deployment configuration only (build-time setup moved to Packer)
- **Template Management**: Added comprehensive tagging and metadata for version tracking
- **CI/CD Pipeline**: Enhanced with local testing capabilities and comprehensive validation

### Fixed

- **Internal Documentation Links**: Updated all internal references to reflect new directory structure
- **Cross-References**: Added proper linking between related documentation files

### Documentation

- **New Directory Structure**: deployment/, development/, infrastructure/, project/ organization
- **Enhanced Pipeline Documentation**: Comprehensive workflow guides and best practices
- **Quick Start Guides**: Updated navigation and setup instructions for new team members
- **Troubleshooting**: Consolidated issue resolution guides

---

## [1.0.0] - 2024-08-30

### Added

- Jump host VM ("jump-man") deployment configuration for Proxmox
- Cloud-init automation for Ubuntu 24.04 LTS with Docker CE and DevOps tools
- Memory ballooning support (2GB dedicated + 1GB floating)
- Parameterized vendor_data in VM module for role-agnostic deployments
- Static IP configuration (192.168.10.250/24)
- Comprehensive package installation via cloud-init:
  - Docker CE with Compose plugin
  - Essential tools: git, tmux, curl, wget, jq, python3
  - Basic nftables firewall configuration
  - QEMU guest agent for Proxmox integration

### Changed

- Refactored VM module to make vendor_data optional and injectable
- Updated VM module to support memory ballooning via `memory_floating` variable
- Simplified repository to focus solely on jump host deployment

### Removed

- All Vault cluster configurations (template code from previous project)
- Unused environment directories (development, staging, test)
- Vault-specific variables and cloud-init files
- SSH configuration from Proxmox provider (not needed for API-based uploads)

### Security

- Implemented basic permissive nftables rules (to be hardened via Ansible)
- SSH access restricted to ansible user with ED25519 key authentication
- No secrets or sensitive data stored in repository

## [0.1.0] - 2024-08-29

### Added

- Initial repository setup from Vault cluster template
- Basic Terraform structure for Proxmox deployments
- VM module with cloud-init support
