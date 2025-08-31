# Example modification for main.tf to support DHCP

# Replace the existing initialization block with this:

/*
initialization {
  interface = "ide2"
  type      = "nocloud"
  user_account {
    username = var.cloud_init_username
    keys     = [var.ci_ssh_key]
  }

  # For DHCP configuration
  dynamic "ip_config" {
    for_each = var.use_dhcp ? [1] : []
    content {
      ipv4 {
        dhcp = true
      }
    }
  }

  # For static IP configuration
  dynamic "ip_config" {
    for_each = !var.use_dhcp ? [1] : []
    content {
      ipv4 {
        address = var.vm_ip_primary
        gateway = var.vm_gateway
      }
    }
  }
}
*/

# Alternative simpler approach - just set dhcp = true:
/*
initialization {
  interface = "ide2"
  type      = "nocloud"
  user_account {
    username = var.cloud_init_username
    keys     = [var.ci_ssh_key]
  }

  ip_config {
    ipv4 {
      dhcp = true  # This enables DHCP
    }
  }
}
*/
