#!/bin/bash
set -euo pipefail

# Firewall Setup for Docker Compatibility
# Docker requires iptables, not pure nftables
# This creates basic rules that work with Docker's automatic chain management

# Install iptables-persistent for saving rules
apt-get install -y iptables-persistent netfilter-persistent

# Basic INPUT chain rules (Docker manages its own chains)
# Accept loopback
iptables -A INPUT -i lo -j ACCEPT

# Accept established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Accept SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Docker will automatically manage the DOCKER, DOCKER-ISOLATION, and DOCKER-USER chains
# Custom rules for Docker containers should be added to DOCKER-USER chain
# For now, we keep the INPUT chain permissive - will be hardened via Ansible

# Log new connections for monitoring (optional)
iptables -A INPUT -m state --state NEW -j LOG --log-prefix "iptables-new: " --log-level 4

# Default policy: ACCEPT for now (permissive during initial setup)
# Will be changed to DROP with specific allow rules via Ansible
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Save rules
netfilter-persistent save

echo "Firewall configured for Docker compatibility"
