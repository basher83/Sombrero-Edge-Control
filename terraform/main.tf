# Jump Host VM (jump-man) - Direct Resource Definition
# Purpose: Provision infrastructure only - VM from template with network configuration
# Configuration: Handled by Ansible in stage 3 of pipeline

resource "proxmox_virtual_environment_vm" "jump_man" {
  name      = var.vm_name
  vm_id     = var.vm_id
  node_name = var.proxmox_node

  tags        = ["terraform", "jump", "production"]
  description = "Jump host provisioned by Terraform from template ${var.template_id}"
  bios        = "ovmf"

  # Enable QEMU agent (pre-installed in template)
  agent {
    enabled = true
    timeout = "5m"
  }

  # Clone from existing template
  clone {
    vm_id     = var.template_id
    node_name = var.proxmox_node
    full      = true
  }

  # Primary disk configuration
  disk {
    datastore_id = var.vm_datastore
    interface    = "scsi0"
    size         = var.vm_disk_size
    file_format  = "raw"
    cache        = "writeback"
    iothread     = false
  }

  # EFI disk for UEFI boot
  efi_disk {
    datastore_id      = var.vm_datastore
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = true
  }

  # Network configuration - static IP
  network_device {
    bridge      = var.vm_bridge
    firewall    = false
    mac_address = var.vm_mac_address
  }

  # Resource allocation
  cpu {
    cores   = var.vm_cores
    sockets = 1
    type    = var.vm_cpu_type
  }

  memory {
    dedicated = var.vm_memory
    floating  = var.vm_memory_floating
  }

  # Cloud-init for SSH access only
  initialization {
    datastore_id = var.vm_datastore
    interface    = "ide0"

    ip_config {
      ipv4 {
        address = var.vm_ip_address
        gateway = var.vm_gateway
      }
    }

    user_account {
      username = var.ci_username
      keys     = var.ssh_authorized_keys
    }
  }

  # Start VM after creation
  started = true

  lifecycle {
    ignore_changes = [
      initialization[0].user_account[0].password,
      initialization[0].user_data_file_id,
      initialization[0].vendor_data_file_id
    ]
  }
}
