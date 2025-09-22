terraform {
  required_version = ">= 1.3.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73.2"
    }
  }
}

# Removed user_data and vendor_data resources for simplified cloud-init

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

    # Use user_account for simplified cloud-init
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
