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

# Run tflint validation
echo -n "Running tflint... "
if tflint --init > /dev/null 2>&1 && tflint > /dev/null 2>&1; then
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
