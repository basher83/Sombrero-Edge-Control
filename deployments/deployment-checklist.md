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

## 🚨 Issues & Resolutions Log

> **Purpose**: Document any issues encountered during deployment for future reference and process improvement.
>
> **Guidelines for Issue Documentation:**
> - Be specific with error messages (copy/paste exact text)
> - Include timestamps to help with timeline analysis
> - Focus on root cause, not just symptoms
> - Document what was tried that didn't work
> - Suggest prevention measures for future deployments

### Issue #1: [TITLE]
- **Phase**: [Pre-flight/Take-off/Post-flight/Emergency]
- **Time**: [HH:MM]
- **Description**: [Brief description of the issue]
- **Error/Symptoms**:
  ```
  [Paste error messages or describe symptoms]
  ```
- **Root Cause**: [What caused this issue?]
- **Resolution**: [How was it resolved?]
- **Time to Resolve**: [Duration from discovery to resolution]
- **Impact**: [High/Medium/Low - effect on deployment]
- **Prevention**: [How can this be prevented in future deployments?]

### Issue #2: [TITLE]
- **Phase**:
- **Time**:
- **Description**:
- **Error/Symptoms**:
- **Root Cause**:
- **Resolution**:
- **Time to Resolve**:
- **Impact**:
- **Prevention**:

*Add more issues as needed...*

---

## 📚 Lessons Learned & Improvements

### What Went Well ✅
- [List successful aspects of this deployment]
- [Tools/processes that worked effectively]
- [Time-saving discoveries]

### What Could Be Improved 🔄
- [Areas for process improvement]
- [Missing automation opportunities]
- [Documentation gaps identified]

### Action Items for Next Deployment 📋
- [ ] **[Priority]** [Specific action item with owner]
- [ ] **[Priority]** [Process improvement needed]
- [ ] **[Priority]** [Documentation to update]

### Process Metrics 📊
- **Total Deployment Time**: [HH:MM]
- **Issue Resolution Time**: [HH:MM]
- **Unplanned Work**: [Percentage of total time]
- **Automation Coverage**: [Manual steps remaining]

---

## Mission Complete 🎯

- [ ] **Document IP/access**: Update team wiki/docs
- [ ] **Commit state file**: If using local backend
- [ ] **Schedule Ansible hardening**: Next phase configuration
- [ ] **Update process documentation**: Based on lessons learned
- [ ] **File improvement tickets**: For identified action items
- [ ] **Share deployment summary**: With team/stakeholders
