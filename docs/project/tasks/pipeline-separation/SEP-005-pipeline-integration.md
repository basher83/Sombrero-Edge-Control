---
Task: Pipeline Integration & Handoffs
Task ID: SEP-005
Priority: P0 (Critical)
Estimated Time: 3 hours
Dependencies: SEP-001, SEP-002, SEP-003, SEP-004
Status: ⏸️ Blocked
---

## Objective

Implement clean handoff mechanisms between the three pipeline stages (Packer → Terraform → Ansible), ensuring each tool can operate independently while maintaining smooth data flow. Create automation scripts and documentation for the complete deployment pipeline.

## Prerequisites

- [ ] SEP-001 completed (minimal Packer template)
- [ ] SEP-002 completed (simplified cloud-init)
- [ ] SEP-003 completed (Ansible collection cleanup)
- [ ] SEP-004 completed (Terraform inventory output)

## Implementation Steps

### 1. **Define Handoff Interfaces**

Create `docs/deployment/pipeline-handoffs.md`:

```markdown
# Pipeline Handoff Specification

## Stage 1 → Stage 2: Packer to Terraform

- **Output**: Template ID (integer)
- **Method**: Manual parameter or environment variable
- **Example**: `template_id=8025`

## Stage 2 → Stage 3: Terraform to Ansible

- **Output**: Inventory JSON file
- **Method**: File export via terraform output
- **Example**: `ansible_inventory.json`
```

### 2. **Create Pipeline Wrapper Script**

Create `scripts/deploy-pipeline.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Pipeline deployment script for three-stage deployment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PACKER_DIR="${PROJECT_ROOT}/packer"
TERRAFORM_DIR="${PROJECT_ROOT}/infrastructure/environments/production"
ANSIBLE_DIR="${PROJECT_ROOT}/ansible_collections/basher83/automation_server"

echo -e "${GREEN}=== Starting Three-Stage Pipeline Deployment ===${NC}"

# Stage 1: Packer
echo -e "\n${YELLOW}Stage 1: Building Minimal Golden Image${NC}"
cd "$PACKER_DIR"

if packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl; then
    echo -e "${GREEN}✓ Packer build successful${NC}"
    # Extract template ID from output
    TEMPLATE_ID=$(packer build -machine-readable ubuntu-server-minimal.pkr.hcl | \
                  awk -F, '/artifact,0,id/ {print $6}')
    echo "Template ID: $TEMPLATE_ID"
else
    echo -e "${RED}✗ Packer build failed${NC}"
    exit 1
fi

# Stage 2: Terraform
echo -e "\n${YELLOW}Stage 2: Provisioning Infrastructure${NC}"
cd "$TERRAFORM_DIR"

# MANDATORY: Initialize and run tflint
if ! tflint --init; then
    echo -e "${RED}✗ tflint init failed${NC}"
    exit 1
fi

if ! tflint; then
    echo -e "${RED}✗ tflint validation failed${NC}"
    exit 1
fi

if terraform apply -var="template_id=${TEMPLATE_ID}" -auto-approve; then
    echo -e "${GREEN}✓ Terraform provisioning successful${NC}"
    # Export inventory
    terraform output -json ansible_inventory > ansible_inventory.json
    echo "Inventory exported to: $(pwd)/ansible_inventory.json"
else
    echo -e "${RED}✗ Terraform provisioning failed${NC}"
    exit 1
fi

# Wait for VM to be ready
echo "Waiting for VM to be ready..."
sleep 30

# Stage 3: Ansible
echo -e "\n${YELLOW}Stage 3: Configuring with Ansible${NC}"
cd "$ANSIBLE_DIR"

# Copy inventory
cp "${TERRAFORM_DIR}/ansible_inventory.json" inventory/

if ansible-playbook -i inventory/ansible_inventory.json playbooks/site.yml; then
    echo -e "${GREEN}✓ Ansible configuration successful${NC}"
else
    echo -e "${RED}✗ Ansible configuration failed${NC}"
    exit 1
fi

echo -e "\n${GREEN}=== Pipeline Deployment Complete ===${NC}"
echo "VM is ready at: 192.168.10.250"
```

### 3. **Create Individual Stage Scripts**

Create modular scripts for each stage:

`scripts/stage-1-packer.sh`:

```bash
#!/bin/bash
set -euo pipefail

cd packer
packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl
echo "Template created. Use the template ID for Terraform."
```

