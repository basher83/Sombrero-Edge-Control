name: "Jump Host VM (Proxmox) — PRP v1"
description: |
Product Requirements Prompt for deploying a single Ubuntu 24.04 jump host VM
("jump-man") to the doggos-homelab Proxmox cluster via Terraform + cloud-init.
This PRP is tailored for an AI coding assistant to implement the required IaC
changes, with clear validation loops and error-handling patterns.

## Purpose

Provide a precise, execution-ready blueprint to provision an operational jump
host VM used for DevOps tasks, decoupled from developer laptops.

## Core Principles

1. Context is King: Include all Terraform, Ansible, and Proxmox details needed
1. Validation Loops: Use fmt/validate/plan/apply + runtime checks
1. Information Dense: Reference repo paths and current module contracts
1. Progressive Success: Start minimal, verify SSH reachability, then extend
1. Global rules: Be sure to follow all rules in CLAUDE.md

---

## Goal

Deploy an Ubuntu 24.04 VM to Proxmox (node: lloyd) named "jump-man" using the
existing Terraform module, with a static IP and essential tooling installed via
cloud-init.

Requested packages (cloud-init):

- qemu-guest-agent
- wget
- gpg
- curl
- unzip
- jq
- net-tools
- ca-certificates
- gnupg
- lsb-release
- software-properties-common
- git
- tmux

## Why

- Provide a dedicated, centrally managed jump host for DevOps and security.
- Reduce risk by separating DevOps tooling from user laptops.

## What

### Success Criteria

- Terraform plan and apply succeed in `infrastructure/environments/production`
- VM "jump-man" is created on node `lloyd` with the expected configuration
- Static IP 192.168.10.250/24 and gateway 192.168.10.1 configured and reachable
- DNS resolvers 8.8.8.8 and 8.8.4.4 configured
- SSH access works as `ansible` user with provided public key
- qemu-guest-agent is running and Terraform outputs show the VM IP(s)
- All requested packages are installed and usable
- Tags applied equal ["terraform","jump","production"]

## All Needed Context

### Documentation & References

```yaml
- url: https://github.com/bpg/terraform-provider-proxmox
  why: Terraform provider used to manage Proxmox resources

- files: infrastructure/modules/vm/
  why: VM module used by environments

- files: infrastructure/environments/production/
  why: Production environment where jump-man will be defined

- file: infrastructure/environments/production/backend_override.tf
  why: Overrides backend to local state for local development/testing

- file: infrastructure/environments/production/cloud-init.yaml
  why: Existing cloud-init example (Vault-oriented); jump-man will use a separate file

- scripts: scripts/generate-docs.sh
  why: Generates Terraform module docs (optional validation step)
```

### Current Codebase Tree (relevant)

```bash
infrastructure/
  environments/
    production/
      main.tf
      variables.tf
      providers.tf
      outputs.tf
      backend_override.tf
      cloud-init.yaml        # Vault-oriented; do not reuse for jump host
  modules/
    vm/
      variables.tf
      main.tf                # NOTE: embeds a Vault vendor_data snippet today
      outputs.tf
```

### Known Gotchas & Library Quirks

- Template baseline: this repo contains Terraform from a previous deployment; treat it as a template.
  Prefer modifying module parameters/implementation over ad-hoc overrides, since this will be a standalone repo for jump-man.
- Vendor data snippet: the VM module currently embeds a Vault-specific cloud-init vendor_data in `modules/vm/main.tf`.
  Rework to injected snippet (not embedded) to keep it DRY and role-agnostic. The jump-man cloud-init should be
  provided via module input and uploaded as a Proxmox snippet.
- Proxmox IP reporting depends on qemu-guest-agent; ensure it starts early in cloud-init.
- Template VM ID and template source node must match actual Proxmox inventory.
- VM IDs must be unique per environment to avoid collisions with existing VMs.
- Docker install uses a third-party repo; ensure resilient key/repo setup and
  run `apt-get update` before installs. Avoid long runcmd chains.
- Scalr is normally used for state/vars but we are using backend_override.tf for local backend during development.
- Terraform var env mapping: Terraform reads `TF_VAR_pve_api_token` for the `pve_api_token` variable; using
  `PROXMOX_API_TOKEN` as the underlying secret is fine but must be exported/mapped to `TF_VAR_pve_api_token`.

