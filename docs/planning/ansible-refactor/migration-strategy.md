# Migration Strategy: Shell Scripts to Ansible Roles

## Overview

This document outlines the step-by-step strategy for migrating from the current shell-based operations to Ansible roles 
while maintaining operational continuity.

## Migration Principles

1. **Zero Downtime**: Production operations continue uninterrupted
2. **Incremental Adoption**: Migrate component by component
3. **Rollback Ready**: Keep legacy scripts operational during transition
4. **Parallel Validation**: Run both approaches for verification
5. **Feature Flagging**: Environment-based switching between implementations

## Current State Inventory

### Shell Scripts to Migrate

| Script/Command | Location | Criticality | Migration Priority |
|----------------|----------|-------------|-------------------|
| smoke-test.sh | scripts/ | High | 1 |
| Direct SSH in RUNBOOK | deployments/RUNBOOK.md | High | 2 |
| restart-vm-ssh.sh | scripts/ | Medium | 3 |
| Inline SSH in mise tasks | .mise.toml | Low | 4 |

### Direct Commands to Replace

```bash
# Current direct commands in runbook
ssh ansible@192.168.10.250 'hostname'
ssh ansible@192.168.10.250 'docker --version'
ssh ansible@192.168.10.250 'systemctl status docker'
ping 192.168.10.250
curl -k ${TF_VAR_pve_api_url}/version
ssh root@proxmox-host "qm list"
```

## Migration Phases

### Phase 1: Parallel Infrastructure (Week 1)

**Objective**: Create Ansible role structure without disrupting current operations

**Actions**:

1. Create role directory structure
2. Implement basic role templates
3. Set up Molecule testing framework
4. Create development inventory

**Deliverables**:

```
ansible/
├── roles/           # New
│   ├── proxmox_validation/
│   ├── vm_smoke_tests/
│   └── ...
├── playbooks/       # Enhanced
│   ├── smoke-test.yml     # New
│   └── post-deploy.yml    # Existing
└── inventory/       # Enhanced
    ├── production/  # Existing
    └── development/ # New for testing
```

### Phase 2: Component Migration (Week 2)

**Objective**: Migrate individual components with validation

#### 2.1 Smoke Tests Migration

**Current State**:

```bash
# scripts/smoke-test.sh
run_test "SSH connectivity" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'exit 0'"
run_test "Docker service running" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'systemctl is-active docker'"
```

**Target State**:

```yaml
# ansible/playbooks/smoke-test.yml
- name: Run smoke tests
  hosts: jump_hosts
  roles:
    - vm_smoke_tests
```

**Migration Steps**:

1. Implement vm_smoke_tests role
2. Create playbook wrapper
3. Add mise task for Ansible version
4. Run both versions in parallel
5. Compare results
6. Deprecate shell script

#### 2.2 Proxmox Validation Migration

**Current State**:

```bash
# In RUNBOOK.md
curl -k ${TF_VAR_pve_api_url}/version
ssh root@proxmox-host "qm list | grep 1001"
```

**Target State**:

```yaml
# ansible/playbooks/validate-infrastructure.yml
- name: Validate Proxmox infrastructure
  hosts: localhost
  roles:
    - proxmox_validation
```

**Migration Steps**:

1. Implement proxmox_validation role
2. Use Proxmox API modules
3. Test against development Proxmox
4. Update runbook documentation

### Phase 3: Integration Updates (Week 3)

**Objective**: Update tooling and documentation

#### 3.1 mise Task Migration

**Current Tasks**:

```toml
[tasks.smoke-test]
run = "./scripts/smoke-test.sh"

[tasks.smoke-test-quick]
run = "ssh ansible@192.168.10.250 'hostname'"
```

**New Tasks**:

```toml
# Ensure Ansible tools are available
[tools]
ansible-core = "2.19.1"  # Already present in .mise.toml

# Keep legacy tasks during transition
[tasks.smoke-test-legacy]
description = "Legacy shell-based smoke tests (deprecated)"
run = "./scripts/smoke-test.sh"

# New Ansible-based tasks
[tasks.smoke-test]
description = "Run smoke tests via Ansible roles"
run = "ansible-playbook -i inventory/production playbooks/smoke-test.yml"

[tasks.smoke-test-quick]
description = "Quick connectivity test via Ansible"
run = "ansible jump_hosts -i inventory/production -m command -a 'hostname'"

# Development setup task
[tasks.ansible-dev-setup]
description = "Setup Ansible development environment"
run = """
mise install  # Ensure all mise tools are installed
uv venv       # Create Python venv for Molecule and ansible-lint
source .venv/bin/activate
uv pip install molecule[docker] ansible-lint pytest-testinfra
"""

# Feature flag for switching
[tasks.test]
description = "Run tests (legacy or Ansible based on feature flag)"
run = """
if [ "$USE_ANSIBLE_ROLES" = "true" ]; then
  mise run smoke-test
else
  mise run smoke-test-legacy
fi
"""
```

#### 3.2 Runbook Updates

**Strategy**: Section-by-section replacement

1. **Environment Setup**: No changes (local only)
2. **Stage 1 (Packer)**: Replace verification commands
3. **Stage 2 (Terraform)**: Remove SSH tests
4. **Stage 3 (Ansible)**: Already uses Ansible
5. **Verification**: Replace with playbook calls
6. **Troubleshooting**: Update to reference diagnostic playbooks

