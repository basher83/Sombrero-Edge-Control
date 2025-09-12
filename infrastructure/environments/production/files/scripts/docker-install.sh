#!/bin/bash
set -euo pipefail

# Docker Installation Script - Following official documentation
# https://docs.docker.com/engine/install/ubuntu/

# Add Docker's official GPG key
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null

# Update package index
apt-get update

# Install Docker packages
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add ansible user to docker group (for non-root Docker access)
usermod -aG docker ansible || true

# Enable and start Docker service
systemctl enable docker
systemctl start docker
