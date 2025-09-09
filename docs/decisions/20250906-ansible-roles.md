# Adopt Ansible Role-First Architecture

- Status: proposed
- Date: 2025-09-06
- Tags: ansible, roles, architecture, operations

## Context and Problem Statement

The current Sombrero Edge Control deployment pipeline uses a mixed approach for remote operations:

1. Direct SSH commands scattered throughout the runbook and scripts
2. Shell scripts for smoke testing and validation
3. Ansible playbooks for some configuration tasks
4. Manual verification steps using ping and curl

This mixed approach violates the principle documented in our Terraform + Ansible Integration Guide that Ansible should be the single orchestration layer for all remote operations after environment setup.

## Decision Outcome

Chosen option: "Ansible Role-First Architecture", because we need a consistent, maintainable approach to handle all post-deployment operations using industry best practices.

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

## Considered Options

### Terraform Provisioners

**Description**: Use Terraform's local-exec and remote-exec provisioners

- Good, because: Integrates with existing Terraform workflow
- Good, because: Familiar tool for infrastructure team
- Bad, because: Tightly couples Terraform and Ansible
- Bad, because: Increases Terraform execution time
- Bad, because: Harder to debug failures

### Maintain Status Quo

**Description**: Keep mixed approach with improvements

- Good, because: No major architectural changes
- Good, because: Builds on existing knowledge
- Bad, because: Doesn't address core maintainability issues
- Bad, because: Perpetuates inconsistent patterns
- Bad, because: Technical debt continues to grow

### Custom Orchestration Tool

**Description**: Build custom Go/Python tool to orchestrate operations

- Good, because: Complete control over the solution
- Good, because: Can be tailored to our exact needs
- Bad, because: Reinventing the wheel
- Bad, because: Additional maintenance burden
- Bad, because: No community support

## Links

- [Terraform + Ansible Integration Guide](../../deployment/terraform-ansible-integration-guide.md)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Scalr Ultimate Guide to Terraform + Ansible](https://scalr.com/learning-center/ultimate-guide-to-using-terraform-with-ansible/)
- [Molecule Documentation](https://molecule.readthedocs.io/)
