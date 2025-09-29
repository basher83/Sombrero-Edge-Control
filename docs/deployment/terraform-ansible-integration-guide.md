# Terraform + Ansible Integration Best Practices Guide

## ⚠️ Important Architecture Update

**As of 2025-01-18**, this project follows a **Complete Pipeline Separation** architecture where:

- **Packer**: Creates minimal golden images (OS only)
- **Terraform**: Provisions infrastructure with minimal cloud-init (SSH only)
- **Ansible**: Handles ALL configuration as the single source of truth

See [ADR-20250118](../decisions/20250118-pipeline-separation.md) for the architectural decision.

## Overview

This document provides best practices for maintaining clean separation between Terraform
and Ansible in our three-stage pipeline, ensuring tool independence while maintaining
efficient data handoffs.

## 🎯 Integration Patterns Comparison

### Recommended Implementation: Complete Separation

The pipeline enforces **Complete Tool Independence** with these principles:

- ✅ Packer: Minimal golden images (OS + cloud-init only)
- ✅ Terraform: Pure infrastructure with minimal cloud-init (SSH access)
- ✅ Ansible: ALL configuration management (single source of truth)
- ✅ Clean handoffs via data (Template ID → Inventory JSON)
- ✅ No direct tool dependencies or coupling

### Anti-Pattern Warning

#### ❌ AVOID: Terraform Provisioners (Local-exec)

**DO NOT USE THIS PATTERN:**

```hcl
# ANTI-PATTERN - Do not implement
resource "null_resource" "ansible_provision" {
  # This tightly couples Terraform and Ansible
  provisioner "local-exec" {
    command = "ansible-playbook ..."
  }
}
```

**Why this is problematic:**

- ❌ Tightly couples tools (violates separation principle)
- ❌ Ansible failures cause Terraform failures
- ❌ Cannot test tools independently
- ❌ Difficult to debug across tool boundaries
- ❌ HashiCorp explicitly discourages provisioner use

**Use Instead**: Clean handoff via inventory JSON after Terraform completes

#### 2. Red Hat Ansible Certified Collection

**Implementation:**

```yaml
# ansible/inventory.yml
plugin: cloud.terraform.terraform_state
backend_type: local
project_path: ../infrastructure/environments/production
state_file: terraform.tfstate

# Group hosts by Terraform resource tags
groups:
  jump_hosts: "'jump' in tags and tags['env'] == 'production'"
```

**Pros:**

- Official Red Hat support
- Standardized integration
- Rich filtering and grouping capabilities

**Cons:**

- Additional dependency management
- May require Ansible Automation Platform for full features

## 🚨 Anti-Patterns to Avoid

### 1. Ansible Generating Terraform Code

**❌ Anti-Pattern:**

```yaml
# DON'T DO THIS
- name: Generate Terraform config
  template:
    src: vpc.tf.j2
    dest: ../infrastructure/vpc.tf
```

**✅ Better Approach:**
Keep Terraform code declarative and version-controlled directly.

### 2. ANY Terraform Provisioners for Configuration

**❌ Anti-Pattern:**

```hcl
# DON'T DO THIS - ANY configuration in Terraform
provisioner "remote-exec" {
  inline = [
    "apt update",          # This belongs in Ansible
    "apt install -y nginx", # This belongs in Ansible
  ]
}

# Also DON'T DO THIS - Complex cloud-init
user_data = <<-EOF
  packages:
    - docker-ce      # This belongs in Ansible
    - nodejs         # This belongs in Ansible
EOF
```

**✅ Correct Approach:**
Terraform provides ONLY minimal cloud-init for SSH access. ALL configuration happens in Ansible.

### 3. Ignoring Idempotency

**❌ Anti-Pattern:**

```yaml
# DON'T DO THIS
- name: Add user
  command: useradd myuser # Fails if user exists
```

**✅ Better Approach:**

```yaml
- name: Add user
  user:
    name: myuser
    state: present
```

## 🔧 Advanced Configuration Patterns

### Dynamic Template Selection with Metadata

**Enhanced Implementation:**

```hcl
# infrastructure/environments/production/main.tf
data "proxmox_virtual_environment_vms" "golden_images" {
  node_name = var.template_node
  tags      = ["packer-built", "ubuntu-24-04", "golden-image"]
}

locals {
  # Enhanced template selection with metadata
  available_templates = [
    for vm in data.proxmox_virtual_environment_vms.golden_images.vms : {
      id          = vm.vm_id
      name        = vm.name
      tags        = vm.tags
      create_time = vm.create_time
    }
    if vm.template
  ]

  # Select most recent by creation time
  selected_template = length(local.available_templates) > 0 ? (
    local.available_templates[index(max(local.available_templates[*].create_time), local.available_templates[*].create_time)]
  ) : null

  template_metadata = local.selected_template != null ? {
    id             = local.selected_template.id
    source         = "packer-golden-image"
    creation_time  = local.selected_template.create_time
    packer_version = local.selected_template.tags["packer-version"]
  } : {
    id             = var.template_id
    source         = "configured-template"
    creation_time  = null
    packer_version = null
  }
}
```

### Clean Handoff: Terraform to Ansible

**Inventory Generation as Data Exchange:**

```hcl
# infrastructure/environments/production/outputs.tf
output "ansible_inventory" {
  description = "Comprehensive Ansible inventory with Terraform metadata"
  value = yamlencode({
    all = {
      hosts = {
        "jump-man" = merge({
          ansible_host = module.jump_man.primary_ip
          ansible_user = var.cloud_init_username
          template_id  = local.template_metadata.id
          template_source = local.template_metadata.source
        }, local.template_metadata.packer_version != null ? {
          packer_version = local.template_metadata.packer_version
          build_timestamp = local.template_metadata.creation_time
        } : {})
      }
      vars = {
        environment = "production"
        terraform_workspace = terraform.workspace
        deployment_timestamp = timestamp()
        infrastructure_version = "1.1.0"
      }
      children = {
        jump_hosts = {
          hosts = ["jump-man"]
          vars = {
            host_role = "jump"
            security_level = "hardened"
            backup_schedule = "daily"
          }
        }
      }
    }
  })
}
```

