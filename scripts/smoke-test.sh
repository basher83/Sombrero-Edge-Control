#!/bin/bash
set -euo pipefail

# Jump Host Infrastructure Smoke Tests
# Validates that the jump-man VM is properly provisioned and configured

# Configuration
JUMP_HOST_IP="${JUMP_HOST_IP:-192.168.10.250}"
JUMP_HOST_USER="${JUMP_HOST_USER:-ansible}"
SSH_OPTS="-o ConnectTimeout=10"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

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
        FAILED_TESTS+=("$test_name")
        return 1
    fi
}

# Check if we can reach the host at all
check_connectivity() {
    echo "--- Pre-flight Checks ---"
    if ! ping -c 1 -W 2 "$JUMP_HOST_IP" &>/dev/null; then
        echo -e "${RED}Cannot ping $JUMP_HOST_IP${NC}"
        echo "Please verify:"
        echo "  1. VM is running"
        echo "  2. Network configuration is correct"
        echo "  3. No firewall blocking ICMP"
        exit 1
    fi
    echo -e "${GREEN}✓ Host is pingable${NC}"
    echo ""
}

echo "==================================="
echo "   Jump Host Smoke Tests"
echo "==================================="
echo "Target: $JUMP_HOST_USER@$JUMP_HOST_IP"
echo "Time: $(date)"
echo ""

# Run pre-flight check
check_connectivity

# Infrastructure Tests
echo "--- Infrastructure Validation ---"
run_test "SSH connectivity" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'exit 0'"
run_test "Correct IP address" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'ip addr show' | grep -q $JUMP_HOST_IP"
run_test "Network gateway configured" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'ip route' | grep -q 'default via 192.168.10.1'"
run_test "DNS resolution" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'nslookup google.com &>/dev/null'"
run_test "Hostname set correctly" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'hostname' | grep -q 'jump-man'"

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
run_test "SSH service on port 22" "nc -zv -w5 $JUMP_HOST_IP 22 2>&1 | grep -q 'succeeded'"
run_test "Firewall rules configured" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'sudo iptables -L INPUT -n' | grep -q 'dpt:22'"
run_test "Docker iptables chains exist" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'sudo iptables -L DOCKER -n &>/dev/null'"
run_test "iptables-persistent installed" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'dpkg -l | grep -q iptables-persistent'"

# Package Tests
echo ""
echo "--- Package Installation ---"
for pkg in git tmux curl wget jq python3; do
    run_test "$pkg installed" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'command -v $pkg'"
done

# File System Tests
echo ""
echo "--- File System Validation ---"
run_test "Docker install script exists" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'test -f /opt/docker-install.sh'"
run_test "Firewall setup script exists" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'test -f /opt/firewall-setup.sh'"
run_test "README exists for ansible user" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'test -f /home/ansible/README.md'"
run_test "Docker firewall notes exist" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'test -f /home/ansible/docker-firewall-notes.md'"

# Docker Functionality Test
echo ""
echo "--- Docker Functionality ---"
run_test "Docker hello-world test" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'docker run --rm hello-world &>/dev/null'"
run_test "Docker network working" "ssh $SSH_OPTS $JUMP_HOST_USER@$JUMP_HOST_IP 'docker network ls | grep -q bridge'"

# Summary
echo ""
echo "==================================="
echo "         Test Summary"
echo "==================================="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  - $test"
    done
fi

echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All smoke tests passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please investigate the failures above.${NC}"
    exit 1
fi
