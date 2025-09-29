# Pipeline Handoff Specification

This document defines the interfaces between pipeline stages to ensure clean separation and reliable data flow.

## Stage 1 → Stage 2: Packer to Terraform

- **Output**: Template ID (integer)
- **Method**: Manual parameter or environment variable
- **Example**: `template_id=8025`
- **Validation**: Template must exist in Proxmox cluster

## Stage 2 → Stage 3: Terraform to Ansible

- **Output**: Inventory JSON file
- **Method**: File export via terraform output
- **Example**: `ansible_inventory.json`
- **Location**: `infrastructure/environments/production/ansible_inventory.json`
- **Format**: JSON with Ansible inventory structure
- **Validation**: Valid JSON and required connection parameters

## Data Flow Diagram

```text
Packer Template (ID: 8025)
        ↓
Terraform Infrastructure (VM: jump-man)
        ↓
Ansible Inventory (JSON format)
        ↓
Configured VM (192.168.10.250)
```

## Handoff Validation

Each handoff should be validated before proceeding:

1. **Template ID**: Verify template exists with `qm list`
1. **Inventory JSON**: Validate with `python3 -m json.tool`
1. **VM Connectivity**: Test SSH access to VM
1. **Ansible Connectivity**: Test with `ansible -m ping`
