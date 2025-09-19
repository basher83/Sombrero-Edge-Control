---
Task: Create Minimal Packer Template
Task ID: SEP-001
Priority: P0 (Critical)
Estimated Time: 2 hours
Dependencies: None
Status: ✅ Complete
---

## Objective

Create a minimal Packer template that builds a bare Ubuntu 24.04 golden image using only the Ubuntu installer with NO post-provisioning. This achieves true separation by having Packer only automate the OS installation, leaving ALL configuration (including package installation) to Terraform/Ansible.

## Prerequisites

- [ ] Access to Proxmox cluster
- [ ] Packer 1.9+ installed
- [ ] Ubuntu 24.04 ISO available to Proxmox
- [ ] Existing Packer configuration backed up

## Implementation Steps

### 1. **Backup Current Packer Configuration**

```bash
cd packer
cp ubuntu-server-numbat-docker.pkr.hcl ubuntu-server-numbat-docker.pkr.hcl.backup
```

### 2. **Create Minimal Template Without Provisioners**

Create `packer/ubuntu-server-minimal.pkr.hcl` with NO provisioning:

```hcl
source "proxmox" "ubuntu-minimal" {
  # Connection settings (keep existing)
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  insecure_skip_tls_verify = var.proxmox_insecure
  node                     = var.proxmox_node

  # VM settings
  vm_name         = "ubuntu-2404-minimal-${local.timestamp}"
  template_name   = "ubuntu-2404-minimal-${local.timestamp}"
  template_description = "Ubuntu 24.04 Minimal - OS only, no modifications"

  # ISO and boot settings here...
}

build {
  sources = ["source.proxmox.ubuntu-minimal"]

  # Build section is empty - no provisioning!
  # No shell scripts, no Ansible, no file uploads
  # Just pure Ubuntu installation
}
```

**Note**: Ubuntu 24.04 Server includes cloud-init and qemu-guest-agent by default. We don't need to install them.

### 3. **Update Build Variables**

Modify `packer/variables.pkrvars.hcl`:

```hcl
# Template settings
template_id          = 8025  # New ID for minimal template
template_name        = "ubuntu-2404-minimal"
template_description = "Ubuntu 24.04 LTS - Base OS only, no modifications"
```

### 4. **Configure Autoinstall**

Create minimal `packer/http/user-data` for automated installation:

```yaml
#cloud-config
autoinstall:
  version: 1
  locale: en_US.UTF-8
  keyboard:
    layout: us
  network:
    network:
      version: 2
      ethernets:
        ens18:
          dhcp4: true
  storage:
    layout:
      name: direct
  packages: []  # No additional packages!
  late-commands: []  # No post-install commands!
  # Let Ubuntu installer handle everything
```

### 5. **Test Build**

```bash
cd packer
packer validate -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl
packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl
```

## Success Criteria

- [ ] Template builds successfully
- [ ] NO post-provisioning scripts run
- [ ] Template contains ONLY what Ubuntu installer provides:
  - Ubuntu 24.04 base OS (with default packages)
  - cloud-init (included by default)
  - qemu-guest-agent (included by default)
- [ ] No additional software installed by Packer
- [ ] Template boots and accepts cloud-init configuration
- [ ] Image is as close to stock Ubuntu as possible

## Validation

### Build Validation

```bash
# Check build time
time packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl

# Verify template exists
ssh root@proxmox-host "qm list | grep ubuntu-2404-minimal"
```

### Template Testing

```bash
# Create test VM from template
cd infrastructure/environments/production
terraform apply -var="template_id=8025" -target=proxmox_vm_qemu.test

# SSH and verify minimal packages
ssh ansible@192.168.10.250 "dpkg -l | grep -E '(docker|nodejs|python3-pip)'"
# Should return no results
```

Expected output:

- Build completes successfully
- No Docker or development packages installed
- Stock Ubuntu 24.04 with default packages only

## Notes

- KISS principle: Packer ONLY automates Ubuntu installation
- No provisioning = no complexity = no maintenance
- cloud-init and qemu-guest-agent come with Ubuntu Server by default
- This is a breaking change - existing deployments will need migration
- Keep old template (ID 8024) for rollback if needed
- If post-provisioning is needed later, it should be minimal (e.g., only cleanup commands)

## References

- [Pipeline Separation ADR](../../../decisions/20250118-pipeline-separation.md)
- [Packer Golden Image Documentation](../../../infrastructure/packer-golden-image.md)
- [Current Packer Configuration](../../../../packer/ubuntu-server-numbat-docker.pkr.hcl)
