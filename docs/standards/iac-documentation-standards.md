# Infrastructure as Code Documentation Standards

## A Comprehensive Template for Terraform, Packer, and Ansible Projects

### Version: 1.0

### Last Updated: September 2025

---

## Table of Contents

1. [Overview](#overview)
2. [Documentation Philosophy](#documentation-philosophy)
3. [GitHub Integration Standards](#github-integration-standards)
4. [Tool-Specific Documentation Requirements](#tool-specific-documentation-requirements)
5. [Content Standards and Guidelines](#content-standards-and-guidelines)
6. [File Structure and Organization](#file-structure-and-organization)
7. [Markdown Standards and Formatting](#markdown-standards-and-formatting)
8. [Code Review and Quality Assurance](#code-review-and-quality-assurance)
9. [Maintenance and Lifecycle Management](#maintenance-and-lifecycle-management)
10. [Templates and Examples](#templates-and-examples)
11. [Compliance and Security Documentation](#compliance-and-security-documentation)
12. [Automation and Tooling](#automation-and-tooling)

---

## Overview

This document establishes comprehensive documentation standards for Infrastructure as Code (IaC) repositories utilizing **Terraform**, **Packer**, and **Ansible**. These standards ensure consistency, maintainability, and collaborative efficiency across all infrastructure projects while leveraging GitHub's native features for enhanced developer experience.

### Purpose

- Standardize documentation practices across all IaC projects
- Improve team collaboration and knowledge sharing
- Reduce onboarding time for new team members
- Ensure documentation remains current and actionable
- Leverage GitHub features for enhanced documentation workflow

### Scope

This standard applies to all repositories containing:

- Terraform configurations and modules
- Packer templates and build scripts
- Ansible playbooks, roles, and inventories
- Mixed infrastructure automation projects

---

## Documentation Philosophy

### Docs-as-Code Principles

Documentation must be treated as a first-class citizen alongside infrastructure code:

1. **Version Controlled**: All documentation lives in Git alongside the code it describes
2. **Peer Reviewed**: Documentation changes follow the same review process as code
3. **Automated Testing**: Documentation accuracy is validated through automation
4. **Living Documentation**: Content evolves with the infrastructure it describes

### Target Audiences

Documentation must serve multiple audiences with varying technical expertise:

- **DevOps Engineers**: Detailed technical implementation guides
- **Infrastructure Architects**: High-level design decisions and patterns
- **Security Teams**: Compliance requirements and security configurations
- **Operations Teams**: Deployment procedures and troubleshooting guides
- **New Team Members**: Onboarding and learning materials

---

## GitHub Integration Standards

### Repository Structure

Every IaC repository must contain these core documentation files:

```
.
├── README.md                    # Primary entry point
├── CHANGELOG.md                 # Version history and changes
├── CONTRIBUTING.md              # Contribution guidelines (TODO)
├── SECURITY.md                  # Security policies and reporting
├── docs/                        # Detailed documentation
│   ├── architecture/            # High-level design documents
│   ├── deployment/              # Deployment guides
│   ├── troubleshooting/         # Common issues and solutions
│   └── examples/                # Usage examples and tutorials
├── .github/                     # GitHub-specific configurations
│   ├── ISSUE_TEMPLATE/          # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md # PR template
│   └── workflows/               # CI/CD workflows
└── scripts/                     # Automation scripts
```

### GitHub Pages Integration

#### Mandatory Setup

- **Enable GitHub Pages** for all documentation repositories
- **Use `/docs` folder** as the source for GitHub Pages
- **Configure custom domain** if available for organizational consistency
- **Implement navigation structure** using Jekyll or similar static site generator

#### Documentation Website Structure

```
docs/
├── _config.yml                  # Jekyll configuration
├── index.md                     # Documentation homepage
├── getting-started/             # Quick start guides
├── reference/                   # API and module references
├── tutorials/                   # Step-by-step tutorials
├── best-practices/              # Recommended patterns
└── assets/                      # Images, diagrams, CSS
```

### Issue and PR Templates

#### Pull Request Template

All repositories must include a standardized PR template covering:

- **Documentation Updates**: Checkbox to confirm docs are updated
- **Testing**: Confirmation that changes are tested
- **Security Review**: Security implications assessment
- **Breaking Changes**: Clear indication of backward compatibility

#### Issue Templates

Provide structured templates for:

- **Bug Reports**: Including environment details and reproduction steps
- **Feature Requests**: With use case justification
- **Documentation Issues**: For reporting doc problems or improvements

### GitHub Actions Integration

#### Required Workflows

1. **Documentation Linting**: Automated markdown linting on all PRs
2. **Link Validation**: Check all external and internal links
3. **Deploy to Pages**: Automatic deployment of docs on merge to main
4. **Security Scanning**: Automated security scanning of IaC code

---

## Tool-Specific Documentation Requirements

### Terraform Documentation Standards

#### Module Documentation

Every Terraform module must include:

**README.md Structure**:

````markdown
# Module Name

Brief description of the module's purpose and functionality.

## Usage

```hcl
module "example" {
  source = "path/to/module"

  # Required variables
  variable_name = "value"
}
```
````

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |

## Providers

[Provider documentation table]

## Modules

[Sub-module documentation table]

## Resources

[Resource documentation table]

## Inputs

[Input variables table]

## Outputs

[Output values table]

## Examples

Link to examples directory with working configurations.

````

**Automated Documentation**:
- Use `terraform-docs` to generate provider, input, and output tables
- Integrate terraform-docs into CI/CD pipeline for automatic updates
- Version documentation alongside module versioning

#### Root Module Documentation
Root modules (environments) require:
- **Architecture diagrams** showing resource relationships
- **Environment-specific variables** and their purposes
- **Deployment procedures** including prerequisites
- **Disaster recovery** and rollback procedures

### Packer Documentation Standards

#### Template Documentation
Every Packer template requires:

**README.md Structure**:
```markdown
# Template Name

Description of the image being built and its intended use.

## Prerequisites

- Required software and versions
- Cloud provider credentials and permissions
- Source images and their locations

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| variable_name | Description | string | "default" | yes |

## Usage

```bash
# Build command examples
packer build -var-file="variables.pkrvars.hcl" template.pkr.hcl
````

## Provisioners

- List of provisioners used and their purposes
- Custom scripts and their functions
- Post-processors and artifact handling

## Testing

- How to validate the built image
- Integration test procedures
- Security scanning requirements

**Build Pipeline Documentation**:

- CI/CD integration procedures
- Artifact storage and versioning
- Image lifecycle management

### Ansible Documentation Standards

#### Playbook Documentation

Every playbook must include:

**README.md Structure**:

```markdown
# Playbook Name

Purpose and scope of the playbook.

## Requirements

- Ansible version compatibility
- Required collections and roles
- Target system requirements

## Role Dependencies

List of dependent roles and their sources.

## Variables

### Required Variables

| Variable | Description | Type | Example |
| -------- | ----------- | ---- | ------- |

### Optional Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
```

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: example-role
      vars:
        variable_name: value
```

## Tags

Available tags for selective execution.

## Testing

- How to test in isolated environments
- Validation procedures
- Idempotency verification

#### Role Documentation

Ansible roles require comprehensive documentation:

**Role README Structure**:

- **Purpose**: Clear description of role functionality
- **Platforms**: Supported operating systems and versions
- **Dependencies**: Required roles, collections, and system packages
- **Variables**: All configurable parameters with defaults and examples
- **Examples**: Multiple usage scenarios
- **Testing**: How to test the role independently

---

## Content Standards and Guidelines

### Writing Style Guide

#### Language and Tone

- **Use clear, concise language** avoiding unnecessary jargon
- **Write in active voice** when possible
- **Be specific and actionable** in instructions
- **Use consistent terminology** throughout documentation
- **Include context** for decisions and configurations

#### Technical Accuracy

- **Verify all code examples** work as documented
- **Include version-specific information** where relevant
- **Test all procedures** before documenting them
- **Update examples** when underlying code changes

#### Accessibility and Inclusion

- **Use descriptive link text** instead of "click here"
- **Provide alternative text** for all images and diagrams
- **Use semantic heading structure** (H1 → H2 → H3)
- **Avoid cultural references** that may not translate globally

### Code Examples and Snippets

#### Code Block Standards

- **Use appropriate syntax highlighting** for all code blocks
- **Include complete, working examples** rather than fragments
- **Provide context** for where code should be placed
- **Use realistic values** in examples, avoiding placeholder text

#### Example Structure

```hcl
# terraform/environments/production/main.tf
# Complete example showing module usage in context

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name               = "production-vpc"
  cidr_block        = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  tags = {
    Environment = "production"
    Owner       = "devops-team"
  }
}
```

### Diagrams and Visual Aids

#### Required Diagrams

- **Architecture diagrams** for complex systems
- **Network topology** for infrastructure layouts
- **Data flow diagrams** for understanding information movement
- **Deployment pipelines** showing CI/CD processes

#### Diagram Standards

- Use consistent color schemes and symbols
- Include legends for complex diagrams
- Store diagrams as code (Mermaid, PlantUML) when possible
- Provide both source files and rendered images
- Update diagrams alongside infrastructure changes

---

## File Structure and Organization

### Documentation Hierarchy

```
docs/
├── index.md                     # Documentation homepage
├── getting-started/             # New user orientation
│   ├── prerequisites.md         # Requirements and setup
│   ├── quick-start.md          # Fast path to first success
│   └── first-deployment.md     # Guided initial deployment
├── architecture/               # System design documentation
│   ├── overview.md             # High-level architecture
│   ├── networking.md           # Network design decisions
│   ├── security.md             # Security architecture
│   └── disaster-recovery.md    # DR and backup strategies
├── user-guides/                # Task-oriented documentation
│   ├── deployment/             # Deployment procedures
│   ├── configuration/          # Configuration management
│   └── monitoring/             # Observability setup
├── reference/                  # Complete technical reference
│   ├── terraform/              # Terraform-specific docs
│   ├── ansible/                # Ansible-specific docs
│   ├── packer/                 # Packer-specific docs
│   └── api/                    # API documentation
├── tutorials/                  # Learning-oriented content
│   ├── beginner/               # Introduction tutorials
│   ├── intermediate/           # Advanced scenarios
│   └── advanced/               # Expert-level content
├── troubleshooting/            # Problem-solving guides
│   ├── common-issues.md        # FAQ and solutions
│   ├── debugging.md            # Debugging procedures
│   └── performance.md          # Performance optimization
└── contributing/               # Contributor information
    ├── development.md          # Development workflow
    ├── testing.md              # Testing procedures
    └── documentation.md        # Documentation guidelines
```

### Cross-References and Navigation

#### Internal Linking Strategy

- **Use relative links** for internal documentation references
- **Maintain consistent URL structure** across all documents
- **Implement breadcrumb navigation** for deep hierarchies
- **Create topic-based landing pages** that guide users to relevant content

#### Table of Contents Standards

- **Auto-generate TOCs** where possible using markdown tools
- **Limit depth** to 3 levels for readability
- **Use descriptive headings** that work well in TOCs
- **Update TOCs** when document structure changes

---

## Markdown Standards and Formatting

### GitHub Flavored Markdown (GFM) Compliance

#### Mandatory Standards

- **Use GitHub Flavored Markdown** as the baseline standard
- **Follow CommonMark specification** for portability
- **Avoid proprietary extensions** that don't render on GitHub
- **Test rendering** in GitHub's preview before committing

#### Formatting Rules

**Headers**:

```markdown
# Primary Title (H1) - One per document

## Section Headers (H2) - Main sections

### Subsection Headers (H3) - Detailed topics

#### Detailed Headers (H4) - Specific procedures
```

**Lists**:

- Use **unordered lists** for items without sequence
- Use **ordered lists** for step-by-step procedures
- **Indent sub-items** consistently (2 spaces)
- **Avoid deep nesting** (max 3 levels)

**Code Blocks**:

````markdown
```language
# Always specify the language for syntax highlighting
# Use meaningful examples that work out of the box
```
````

````

**Tables**:
```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Data     | Data     | Data     |
````

**Links**:

```markdown
[Descriptive link text](relative/path/to/file.md)
[External link](https://example.com) - Include protocol
```

### Linting and Quality Assurance

#### Required Linting Tools

- **markdownlint-cli2**: Syntax and style consistency
- **write-good**: Grammar and readability
- **markdown-link-check**: Link validation

#### CI/CD Integration

```yaml
# .github/workflows/docs-quality.yml
name: Documentation Quality Check

on:
  pull_request:
    paths:
      - "**/*.md"
      - "docs/**/*"

jobs:
  lint-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run markdownlint
        uses: DavidAnson/markdownlint-cli2-action@v20
        with:
          config: .markdownlint-cli2.jsonc
          files: "**/*.md"

      - name: Check links
        uses: gaurav-nelson/github-action-markdown-link-check@v1
        with:
          use-quiet-mode: "yes"
          config-file: ".markdown-link-check.json"
```

#### Linting Configuration

**.markdownlint-cli2.jsonc**:

```json
{
  "MD013": { "line_length": 100 },
  "MD033": false,
  "MD041": false
}
```

---

## Code Review and Quality Assurance

### Documentation Review Process

#### Mandatory Review Criteria

All documentation changes must be reviewed for:

1. **Technical Accuracy**: Code examples work as documented
2. **Completeness**: All necessary information is included
3. **Clarity**: Instructions are clear and unambiguous
4. **Consistency**: Follows established style and format standards
5. **Accessibility**: Content is inclusive and accessible
6. **Security**: No sensitive information is exposed

#### Review Checklist Template

```markdown
## Documentation Review Checklist

### Content Quality

- [ ] Technical accuracy verified
- [ ] Code examples tested
- [ ] Instructions are clear and complete
- [ ] Screenshots and diagrams are current
- [ ] Links work correctly

### Style and Format

- [ ] Follows markdown standards
- [ ] Consistent with style guide
- [ ] Proper heading hierarchy
- [ ] Table formatting is correct
- [ ] Code blocks have syntax highlighting

### Accessibility

- [ ] Images have alt text
- [ ] Links have descriptive text

### Security and Compliance

- [ ] No credentials or secrets exposed
- [ ] Compliance requirements addressed
- [ ] Security implications documented
```

### Automated Quality Gates

#### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.37.0
    hooks:
      - id: markdownlint
        args: ["--config", ".markdownlint.json"]

  - repo: https://github.com/tcort/markdown-link-check
    rev: v3.11.2
    hooks:
      - id: markdown-link-check
```

#### Quality Metrics

Track and improve documentation quality through metrics:

- **Link failure rate**: Percentage of broken links
- **Documentation coverage**: Ratio of documented to undocumented components
- **Freshness score**: How recently documentation was updated
- **User feedback**: Issues and improvement suggestions

---

## Maintenance and Lifecycle Management

### Documentation Lifecycle

#### Creation Standards

- **Document during development**, not after deployment
- **Include documentation requirements** in definition of done
- **Review documentation** as part of code review process
- **Test all procedures** before documenting them

#### Update Procedures

- **Trigger documentation updates** on infrastructure changes
- **Version documentation** alongside infrastructure versions
- **Deprecate outdated content** clearly and provide migration paths
- **Archive obsolete documentation** rather than deleting

#### Regular Maintenance

- **Quarterly documentation review** for accuracy and relevance
- **Annual structural review** for organization and navigation
- **Continuous link checking** to prevent broken references
- **User feedback integration** for continuous improvement

### Ownership and Responsibility

#### Documentation Ownership Model

```markdown
# CODEOWNERS file example

# Documentation ownership by component

# Global documentation standards

/docs/ @devops-team @tech-writers

# Tool-specific documentation

/docs/terraform/ @terraform-maintainers
/docs/ansible/ @ansible-maintainers
/docs/packer/ @packer-maintainers

# Architecture documentation

/docs/architecture/ @architecture-team @senior-devops
```

#### Roles and Responsibilities

**Infrastructure Engineers**:

- Create and maintain technical documentation for their components
- Ensure code examples are accurate and tested
- Update documentation with infrastructure changes

**Technical Writers** (if available):

- Review documentation for clarity and style
- Maintain documentation standards and guidelines
- Create user-focused guides and tutorials

**Team Leads**:

- Ensure documentation standards are followed
- Allocate time for documentation work
- Review and approve documentation strategy changes

---

## Templates and Examples

### README Template for Terraform Modules

````markdown
# [Module Name]

[Brief description of what this module does and why it exists]

## Usage

Basic usage example:

```hcl
module "example" {
  source = "git::https://github.com/org/repo//modules/module-name?ref=v1.0.0"

  name = "my-resource"
  # Add other required variables
}
```
````

## Examples

- [Basic Example](examples/basic/) - Simple implementation
- [Advanced Example](examples/advanced/) - Full-featured implementation
- [Multi-Environment](examples/multi-env/) - Environment-specific configs

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0   |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                      | Type     |
| ------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_example_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/example_resource) | resource |

## Inputs

| Name                                          | Description           | Type     | Default | Required |
| --------------------------------------------- | --------------------- | -------- | ------- | :------: |
| <a name="input_name"></a> [name](#input_name) | Name for the resource | `string` | n/a     |   yes    |

## Outputs

| Name                                      | Description                |
| ----------------------------------------- | -------------------------- |
| <a name="output_id"></a> [id](#output_id) | ID of the created resource |

## Contributing

<!-- TODO: Create CONTRIBUTING.md file -->
See the project README and documentation standards for contribution guidelines.

## License

[License information]

### Ansible Role Template

````markdown
# Ansible Role: [Role Name]

[Description of what this role accomplishes]

## Requirements

- Ansible >= 2.9
- Target OS: Ubuntu 20.04+, CentOS 8+, RHEL 8+
- Privilege escalation required: Yes/No

## Role Variables

### Required Variables

```yaml
required_variable: "description"
```
````

### Optional Variables

```yaml
optional_variable: "default_value" # Description
```

### Example Variable File

```yaml
# group_vars/all.yml
role_config:
  setting1: value1
  setting2: value2
```

## Dependencies

```yaml
dependencies:
  - role: dependency-role
    vars:
      variable: value
```

## Example Playbook

```yaml
- hosts: servers
  become: yes
  roles:
    - role: role-name
      vars:
        required_variable: "value"
```

## Testing

This role includes Molecule tests:

```bash
molecule test
```

## Tags

- `config`: Configuration tasks only
- `install`: Installation tasks only
- `service`: Service management tasks

## Compatibility

| Platform | Versions     |
| -------- | ------------ |
| Ubuntu   | 20.04, 22.04 |
| CentOS   | 8, 9         |
| RHEL     | 8, 9         |

## Author Information

Created by [Author Name] ([email@example.com])

### Packer Template Documentation

````markdown
# Packer Template: [Template Name]

[Description of the image being built and its intended use cases]

## Prerequisites

### Software Requirements

- Packer >= 1.8.0
- Cloud provider CLI tools configured
- Source image access permissions

### Credentials Setup

```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```
````

## Variables

| Name            | Description          | Type   | Default   | Required |
| --------------- | -------------------- | ------ | --------- | -------- |
| `region`        | AWS region for build | string | us-west-2 | no       |
| `instance_type` | EC2 instance type    | string | t3.micro  | no       |
| `source_ami`    | Base AMI ID          | string | ami-12345 | yes      |

## Usage

### Basic Build

```bash
packer build \
  -var 'source_ami=ami-12345' \
  template.pkr.hcl
```

### Production Build

```bash
packer build \
  -var-file="production.pkrvars.hcl" \
  template.pkr.hcl
```

## Build Process

1. **Launch**: Creates temporary EC2 instance
2. **Provision**: Runs provisioning scripts
3. **Cleanup**: Installs cleanup scripts
4. **Snapshot**: Creates AMI from instance
5. **Terminate**: Destroys temporary resources

## Provisioners

- **Shell**: System updates and package installation
- **Ansible**: Application configuration
- **File**: Copy configuration files
- **Breakpoint**: Debug point for troubleshooting

## Testing

### Local Validation

```bash
packer validate template.pkr.hcl
```

### Integration Testing

```bash
# Test the built image
./test/integration-test.sh ami-67890
```

## Troubleshooting

### Common Issues

- **Build Timeout**: Increase `ssh_timeout` value
- **Permission Denied**: Check IAM policies
- **Network Issues**: Verify security groups and VPC settings

### Debug Mode

```bash
packer build -debug template.pkr.hcl
```

## Output

This template produces:

- AMI ID: `ami-{{.BuildName}}-{{timestamp}}`
- Build artifacts logged to: `./builds/`
- Manifest file: `./manifest.json`

---

## Compliance and Security Documentation

### Security Documentation Requirements

#### Mandatory Security Sections

Every IaC project must document:

1. **Security Architecture**: High-level security design decisions
2. **Access Controls**: IAM policies, RBAC configurations, and permission models
3. **Data Protection**: Encryption at rest and in transit
4. **Network Security**: Firewall rules, security groups, and network policies
5. **Secrets Management**: How sensitive data is handled and stored
6. **Compliance Mappings**: Alignment with regulatory requirements

#### Security Review Checklist

```markdown
## Security Documentation Review

### Secrets and Credentials

- [ ] No hardcoded secrets in documentation
- [ ] Secret management procedures documented
- [ ] Credential rotation procedures defined

### Access and Permissions

- [ ] IAM policies documented and justified
- [ ] Principle of least privilege applied
- [ ] Access review procedures defined

### Network Security

- [ ] Network architecture documented
- [ ] Security group rules explained
- [ ] VPN and connectivity requirements covered

### Compliance Requirements

- [ ] Regulatory requirements identified
- [ ] Compliance controls mapped
- [ ] Audit procedures documented
```

### Compliance Documentation Templates

#### SOC 2 Compliance Template

```markdown
# SOC 2 Compliance Documentation

## Security Controls

### Access Controls (CC6.1)

- **Implementation**: [Description of access control implementation]
- **Monitoring**: [How access is monitored and reviewed]
- **Documentation**: [Location of access control policies]

### Logical and Physical Access (CC6.2)

- **Network Security**: [Firewall and security group configurations]
- **Physical Security**: [Data center security measures]
- **Remote Access**: [VPN and remote access procedures]

### System Operations (CC7.1)

- **Change Management**: [How infrastructure changes are managed]
- **Incident Response**: [Incident response procedures]
- **Monitoring**: [System monitoring and alerting]
```

---

## Automation and Tooling

### Documentation Automation Pipeline

#### Automated Documentation Generation

```yaml
# .github/workflows/docs-automation.yml
name: Documentation Automation

on:
  push:
    branches: [main]
    paths:
      - "**.tf"
      - "**.yml"
      - "**.yaml"

jobs:
  generate-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate Terraform docs
        uses: terraform-docs/gh-actions@v1.0.0
        with:
          working-dir: .
          output-file: README.md
          output-method: inject

      - name: Generate Ansible docs
        run: |
          pip install ansible-doc-extractor
          ansible-doc-extractor roles/ > docs/ansible-roles.md

      - name: Commit documentation
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "docs: auto-generate documentation [skip ci]"
```

#### Required Automation Tools

**Terraform Documentation**:

- `terraform-docs`: Generate provider, input, and output tables
- `tfdocs-format`: Standardize terraform-docs output format
- `pre-commit-terraform`: Validate and format Terraform files

**Ansible Documentation**:

- `ansible-doc`: Extract role and module documentation
- `ansible-lint`: Validate playbook syntax and best practices
- `yamllint`: Ensure YAML formatting consistency

**General Documentation**:

- `markdownlint-cli2`: Enforce markdown standards
- `markdown-link-check`: Validate all links
- `doctoc`: Auto-generate table of contents

### Integration with Development Workflow

#### Pre-commit Configuration

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.2
    hooks:
      - id: terraform_fmt
      - id: terraform_docs
      - id: terraform_validate
      - id: terraform_tflint

  - repo: https://github.com/ansible/ansible-lint
    rev: v6.20.0
    hooks:
      - id: ansible-lint

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.37.0
    hooks:
      - id: markdownlint
        args: ["--fix", "--config", ".markdownlint.json"]
```

#### Documentation Quality Gates

```yaml
# Quality gates that must pass before merge
required_checks:
  - "Documentation Lint"
  - "Link Validation"
  - "Terraform Docs Updated"
  - "Security Scan Complete"
  - "Examples Tested"
```

---

## Implementation Checklist

### Initial Setup

- [ ] Create repository structure following standards
- [ ] Configure GitHub Pages for documentation site
- [ ] Set up automated linting and quality checks
- [ ] Create issue and PR templates
- [ ] Configure CODEOWNERS for documentation review
- [ ] Install and configure pre-commit hooks

### Content Creation

- [ ] Write comprehensive README following template
- [ ] Document all modules, roles, and templates
- [ ] Create architecture diagrams and visual aids
- [ ] Develop getting-started guides and tutorials
- [ ] Document security and compliance requirements
- [ ] Create troubleshooting guides

### Automation and Maintenance

- [ ] Set up documentation generation pipelines
- [ ] Configure link checking and validation
- [ ] Establish documentation review process
- [ ] Create maintenance schedules and ownership
- [ ] Implement feedback collection mechanisms
- [ ] Set up documentation metrics and monitoring

### Quality Assurance

- [ ] Test all documented procedures
- [ ] Validate code examples work correctly
- [ ] Review content for accuracy and clarity
- [ ] Check accessibility and inclusion standards
- [ ] Verify compliance documentation completeness
- [ ] Conduct peer review of documentation standards

---

## Conclusion

These documentation standards provide a comprehensive framework for creating, maintaining, and improving Infrastructure as Code documentation. By following these guidelines, teams can ensure their documentation serves as an effective tool for collaboration, onboarding, and operational excellence.

Regular review and improvement of these standards is essential as tools, practices, and team needs evolve. Documentation is not just a deliverable—it's a critical component of infrastructure reliability and team effectiveness.

For questions or suggestions regarding these standards, please create an issue in the documentation standards repository or contact the DevOps team directly.

---

**Document Version**: 1.0
**Last Updated**: September 2025
**Next Review**: December 2025
**Maintained By**: DevOps Team
**Approved By**: [Approval Authority]
