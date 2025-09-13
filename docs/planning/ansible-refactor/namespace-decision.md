# Ansible Collection Namespace Decision

## Chosen Namespace

**`basher83.automation_server.role_name`**

## Rationale

### Username Component: `basher83`

- Uses GitHub username for consistency and ownership identification
- Follows Ansible collection naming conventions
- Provides clear attribution to the collection maintainer

### Server Type Component: `automation_server`

- **Generic and widely understood term** for the VM's purpose
- Clearly indicates the system's role in running automation tasks
- Encompasses multiple automation domains:
  - Infrastructure as Code (IaC) deployments
  - Configuration management
  - Orchestration workflows

## Sources

- [Alooba - Automation Server Concept](https://www.alooba.com/skills/concepts/devops/automation-server/)
- [AttuneOps - What is Server Automation?](https://attuneops.io/what-is-server-automation/)

## Usage Examples

```yaml
# In playbooks
- hosts: automation_servers
  roles:
    - basher83.automation_server.docker
    - basher83.automation_server.terraform_outputs
    - basher83.automation_server.vm_lifecycle
```

## Decision Date

September 12, 2025
