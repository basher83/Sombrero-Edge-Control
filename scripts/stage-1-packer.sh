#!/bin/bash
set -euo pipefail

cd packer
echo "Building Packer template..."
packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl

echo "✓ Packer build successful"
echo "Template created. Use the template ID for Terraform."
