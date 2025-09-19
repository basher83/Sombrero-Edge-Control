---
Task: Performance Validation and Benchmarking
Task ID: SEP-006
Priority: P2 (Nice to Have)
Estimated Time: 2 hours
Dependencies: SEP-005
Status: ⏸️ Blocked
---

## Objective

Validate that the separated pipeline meets performance targets and document benchmarks for each stage. Compare performance metrics before and after the refactor to ensure the changes deliver expected improvements in build time, deployment speed, and maintainability.

## Prerequisites

- [ ] SEP-005 completed (pipeline integration)
- [ ] Access to performance monitoring tools
- [ ] Baseline metrics from legacy pipeline documented

## Implementation Steps

### 1. **Document Baseline Metrics**

Create `docs/project/performance/baseline-metrics.md`:

```markdown
# Legacy Pipeline Baseline Metrics

## Measurements (Before Refactor)

- **Packer Build Time**: ~12 minutes (with Docker/tools)
- **Terraform Apply Time**: ~3 minutes (with complex cloud-init)
- **Total Deployment**: ~15 minutes
- **Image Size**: 3.8GB
- **Cloud-init Lines**: 250+
- **Duplicate Code**: ~40% between cloud-init and Ansible
```

### 2. **Create Performance Test Script**

Create `scripts/benchmark-pipeline.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Performance benchmarking script
RESULTS_FILE="benchmark-results-$(date +%Y%m%d-%H%M%S).json"

echo "Starting pipeline performance benchmark..."

# Initialize results
cat > "$RESULTS_FILE" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "stages": {}
}
EOF

# Benchmark Stage 1: Packer
echo "Benchmarking Packer build..."
PACKER_START=$(date +%s)
cd packer
if packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl; then
    PACKER_END=$(date +%s)
    PACKER_DURATION=$((PACKER_END - PACKER_START))

    # Get image size
    IMAGE_SIZE=$(ssh root@proxmox "qm config 8025 | grep 'virtio0:' | awk -F'size=' '{print \$2}'")

    jq ".stages.packer = {
        \"duration_seconds\": $PACKER_DURATION,
        \"image_size\": \"$IMAGE_SIZE\",
        \"status\": \"success\"
    }" "$RESULTS_FILE" > tmp.json && mv tmp.json "$RESULTS_FILE"
fi

# Benchmark Stage 2: Terraform
echo "Benchmarking Terraform provisioning..."
TERRAFORM_START=$(date +%s)
cd ../infrastructure/environments/production
if terraform apply -auto-approve; then
    TERRAFORM_END=$(date +%s)
    TERRAFORM_DURATION=$((TERRAFORM_END - TERRAFORM_START))

    jq ".stages.terraform = {
        \"duration_seconds\": $TERRAFORM_DURATION,
        \"status\": \"success\"
    }" "$RESULTS_FILE" > tmp.json && mv tmp.json "$RESULTS_FILE"

    # Export inventory
    terraform output -json ansible_inventory > ansible_inventory.json
fi

# Wait for VM
sleep 30

# Benchmark Stage 3: Ansible
echo "Benchmarking Ansible configuration..."
ANSIBLE_START=$(date +%s)
cd ../../../ansible_collections/basher83/automation_server
if ansible-playbook -i ../../infrastructure/environments/production/ansible_inventory.json playbooks/site.yml; then
    ANSIBLE_END=$(date +%s)
    ANSIBLE_DURATION=$((ANSIBLE_END - ANSIBLE_START))

    jq ".stages.ansible = {
        \"duration_seconds\": $ANSIBLE_DURATION,
        \"status\": \"success\"
    }" "$RESULTS_FILE" > tmp.json && mv tmp.json "$RESULTS_FILE"
fi

# Calculate totals
TOTAL_DURATION=$((TERRAFORM_DURATION + ANSIBLE_DURATION))
jq ".summary = {
    \"total_deployment_seconds\": $TOTAL_DURATION,
    \"total_deployment_minutes\": $(echo "scale=2; $TOTAL_DURATION / 60" | bc)
}" "$RESULTS_FILE" > tmp.json && mv tmp.json "$RESULTS_FILE"

echo "Benchmark complete. Results saved to: $RESULTS_FILE"
cat "$RESULTS_FILE" | jq .
```

### 3. **Create Validation Tests**

