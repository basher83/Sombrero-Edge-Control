# Move to Ansible for Post-Deployment Configuration

- Status: accepted
- Date: 2025-09-02
- Tags: ansible, terraform, configuration, infrastructure

## Context and Problem Statement

During the implementation of the jump-man VM deployment, we encountered issues with cloud-init vendor-data processing. The cloud-init status shows "degraded done" with warnings about "Unhandled non-multipart (text/x-not-multipart) userdata". This resulted in:

- Docker installation scripts not being created (`/opt/docker-install.sh` missing)
- Advanced configuration tasks (firewall setup, development tools) not executing
- Complex debugging of multipart MIME formatting in cloud-init

Our current approach attempts to handle both basic provisioning (user-data) and advanced configuration (vendor-data) through cloud-init, which has proven unreliable in the Proxmox NoCloud datasource environment.

## Decision Outcome

Chosen option: "Adopt separation of concerns with Terraform + Ansible", because we needed a reliable, industry-standard approach to handle complex post-deployment configuration that cloud-init alone couldn't provide consistently.

### Positive Consequences

- **Separation of Concerns**: Clear boundary between infrastructure (Terraform) and configuration (Ansible)
- **Better Error Handling**: Ansible provides robust error handling, retries, and task-level debugging
- **Idempotent Operations**: Can safely re-run configuration without side effects
- **Industry Standard Pattern**: Follows widely-adopted DevOps practices
- **Easier Debugging**: Task-by-task feedback and detailed logging
- **Team Collaboration**: More maintainable for teams familiar with Ansible
- **Flexibility**: Can easily add new configuration tasks without Terraform changes

### Negative Consequences

- **Additional Tool Dependency**: Requires Ansible to be installed and configured
- **Two-Step Deployment**: Must run Terraform first, then Ansible (vs single cloud-init)
- **Learning Curve**: Team members need Ansible knowledge

## Considered Options

### Fix Cloud-Init Multipart Issues

**Description**: Debug and resolve the vendor-data processing issues in cloud-init

- Good, because: Maintains single-tool deployment process
- Good, because: No additional dependencies
- Bad, because: Complex multipart MIME debugging in Proxmox environment
- Bad, because: Vendor-data limitations in NoCloud datasource
- Bad, because: Single point of failure for all configuration

### Move Everything to User-Data

**Description**: Consolidate all configuration into a single user-data file

- Good, because: Simpler deployment process
- Good, because: No vendor-data complexity
- Bad, because: Creates monolithic configuration files
- Bad, because: Harder to maintain and debug
- Bad, because: Still subject to cloud-init limitations

### Custom Shell Scripts via Cloud-Init

**Description**: Use cloud-init runcmd to download and execute custom scripts

- Good, because: Flexible configuration approach
- Good, because: Can use existing scripting knowledge
- Bad, because: Network dependencies during provisioning
- Bad, because: Limited error handling and retry capabilities
- Bad, because: No idempotency guarantees

## Links

- [Cloud-Init NoCloud Datasource Documentation](https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html)
- [Docker Installation Documentation](https://docs.docker.com/engine/install/ubuntu/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [Infrastructure as Code Patterns](https://www.terraform.io/use-cases/infrastructure-as-code)