### CRITICAL CONTEXT FOR AI ASSISTANTS

**⚠️ TEMPLATE REUSE NOTICE:**
This repository was cloned from a previous Vault cluster deployment and contains leftover code that should be
IGNORED or REMOVED. The Vault VMs and related configurations are NOT part of this deployment - they are just
template artifacts.

**What you're ACTUALLY deploying:**

- ONE VM only: jump-man (the jump host)
- Expected Terraform resources to create: 2 total
  - 1x jump-man VM resource
  - 1x jump-man vendor_data cloud-init file

**What to IGNORE/REMOVE:**

- Any existing VM definitions in main.tf (vault-master, vault-prod-1/2/3, etc.)
- Any Vault-specific configurations that aren't being parameterized
- The existing cloud-init.yaml file (Vault-oriented) - create a new one for jump-man

**Understanding the Tasks:**

- Task 1 (parameterize vendor_data): This makes the module REUSABLE for different VM types, not for deploying Vault
- Task 3 (wire module): REPLACE the existing VM definitions with ONLY the jump_man module (remove or comment out vault VMs)
- When you see "existing Vault code" - this is template code to be refactored/removed, NOT deployed

**Validation Checkpoint:**
After implementation, `terraform plan` should show:

- ✅ Creating 2 resources (jump_man VM + vendor_data)
- ❌ NOT creating any Vault VMs
- ❌ NOT creating 10+ resources

If you see more than 2 resources being created, you've included template code that should have been removed.

## Deployment Parameters (Authoritative)

- Proxmox node: `lloyd`
- Template ID: `8024`
- Template source node: `lloyd` (confirmed)
- Datastore: `local-lvm`
- Bridges: `vmbr0` (single NIC; no VLAN)
- IP: `192.168.10.250/24` (static)
- Gateway: `192.168.10.1`
- DNS servers: `8.8.8.8`, `8.8.4.4`
- Cloud-init username: `ansible`
- SSH public key: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP27rvlC7YSFHzPxMQFWjlb/Rfzls+B6oQh9+Tgi+/aP ansible@jump-man`
- vCPU: `2`
- Memory: `2048` MB with ballooning (floating = `1024` MiB); requires module change (see Task 1b)
- Disk size: `32` GB
- Tags: ["terraform","jump","production"]
- Docker version: latest from official Docker APT repository (no pin)

## Implementation Blueprint

### Terraform Module Interface (Jump Host)

HCL (module usage to be added to `infrastructure/environments/production/main.tf`):

```hcl
module "jump_man" {
  source = "../../modules/vm"

  vm_name      = "jump-man"
  vm_id        = 7000
  vm_node_name = "lloyd"

  # Networking
  vm_ip_primary = "192.168.10.250/24"
  vm_gateway    = "192.168.10.1"
  enable_dual_network = false
  vm_ip_secondary     = ""
  vm_bridge_1         = var.vm_bridge_1     # expect "vmbr0"
  vm_bridge_2         = ""                  # unused
  dns_servers         = var.dns_servers     # [8.8.8.8, 8.8.4.4]

  # Compute + storage
  vcpu       = 2
  vcpu_type  = "host"
  memory     = 2048
  vm_datastore = var.vm_datastore          # "local-lvm"
  vm_disk_size = 32                        # explicit for jump-man

  # Cloud-init
  cloud_init_username = "ansible"
  ci_ssh_key          = var.ci_ssh_key     # set in workspace/vars
  template_id         = var.template_id    # 8024
  template_node       = var.template_node  # lloyd

  # Ballooning (requires module update in vm module — see Task 1b)
  # Enable after module change:
  # memory_floating = 1024

  # Tags (explicit to avoid inheriting vault-related defaults)
  vm_tags = ["terraform","jump","production"]

