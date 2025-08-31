# Changelog

All notable changes to the Jump Host Infrastructure project will be documented in this file.

---

_This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
format and [Semantic Versioning](https://semver.org/spec/v2.0.0.html)._

## [1.0.0] - 2024-08-30

### Added

- Jump host VM ("jump-man") deployment configuration for Proxmox
- Cloud-init automation for Ubuntu 22.04 LTS with Docker CE and DevOps tools
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
