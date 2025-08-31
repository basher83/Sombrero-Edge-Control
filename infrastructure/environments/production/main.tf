# Jump Host VM (jump-man) - Production Environment
# This is the only VM being deployed in this configuration

module "jump_man" {
  source = "../../modules/vm"

  vm_name      = "jump-man"
  vm_id        = 7000
  vm_node_name = "lloyd"

  # Networking
  vm_ip_primary       = "192.168.10.250/24"
  vm_gateway          = "192.168.10.1"
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

  # Cloud-init
  cloud_init_username = "ansible"
  ci_ssh_key          = var.ci_ssh_key
  template_id         = var.template_id
  template_node       = var.template_node

  # Tags
  vm_tags = ["terraform", "jump", "production"]

  # Vendor-data for jump-man cloud-init
  enable_vendor_data = true
  vendor_data_content = templatefile("${path.module}/cloud-init.jump-man.yaml", {
    docker_install_script = file("${path.module}/files/scripts/docker-install.sh")
    firewall_setup_script = file("${path.module}/files/scripts/firewall-setup.sh")
    readme_content        = file("${path.module}/files/docs/jump-host-readme.md")
    docker_firewall_docs  = file("${path.module}/files/docs/docker-firewall-compatibility.md")
    ci_ssh_key            = var.ci_ssh_key
  })
}
