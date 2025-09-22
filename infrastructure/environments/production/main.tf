# Jump Host VM (jump-man) - Production Environment
# Uses dynamic template selection to automatically use the latest Packer-built golden image

# Data source to find Packer-built templates (when available)
data "proxmox_virtual_environment_vms" "golden_images" {
  node_name = var.template_node
  tags      = ["packer-built", "ubuntu-24-04"]
}

# Select the most recent golden image template, fallback to configured template
locals {
  # Find the highest VM ID among templates (most recent Packer build)
  golden_image_templates = [
    for vm in try(data.proxmox_virtual_environment_vms.golden_images.vms, []) : vm.vm_id
    if try(vm.template, false)
  ]

  # Use latest golden image or fallback to configured template ID
  selected_template_id = length(local.golden_image_templates) > 0 ? max(local.golden_image_templates...) : var.template_id

  # Template selection metadata for outputs
  template_source = length(local.golden_image_templates) > 0 ? "packer-golden-image" : "configured-template"
}

module "jump_man" {
  source = "../../modules/vm"

  vm_name      = "jump-man"
  vm_id        = 7000
  vm_node_name = "lloyd"

  # Networking
  vm_ip_primary       = "192.168.10.250/24"
  vm_gateway          = var.vm_gateway
  enable_dual_network = false
  vm_ip_secondary     = ""
  vm_bridge_1         = var.vm_bridge_1
  vm_bridge_2         = ""
  dns_servers         = var.dns_servers

  # Compute + storage
  vcpu            = 2
  vcpu_type       = "host"
  memory          = 2048
  memory_floating = 1024 # Enable memory ballooning
  vm_datastore    = var.vm_datastore
  vm_disk_size    = 32

  # Cloud-init with dynamic template selection
  template_id   = local.selected_template_id
  template_node = var.template_node

  # Tags
  vm_tags = ["terraform", "jump", "production"]

  # Simplified cloud-init - SSH access only
  ci_ssh_key = var.ci_ssh_key
}
