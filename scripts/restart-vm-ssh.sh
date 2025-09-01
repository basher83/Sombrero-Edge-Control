#!/bin/bash
set -euo pipefail

# Jump Host VM Restart Script
# Restarts the VM and handles SSH key updates for proper connectivity

# Configuration
VM_IP="${VM_IP:-192.168.10.250}"
VM_USER="${VM_USER:-ansible}"
MAX_WAIT_TIME=${MAX_WAIT_TIME:-300}  # 5 minutes max wait

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Restarting jump-man VM to apply configuration changes...${NC}"
echo "Target: $VM_USER@$VM_IP"
echo "Time: $(date)"
echo ""

# Step 1: Initiate reboot
echo -e "${YELLOW}1. Initiating VM reboot...${NC}"
if ssh -o ConnectTimeout=10 -o BatchMode=yes "$VM_USER@$VM_IP" 'sudo reboot' 2>/dev/null; then
    echo "✓ Reboot command sent successfully"
else
    echo "⚠️  Connection lost during reboot (expected)"
fi

# Step 2: Wait for VM to go down
echo -e "\n${YELLOW}2. Waiting for VM to shut down...${NC}"
sleep 15

# Wait for VM to stop responding
for i in {1..10}; do
    if ! ping -c 1 -W 2 "$VM_IP" &>/dev/null; then
        echo "✓ VM is down after $((i * 2)) seconds"
        break
    fi
    echo "Waiting for shutdown... $((i * 2))s"
    sleep 2
done

# Step 3: Wait for VM to come back online
echo -e "\n${YELLOW}3. Waiting for VM to come back online...${NC}"
start_time=$(date +%s)

while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))

    if [ $elapsed -gt $MAX_WAIT_TIME ]; then
        echo -e "${RED}❌ Timeout: VM did not come back online within $((MAX_WAIT_TIME / 60)) minutes${NC}"
        exit 1
    fi

    if ping -c 1 -W 2 "$VM_IP" &>/dev/null; then
        echo -e "${GREEN}✓ VM is responding to ping after ${elapsed} seconds${NC}"
        break
    fi

    echo "Waiting for VM... ${elapsed}s elapsed"
    sleep 5
done

# Step 4: Update SSH known_hosts (VM likely has new host key)
echo -e "\n${YELLOW}4. Updating SSH known_hosts for new host key...${NC}"
echo "Removing old host key..."
ssh-keygen -R "$VM_IP" 2>/dev/null || true

echo "Adding new host key..."
sleep 5  # Give SSH service time to start
if ssh-keyscan -t ed25519 "$VM_IP" >> ~/.ssh/known_hosts 2>/dev/null; then
    echo "✓ New host key added successfully"
else
    echo -e "${YELLOW}⚠️  Could not add host key automatically, SSH may prompt for verification${NC}"
fi

# Step 5: Test SSH connectivity
echo -e "\n${YELLOW}5. Testing SSH connectivity...${NC}"
for i in {1..12}; do  # Try for up to 1 minute
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$VM_USER@$VM_IP" exit &>/dev/null; then
        echo -e "${GREEN}✓ SSH connection successful after $((i * 5)) seconds${NC}"
        break
    fi

    if [ $i -eq 12 ]; then
        echo -e "${RED}❌ SSH connection failed after 60 seconds${NC}"
        echo "Manual intervention may be required."
        exit 1
    fi

    echo "SSH attempt $i failed, retrying in 5s..."
    sleep 5
done

# Step 6: Verify VM is functioning
echo -e "\n${YELLOW}6. Verifying VM functionality...${NC}"

echo "Hostname: $(ssh -o ConnectTimeout=10 "$VM_USER@$VM_IP" hostname)"
echo "Uptime: $(ssh -o ConnectTimeout=10 "$VM_USER@$VM_IP" uptime)"

# Check essential services
echo "\nService Status:"
echo -n "  QEMU Guest Agent: "
ssh -o ConnectTimeout=10 "$VM_USER@$VM_IP" 'systemctl is-active qemu-guest-agent' || echo "inactive"

echo -n "  Docker: "
ssh -o ConnectTimeout=10 "$VM_USER@$VM_IP" 'systemctl is-active docker' || echo "inactive"

# Step 7: Run quick smoke test
echo -e "\n${YELLOW}7. Running quick connectivity test...${NC}"
if ssh -o ConnectTimeout=10 "$VM_USER@$VM_IP" 'curl -s --connect-timeout 5 https://google.com > /dev/null'; then
    echo "✓ Internet connectivity working"
else
    echo "⚠️  Internet connectivity test failed"
fi

echo -e "\n${GREEN}🎉 VM restart completed successfully!${NC}"
echo "VM is accessible at: ssh $VM_USER@$VM_IP"
echo ""
echo -e "${BLUE}💡 Next steps:${NC}"
echo "  • Run full smoke tests: mise run smoke-test"
echo "  • Check cloud-init status: ssh $VM_USER@$VM_IP 'cloud-init status --long'"
echo "  • View system logs: ssh $VM_USER@$VM_IP 'sudo journalctl -u cloud-init --no-pager | tail -20'"
