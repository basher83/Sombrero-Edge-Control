# Jump-Man Deployment Flight Checklist 🚀

## Pre-Flight Checks ✈️

- [ ] **Environment variables loaded**: `mise env` shows TF_VAR_* values
- [ ] **Initialize Terraform**: `mise run prod-init`
- [ ] **Validate configuration**: `mise run prod-validate`
- [ ] **Review plan**: `mise run prod-plan` (verify creating 2 resources)
- [ ] **Proxmox accessible**: `ping proxmox-host` succeeds
- [ ] **Template exists**: Verify Ubuntu template ID 8024 on node lloyd

## Take-Off 🛫

- [ ] **Deploy infrastructure**: `mise run prod-apply`
- [ ] **Monitor progress**: Watch Proxmox console for VM creation
- [ ] **Wait for cloud-init**: ~30-60 seconds for initial boot

## Post-Flight Verification ✅

- [ ] **Quick connectivity**: `mise run smoke-test-quick`
- [ ] **Full smoke tests**: `mise run smoke-test`
- [ ] **Docker check**: `mise run smoke-test-docker`
- [ ] **SSH access**: `ssh ansible@192.168.10.250`
- [ ] **Verify hostname**: Returns `jump-man`
- [ ] **Check services**: Docker running, QEMU agent active

## Emergency Procedures 🆘

### Rollback
```bash
terraform destroy -target=module.jump_man -auto-approve
```

### Debug cloud-init
```bash
ssh ansible@192.168.10.250 "sudo cloud-init status --long"
ssh ansible@192.168.10.250 "sudo journalctl -u cloud-init"
```

### Connection timeout
```bash
# Check VM status in Proxmox
qm status 7000

# Check network from Proxmox host
ping 192.168.10.250
```

## Mission Complete 🎯

- [ ] **Document IP/access**: Update team wiki/docs
- [ ] **Commit state file**: If using local backend
- [ ] **Schedule Ansible hardening**: Next phase configuration
