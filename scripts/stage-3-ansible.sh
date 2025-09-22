#!/bin/bash
set -euo pipefail

INVENTORY=${1:-ansible_inventory.json}
cd ansible_collections/basher83/automation_server

echo "Running Ansible playbook..."
ansible-playbook -i "$INVENTORY" playbooks/site.yml

echo "✓ Configuration complete"
