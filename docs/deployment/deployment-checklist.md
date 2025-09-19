# Jump-Man Three-Stage Deployment Checklist 🚀

## Stage 1: Packer - Golden Image 📀

- [ ] **Verify Packer installed**: `packer version`
- [ ] **Check template definition**: Review `packer/ubuntu-server-minimal.pkr.hcl`
- [ ] **Build golden image**: `mise run deploy-golden-image`
- [ ] **Verify template created**: Note template ID for Terraform
- [ ] **Confirm minimal image**: Only OS + cloud-init + qemu-guest-agent

## Stage 2: Terraform - Infrastructure 🏗️

- [ ] **Environment variables loaded**: `mise env` shows TF_VAR_* values
- [ ] **Set template ID**: Export template ID from Packer
- [ ] **Initialize Terraform**: `mise run prod-init`
- [ ] **Validate configuration**: `mise run prod-validate`
- [ ] **Review plan**: `mise run prod-plan` (verify creating jump-man VM)
- [ ] **Deploy infrastructure**: `mise run prod-apply`
- [ ] **Verify SSH access**: `ssh ansible@192.168.10.250` (basic connectivity only)
- [ ] **Generate inventory**: `terraform output -json ansible_inventory > inventory.json`

## Stage 3: Ansible - Configuration 🔧

- [ ] **Verify inventory**: Check `ansible_inventory.json` has VM details
- [ ] **Run Ansible playbook**: `mise run deploy-configuration`
- [ ] **Monitor progress**: Watch Ansible task execution
- [ ] **Verify Docker installed**: Ansible reports Docker tasks complete
- [ ] **Verify security hardening**: Firewall and SSH hardening applied
- [ ] **Verify development tools**: mise, uv, nodejs installed

## Final Verification ✅

- [ ] **Run smoke tests**: `mise run smoke-test` (now using Ansible)
- [ ] **Docker check**: `ssh ansible@192.168.10.250 'docker --version'`
- [ ] **Services running**: Docker, fail2ban, nftables active
- [ ] **Development tools**: mise, uv, nodejs functional
- [ ] **Total deployment time**: Confirm < 60 seconds

## Emergency Procedures 🆘

### Rollback Procedures

**Stage-specific rollback:**

```bash
# Rollback Ansible changes only
ansible-playbook playbooks/rollback.yml -i inventory.json

# Rollback Terraform infrastructure
terraform destroy -target=module.jump_man -auto-approve

# Remove Packer template
# Manual removal needed in Proxmox UI or via API
```

### Debug Connection Issues

```bash
# Check VM status in Proxmox
qm status 7000

# Verify network connectivity
ping 192.168.10.250

# Check SSH service (minimal cloud-init should have started it)
ssh ansible@192.168.10.250 "systemctl status ssh"
```

### Debug Ansible Issues

```bash
# Run with verbose output
ansible-playbook -vvv playbooks/site.yml -i inventory.json

# Check specific role
ansible-playbook playbooks/site.yml -i inventory.json --tags docker

# Verify inventory
ansible-inventory -i inventory.json --list
```

## Mission Complete 🎯

- [ ] **Document IP/access**: Update team wiki/docs
- [ ] **Commit state file**: If using local backend
- [ ] **Schedule Ansible hardening**: Next phase configuration
