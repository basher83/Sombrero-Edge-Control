# Ansible-First Infrastructure Refactor Plan

## Executive Summary

This document outlines the comprehensive plan to refactor the Sombrero Edge Control deployment pipeline from direct SSH/shell operations to a role-based Ansible architecture. This aligns with industry best practices as documented in our [Terraform + Ansible Integration Guide](../../deployment/terraform-ansible-integration-guide.md).

## Current State Analysis

### Problem Statement

The current deployment runbook violates the principle of using Ansible as the single orchestration layer:

1. **Direct SSH Commands**: Multiple `ssh ansible@192.168.10.250` commands throughout the runbook
2. **Shell-based Testing**: Smoke tests use bash scripts with SSH instead of Ansible modules
3. **Manual Verification**: Ping tests and curl commands that should be Ansible tasks
4. **Inconsistent Patterns**: Mix of automation approaches reduces maintainability

### Current Architecture

```
Packer (Build) → Terraform (Deploy) → Mixed (SSH + Ansible) → Manual Verification
```

### Impact

- **Maintainability**: Scattered logic across bash scripts and direct commands
- **Testability**: Cannot easily test operations without full deployment
- **Consistency**: Different patterns for similar operations
- **Security**: SSH key management complexity
- **Debugging**: Harder to troubleshoot across tool boundaries

## Target State

### Principles

Following the **Decoupled Dynamic Inventory Pattern** with these core tenets:

1. **Ansible Roles First**: All operations structured as reusable, testable roles
2. **Zero Direct SSH**: No SSH commands after environment setup
3. **Idempotent Operations**: Every task safely repeatable
4. **Single Orchestration Layer**: Ansible handles ALL remote operations
5. **Clear Separation**: Packer builds, Terraform provisions, Ansible configures

### Target Architecture

```
Packer (Build) → Terraform (Deploy) → Ansible Only (Configure/Validate/Operate)
```

## Implementation Strategy

### Phase 1: Planning & Documentation (Current)

**Timeline**: January 6-8, 2025
**Status**: In Progress

**Deliverables**:
- [x] Planning directory structure
- [ ] This refactor plan document
- [ ] Role specifications
- [ ] Migration strategy
- [ ] Testing strategy
- [ ] Architecture Decision Record (ADR)

### Phase 2: Role Development

**Timeline**: January 9-15, 2025
**Status**: Not Started

#### Research-First Approach

Before creating any role, invoke the **ansible-research subagent** to:

1. **Discover existing collections** that solve similar problems
2. **Evaluate quality** using the 100-point scoring system
3. **Determine integration strategy**:
   - Use existing collection (Tier 1: 80-100 points)
   - Reference for patterns (Tier 2: 60-79 points)
   - Build custom with learnings (Tier 3 or below)

Example research invocations:
```
# For proxmox_validation role
"Use ansible-research to discover proxmox ansible collections"

# For docker_validation role
"Use ansible-research to analyze community.docker collection"

# For general patterns
"Use ansible-research to discover ansible testing collections"
```

**Ansible Roles to Create**:

#### Core Infrastructure Roles

1. **proxmox_validation**
   - Verify Proxmox API connectivity
   - Validate template existence and metadata
   - Check node availability and resources

2. **terraform_outputs**
   - Parse Terraform state/outputs
   - Generate dynamic inventory
   - Validate infrastructure provisioning

#### Validation Roles

3. **vm_smoke_tests**
   - Infrastructure validation (network, DNS, hostname)
   - Service validation (Docker, QEMU agent)
   - Security validation (firewall, SSH config)
   - Package installation verification

4. **docker_validation**
   - Docker service health
   - Container runtime tests
   - Network configuration
   - Volume management

#### Operational Roles

5. **vm_diagnostics**
   - Log collection
   - Service status reporting
   - Network troubleshooting
   - Performance metrics

6. **vm_lifecycle**
   - Safe rollback procedures
   - State cleanup
   - Emergency recovery

### Phase 3: Playbook Creation

**Timeline**: January 16-18, 2025
**Status**: Not Started

**Playbooks to Create**:

```yaml
ansible/playbooks/
├── validate-infrastructure.yml  # Pre-deployment validation
├── configure-vm.yml             # Post-deployment configuration (existing)
├── smoke-test.yml              # Comprehensive validation suite
├── diagnose.yml                # Troubleshooting operations
├── rollback.yml                # Safe destruction and cleanup
└── full-pipeline.yml           # Orchestrate entire deployment
```

### Phase 4: Integration Updates

**Timeline**: January 19-22, 2025
**Status**: Not Started

**Updates Required**:

1. **mise Configuration**:
   ```toml
   # Note: ansible-core is already in .mise.toml [tools] section
   # Python packages (ansible-lint, molecule) are installed via uv

   # Add new tasks for Ansible operations
   [tasks.validate-proxmox]
   description = "Validate Proxmox infrastructure readiness"
   run = "ansible-playbook -i localhost, playbooks/validate-infrastructure.yml"

   [tasks.smoke-test]
   description = "Run comprehensive smoke tests via Ansible"
   run = "ansible-playbook -i inventory/production playbooks/smoke-test.yml"

   [tasks.diagnose]
   description = "Run diagnostic playbook for troubleshooting"
   run = "ansible-playbook -i inventory/production playbooks/diagnose.yml"

   [tasks.ansible-setup]
   description = "Setup Ansible development environment with Molecule"
   run = """
   uv venv
   source .venv/bin/activate
   uv pip install molecule[docker] ansible-lint
   """

   [tasks.molecule-test]
   description = "Run Molecule tests for Ansible roles"
   run = """
   source .venv/bin/activate
   cd ansible/roles/${ROLE:-vm_smoke_tests}
   molecule test
   """
   ```

