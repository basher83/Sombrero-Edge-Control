# Jump Host (jump-man) - DevOps Management Server

This Ubuntu 22.04 jump host is configured for DevOps operations.

## Installed Tools

- Docker CE with Compose plugin
- Git, tmux, curl, wget, jq
- Python3
- iptables (Docker-compatible firewall configuration)

## Network Configuration

- IP: 192.168.10.250/24
- Gateway: 192.168.10.1
- DNS: 8.8.8.8, 8.8.4.4

## Post-Provisioning

- Additional hardening will be applied via Ansible
- Node.js, npm, mise, and uv will be installed via Ansible

## Docker Commands

- docker ps                     # List running containers
- docker compose up -d          # Start services
- docker system prune -a        # Clean up unused resources

## SSH Access

User: ansible
Key: ED25519 key configured via cloud-init
