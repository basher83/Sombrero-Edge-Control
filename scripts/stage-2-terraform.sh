#!/bin/bash
set -euo pipefail

TEMPLATE_ID=${1:-8025}
cd infrastructure/environments/production

echo "Initializing tflint..."
tflint --init || exit 1

echo "Running tflint..."
tflint || exit 1

echo "Applying Terraform configuration with template_id=${TEMPLATE_ID}..."
terraform apply -var="template_id=${TEMPLATE_ID}" -auto-approve

echo "Exporting Ansible inventory..."
terraform output -json ansible_inventory > ansible_inventory.json

echo "✓ Infrastructure provisioned"
echo "Inventory exported to: ansible_inventory.json"
