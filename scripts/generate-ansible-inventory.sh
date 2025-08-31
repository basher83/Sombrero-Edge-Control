#!/bin/bash
# Generate Ansible inventory files from Terraform outputs
# Usage: ./scripts/generate-ansible-inventory.sh [environment]

set -euo pipefail

ENVIRONMENT="${1:-production}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/infrastructure/environments/$ENVIRONMENT"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"
INVENTORY_DIR="$ANSIBLE_DIR/inventory"

# Ensure directories exist
mkdir -p "$INVENTORY_DIR"

# Check if we're in the right terraform directory
if [[ ! -f "$TERRAFORM_DIR/main.tf" && ! -f "$TERRAFORM_DIR/providers.tf" ]]; then
    echo "Error: Terraform environment '$ENVIRONMENT' not found at $TERRAFORM_DIR"
    echo "Available environments:"
    ls -1 "$PROJECT_ROOT/infrastructure/environments/" | grep -v README.md || true
    exit 1
fi

echo "🔄 Generating Ansible inventory for $ENVIRONMENT environment..."

# Change to terraform directory and get outputs
cd "$TERRAFORM_DIR"

# Check if terraform state exists
if ! terraform state list >/dev/null 2>&1; then
    echo "❌ No Terraform state found. Run 'terraform apply' first."
    exit 1
fi

# Extract clean IP addresses from terraform output
echo "📡 Extracting VM details from Terraform state..."

# Get master node info
MASTER_NAME=$(terraform output -json vault_master | jq -r '.name')
MASTER_IP=$(terraform output -json vault_master | jq -r '.ip' | sed 's|/24||g')
MASTER_NODE=$(terraform output -json vault_master | jq -r '.node')

# Generate YAML inventory
cat > "$INVENTORY_DIR/$ENVIRONMENT.yml" << EOF
---
# Ansible Inventory for Vault $ENVIRONMENT Cluster
# Auto-generated from Terraform state on $(date -u +"%Y-%m-%d %H:%M:%S UTC")
all:
  children:
    vault_master:
      hosts:
        $MASTER_NAME:
          ansible_host: $MASTER_IP
          ansible_user: ubuntu
          vault_role: master
          vault_node_id: vault-master
          proxmox_node: $MASTER_NODE

    vault_production:
      hosts:
EOF

# Get production nodes and add them
terraform output -json vault_production_nodes | jq -r 'to_entries[] | "\(.value.name) \(.value.ip) \(.value.node)"' | while read -r name ip node; do
    # Clean IP address (remove CIDR notation)
    clean_ip=$(echo "$ip" | sed 's|/24||g')
    vault_node_id=$(echo "$name" | sed 's|-[^-]*$//')

    cat >> "$INVENTORY_DIR/$ENVIRONMENT.yml" << EOF
        $name:
          ansible_host: $clean_ip
          ansible_user: ubuntu
          vault_role: production
          vault_node_id: $vault_node_id
          proxmox_node: $node

EOF
done

# Add cluster-wide variables
cat >> "$INVENTORY_DIR/$ENVIRONMENT.yml" << EOF

    # Group all Vault nodes for common configuration
    vault_cluster:
      children:
        - vault_master
        - vault_production
      vars:
        vault_datacenter: "doggos-cluster"
        vault_domain: "vault.hercules.local"
        vault_port: 8200
        vault_cluster_port: 8201
        vault_data_dir: "/opt/vault/data"
        vault_config_dir: "/etc/vault.d"
        vault_log_dir: "/opt/vault/logs"
        vault_user: "vault"
        ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
EOF

echo "✅ Generated Ansible inventory: $INVENTORY_DIR/$ENVIRONMENT.yml"

# Test the inventory
cd "$ANSIBLE_DIR"
echo "🧪 Testing inventory syntax..."
if ansible-inventory --list -i "inventory/$ENVIRONMENT.yml" >/dev/null 2>&1; then
    echo "✅ Inventory syntax is valid"
    echo ""
    echo "📋 Inventory summary:"
    ansible-inventory --list -i "inventory/$ENVIRONMENT.yml" | jq '.vault_cluster.children + .vault_cluster.hosts' 2>/dev/null || echo "Install jq for detailed inventory parsing"
else
    echo "❌ Inventory syntax error - please check the generated file"
fi

echo ""
echo "🚀 Ready to use with Ansible:"
echo "   cd ansible/"
echo "   ansible all -i inventory/$ENVIRONMENT.yml -m ping"