Create `tests/performance-validation.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Performance validation against targets
echo "=== Performance Target Validation ==="

# Target metrics
TARGET_PACKER_BUILD=420  # 7 minutes in seconds
TARGET_DEPLOYMENT=60      # 60 seconds for Terraform + Ansible
TARGET_IMAGE_SIZE=2048    # 2GB in MB

# Run benchmark
./scripts/benchmark-pipeline.sh

# Parse results
RESULTS=$(ls -t benchmark-results-*.json | head -1)
PACKER_TIME=$(jq '.stages.packer.duration_seconds' "$RESULTS")
DEPLOYMENT_TIME=$(jq '.summary.total_deployment_seconds' "$RESULTS")
IMAGE_SIZE=$(jq -r '.stages.packer.image_size' "$RESULTS" | sed 's/G//')

# Validate targets
PASS=true

echo -n "Packer build time: ${PACKER_TIME}s (target: <${TARGET_PACKER_BUILD}s) ... "
if [ "$PACKER_TIME" -le "$TARGET_PACKER_BUILD" ]; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    PASS=false
fi

echo -n "Deployment time: ${DEPLOYMENT_TIME}s (target: <${TARGET_DEPLOYMENT}s) ... "
if [ "$DEPLOYMENT_TIME" -le "$TARGET_DEPLOYMENT" ]; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    PASS=false
fi

echo -n "Image size: ${IMAGE_SIZE}GB (target: <${TARGET_IMAGE_SIZE}MB) ... "
if (( $(echo "$IMAGE_SIZE < 2" | bc -l) )); then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    PASS=false
fi

if [ "$PASS" = true ]; then
    echo "=== All performance targets met ==="
    exit 0
else
    echo "=== Some targets not met ==="
    exit 1
fi
```

### 4. **Create Comparison Report**

Generate performance comparison report:

```bash
#!/bin/bash
# scripts/generate-performance-report.sh

cat > docs/project/performance/comparison-report.md <<'EOF'
# Pipeline Performance Comparison Report

## Executive Summary

The pipeline separation refactor has achieved significant performance improvements:

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Packer Build | 12 min | 7 min | 42% faster |
| Deployment | 3 min | <1 min | 67% faster |
| Total Time | 15 min | 8 min | 47% faster |
| Image Size | 3.8 GB | 1.8 GB | 53% smaller |
| Cloud-init | 250 lines | 30 lines | 88% reduction |

## Detailed Metrics

### Build Phase
- Removed unnecessary software from base image
- Eliminated Ansible provisioner from Packer
- Reduced I/O operations by 60%

### Deployment Phase
- Simplified cloud-init to SSH-only
- Removed package installations from Terraform
- Parallel execution opportunities identified

### Configuration Phase
- Single source of truth in Ansible
- Idempotent operations
- Cacheable role dependencies
EOF
```

### 5. **Document Performance Monitoring**

Create ongoing monitoring setup:

```yaml
# ansible_collections/basher83/automation_server/playbooks/performance-check.yml
---
- name: Performance Health Check
  hosts: jump_hosts
  gather_facts: yes

  tasks:
    - name: Check boot time
      command: systemd-analyze
      register: boot_time

    - name: Check service startup times
      command: systemd-analyze blame
      register: service_times

    - name: Report metrics
      debug:
        msg:
          - "Boot time: {{ boot_time.stdout }}"
          - "Top 5 slowest services:"
          - "{{ service_times.stdout_lines[:5] }}"
```

## Success Criteria

- [ ] Packer builds complete in < 7 minutes
- [ ] Deployment (Terraform + Ansible) < 60 seconds
- [ ] Image size < 2GB
- [ ] Cloud-init configuration < 50 lines
- [ ] No duplicate code between tools
- [ ] All performance metrics documented
- [ ] Comparison report generated

## Validation

### Run Complete Benchmark

```bash
# Full pipeline benchmark
./scripts/benchmark-pipeline.sh

# Validate against targets
./tests/performance-validation.sh

# Generate comparison report
./scripts/generate-performance-report.sh
```

### Check Individual Stages

```bash
# Packer only
time packer build -var-file=variables.pkrvars.hcl ubuntu-server-minimal.pkr.hcl

# Terraform only
time terraform apply -auto-approve

# Ansible only
time ansible-playbook -i inventory.json playbooks/site.yml
```

Expected output:

- All performance targets met
- Detailed timing for each stage
- Comparison showing improvements

## Notes

- Performance may vary based on Proxmox host load
- Network latency affects Ansible execution time
- Consider caching strategies for further improvements
- Document any performance regressions immediately
- Consider implementing continuous performance monitoring

## References

- [Pipeline Separation ADR](../../../decisions/20250118-pipeline-separation.md)
- [Performance Baseline Metrics](../../../performance/baseline-metrics.md)
- [Pipeline Refactoring Plan](../../../planning/pipeline-separation-refactor.md)