  # Vendor-data (enable after Task 1 is complete)
  # enable_vendor_data  = true
  # vendor_data_content = file("${path.module}/cloud-init.jump-man.yaml")
}
```

### Tasks (in order)

```yaml
Task 1: Parameterize/disable Vault vendor_data in VM module
  MODIFY infrastructure/modules/vm/variables.tf:
    - ADD variable "enable_vendor_data" (bool, default = false)
    - ADD variable "vendor_data_content" (string, default = "")

  MODIFY infrastructure/modules/vm/main.tf:
    - WRAP proxmox_virtual_environment_file.vendor_data in a conditional
      so it is CREATED ONLY when var.enable_vendor_data is true
    - SET initialization.vendor_data_file_id ONLY when enabled, otherwise omit
    - REMOVE embedded Vault-specific content and source from var.vendor_data_content
    - KEEP backward compatibility by defaulting vendor_data disabled

  VALIDATE: terraform validate in modules/vm passes
  DOCS: run scripts/generate-docs.sh to refresh module inputs/outputs

Task 1b: Add memory ballooning support (per provider semantics)
  MODIFY infrastructure/modules/vm/variables.tf:
    - ADD variable "memory_floating" (number, default = 0)  # 0 disables ballooning

  MODIFY infrastructure/modules/vm/main.tf:
    - In memory { ... } block, SET floating = var.memory_floating when > 0

  NOTE: Confirm provider attribute name (expected: memory.floating) in bpg/proxmox docs
  VALIDATE: terraform validate in modules/vm passes
  DOCS: update module README to document new memory_floating variable

Task 1c: Env mapping for Terraform var
  CONTEXT: Not loading from Infisical at this stage; mise loads env directly.
  MODIFY `.mise.local.toml` to set:
    - `TF_VAR_pve_api_token` directly (required for Terraform)
    - Optionally also set `PROXMOX_API_TOKEN` for consistency/debugging
  VALIDATE: `printenv | grep -E "TF_VAR_pve_api_token|PROXMOX_API_TOKEN"` prints at least:
    - `TF_VAR_pve_api_token=<non-empty>`
    - `PROXMOX_API_TOKEN=<non-empty>` (optional)

Task 2: Create cloud-init file for jump-man
  ADD infrastructure/environments/production/cloud-init.jump-man.yaml:
    - Include package list from Goal
    - Ensure qemu-guest-agent is enabled/started
    - Keep Docker in cloud-init: add official Docker APT repo then install
    - Do NOT install Node.js/npm/uv/mise in cloud-init; defer to Ansible
    - Keep rules permissive (nftables baseline), hardening deferred to Ansible

  VALIDATE: YAML is syntactically valid; minimal runcmd, resilient to retries

Task 3: Wire module in production environment
  MODIFY infrastructure/environments/production/main.tf:
    - ADD module "jump_man" block (see Terraform Module Interface above)
    - Pass var.template_id=8024, var.template_node=lloyd, and other vars
    - Set enable_dual_network=false; do not set secondary bridge/IP
    - If vendor_data made optional, set enable_vendor_data=true and vendor_data_content to file content

  VALIDATE: terraform fmt && terraform validate && terraform plan

Task 4: Expose outputs for jump-man
  MODIFY infrastructure/environments/production/outputs.tf:
    - ADD outputs for module.jump_man.vm_name, vm_id, and ipv4_addresses

  VALIDATE: terraform plan shows outputs

Task 5: Docs
  MODIFY infrastructure/README.md:
    - ADD Jump Host section with usage steps
  RUN scripts/generate-docs.sh (optional) to refresh module docs

Task 6: Runtime validation
  After apply: ping/ssh to 192.168.10.250; verify packages and guest agent
