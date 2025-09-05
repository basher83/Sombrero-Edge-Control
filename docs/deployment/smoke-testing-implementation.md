# Smoke Testing Implementation Guide

## Overview

This document defines the smoke testing strategy for the Sombrero Edge Control jump host infrastructure,
covering both Terraform provisioning validation and post-deployment verification.

## What Are Smoke Tests?

In our IaC context, smoke tests are **lightweight, automated validation checks** that verify:

- Infrastructure resources were created successfully (Terraform)
- Basic connectivity and network paths are functional
- Essential services are running and accessible
- Critical configurations are applied correctly

## Testing Phases

### Phase 1: Infrastructure Provisioning (Terraform)

After `terraform apply`, validate that core infrastructure components exist and are accessible.

#### 1.1 Resource Existence Checks

```bash
# Verify VM creation
terraform output jump_host

# Check VM is visible in Proxmox
ssh root@proxmox-host "qm status 7000"
```

#### 1.2 Network Connectivity

```bash
# Test SSH connectivity
ssh -o ConnectTimeout=10 ansible@192.168.10.250 "echo 'SSH connection successful'"

# Verify network configuration
ssh ansible@192.168.10.250 "ip addr show | grep 192.168.10.250"
ssh ansible@192.168.10.250 "ip route | grep default"
```

#### 1.3 QEMU Guest Agent

```bash
# Verify agent is running (enables IP reporting in Terraform)
ssh ansible@192.168.10.250 "systemctl is-active qemu-guest-agent"

# Check Terraform can retrieve IPs
terraform output -json jump_host | jq '.ipv4_addresses'
```

### Phase 2: Service Validation (Post-Cloud-Init)

Verify that cloud-init completed successfully and services are operational.

#### 2.1 Cloud-Init Status

```bash
# Check cloud-init completion
ssh ansible@192.168.10.250 "cloud-init status --wait"

# Verify no cloud-init errors
ssh ansible@192.168.10.250 "cloud-init status --long"
```

#### 2.2 Docker Installation

```bash
# Docker service status
ssh ansible@192.168.10.250 "systemctl is-active docker"

# Docker version verification
ssh ansible@192.168.10.250 "docker --version"

# Docker Compose plugin
ssh ansible@192.168.10.250 "docker compose version"

# Verify ansible user can run Docker
ssh ansible@192.168.10.250 "docker run --rm hello-world"
```

#### 2.3 Firewall Configuration

```bash
# Verify iptables is configured
ssh ansible@192.168.10.250 "sudo iptables -L INPUT -n | grep -q 'tcp dpt:22'"

# Check Docker chains exist
ssh ansible@192.168.10.250 "sudo iptables -L DOCKER -n 2>/dev/null && echo 'Docker chains configured'"

# Verify iptables-persistent is installed
ssh ansible@192.168.10.250 "dpkg -l | grep iptables-persistent"
```

#### 2.4 Essential Packages

```bash
# Create a package verification script
cat << 'EOF' > /tmp/check_packages.sh
#!/bin/bash
packages=("git" "tmux" "curl" "wget" "jq" "python3")
for pkg in "${packages[@]}"; do
    if command -v "$pkg" &> /dev/null; then
        echo "✓ $pkg installed"
    else
        echo "✗ $pkg missing"
        exit 1
    fi
done
EOF

# Run package checks
scp /tmp/check_packages.sh ansible@192.168.10.250:/tmp/
ssh ansible@192.168.10.250 "bash /tmp/check_packages.sh"
```

## Automated Smoke Test Script

Create `scripts/smoke-test.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Configuration
JUMP_HOST_IP="192.168.10.250"
JUMP_HOST_USER="ansible"
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name... "
    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "=== Jump Host Smoke Tests ==="
echo "Target: $JUMP_HOST_USER@$JUMP_HOST_IP"
echo ""

# Infrastructure Tests
echo "--- Infrastructure Validation ---"
run_test "Terraform outputs available" "terraform output jump_host &>/dev/null"
run_test "SSH connectivity" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'exit 0'"
run_test "Correct IP address" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'ip addr show' | grep -q $JUMP_HOST_IP"
run_test "Network gateway configured" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'ip route' | grep -q 'default via 192.168.10.1'"
run_test "DNS resolution" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'nslookup google.com' | grep -q 'Address:'"

# Service Tests
echo ""
echo "--- Service Validation ---"
run_test "Cloud-init completed" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'cloud-init status' | grep -q 'status: done'"
run_test "QEMU guest agent running" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'systemctl is-active qemu-guest-agent'"
run_test "Docker service running" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'systemctl is-active docker'"
run_test "Docker accessible by ansible user" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'docker ps'"
run_test "Docker Compose plugin installed" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'docker compose version'"

# Security Tests
echo ""
echo "--- Security Validation ---"
run_test "SSH service on port 22" "nc -zv -w5 $JUMP_HOST_IP 22"
run_test "Firewall rules configured" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'sudo iptables -L INPUT -n' | grep -q 'dpt:22'"
run_test "Docker iptables chains exist" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'sudo iptables -L DOCKER -n &>/dev/null'"

# Package Tests
echo ""
echo "--- Package Installation ---"
for pkg in git tmux curl wget jq python3; do
    run_test "$pkg installed" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'command -v $pkg'"
done

# Summary
echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All smoke tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please investigate.${NC}"
    exit 1
fi
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Infrastructure Smoke Tests

on:
  workflow_dispatch:
  push:
    paths:
      - 'infrastructure/**'
      - '.github/workflows/smoke-tests.yml'

jobs:
  smoke-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.3.0"

      - name: Initialize Terraform
        run: |
          cd infrastructure/environments/production
          terraform init

      - name: Get Infrastructure Outputs
        run: |
          cd infrastructure/environments/production
          terraform output -json > /tmp/outputs.json

      - name: Run Smoke Tests
        run: |
          chmod +x scripts/smoke-test.sh
          ./scripts/smoke-test.sh

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: smoke-test-results
          path: /tmp/smoke-test-*.log
```

