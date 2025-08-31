terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73.2"
    }
  }
}

# Create vendor data snippet on the target Proxmox node (only if enabled)
resource "proxmox_virtual_environment_file" "vendor_data" {
  count = var.enable_vendor_data ? 1 : 0

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.vm_node_name

  source_raw {
    file_name = "${var.vm_name}-vendor.yaml"
    data      = var.vendor_data_content
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  vm_id     = var.vm_id
  node_name = var.vm_node_name

  tags        = var.vm_tags
  description = "Provisioned by Terraform"
  bios        = "ovmf"

  agent {
    enabled = true # Will be installed via cloud-init
    timeout = "5m" # Reduced from default 15m since cloud-init installs it quickly
  }

  clone {
    vm_id     = var.template_id
    node_name = var.template_node # Source node where template exists
    full      = true
  }

  disk {
    datastore_id = var.vm_datastore
    interface    = "scsi0"
    size         = var.vm_disk_size
    file_format  = "raw"
    cache        = "writeback"
    iothread     = false
  }

  efi_disk {
    datastore_id      = var.vm_datastore
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = true
  }

  network_device {
    bridge = var.vm_bridge_1
  }

  dynamic "network_device" {
    for_each = var.enable_dual_network ? [1] : []
    content {
      bridge = var.vm_bridge_2
    }
  }

  cpu {
    cores = var.vcpu
    type  = var.vcpu_type
  }

  memory {
    dedicated = var.memory
    floating  = var.memory_floating > 0 ? var.memory_floating : null
  }

  initialization {
    interface = "ide2"
    type      = "nocloud"

    vendor_data_file_id = var.enable_vendor_data ? proxmox_virtual_environment_file.vendor_data[0].id : null

    user_account {
      username = var.cloud_init_username
      keys     = [var.ci_ssh_key]
    }

    ip_config {
      ipv4 {
        address = var.vm_ip_primary
        gateway = var.vm_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    dynamic "ip_config" {
      for_each = var.enable_dual_network && var.vm_ip_secondary != "" ? [1] : []
      content {
        ipv4 {
          address = var.vm_ip_secondary
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [initialization["user_account"]]
  }
}