```

### Cloud-init Notes (jump-man)

- Start qemu-guest-agent early (ensure Proxmox IP reporting for outputs)
- Always `apt-get update` prior to package installs after adding repos
- Docker: use official Docker APT repo (keyring signed-by). Install docker and compose plugin.
- Node.js/npm/mise/uv: defer to Ansible (not installed via cloud-init)
- Keep nftables permissive; Ansible will apply hardening later

## Integration Points

- Providers/Backends:

  - Proxmox provider configured in `infrastructure/environments/production/providers.tf`
  - Local backend override present at `infrastructure/environments/production/backend_override.tf`
  - Env loading: `.mise.local.toml` sets environment variables directly (no Infisical integration yet)
    - Required vars set:
      - `TF_VAR_pve_api_url` → Terraform var `pve_api_url`
      - `TF_VAR_pve_api_token` → Terraform var `pve_api_token` (sensitive)
      - `TF_VAR_ci_ssh_key` → Terraform var `ci_ssh_key` (public key)
    - Optional vars set:
      - `TF_VAR_proxmox_insecure` → Terraform var `proxmox_insecure` (bool as string ok)
      - `PROXMOX_API_TOKEN` → convenience mirror of the token (optional; may be omitted)
    - Validation: `printenv | grep -E "TF_VAR_pve_api_(url|token)|TF_VAR_ci_ssh_key|TF_VAR_proxmox_insecure|PROXMOX_API_TOKEN"`
      prints non-empty values for the TF_VAR entries; `PROXMOX_API_TOKEN` may be absent

- Variables (production):

  - `variables.tf` already includes: `template_id` (default 8024), `template_node` (default lloyd),
    `vm_datastore` (local-lvm), `vm_bridge_1` (vmbr0), `dns_servers`, `ci_ssh_key`
  - Ensure `ci_ssh_key` contains the provided public key

- Networking:

  - Single NIC on `vmbr0`; no VLAN
  - Static IP and gateway as above (not DHCP)

- Ansible:
  - Hardening and post-provisioning will be handled via Ansible later
  - Inventory generation may leverage `scripts/generate-ansible-inventory.sh` [TODO: integrate]

## Validation Loop

### Level 1: Static & Syntax

```bash
cd infrastructure/environments/production
terraform init
terraform fmt -check
terraform validate

# Env check (Terraform var injected via mise)
printenv | grep -E "TF_VAR_pve_api_token|PROXMOX_API_TOKEN"
# Expected output (example):
# TF_VAR_pve_api_token=******(non-empty)
# PROXMOX_API_TOKEN=******(optional)

# Optional docs
cd ../../../ && ./scripts/generate-docs.sh
```

Expected: No errors.

### Level 2: Plan Review

```bash
cd infrastructure/environments/production
terraform plan -out=plan.tfplan
```

Review: exactly one VM add (jump-man) on node lloyd, correct IP/gateway, datastore `local-lvm`, bridge `vmbr0`,
agent enabled, tags as expected, vendor_data only set if explicitly enabled,
and memory.floating set to 1024 (once module change is in place).

### Level 3: Apply + Runtime Checks

```bash
terraform apply plan.tfplan

# From admin host once VM boots
ping -c 3 192.168.10.250
ssh ansible@192.168.10.250   # uses provided public key

# On the VM
systemctl status qemu-guest-agent
docker --version
git --version && tmux -V
docker compose version
```

Expected: SSH works; qemu-guest-agent running; packages installed.

### Level 4: Idempotency

```bash
terraform apply  # no changes
```

Expected: No changes reported.

## Error Handling Patterns

- Proxmox API timeouts: prefer reasonable provider/resource timeouts; avoid batch cloning across nodes.
- Agent dependency: start qemu-guest-agent early to ensure IP reporting; tolerate brief delays in first boot.
- Cloud-init resilience: add retries and `apt-get update` after adding repos; keep runcmd short and idempotent.
- IP conflicts: ensure unique `vm_id` and static IP unused; fail fast with clear error if allocation is busy.
- Vendor-data: make optional to avoid unintended software installs across different VM roles.

## Test Requirements

- Static checks: `terraform fmt -check`, `terraform validate` (optionally `tflint`, `tfsec` if available)
- Plan diff: human-reviewed plan confirming only expected resources change
- Runtime smoke: ping + SSH, verify packages and agent
- Outputs: confirm Terraform outputs expose IP(s) for jump-man
- Drift: re-apply shows no changes

## Final Validation Checklist

- [ ] Plan and apply succeed with local backend override
- [ ] VM reachable at 192.168.10.250 via SSH as ansible
- [ ] qemu-guest-agent running; IPs visible in outputs
- [ ] All requested packages installed and working
- [ ] Tags applied correctly
- [ ] Re-apply is idempotent (no changes)
- [ ] Documentation updated (README Jump Host section)

## Open TODOs For You To Confirm

None — decisions above finalize the PRP. Proceed with implementation tasks.