### Mise Task Integration

Add to `.mise.toml`:

```toml
[tasks.smoke-test]
description = "Run infrastructure smoke tests"
deps = ["prod-apply"]
run = "./scripts/smoke-test.sh"

[tasks.smoke-test-docker]
description = "Test Docker functionality specifically"
run = """
ssh ansible@192.168.10.250 <<'EOF'
  docker run --rm hello-world
  docker ps -a
  docker system info
EOF
"""

[tasks.smoke-test-quick]
description = "Quick connectivity test"
run = """
echo "Testing SSH connectivity..."
ssh -o ConnectTimeout=5 ansible@192.168.10.250 'hostname && uptime'
"""
```

## Terraform Native Testing

### Using Terraform Check Blocks

Add to `infrastructure/environments/production/checks.tf`:

```hcl
# Check blocks for post-apply validation
check "jump_host_connectivity" {
  data "http" "ssh_test" {
    url = "http://192.168.10.250:22"
    request_timeout_ms = 5000
  }

  assert {
    condition = can(data.http.ssh_test)
    error_message = "Jump host is not reachable on SSH port"
  }
}

check "vm_running" {
  assert {
    condition = module.jump_man.vm_id == 7000
    error_message = "Jump host VM ID mismatch"
  }
}
```

### Using Terraform Test Framework

Create `infrastructure/tests/jump_host.tftest.hcl`:

```hcl
variables {
  ci_ssh_key = "ssh-ed25519 AAAAC3... test@example"
}

run "validate_jump_host" {
  command = plan

  assert {
    condition = module.jump_man.vm_name == "jump-man"
    error_message = "VM name should be jump-man"
  }

  assert {
    condition = module.jump_man.vm_id == 7000
    error_message = "VM ID should be 7000"
  }
}

run "apply_and_verify" {
  command = apply

  assert {
    condition = length(module.jump_man.ipv4_addresses) > 0
    error_message = "VM should have at least one IPv4 address"
  }
}
```

## Monitoring and Alerting

### Health Check Endpoint

For continuous monitoring, consider adding a simple health check service:

```bash
# Create health check script on jump host
cat << 'EOF' > /usr/local/bin/health-check.sh
#!/bin/bash
{
  echo "HTTP/1.1 200 OK"
  echo "Content-Type: application/json"
  echo ""
  echo '{"status":"healthy","services":{'
  echo -n '"docker":"'$(systemctl is-active docker)'",'
  echo -n '"qemu-agent":"'$(systemctl is-active qemu-guest-agent)'"'
  echo '}}'
} | nc -l -p 8080 -q 1
EOF

chmod +x /usr/local/bin/health-check.sh
```

## Best Practices

### 1. Test Design Principles

- **Fast Execution**: Keep tests under 60 seconds total
- **Critical Path Focus**: Test only essential functionality
- **Clear Failure Messages**: Provide actionable error messages
- **Idempotent**: Tests should be runnable multiple times

### 2. Test Categories Priority

1. **Critical (P0)**: SSH access, network connectivity
1. **High (P1)**: Docker service, firewall rules
1. **Medium (P2)**: Package installations, configurations
1. **Low (P3)**: Documentation files, optional features

### 3. Failure Response

- **Critical failures**: Block deployment, trigger rollback
- **High failures**: Alert team, manual intervention required
- **Medium failures**: Log warning, continue with caution
- **Low failures**: Log for review, no immediate action

## Troubleshooting Guide

### Common Issues and Solutions

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| SSH connection timeout | Network misconfiguration | Check security groups, firewall rules |
| Docker not running | Cloud-init failure | Review `/var/log/cloud-init-output.log` |
| QEMU agent not responding | Service not started | Run `systemctl restart qemu-guest-agent` |
| Terraform outputs empty | Agent not running | Ensure QEMU guest agent is active |
| Package missing | Cloud-init incomplete | Check apt logs, retry installation |

### Debug Commands

```bash
# Check cloud-init logs
ssh ansible@192.168.10.250 "sudo journalctl -u cloud-init"

# View Docker logs
ssh ansible@192.168.10.250 "sudo journalctl -u docker"

# Check system resources
ssh ansible@192.168.10.250 "free -h && df -h"

# Network diagnostics
ssh ansible@192.168.10.250 "ss -tulpn"
```

## References

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Docker Post-Installation Steps](https://docs.docker.com/engine/install/linux-postinstall/)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/)
- [Proxmox QEMU Guest Agent](https://pve.proxmox.com/wiki/Qemu-guest-agent)
