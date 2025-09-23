# Changelog

All notable changes to the Jump Host Infrastructure project will be documented in this file.

---

_This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
format and [Semantic Versioning](https://semver.org/spec/v2.0.0.html)._

## [Unreleased] - 2025-09-22

### Added

- **Bootstrap Roles Implementation (ANS-001)**: Production-ready bootstrap and bootstrap_check roles with DebOps patterns (95/100 score):
  - Enhanced Python installation with APT cache management
  - Connection reset after Python installation for fresh VMs
  - Dual marker system (filesystem + ansible facts) for idempotency
  - Ubuntu 24.04 systemd-resolved DNS configuration
  - Comprehensive error handling with 3-retry logic
  - Test playbook for validation (`playbooks/test-bootstrap.yml`)
- **Netdata Monitoring Stack (ANS-005)**: Complete monitoring solution using official Netdata Ansible repository (85/100 score):
  - Netdata role with Docker container monitoring via cgroups
  - Web dashboard configuration on port 19999
  - Firewall integration for UFW and nftables
  - Monitoring and validation playbooks (`playbooks/monitoring.yml`, `playbooks/test-netdata.yml`)
  - Integration with site.yml for automated deployment
  - Requirements.yml for Netdata Ansible collection
- **Ansible Research Reports**:
  - Bootstrap patterns research from DebOps and community collections (`.claude/research-reports/ansible-bootstrap-research-20250922-021729.md`)
  - Netdata Ansible collection analysis evaluating 6 repositories (`.claude/research-reports/ansible-research-20250922-213639.md`)
- **Pipeline Orchestration Scripts**: Complete three-stage deployment automation (`scripts/deploy-pipeline.sh`, `stage-1-packer.sh`, `stage-2-terraform.sh`, `stage-3-ansible.sh`)
- **Pipeline Documentation Suite**:
  - Pipeline operation guide (`docs/deployment/pipeline-operation.md`)
  - Pipeline handoff specifications (`docs/deployment/pipeline-handoffs.md`)
  - Pipeline rollback procedures (`docs/deployment/pipeline-rollback.md`)
- **Terraform Inventory Export**: Automated inventory generation for Ansible from Terraform outputs (`infrastructure/environments/production/export-inventory.sh`)
- **Cursor IDE Integration**: Complete command structure for task management and git operations (`.cursor/commands/`)
- **Pipeline Separation Architecture**: Complete separation of Packer, Terraform, and Ansible into independent stages with clean handoffs (ADR-20250918)
- **Ansible Collection Research**: Comprehensive research on community collections for Proxmox, Docker, NetBox, HashiCorp stack, and DNS/IPAM systems
- **Pipeline Documentation**:
  - Packer golden image strategy guide (`docs/infrastructure/packer-golden-image.md`)
  - Ansible configuration management guide (`docs/deployment/ansible-configuration-guide.md`)
  - Pipeline separation refactoring plan (`docs/planning/pipeline-separation-refactor.md`)
- **Architectural Decision**: ADR-20250918 documenting complete pipeline separation decision
- **Ansible Collection Migration**: Comprehensive migration strategy and documentation for transitioning to Ansible collections structure
- **Ansible Development Tools**: Added ansible-dev-tools, uv, python 3.12, and antsibull-changelog
  to mise.toml for enhanced Ansible development workflow
- **Ansible Collection Structure**: Complete basher83.automation_server collection with 11 migrated roles
  (development-tools, docker, docker_validation, firewall, proxmox_validation, run, security,
  terraform_outputs, vm_diagnostics, vm_lifecycle, vm_smoke_tests), 8 playbooks, inventory, and CI/CD configuration
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

- **Task Tracker Status**: Updated to 91% complete (10/11 tasks) with all Ansible Configuration tasks now finished:
  - ANS-001 Bootstrap Playbook: Implemented with DebOps patterns (September 22)
  - ANS-002, ANS-003, ANS-004: Discovered already implemented in production
  - ANS-005 Netdata Monitoring: Implemented with official repository (September 22)
  - Only optional SEP-006 performance validation remains
- **Cloud-Init Simplification**: Removed complex provisioning logic, reduced to SSH-only configuration (SEP-002)
- **Terraform Module**: Added `ssh_authorized_keys` variable support for flexible key management
- **Terraform Outputs**: Refactored for cleaner Ansible inventory generation with proper JSON structure
- **Pre-commit Integration**: Updated hooks to use mise tasks for consistency
- **Project Architecture**: Refactored to three-stage pipeline with complete tool separation (Packer → Terraform → Ansible)
- **Ansible Configuration Phase**: Now 100% complete with all 5 tasks implemented
- **Project Roadmap**: Updated to reflect 90% completion of Phase 5 (Ansible as Single Source of Truth)
- **Documentation Updates**:
  - Updated Project PRP to reflect pipeline separation architecture
  - Revised deployment checklist for three-stage process
  - Updated Terraform-Ansible integration guide to discourage provisioners
  - Changed Ansible collection structure from "migration" to "primary" status
- **ROADMAP Restructure**: Reorganized phases to align with pipeline separation strategy:
  - Added Pipeline Separation Architecture phase (65% complete)
  - Added Minimal Golden Images phase (40% complete)
  - Added Pure Infrastructure phase (60% complete)
  - Revised all timelines and success metrics for tool independence
- **Docker Role Structure**: Applied FQCN (fully qualified collection name) throughout all tasks
- **Variable Management**: Moved all Docker role variables from vars/ to defaults/ for proper precedence
- **Error Handling**: Added comprehensive block/rescue/always patterns with backup and rollback mechanisms
- **MegaLinter Configuration**: Optimized performance with fast mode and non-blocking errors
- **Documentation Structure**: Added comprehensive guides for Ansible collection migration
- **Namespace References**: Updated all documentation and metadata from 'sombrero.edge_control' and 'sombrero_edge' to 'basher83.automation_server' namespace
- **CI Workflows**: Simplified and fixed workflow syntax issues

### Fixed

- **Documentation Alignment**: All documentation now correctly reflects pipeline separation architecture
- **Date Corrections**: Fixed incorrect dates in ROADMAP (was showing January 2025, corrected to September 2025)
- **ADR References**: Updated ADR references to use correct date (20250918)
- **Task Status Accuracy**: Corrected task tracker to reflect actual implementation status of Ansible roles
- **Docker Role Variables**: Added all missing variable definitions preventing role execution
- **Docker Socket Permissions**: Fixed validation logic with proper stat check and octal format comparison
- **User Namespace Remapping**: Implemented dockremap user creation and verification
- **Network and Volume Tests**: Added missing validation implementations
- **Registry Validation**: Enhanced with proper connectivity testing
- **Handler Syntax**: Updated all handlers to use FQCN format
- **CI/CD Issues**: Resolved MegaLinter workflow failures and duplicate workflow files
- **Terraform Configuration**: Removed duplicate version requirements
- **DevContainer**: Improved structure and property ordering

### Removed

- **Legacy Ansible Directory**: Archived old ansible/ directory structure (backed up as `ansible-legacy-backup-20250921-235432.tar.gz`)
- **Unused Documentation**: Removed ACTIONABLE-INSIGHTS.md and outdated references
- **Complex Cloud-Init Scripts**: Removed docker-install.sh and firewall-setup.sh in favor of Ansible roles

### Documentation

- **Pipeline Orchestration Guides**: Complete set of operation, handoff, and rollback documentation
- **Task Completion Updates**:
  - SEP-001 through SEP-005: All pipeline separation tasks marked complete
  - ANS-001: Bootstrap Playbook marked complete with DebOps implementation
  - ANS-005: Netdata Monitoring marked complete with official repository implementation
- **Research Reports**:
  - Bootstrap patterns analysis from DebOps (`.claude/research-reports/ansible-bootstrap-research-20250922-021729.md`)
  - Netdata Ansible collection evaluation (`.claude/research-reports/ansible-research-20250922-213639.md`)
- **Pipeline Separation Strategy**: Complete refactoring plan for three-stage architecture
- **Golden Image Documentation**: Minimal Packer image strategy and implementation guide
- **Ansible Configuration Guide**: Comprehensive playbook structure and role specifications
- **Updated Deployment Documentation**: Three-stage checklist and procedures
- **Ansible Collection Research**: Analysis of community collections with scoring and recommendations
- **Ansible Collection Migration Guide**: Comprehensive guide for transitioning to collection-based architecture
- **Namespace Decision Documentation**: Added namespace-decision.md documenting the basher83.automation_server
  namespace choice and rationale
- **ADRs**: Multiple architectural decision records for Ansible collections, Renovate, MegaLinter, and pipeline separation
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
