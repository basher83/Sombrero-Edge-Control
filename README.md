![GitHub last commit](https://img.shields.io/github/last-commit/basher83/Sombrero-Edge-Control?path=README.md&display_timestamp=author&style=plastic&logo=github)
![GitHub License](https://img.shields.io/github/license/basher83/Sombrero-Edge-Control?style=plastic)

![Terraform](https://img.shields.io/badge/terraform-000000?style=plastic&logo=terraform&logoColor=)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=plastic&logo=ubuntu&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-E5780B?style=plastic&logo=proxmox&logoColor=white)
![Infisical](https://img.shields.io/badge/Infisical-000000?style=plastic&logo=infisical&logoColor=)

# Sombrero Edge Control - Jump Host Infrastructure

Infrastructure as Code (IaC) for deploying a centralized jump host VM to Proxmox using Terraform and cloud-init automation.

## 🎯 Purpose

This repository deploys a dedicated Ubuntu 22.04 LTS jump host ("jump-man") for DevOps operations, providing a secure, centralized management point decoupled from developer laptops.

## ✨ Features

- **Automated Deployment**: Single command Terraform deployment to Proxmox
- **Cloud-init Configuration**: Fully automated VM provisioning with all required tools
- **Docker Ready**: Docker CE with Compose plugin pre-installed
- **DevOps Tooling**: Git, tmux, curl, wget, jq, Python3, and more
- **Memory Efficiency**: Ballooning support (2GB RAM + 1GB floating)
- **Static Networking**: Fixed IP (192.168.10.250/24) with reliable DNS
- **Security First**: SSH key-only authentication with ansible user

## 🚀 Quick Start

### Prerequisites

- Proxmox cluster with Ubuntu 22.04 template (ID: 8000)
- Terraform >= 1.3.0
- Proxmox API token with appropriate permissions
- mise for environment management (optional but recommended)

### Environment Setup

1. Configure environment variables in `.mise.local.toml`:

```toml
[env]
TF_VAR_pve_api_token = "terraform@pve!token=your-token-here"
TF_VAR_pve_api_url = "https://your-proxmox:8006/api2/json"
TF_VAR_ci_ssh_key = "ssh-ed25519 YOUR-PUBLIC-KEY ansible@jump-man"
TF_VAR_proxmox_insecure = "true"  # Only for self-signed certs
```

2. Load environment:

```bash
eval "$(mise env -s bash)"
```

### Deployment

```bash
cd infrastructure/environments/production
terraform init
terraform plan
terraform apply
```

### Access

```bash
ssh ansible@192.168.10.250
```

## 📁 Repository Structure

```
├── infrastructure/
│   ├── environments/
│   │   └── production/     # Production jump host configuration
│   └── modules/
│       └── vm/             # Reusable VM module
├── docs/
│   └── PRP.md             # Product Requirements Prompt
├── CHANGELOG.md           # Version history
└── README.md             # This file
```

## 🔧 Configuration

### VM Specifications

- **vCPUs**: 2 cores (host type)
- **Memory**: 2GB dedicated + 1GB floating
- **Storage**: 32GB disk
- **Network**: Static IP 192.168.10.250/24
- **Node**: lloyd (Proxmox node)

### Installed Software

Via cloud-init automation:

- Docker CE & Docker Compose
- Git, tmux
- curl, wget, gpg
- jq, net-tools
- Python3
- nftables (basic configuration)
- QEMU guest agent

## 🔐 Security

- SSH access only (no password authentication)
- ansible user with sudo privileges
- ED25519 SSH key authentication
- Basic nftables firewall (to be hardened via Ansible)
- No secrets stored in repository

## 📝 Post-Deployment

Additional configuration will be applied via Ansible:

- Security hardening
- Advanced nftables rules
- Node.js, npm, mise, uv installation
- Custom DevOps tooling

## 🤝 Contributing

This is a production infrastructure repository. Changes should be:

1. Tested in a non-production environment first
2. Reviewed before merging
3. Documented in CHANGELOG.md

## 📄 License

[Your License Here]

## 📚 Documentation

- [Infrastructure Documentation](infrastructure/README.md)
- [Product Requirements](docs/PRP.md)
- [Change Log](CHANGELOG.md)