## 🔐 Security Best Practices

### Secrets Management Strategy

**Recommended Approach:**

```hcl
# Use external secrets management
data "aws_secretsmanager_secret_version" "ansible_vault_password" {
  secret_id = "ansible/vault-password"
}

# For Proxmox environment, consider:
# - HashiCorp Vault integration
# - Ansible Vault with automated password retrieval
# - Cloud-native secrets managers
```

### Access Control Matrix

| Component     | Access Level    | Authentication         | Authorization              |
| ------------- | --------------- | ---------------------- | -------------------------- |
| Packer Builds | Service Account | API Token              | Build permissions only     |
| Terraform     | CI/CD Service   | OIDC/Workload Identity | Infrastructure permissions |
| Ansible       | SSH Key         | ED25519                | sudo for configuration     |
| Proxmox       | API Token       | PVE API                | VM management permissions  |

## 📊 Performance Optimization

### Pipeline Performance Metrics

**Target Metrics:**

- **End-to-End Deployment**: < 10 minutes
- **Packer Build**: < 5 minutes
- **Terraform Apply**: < 2 minutes
- **Ansible Configuration**: < 3 minutes

### Optimization Strategies

#### 1. Parallel Execution

```hcl
# Enable parallel resource creation
terraform {
  experiments = [module_variable_optional_attrs]
}

# Configure provider parallelism
provider "proxmox" {
  parallel = 2  # Adjust based on Proxmox capacity
}
```

#### 2. Caching and Optimization

```bash
# .mise.toml - Add caching tasks
[tasks.cache-packer]
description = "Cache Packer plugins for faster builds"
run = "packer init packer/ubuntu-server-numbat-docker.pkr.hcl"

[tasks.cache-terraform]
description = "Cache Terraform providers"
run = """
cd infrastructure/environments/production
terraform providers mirror /tmp/terraform-cache
"""
```

#### 3. Selective Testing

```bash
# scripts/smoke-test.sh - Add selective testing
case "$TEST_LEVEL" in
  "quick")
    run_test "SSH connectivity" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'exit 0'"
    ;;
  "full")
    run_full_test_suite
    ;;
  "comprehensive")
    run_full_test_suite
    run_performance_tests
    run_security_audit
    ;;
esac
```

## 🏢 Organizational Considerations

### Skills Matrix

**Required Skill Levels:**

| Role                     | Terraform | Ansible      | Packer       | DevOps       |
| ------------------------ | --------- | ------------ | ------------ | ------------ |
| Platform Engineer        | Expert    | Expert       | Advanced     | Expert       |
| DevOps Engineer          | Advanced  | Expert       | Advanced     | Advanced     |
| Infrastructure Developer | Advanced  | Intermediate | Intermediate | Intermediate |
| Developer                | Basic     | Basic        | Basic        | Intermediate |

### Training Recommendations

**Learning Path:**

1. **Foundation**: Terraform Associate certification
1. **Intermediate**: Ansible Automation Platform certification
1. **Advanced**: Packer and immutable infrastructure patterns
1. **Expert**: Multi-cloud orchestration and GitOps

### Change Management Process

**Implementation Phases:**

1. **Assessment**: Current state analysis and gap identification
1. **Pilot**: Small-scale implementation with monitoring
1. **Expansion**: Gradual rollout with feedback loops
1. **Optimization**: Performance tuning and best practice refinement
1. **Standardization**: Documentation and training program

## 🔄 Continuous Improvement

### Metrics and KPIs

**Technical Metrics:**

- Deployment success rate (> 95%)
- Mean time to deploy (< 15 minutes)
- Infrastructure drift detection (< 5% drift)
- Security scan pass rate (100%)

**Business Metrics:**

- Developer productivity improvement
- Time to market reduction
- Infrastructure cost optimization
- Incident response time

### Feedback Loops

**Implementation:**

```yaml
# .github/workflows/feedback.yml
name: Deployment Feedback Collection

on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]

jobs:
  collect-feedback:
    runs-on: ubuntu-latest
    steps:
      - name: Send deployment metrics to dashboard
      - name: Trigger automated improvement analysis
      - name: Update deployment success metrics
```

## 📚 Additional Resources

### Industry Standards

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Packer Best Practices](https://developer.hashicorp.com/packer/docs/best-practices)

### Community Resources

- [Terraform Registry](https://registry.terraform.io/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [HashiCorp Discuss](https://discuss.hashicorp.com/)

### Training and Certification

- [Terraform Associate Certification](https://www.hashicorp.com/certification/terraform-associate)
- [Red Hat Ansible Automation](https://www.redhat.com/en/services/certification/rhce)

---

## 🎯 Implementation Priority

**Phase 1 (Immediate):**

- [ ] Document current integration patterns
- [ ] Add anti-patterns section to existing docs
- [ ] Implement enhanced inventory metadata

**Phase 2 (Short-term):**

- [ ] Add performance monitoring
- [ ] Implement security hardening guidelines
- [ ] Create skills assessment framework

**Phase 3 (Long-term):**

- [ ] Advanced multi-environment support
- [ ] Automated compliance checking
- [ ] AI-assisted
      optimization

This guide provides a foundation for continuously improving the Terraform + Ansible
integration while maintaining the excellent existing pipeline structure.
