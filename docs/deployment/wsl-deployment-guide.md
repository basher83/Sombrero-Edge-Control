# WSL Deployment Guide for Sombrero Edge Control

## Overview

This guide addresses specific considerations and solutions for deploying infrastructure from Windows Subsystem for Linux (WSL) environments.

## Known WSL-Specific Issues

### 1. SSH Agent Persistence

**Problem**: SSH agent in WSL doesn't persist between sessions, causing authentication failures for Terraform and Packer.

**Solutions**:

#### Option A: Keychain (Recommended)

```bash
# Install keychain
sudo apt-get update && sudo apt-get install keychain

# Add to ~/.bashrc or ~/.zshrc
echo 'eval `keychain --eval --agents ssh id_rsa`' >> ~/.bashrc

# Reload shell configuration
source ~/.bashrc

# Verify
ssh-add -l
```

#### Option B: Windows SSH Agent Bridge

```bash
# Install npiperelay and socat
sudo apt install socat

# Configure WSL to use Windows SSH agent
# Add to ~/.bashrc:
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
ss -a | grep -q $SSH_AUTH_SOCK
if [ $? -ne 0 ]; then
    rm -f $SSH_AUTH_SOCK
    (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi
```

### 2. Network Connectivity

**Problem**: Windows Firewall may block WSL network access to Proxmox.

**Solutions**:

```powershell
# Run in Windows PowerShell as Administrator
# Allow WSL through firewall
New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)" -Action Allow

# Or allow specific port for SSH
New-NetFirewallRule -DisplayName "WSL SSH to Proxmox" -Direction Outbound -Protocol TCP -RemotePort 22 -Action Allow
```

### 3. File Permissions

**Problem**: Windows file system doesn't preserve Linux permissions properly.

**Solutions**:

```bash
# Store project in WSL filesystem, not Windows mount
cd ~/dev  # Use WSL home directory
git clone <repository>

# If must use Windows filesystem, configure WSL
# /etc/wsl.conf
[automount]
options = "metadata,umask=22,fmask=11"
```

## Pre-Deployment Checklist for WSL

### System Requirements

- [ ] WSL 2 installed (check with `wsl --version`)
- [ ] Ubuntu 20.04+ or Debian 11+ distribution
- [ ] Sufficient RAM allocated to WSL (at least 4GB)
- [ ] Network connectivity from WSL to Proxmox

### Tool Installation

```bash
# Core tools
sudo apt-get update
sudo apt-get install -y \
  openssh-client \
  keychain \
  git \
  curl \
  wget

# Install mise
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# Install Terraform via mise
mise install terraform@1.13.0
```

### SSH Configuration

```bash
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "wsl-deployment"

# Set up keychain
eval `keychain --eval --agents ssh id_ed25519`

# Copy public key to Proxmox
ssh-copy-id root@192.168.10.2

# Test connection
ssh root@192.168.10.2 "echo 'Connected from WSL'"
```

## Deployment Process

### 1. Environment Setup

```bash
# Clone repository in WSL filesystem
cd ~/dev
git clone https://github.com/basher83/Sombrero-Edge-Control.git
cd Sombrero-Edge-Control

# Configure environment
cp .mise.local.toml.example .mise.local.toml
# Edit .mise.local.toml with your credentials

# Load environment
eval "$(mise env)"
```

### 2. SSH Agent Setup (Every WSL Session)

```bash
# If using keychain (automatic)
# Already loaded via .bashrc

# If manual
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l  # Verify
```

### 3. Run Deployment

```bash
# Initialize
mise run prod-init

# Validate
mise run prod-validate

# Plan
mise run prod-plan

# Apply
mise run prod-apply
```

## Troubleshooting WSL-Specific Issues

### SSH Agent Not Found

```bash
# Check if agent is running
ps aux | grep ssh-agent

# Restart agent
killall ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Network Timeouts

```bash
# Check WSL network
ip addr show

# Test connectivity
ping 192.168.10.2

# Check Windows firewall (from PowerShell)
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*WSL*"}
```

### Permission Denied Errors

```bash
# Fix SSH key permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh

# Fix project permissions if on Windows mount
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```

## Best Practices for WSL Deployments

1. **Always use WSL filesystem** for projects, not /mnt/c/
2. **Set up keychain** for persistent SSH agent
3. **Document WSL version** in deployment logs
4. **Test network connectivity** before deployments
5. **Keep WSL updated**: `wsl --update`
6. **Use WSL 2** for better performance
7. **Allocate sufficient memory** in .wslconfig

## WSL Configuration File

Create `C:\Users\<username>\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
localhostForwarding=true
```

## Environment Variables for WSL

Add to `.mise.local.toml`:

```toml
[env]
# Proxmox connection
TF_VAR_pve_api_url = "https://192.168.10.2:8006/api2/json"
TF_VAR_pve_api_token = "terraform@pve!terraform=<token>"
TF_VAR_proxmox_insecure = "true"

# SSH configuration
TF_VAR_proxmox_ssh_username = "root"

# WSL-specific
WSL_DEPLOYMENT = "true"
WSL_DISTRO = "Ubuntu-20.04"  # or your distro
```

## Deployment Checklist Template Addition

When creating deployment checklists, include:

```markdown
## Deployment Environment Details
- **Platform**: Windows WSL 2
- **WSL Distribution**: Ubuntu 20.04
- **Host OS**: Windows 11 Pro
- **WSL Version**: 2.0.0.0
- **Deployment Method**: Remote from WSL
- **SSH Agent**: Keychain-managed
```

## Related Documentation

- [Microsoft WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [WSL Networking Guide](https://docs.microsoft.com/en-us/windows/wsl/networking)
- [SSH Agent in WSL](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#auto-launching-ssh-agent-on-git-for-windows)
