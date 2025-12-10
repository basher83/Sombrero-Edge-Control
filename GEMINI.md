# GEMINI Project Context: Sombrero-Edge-Control

**PRIME DIRECTIVE:** This project is refactoring towards a "Pipeline Separation Architecture."
- **Source of Truth:** [Project Roadmap](docs/ROADMAP.md).
- **Warning:** `README.md` and `scripts/deploy-pipeline.sh` may contain outdated paths. Verify paths against the file structure below.

---

## 1. Project Overview
`Sombrero-Edge-Control` is an Infrastructure as Code (IaC) project deploying a secure DevOps jump host on Proxmox.

**The 3-Stage Pipeline:**
1. **Packer (Build):** Creates a "golden" Ubuntu 24.04 template (OS + `cloud-init` + `qemu-guest-agent` only).
2. **Terraform (Provision):** Clones the Packer template to create the VM hardware and networking.
    - *Output:* Generates `inventory.json` which links Stage 2 to Stage 3.
3. **Ansible (Configure):** Applies software, security hardening, and logic via the `automation_server` collection.

## 2. Directory Map (Critical)
* `packer/`: Image definitions (`.pkr.hcl`).
* `terraform/`: Infrastructure definitions.
* `ansible_collections/basher83/automation_server/`: The Ansible Collection root.
    * `roles/`: Configuration logic.
    * `playbooks/`: Entry points (e.g., `site.yml`).
* `docs/decisions/`: Architectural Decision Records (ADRs).

## 3. Deployment Workflow (Conceptual)
The workflow is sequential. `mise` is used to run all tools.

```bash
# 1. Build Image
packer build ... # Output: Template ID

# 2. Provision Hardware
terraform apply ... # Output: ansible_inventory.json

# 3. Configure Software
ansible-playbook -i ansible_inventory.json playbooks/site.yml


## 4. Development Conventions

  * **Tooling:** Managed via `mise` (see `.mise.toml`).
      * **Python:** Use `uv` exclusively. Never use `pip`.
  * **Linting:**
      * **Pre-commit:** Enforced locally (`terraform fmt`, `terraform-docs`).
      * **MegaLinter:** Enforced in CI (`tflint`, `shellcheck`, `yamllint`).
  * **Dependencies:** Managed via **Renovate**.
  *   **Commits:** Follow [Conventional Commits](https://www.conventionalcommits.org/). Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## 5. Security & Safety

  * **Secrets:** Never output `.tfvars`, `terraform.tfstate`, or private keys. Assume credentials are injected via environment variables.
  * **Testing Status:**
      * *Active:* Pre-commit hooks, Linting.
      * *Planned/Roadmap:* `Terratest`, `Molecule`, `vm_smoke_tests` (Do not attempt to run these yet).
