# Terraform Proxmox SSH Authentication Troubleshooting

## Problem Description

When using the bpg/proxmox Terraform provider, you may encounter SSH authentication errors when Terraform attempts to upload files (like cloud-init vendor data) to the Proxmox host:

```
Error: ssh: unable to authenticate, attempted methods [none]
```

## Root Cause

The bpg/proxmox provider requires SSH access to the Proxmox host for certain operations, particularly:
- Uploading cloud-init configuration files
- Managing vendor data files
- Accessing storage pools directly

## Solution Steps

### 1. Configure SSH Agent

The provider is configured to use SSH agent authentication (`agent = true` in providers.tf):

```bash
# Start SSH agent if not running
eval "$(ssh-agent -s)"

# Add your SSH key
ssh-add ~/.ssh/id_rsa  # or path to your private key

# Verify key is loaded
ssh-add -l
```

### 2. Set Required Environment Variables

Ensure the Proxmox SSH username is set in your `.mise.local.toml`:

```toml
[env]
TF_VAR_proxmox_ssh_username = "root"  # Usually root for Proxmox
```

Verify it's loaded:
```bash
mise env | grep proxmox_ssh_username
```

### 3. Configure SSH Access to Proxmox

On the Proxmox host, ensure your public key is in the authorized_keys:

```bash
# Copy your public key to Proxmox host
ssh-copy-id root@192.168.10.2

# Or manually add to /root/.ssh/authorized_keys on Proxmox
```

### 4. Test SSH Connection

Before running Terraform, verify SSH works:

```bash
# Test basic connection
ssh root@192.168.10.2 "echo 'SSH connection successful'"

# Test with agent forwarding
ssh -A root@192.168.10.2 "echo 'Agent forwarding working'"
```

### 5. Provider Configuration

Ensure your `providers.tf` has the SSH block configured:

```hcl
provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = var.pve_api_token
  insecure  = var.proxmox_insecure

  ssh {
    agent    = true
    username = var.proxmox_ssh_username
    # private_key = file("~/.ssh/id_rsa")  # Optional: explicit key path
  }
}
```

## Alternative Solutions

### Option 1: Use Explicit Private Key

Instead of SSH agent, specify the private key directly:

```hcl
provider "proxmox" {
  # ... other config ...

  ssh {
    agent       = false
    username    = var.proxmox_ssh_username
    private_key = file(pathexpand("~/.ssh/id_rsa"))
  }
}
```

### Option 2: Use Password Authentication

Not recommended for production, but useful for testing:

```hcl
provider "proxmox" {
  # ... other config ...

  ssh {
    agent    = false
    username = var.proxmox_ssh_username
    password = var.proxmox_ssh_password  # Set via environment variable
  }
}
```

## Common Issues and Fixes

### Issue: SSH agent not persisting

**Solution**: Add to your shell profile:
```bash
# Add to ~/.bashrc or ~/.zshrc
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
fi
```

### Issue: Permission denied even with correct key

**Solution**: Check Proxmox SSH configuration:
```bash
# On Proxmox host
grep -E "^(PermitRootLogin|PubkeyAuthentication)" /etc/ssh/sshd_config
# Should show:
# PermitRootLogin yes (or prohibit-password)
# PubkeyAuthentication yes
```

### Issue: Multiple SSH keys causing confusion

**Solution**: Specify exact key in SSH config:
```bash
# ~/.ssh/config
Host proxmox 192.168.10.2
  HostName 192.168.10.2
  User root
  IdentityFile ~/.ssh/proxmox_rsa
  IdentitiesOnly yes
```

## Verification Commands

After fixing SSH, verify Terraform can connect:

```bash
# Plan should work without SSH errors
terraform plan

# For verbose SSH debugging
TF_LOG=DEBUG terraform plan 2>&1 | grep -i ssh
```

## Related Documentation

- [bpg/proxmox Provider SSH Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#ssh-connection)
- [SSH Agent Forwarding Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding)
- [Proxmox SSH Configuration](https://pve.proxmox.com/wiki/SSH_Access)
