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
    TEMPLATE_ID=$(packer build -machine-readable -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl 2>/dev/null | \
                  awk -F, '/artifact,0,id/ {print $6}' | tail -1)
    echo "Template ID: $TEMPLATE_ID"
else
    echo -e "${RED}✗ Packer build failed${NC}"
    exit 1
fi

# Stage 2: Terraform
echo -e "\n${YELLOW}Stage 2: Provisioning Infrastructure${NC}"
cd "$TERRAFORM_DIR"

# MANDATORY: Initialize and run tflint
echo -n "Initializing tflint... "
if ! tflint --init > /dev/null 2>&1; then
    echo -e "${RED}✗ tflint init failed${NC}"
    exit 1
fi
echo "✓"

echo -n "Running tflint... "
if ! tflint > /dev/null 2>&1; then
    echo -e "${RED}✗ tflint validation failed${NC}"
    exit 1
fi
echo "✓"

echo -n "Applying Terraform configuration... "
if terraform apply -var="template_id=${TEMPLATE_ID}" -auto-approve > /dev/null 2>&1; then
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

echo -n "Running Ansible playbook... "
if ansible-playbook -i inventory/ansible_inventory.json playbooks/site.yml > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Ansible configuration successful${NC}"
else
    echo -e "${RED}✗ Ansible configuration failed${NC}"
    exit 1
fi

echo -e "\n${GREEN}=== Pipeline Deployment Complete ===${NC}"
echo "VM is ready at: 192.168.10.250"