2. **GitHub Actions**:
   - Update CI/CD to use Ansible playbooks
   - Add Ansible role testing with Molecule

3. **Documentation**:
   - Update RUNBOOK.md to remove all SSH commands
   - Create role usage documentation
   - Update troubleshooting guides

### Phase 5: Migration & Testing

**Timeline**: January 23-25, 2025
**Status**: Not Started

**Activities**:
1. Deprecate shell-based scripts
2. Parallel run for validation
3. Performance comparison
4. Full regression testing
5. Documentation updates

## Success Criteria

### Technical Metrics

- [ ] Zero SSH commands in runbook (except troubleshooting explanations)
- [ ] All smoke tests converted to Ansible roles
- [ ] 100% idempotent operations
- [ ] Molecule tests for each role
- [ ] Performance maintained or improved

### Quality Metrics

- [ ] Reduced lines of code (consolidation)
- [ ] Improved test coverage
- [ ] Faster debugging cycles
- [ ] Cleaner separation of concerns

### Operational Metrics

- [ ] Deployment time ≤ current baseline
- [ ] All existing functionality preserved
- [ ] Rollback procedures tested
- [ ] Team trained on new approach

## Risk Management

### Identified Risks

1. **Learning Curve**
   - **Risk**: Team unfamiliar with Ansible roles
   - **Mitigation**: Comprehensive documentation and examples

2. **Migration Complexity**
   - **Risk**: Parallel maintenance during transition
   - **Mitigation**: Phased approach with fallback options

3. **Performance Impact**
   - **Risk**: Ansible overhead vs direct SSH
   - **Mitigation**: Optimize with facts caching, parallel execution

4. **Testing Coverage**
   - **Risk**: Missing edge cases in role conversion
   - **Mitigation**: Comprehensive Molecule test suite

## Dependencies

### Technical Dependencies

Tools managed via mise:
- ansible-core 2.19.1 (already in .mise.toml)
- Python 3.8+ (system requirement for Ansible)
- Docker (for Molecule test containers)

Python packages managed via uv:
- ansible-lint 6.22.2 (Python package for linting)
- molecule[docker]>=4.0 (Python package for testing)
- pytest-testinfra (for test assertions)

Installation in project-local venv:
```bash
uv venv
source .venv/bin/activate
uv pip install molecule[docker]>=4.0 ansible-lint>=6.22.2 pytest-testinfra
```

### Knowledge Dependencies

- Team training on Ansible best practices
- Understanding of role development
- Molecule testing framework

## Resource Requirements

### Development Resources

- 1 Senior DevOps Engineer (lead)
- 1 DevOps Engineer (implementation)
- Code review from platform team

### Infrastructure Resources

- Development environment for testing
- CI/CD pipeline updates
- Documentation platform

## Rollback Plan

If the refactor encounters critical issues:

1. **Preserve Current State**: Keep all existing scripts operational
2. **Feature Flag**: Environment variable to choose implementation
3. **Gradual Rollback**: Revert role by role if needed
4. **Documentation**: Clear instructions for using legacy approach

## Communication Plan

### Stakeholders

- Development Team (primary users)
- Platform Team (reviewers)
- Operations Team (support)

### Communication Strategy

1. **Weekly Updates**: Progress against plan
2. **Demo Sessions**: Show new capabilities
3. **Documentation**: Comprehensive guides
4. **Training**: Hands-on sessions

## Appendix

### A. File Mapping

| Current File | Target Role | Notes |
|--------------|------------|-------|
| scripts/smoke-test.sh | vm_smoke_tests | Full conversion to Ansible |
| Direct SSH in RUNBOOK.md | Various roles | Replace with playbook calls |
| scripts/restart-vm-ssh.sh | vm_diagnostics | Troubleshooting role |

### B. Command Conversion Examples

**Before**:
```bash
ssh ansible@192.168.10.250 'docker --version'
```

**After**:
```bash
ansible-playbook -i inventory/production playbooks/smoke-test.yml --tags docker
```

### C. Timeline Summary

- **Week 1** (Jan 6-8): Planning & Documentation
- **Week 2** (Jan 9-15): Role Development
- **Week 3** (Jan 16-22): Playbook & Integration
- **Week 4** (Jan 23-25): Migration & Testing
- **Week 5** (Jan 26-31): Production Rollout

## Approval

**Document Status**: DRAFT
**Version**: 1.0.0
**Last Updated**: January 6, 2025
**Author**: AI IDE Agent
**Reviewer**: [Pending]
**Approved By**: [Pending]

## Next Steps

1. Review and provide feedback on this plan
2. Adjust timeline and scope based on feedback
3. Create detailed role specifications
4. Begin Phase 2 implementation upon approval
