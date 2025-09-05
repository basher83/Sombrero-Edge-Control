# Ubuntu Server numbat
# ---
# Packer Template to create an Ubuntu Server (numbat) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}


variable "proxmox_node_name" {
  type      = string
  sensitive = true
}


variable "instance_username" {
  type      = string
  sensitive = true
}

variable "instance_password" {
  type      = string
  sensitive = true
}

# Resource Definiation for the VM Template
source "proxmox-clone" "ubuntu-server-numbat" {

  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_api_url}"
  username    = "${var.proxmox_api_token_id}"
  token       = "${var.proxmox_api_token_secret}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true

  # VM General Settings
  node                 = "${var.proxmox_node_name}"
  # vm_id is not specified - Proxmox will assign next available ID dynamically
  vm_name              = "ubuntu-server-numbat-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  template_description = "Golden Image: Ubuntu 24.04 LTS with Docker, nvm, mise, uv. Built ${formatdate("YYYY_MM_DD hh:mm", timestamp())}"

  # Tags for dynamic template selection (temporarily disabled to test validation)
  # tags = "packer_built,ubuntu_24_04,golden_image,docker,development_tools"

  # Clone from existing template - use template name
  clone_vm = "ubuntu24"  # Your existing cloud-init template name
  full_clone = true

  # VM System Settings
  qemu_agent = true

  # VM CPU Settings
  cores = "1"

  # VM Memory Settings
  memory = "2048"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  ssh_username = "${var.instance_username}"

  # Use password for initial connection (will be disabled after SSH key setup)
  ssh_password = "${var.instance_password}"
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  # ssh_private_key_file = "~/.ssh/proxmox_default"

  # Raise the timeout, when installation takes longer
  ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

  name    = "ubuntu-server-numbat"
  sources = ["source.proxmox-clone.ubuntu-server-numbat"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

  # Provisioning with Ansible for comprehensive golden image setup
  provisioner "ansible" {
    # Core configuration
    playbook_file = "../ansible/playbooks/packer-provision.yml"
    user         = "${var.instance_username}"

    # Performance and reliability settings
    use_proxy                = false  # Recommended for Ansible 2.8+
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_FORCE_COLOR=1",
      "PYTHONUNBUFFERED=1"
    ]

    # Pass Packer context to Ansible
    extra_arguments = [
      "--extra-vars", "packer_build=true",
      "--extra-vars", "golden_image_build=true",
      "--extra-vars", "build_timestamp=${timestamp()}",
      "-v"  # Verbose output for debugging
    ]

    # Inventory configuration (automatically handled by Packer)
    groups = ["golden_image", "packer_build"]
  }
}
