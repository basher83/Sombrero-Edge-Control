# Pipeline Rollback Procedures

## Stage 3 Rollback (Ansible)

```bash
# Re-run with previous playbook version
git checkout HEAD~1 -- ansible_collections/
ansible-playbook -i inventory/ansible_inventory.json playbooks/site.yml
```

## Stage 2 Rollback (Terraform)

```bash
cd infrastructure/environments/production
terraform destroy -auto-approve
# Or revert to previous state
terraform apply -target=proxmox_vm_qemu.jump-man -replace=proxmox_vm_qemu.jump-man
```

## Stage 1 Rollback (Packer)

```bash
# Use previous template ID
terraform apply -var="template_id=8024"  # Old template
```

## Emergency Rollback

If the pipeline fails catastrophically:

1. **Destroy VM**: `terraform destroy -auto-approve`
1. **Use known good template**: `terraform apply -var="template_id=8024"`
1. **Re-run Ansible**: `./scripts/stage-3-ansible.sh`

## Validation After Rollback

```bash
./scripts/validate-pipeline.sh
```

If validation fails, start from Stage 1:

```bash
./scripts/stage-1-packer.sh
./scripts/stage-2-terraform.sh 8025
./scripts/stage-3-ansible.sh
```
