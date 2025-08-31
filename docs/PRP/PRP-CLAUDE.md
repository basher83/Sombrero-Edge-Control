# CLAUDE.md

Guidance for AI coding assistants working in this repository. This project is an IaC repo (Terraform + cloud-init)
targeting Proxmox for a jump host VM ("jump-man"). Older Vault-cluster guidance exists; use this file and
docs/PRP.md as the current source of truth.

## 🔄 Project Awareness & Context

- Always read docs/PRP.md at the start of a new conversation for goals, parameters, and validation steps.
  If PLANNING.md exists, read it too.
- Check TASK.md before starting new work. If missing, create it and log tasks with dates and brief descriptions.
- Keep naming, file structure, and patterns consistent with infrastructure/modules and infrastructure/environments.
- Activate mise env before running Terraform or scripts so TF*VAR*\* env vars are present. Example: eval "$(mise env -s bash)".

### 🧱 Code Structure & Modularity

- Keep files under 500 lines; split into smaller modules/files when needed.
- Organize Terraform by responsibility:
  - infrastructure/modules/vm: reusable VM provisioning module
  - infrastructure/environments/{env}: environment-specific wiring and values
- Prefer parameterization over copy-paste. Avoid embedding role-specific cloud-init; inject vendor_data via
  module inputs (see docs/PRP.md tasks).
- For memory ballooning, prefer provider-native attributes (memory.floating) implemented as module inputs.
- Use clear variable/outputs naming (snake_case), and keep tags consistent across resources.

### 🧪 Testing & Reliability

- Run static checks before changes land:
  - terraform fmt -check
  - terraform validate
  - Optional: tflint, tfsec, terraform-docs generation
- For plans and applies:
  - Use backend_override.tf for local testing when provided
  - terraform plan -out=plan.tfplan and review for only expected diffs
  - terraform apply plan.tfplan for controlled changes
- Runtime verification (for VMs): ensure qemu-guest-agent runs; verify SSH, IPs, and required packages as per docs/PRP.md.

### ✅ Task Completion

- Mark tasks done in TASK.md when complete; add a “Discovered During Work” section for follow-ups.
- Update docs/PRP.md if requirements or validation steps change.

### 📎 Style & Conventions

- Primary language: Terraform HCL (not Python).
- Pin providers with version constraints; follow existing version blocks.
- Do not commit .tfstate, .terraform, or sensitive files; keep .mise.local.toml out of VCS (already ignored).
- Use terraform-docs for module/environment READMEs where applicable.
- Environment variables: set via `.mise.local.toml` using TF*VAR*\* for Terraform variables.

### 📚 Documentation & Explainability

- Update README.md and module READMEs when inputs/outputs or usage change.
- For non-obvious logic, add concise comments explaining “why” (use # comments in HCL sparingly and meaningfully).
- Regenerate docs with ./scripts/generate-docs.sh when inputs/outputs change.

### 🧠 AI Behavior Rules

- Never assume missing context; ask if uncertain (e.g., VM IDs, node placement, disk sizes).
- Do not hallucinate resources or providers; align with bpg/proxmox provider.
- Confirm files/paths before referencing or editing.
- Avoid deleting or overwriting unrelated code; keep changes minimal and scoped to the task.

## Quick Commands

- Initialize and validate (production):

```bash
cd infrastructure/environments/production
mise env  # ensure TF_VAR_* env vars are exported
terraform init
terraform fmt -check
terraform validate
terraform plan
```

- Apply (local backend override present):

```bash
terraform apply
```

- Docs generation:

```bash
./scripts/generate-docs.sh
```

## Provider & Versions

- Terraform: >= 1.3.0
- Proxmox provider: bpg/proxmox >= 0.73.2

## Environment Variables (mise)

Set in .mise.local.toml (no secrets committed):

- TF_VAR_pve_api_url → var.pve_api_url (e.g., `https://pve:8006/api2/json`)
- TF_VAR_pve_api_token → var.pve_api_token (sensitive)
- TF_VAR_ci_ssh_key → var.ci_ssh_key (public key)
- TF_VAR_proxmox_insecure → var.proxmox_insecure (optional)

Validate env:

```bash
printenv | grep -E 'TF_VAR_pve_api_(url|token)|TF_VAR_ci_ssh_key|TF_VAR_proxmox_insecure'
```

## Project Layout (current)

- infrastructure/environments/production/ — production wiring and variables
- infrastructure/modules/vm/ — reusable VM module (to be made role-agnostic via injected vendor_data)
- scripts/ — utilities (docs generation, tags)
- docs/ — PRP and related documentation

## Important Notes

- Prefer injected cloud-init vendor_data over embedded role-specific snippets (DRY, role-agnostic module).
- Keep Docker install in cloud-init via official Docker repo; other tooling via Ansible later.
- Use memory.floating for ballooning support (implement via module variable as described in docs/PRP.md).
- Do not commit state or secrets; use `.mise.local.toml` for local TF*VAR*\* envs; backend overrides exist for local testing.
