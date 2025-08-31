#!/bin/bash
# Generate Terraform documentation for all modules and environments

set -e

# Check if terraform-docs is available
if ! command -v terraform-docs >/dev/null 2>&1; then
    echo "ERROR: terraform-docs is required but not installed." >&2
    echo "Install it using: mise install terraform-docs" >&2
    exit 1
fi

# Change to the repository root
cd "$(git rev-parse --show-toplevel)"

echo "Generating Terraform documentation..."

# Generate docs for infrastructure directory and its modules
echo "Processing infrastructure directory and modules..."
(cd infrastructure && terraform-docs --config .terraform-docs.yml .)

# Generate docs for each environment individually
for env_dir in infrastructure/environments/*/; do
    if [ -d "$env_dir" ] && [ -f "${env_dir}main.tf" ]; then
        env_name=$(basename "$env_dir")
        echo "Processing environment: $env_name"
        terraform-docs --config .terraform-docs.yml "$env_dir"
    fi
done

# Generate docs for scalr-management if it has terraform files
if [ -f "infrastructure/scalr-management/main.tf" ] || [ -f "infrastructure/scalr-management/workspaces.tf" ]; then
    echo "Processing scalr-management..."
    terraform-docs --config .terraform-docs.yml infrastructure/scalr-management/
fi

echo "Documentation generation complete!"
