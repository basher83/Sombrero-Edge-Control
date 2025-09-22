#!/bin/bash
set -euo pipefail

# Export Terraform output to Ansible inventory
terraform output -json ansible_inventory > ansible_inventory.json

# Validate JSON format
python3 -m json.tool ansible_inventory.json > /dev/null || {
    echo "Error: Invalid JSON in inventory"
    exit 1
}

# Copy to Ansible collection location
ANSIBLE_DIR="../../../ansible_collections/basher83/automation_server"
if [ -d "${ANSIBLE_DIR}" ]; then
    mkdir -p "${ANSIBLE_DIR}/inventory"
    cp ansible_inventory.json "${ANSIBLE_DIR}/inventory/"
    echo "Inventory exported to:"
    echo "  - $(pwd)/ansible_inventory.json"
    echo "  - ${ANSIBLE_DIR}/inventory/ansible_inventory.json"
else
    echo "Warning: Ansible collection directory not found, skipping copy"
    echo "Inventory exported to: $(pwd)/ansible_inventory.json"
fi
