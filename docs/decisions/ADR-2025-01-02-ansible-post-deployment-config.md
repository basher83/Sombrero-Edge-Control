# ADR-2025-01-02: Move to Ansible for Post-Deployment Configuration

![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)
![Date](https://img.shields.io/badge/Date-2025--01--02-lightgrey)
![GitHub last commit](https://img.shields.io/github/last-commit/basher83/Sombrero-Edge-Control?path=docs%2Fdecisions%2FADR-2025-01-02-ansible-post-deployment-config.md&display_timestamp=author&style=plastic&logo=github)

## Status

Accepted

## Context

During the implementation of the jump-man VM deployment, we encountered issues with cloud-init vendor-data processing. The cloud-init status shows "degraded done" with warnings about "Unhandled non-multipart (text/x-not-multipart) userdata". This resulted in:

- Docker installation scripts not being created (`/opt/docker-install.sh` missing)
- Advanced configuration tasks (firewall setup, development tools) not executing
- Complex debugging of multipart MIME formatting in cloud-init

Our current approach attempts to handle both basic provisioning (user-data) and advanced configuration (vendor-data) through cloud-init, which has proven unreliable in the Proxmox NoCloud datasource environment.

## Decision

We will adopt a **separation of concerns** approach:

- **Terraform**: Handle infrastructure provisioning (VM creation, networking, basic OS bootstrap)
- **Ansible**: Handle post-deployment configuration (Docker, security hardening, development tools)

Cloud-init will be simplified to only handle essential bootstrapping:
- OS package updates
- User account creation
- SSH key deployment
- QEMU guest agent setup

All advanced configuration will be moved to Ansible playbooks executed after Terraform deployment.

## Consequences

### Positive

- **Separation of Concerns**: Clear boundary between infrastructure (Terraform) and configuration (Ansible)
- **Better Error Handling**: Ansible provides robust error handling, retries, and task-level debugging
- **Idempotent Operations**: Can safely re-run configuration without side effects
- **Industry Standard Pattern**: Follows widely-adopted DevOps practices
- **Easier Debugging**: Task-by-task feedback and detailed logging
- **Team Collaboration**: More maintainable for teams familiar with Ansible
- **Flexibility**: Can easily add new configuration tasks without Terraform changes

### Negative

- **Additional Tool Dependency**: Requires Ansible to be installed and configured
- **Two-Step Deployment**: Must run Terraform first, then Ansible (vs single cloud-init)
- **Learning Curve**: Team members need Ansible knowledge
- **Inventory Management**: Need to maintain Ansible inventory (though can be generated from Terraform)

### Risks

- **State Drift**: Configuration could drift between Ansible runs if not regularly applied
- **Connectivity Dependencies**: Ansible requires SSH connectivity to target hosts
- **Timing Issues**: Need to ensure VM is fully ready before running Ansible tasks

## Alternatives Considered

### Alternative 1: Fix Cloud-Init Multipart Issues

- **Description**: Debug and resolve the vendor-data processing issues in cloud-init
- **Why we didn't choose it**:
  - Complex multipart MIME debugging in Proxmox environment
  - Vendor-data limitations in NoCloud datasource
  - Single point of failure for all configuration
  - Less flexible for future configuration changes

### Alternative 2: Move Everything to User-Data

- **Description**: Consolidate all configuration into a single user-data file
- **Why we didn't choose it**:
  - Creates monolithic configuration files
  - Harder to maintain and debug
  - Still subject to cloud-init limitations
  - Less modular and reusable

### Alternative 3: Custom Shell Scripts via Cloud-Init

- **Description**: Use cloud-init runcmd to download and execute custom scripts
- **Why we didn't choose it**:
  - Network dependencies during provisioning
  - Limited error handling and retry capabilities
  - No idempotency guarantees
  - Harder to manage configuration state

## Implementation

Key steps to implement this decision:

1. **Simplify Cloud-Init Configuration**
   - Remove vendor-data from Terraform configuration
   - Keep only essential bootstrapping in user-data
   - Test simplified cloud-init deployment

2. **Create Ansible Playbook Structure**
   - Set up ansible/ directory with proper structure
   - Create inventory files (can be generated from Terraform outputs)
   - Develop playbooks for Docker installation and configuration

3. **Update Deployment Process**
   - Modify deployment scripts to run terraform apply followed by ansible-playbook
   - Update deployment checklists to include Ansible steps
   - Document the two-phase deployment process

4. **Create Ansible Tasks**
   - Docker CE installation and configuration
   - User group management (docker group)
   - Firewall configuration (iptables for Docker compatibility)
   - Development tools (Node.js, npm, mise, uv)
   - Security hardening

5. **Update Documentation**
   - Update README.md with new deployment process
   - Update WARP.md with Ansible commands
   - Create Ansible-specific documentation

## References

- [Cloud-Init NoCloud Datasource Documentation](https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html)
- [Docker Installation Documentation](https://docs.docker.com/engine/install/ubuntu/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [Infrastructure as Code Patterns](https://www.terraform.io/use-cases/infrastructure-as-code)