`scripts/stage-2-terraform.sh`:

```bash
#!/bin/bash
set -euo pipefail

TEMPLATE_ID=${1:-8025}
cd infrastructure/environments/production

# MANDATORY: Initialize and run tflint
tflint --init || exit 1
tflint || exit 1

terraform apply -var="template_id=${TEMPLATE_ID}"
terraform output -json ansible_inventory > ansible_inventory.json
echo "Infrastructure provisioned. Inventory at: ansible_inventory.json"
```

`scripts/stage-3-ansible.sh`:

```bash
#!/bin/bash
set -euo pipefail

INVENTORY=${1:-ansible_inventory.json}
cd ansible_collections/basher83/automation_server
ansible-playbook -i "$INVENTORY" playbooks/site.yml
echo "Configuration complete."
```

### 4. **Create Validation Script**

Create `scripts/validate-pipeline.sh`:

```bash
#!/bin/bash
set -euo pipefail

echo "=== Pipeline Validation ==="

# Check Packer template
echo -n "Checking Packer template... "
if qm list | grep -q "ubuntu-2404-minimal"; then
    echo "✓"
else
    echo "✗ Template not found"
    exit 1
fi

# Check Terraform state
echo -n "Checking Terraform state... "
cd infrastructure/environments/production

# Run tflint first
echo -n "Initializing tflint... "
if tflint --init > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗ tflint init failed"
    exit 1
fi

echo -n "Running tflint... "
if tflint > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗ tflint validation failed"
    exit 1
fi

if terraform show > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗ Invalid state"
    exit 1
fi

# Check VM accessibility
echo -n "Checking VM SSH access... "
if ssh -o ConnectTimeout=5 ansible@192.168.10.250 "echo connected" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗ Cannot connect"
    exit 1
fi

# Check Ansible connectivity
echo -n "Checking Ansible connectivity... "
cd ansible_collections/basher83/automation_server
if ansible -i inventory/ansible_inventory.json jump_hosts -m ping > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗ Ansible cannot connect"
    exit 1
fi

echo "=== All validations passed ==="
```

### 5. **Create Rollback Procedures**

Document rollback steps in `docs/deployment/pipeline-rollback.md`:

````markdown
# Pipeline Rollback Procedures

## Stage 3 Rollback (Ansible)

```bash
# Re-run with previous playbook version
git checkout HEAD~1 -- ansible_collections/
ansible-playbook -i inventory/ansible_inventory.json playbooks/site.yml
```
````

## Stage 2 Rollback (Terraform)

```bash
cd infrastructure/environments/production
terraform destroy -auto-approve
# Or revert to previous state
terraform apply -target=proxmox_vm_qemu.jump-man -replace=proxmox_vm_qemu.jump-man
```

## Stage 1 Rollback (Packer)

```bash
# Use previous template ID
terraform apply -var="template_id=8024"  # Old template
```

### 6. **Update Documentation**

Create comprehensive pipeline documentation in `docs/deployment/pipeline-operation.md`.

## Success Criteria

- [ ] Complete pipeline script executes successfully
- [ ] Each stage can run independently
- [ ] Clean data handoff between stages
- [ ] Validation script confirms all stages
- [ ] Rollback procedures documented and tested
- [ ] End-to-end deployment < 60 seconds (excluding Packer build)

## Validation

### Pipeline Testing

```bash
# Run complete pipeline
./scripts/deploy-pipeline.sh

# Run validation
./scripts/validate-pipeline.sh

# Test individual stages
./scripts/stage-1-packer.sh
./scripts/stage-2-terraform.sh 8025
./scripts/stage-3-ansible.sh ansible_inventory.json
```

### Performance Testing

```bash
# Time the deployment (excluding Packer)
time (./scripts/stage-2-terraform.sh && ./scripts/stage-3-ansible.sh)
# Target: < 60 seconds
```

Expected output:

- All three stages complete successfully
- Clean handoff of data between stages
- VM fully configured and accessible

## Notes

- Consider implementing idempotency checks
- Add error handling and retry logic
- Log outputs for debugging
- Consider parallel execution where possible
- Document minimum time between stages

## References

- [Pipeline Separation ADR](../../../decisions/20250118-pipeline-separation.md)
- [Pipeline Refactoring Plan](../../../planning/pipeline-separation-refactor.md)
- [Deployment Checklist](../../../deployment/deployment-checklist.md)
