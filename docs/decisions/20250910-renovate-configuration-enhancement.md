# Enhance Renovate Configuration for Infrastructure Dependencies

- Status: proposed
- Date: 2025-09-10
- Tags: dependencies, automation, renovate, infrastructure

## Context and Problem Statement

The current Renovate configuration uses only the minimal `config:recommended` preset. This doesn't address the specific needs of an infrastructure-as-code repository that manages Terraform providers, Ansible collections, Packer plugins, GitHub Actions, and mise-managed tools. Each dependency type requires different update strategies to balance automation with stability.

## Decision Outcome

Chosen option: "Infrastructure-focused configuration with selective automation", because it provides the right balance between automation and control for infrastructure dependencies while maintaining production stability.

### Positive Consequences

1. **Reduced Manual Overhead**
   - Automated patch updates for low-risk dependencies
   - Security patches applied automatically for GitHub Actions
   - Less time spent on routine dependency management

2. **Better Organization**
   - Related updates grouped together (Ansible collections, GitHub Actions)
   - Clear dependency dashboard for tracking all updates
   - Semantic commit messages for changelog generation

3. **Improved Stability**
   - Major updates require explicit approval
   - Infrastructure tools (Terraform, Packer, Ansible) pinned for consistency
   - Scheduled updates during low-activity periods (early Mondays)

### Negative Consequences

1. **Configuration Complexity**
   - More complex configuration to maintain
   - Requires understanding of Renovate's DSL

2. **Monitoring Requirements**
   - Need to monitor auto-merge behavior
   - May require fine-tuning based on actual patterns

## Implementation Details

The enhanced configuration includes:

### Core Extensions

- `config:recommended` - Base best practices
- `:semanticCommits` - Structured commit messages
- `:dependencyDashboard` - Issue-based update tracking
- `schedule:earlyMondays` - Predictable update timing

### Package Rules

1. **Terraform Providers** - Auto-merge patches only
2. **Ansible Collections** - Group all collection updates
3. **Infrastructure Tools** - Pin versions in mise for stability
4. **GitHub Actions** - Auto-merge patches and minor updates
5. **Proxmox Provider** - Require approval for major updates

### Custom Managers

1. **Mise Tools** - Regex manager for `.mise.toml` versions
2. **Packer Plugins** - Custom extraction from `.pkr.hcl` files
3. **Ansible Galaxy** - Parse `requirements.yml` for collections

### Configuration Features

- PR concurrent limit: 3 (prevent overwhelming CI)
- Vulnerability alerts with security labels
- Commit message format: `chore(deps): update {{depName}} to {{newVersion}}`

## Links

- Implements dependency management best practices for IaC pipelines
- Related to infrastructure stability requirements in Project-PRP.md