### Phase 4: Validation & Cutover (Week 4)

**Objective**: Validate new implementation and switch over

#### 4.1 Validation Checklist

- [ ] All roles pass Molecule tests
- [ ] Playbooks execute successfully in dev
- [ ] Performance benchmarks acceptable
- [ ] Documentation updated
- [ ] Team trained on new approach
- [ ] Rollback procedures tested

#### 4.2 Cutover Plan

**Day 1-2: Staging Validation**

```bash
# Run full pipeline with Ansible roles in staging
ENV=staging USE_ANSIBLE_ROLES=true mise run deploy-full
```

**Day 3: Production Parallel Run**

```bash
# Run both implementations
mise run smoke-test-legacy > /tmp/legacy.out
mise run smoke-test > /tmp/ansible.out
diff /tmp/legacy.out /tmp/ansible.out
```

**Day 4: Switch Default**

```toml
# .mise.toml
[env]
USE_ANSIBLE_ROLES = "true"  # Make Ansible default
```

**Day 5: Monitor & Adjust**

- Monitor for issues
- Quick rollback if needed
- Document lessons learned

## Rollback Procedures

### Immediate Rollback

```bash
# Switch back to legacy implementation
export USE_ANSIBLE_ROLES=false
mise run deploy-full
```

### Partial Rollback

```toml
# Rollback specific components
[tasks.smoke-test]
run = "./scripts/smoke-test.sh"  # Revert to shell script

[tasks.validate]
run = "ansible-playbook playbooks/validate.yml"  # Keep Ansible
```

## Risk Mitigation

### Risk 1: Ansible Module Compatibility

**Mitigation**:

- Test all modules in development first
- Have fallback shell modules ready
- Document module version requirements

### Risk 2: Performance Degradation

**Mitigation**:

- Benchmark both implementations
- Optimize with fact caching
- Use async tasks where appropriate

### Risk 3: Team Knowledge Gap

**Mitigation**:

- Create comprehensive documentation
- Provide hands-on training sessions
- Pair programming during implementation

## Success Metrics

### Quantitative Metrics

| Metric | Current Baseline | Target | Acceptable Range |
|--------|-----------------|--------|------------------|
| Smoke test duration | 45 seconds | 30 seconds | 25-40 seconds |
| Lines of code | 500 (shell) | 300 (Ansible) | 250-350 |
| Test coverage | 60% | 90% | 85-95% |
| Deployment time | 4 minutes | 4 minutes | 3-5 minutes |

### Qualitative Metrics

- Improved maintainability (survey team)
- Better debugging experience
- Cleaner code organization
- Easier onboarding for new team members

## Communication Plan

### Week 1: Announcement

- Email to team about upcoming changes
- Overview presentation in team meeting
- Share planning documents

### Week 2: Progress Updates

- Daily standups include migration status
- Slack channel for questions
- Demo sessions for completed roles

### Week 3: Training

- Hands-on workshop for Ansible roles
- Documentation walkthrough
- Q&A session

### Week 4: Cutover Communication

- Cutover schedule announcement
- Real-time status updates
- Post-cutover retrospective

## Tools and Resources

### Required Tools

```toml
# .mise.toml [tools] section
ansible-core = "2.19.1"  # Already present - this is the only Ansible tool in mise
```

```bash
# For Python packages (molecule, ansible-lint), use uv in a virtual environment:
uv venv
source .venv/bin/activate
uv pip install molecule[docker]>=4.0 ansible-lint>=6.22.2
```

```bash
# Verify installations via mise
mise install  # Install all tools defined in .mise.toml
mise ls       # List installed tools and versions

# Verify Ansible
ansible --version

# For molecule (installed via uv)
source .venv/bin/activate
molecule --version
```

### Documentation Resources

- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Ansible Module Index](https://docs.ansible.com/ansible/latest/module_plugin_guide/modules_intro.html)
- Internal: [Terraform + Ansible Integration Guide](../../deployment/terraform-ansible-integration-guide.md)

## Appendix A: Command Mapping

| Shell Command | Ansible Equivalent |
|---------------|-------------------|
| `ssh user@host 'command'` | `ansible host -m command -a 'command'` |
| `ssh user@host 'systemctl status service'` | `ansible host -m systemd -a 'name=service'` |
| `ping host` | `ansible host -m ping` |
| `curl url` | `ansible localhost -m uri -a 'url=url'` |
| Complex shell script | Ansible role with multiple tasks |

## Appendix B: File Retention Plan

### Files to Keep (Deprecated)

```
scripts/
├── smoke-test.sh.deprecated       # Renamed, kept for reference
├── restart-vm-ssh.sh.deprecated   # Renamed, kept for emergency
└── README.md                      # Updated with deprecation notice
```

### Files to Archive

```
archive/
└── 2025-01-ansible-migration/
    ├── original-scripts/
    ├── migration-notes.md
    └── performance-comparison.xlsx
```

## Next Steps

1. Review and approve migration strategy
2. Set up development environment
3. Begin Phase 1 implementation
4. Schedule team training sessions
5. Create migration tracking dashboard
