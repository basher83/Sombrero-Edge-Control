# Jump Host VM (jump-man) - Direct Resource Definition
# Purpose: Provision infrastructure only - VM from template with network configuration
# Configuration: Handled by Ansible in stage 3 of pipeline

resource "proxmox_virtual_environment_vm" "jump_man" {
  name      = var.vm_name
  vm_id     = var.vm_id
  node_name = var.vm_node_name

  tags        = ["terraform", "jump", "production"]
  description = "Provisioned by Terraform from template ${var.vm_clone_vm_id}"
  bios        = var.vm_bios
  started     = true

  # Enable QEMU agent (pre-installed in template)
  agent {
    enabled = var.vm_agent_enabled
    timeout = var.vm_agent_timeout
  }

  # Clone from existing template
  clone {
    vm_id     = var.vm_clone_vm_id
    node_name = var.vm_clone_node_name
    full      = var.vm_clone_full
  }

  # Primary disk configuration
  disk {
    datastore_id = var.vm_disk_datastore
    interface    = var.vm_disk_interface
    size         = var.vm_disk_size
    file_format  = var.vm_disk_file_format
    cache        = var.vm_disk_cache
    iothread     = var.vm_disk_iothread
  }

  # EFI disk for UEFI boot
  efi_disk {
    datastore_id      = var.vm_efi_disk_datastore_id
    file_format       = var.vm_efi_disk_file_format
    type              = var.vm_efi_disk_type
    pre_enrolled_keys = var.vm_efi_disk_pre_enrolled_keys
  }

  # Network configuration - static IP
  network_device {
    bridge      = var.vm_network_device_bridge
    firewall    = var.vm_network_device_firewall
    mac_address = var.vm_network_device_mac_address
  }

  # Resource allocation
  cpu {
    cores   = var.vm_cpu_cores
    sockets = var.vm_cpu_sockets
    type    = var.vm_cpu_type
  }

  memory {
    dedicated = var.vm_memory_dedicated
    floating  = var.vm_memory_floating
  }

  # Cloud-init for SSH access only
  initialization {
    datastore_id = var.vm_initialization_datastore_id
    interface    = var.vm_initialization_interface

    ip_config {
      ipv4 {
        address = var.vm_initialization_ip_config_ipv4_address
        gateway = var.vm_initialization_ip_config_ipv4_gateway
      }
    }

    user_account {
      username = var.vm_initialization_user_account_username
      keys     = var.vm_initialization_user_account_keys
    }
  }

  lifecycle {
    ignore_changes = [
      initialization[0].user_account[0].password,
      initialization[0].user_data_file_id,
      initialization[0].vendor_data_file_id
    ]
  }
}
