# Changelog

All notable changes to the Jump Host Infrastructure project will be documented in this file.

---

_This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
format and [Semantic Versioning](https://semver.org/spec/v2.0.0.html)._

## [1.1.0] - 2025-01-02

### Added

- **Golden Image Pipeline**: Complete Packer → Terraform → Ansible workflow with golden image approach
- **Documentation Reorganization**: Logical directory structure with deployment/, development/, infrastructure/, project/ subdirectories
- **Industry Best Practices**: Added supporting references and cross-references to industry standards
- **Performance Improvements**: 90% faster deployments (30 seconds vs. 5-10 minutes) using pre-built golden images
- **Enhanced Tool Integration**: nvm, mise, uv, Docker CE with Compose/Buildx plugins pre-installed
- **Comprehensive Documentation**: Pipeline enhancement summary, CI/CD workflow, deployment processes, and troubleshooting guides
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
