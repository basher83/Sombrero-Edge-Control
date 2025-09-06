# ADR-2025-01-06: Adopt Ansible Role-First Architecture

## Status

**PROPOSED** - Under Review

## Context

The current Sombrero Edge Control deployment pipeline uses a mixed approach for remote operations:

1. **Direct SSH commands** scattered throughout the runbook and scripts
2. **Shell scripts** for smoke testing and validation
3. **Ansible playbooks** for some configuration tasks
4. **Manual verification** steps using ping and curl

This mixed approach violates the principle documented in our [Terraform + Ansible Integration Guide](../../deployment/terraform-ansible-integration-guide.md) that Ansible should be the single orchestration layer for all remote operations.

### Problems with Current Approach

- **Maintainability**: Logic scattered across multiple files and languages
- **Testability**: Cannot unit test bash scripts with SSH commands
- **Consistency**: Different patterns for similar operations
- **Debugging**: Difficult to troubleshoot across tool boundaries
- **Security**: Complex SSH key management
- **Idempotency**: Shell scripts lack idempotency guarantees

### Industry Best Practices

According to the Scalr Ultimate Guide and Ansible documentation:
- Use Ansible as the single orchestration layer
- Structure operations as reusable roles
- Maintain clear separation between provisioning (Terraform) and configuration (Ansible)
- Avoid Terraform provisioners for complex configuration

## Decision

We will adopt an **Ansible Role-First Architecture** where:

1. **ALL remote operations** after environment setup use Ansible
2. **Operations are structured as reusable roles** following Ansible best practices
3. **Playbooks become thin wrappers** around role invocations
4. **No direct SSH commands** except in documentation for manual troubleshooting
5. **Testing via Molecule** for all roles

### Architecture Pattern

```
Environment Setup (Local) → Packer (Build) → Terraform (Provision) → Ansible Only (Everything Else)
```

### Role Categories

1. **Infrastructure Validation** - Proxmox readiness checks
2. **Deployment Validation** - Smoke tests and verification
3. **Operational Tasks** - Diagnostics, troubleshooting, lifecycle
4. **Integration** - Terraform output parsing, inventory generation

## Consequences

### Positive Consequences

1. **Improved Maintainability**
   - Single language (YAML) for all operations
   - Consistent patterns across all tasks
   - Reusable components

2. **Better Testing**
   - Molecule tests for each role
   - Idempotency verification
   - CI/CD integration

3. **Enhanced Security**
   - Centralized credential management
   - Ansible Vault for secrets
   - Consistent access patterns

4. **Operational Benefits**
   - Easier debugging with consistent tooling
   - Better error messages and handling
   - Ansible's extensive module library

5. **Team Efficiency**
   - Single tool to learn and master
   - Clear separation of concerns
   - Better documentation patterns

### Negative Consequences

1. **Learning Curve**
   - Team needs Ansible role development skills
   - Understanding of Molecule testing
   - YAML syntax proficiency

2. **Initial Development Effort**
   - Time to create and test all roles
   - Migration from existing scripts
   - Documentation updates

3. **Potential Performance Impact**
   - Ansible overhead vs direct SSH
   - Fact gathering time
   - Module execution overhead

### Mitigation Strategies

1. **Learning Curve**: Comprehensive documentation and training sessions
2. **Development Effort**: Phased migration with parallel operation
3. **Performance**: Optimization with fact caching, async tasks, and parallelization

## Alternatives Considered

### Alternative 1: Terraform Provisioners

**Pattern**: Use Terraform's local-exec and remote-exec provisioners

```hcl
provisioner "local-exec" {
  command = "ansible-playbook -i ${self.ip} playbook.yml"
}
```

**Rejected Because**:
- Tightly couples Terraform and Ansible
- Increases Terraform execution time
- Harder to debug failures
- Goes against HashiCorp's own recommendations

### Alternative 2: Maintain Status Quo

**Pattern**: Keep mixed approach with improvements

**Rejected Because**:
- Doesn't address core maintainability issues
- Perpetuates inconsistent patterns
- Technical debt continues to grow
- Against industry best practices

### Alternative 3: Custom Orchestration Tool

**Pattern**: Build custom Go/Python tool to orchestrate operations

**Rejected Because**:
- Reinventing the wheel
- Additional maintenance burden
- No community support
- Longer development time

## Implementation Plan

### Phase 1: Planning (Week 1)
- ✅ Document refactor plan
- ✅ Create role specifications
- ✅ Define migration strategy
- ✅ Create this ADR

### Phase 2: Development (Week 2)
- Create role structure
- Implement core roles
- Add Molecule tests

### Phase 3: Integration (Week 3)
- Create playbooks
- Update mise tasks
- Modify CI/CD

### Phase 4: Migration (Week 4)
- Parallel validation
- Cutover to new system
- Deprecate old scripts

## Validation Criteria

The decision will be considered successful when:

1. **Technical Metrics**
   - Zero SSH commands in operational runbooks
   - 100% role test coverage with Molecule
   - Deployment time ≤ current baseline
   - All operations idempotent

2. **Quality Metrics**
   - Reduced total lines of code
   - Improved test coverage (>90%)
   - Faster mean time to resolution

3. **Team Metrics**
   - Positive feedback from development team
   - Reduced onboarding time for new members
   - Decreased debugging time

## References

1. [Terraform + Ansible Integration Guide](../../deployment/terraform-ansible-integration-guide.md)
2. [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
3. [Scalr Ultimate Guide to Terraform + Ansible](https://scalr.com/learning-center/ultimate-guide-to-using-terraform-with-ansible/)
4. [HashiCorp on Provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#provisioners-are-a-last-resort)
5. [Molecule Documentation](https://molecule.readthedocs.io/)

## Appendix: Example Role Structure

```yaml
# Example: vm_smoke_tests role structure
vm_smoke_tests/
├── defaults/
│   └── main.yml         # Default variables
├── tasks/
│   ├── main.yml         # Entry point
│   ├── infrastructure.yml
│   ├── services.yml
│   └── security.yml
├── handlers/
│   └── main.yml         # Event handlers
├── templates/
│   └── report.j2        # Test report template
├── molecule/
│   └── default/
│       ├── molecule.yml # Test configuration
│       └── verify.yml   # Verification tests
└── README.md            # Documentation
```

## Decision History

| Date | Status | Author | Notes |
|------|--------|--------|-------|
| 2025-01-06 | PROPOSED | AI IDE Agent | Initial draft based on runbook review |
| TBD | REVIEWED | TBD | Pending review |
| TBD | ACCEPTED | TBD | Pending approval |

## Review Comments

*Space for review comments and feedback*

---

**Document Version**: 1.0.0
**Template Version**: [ADR Template](../ADR-TEMPLATE.md)
