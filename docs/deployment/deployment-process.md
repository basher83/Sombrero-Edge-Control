# Official Deployment Process 📋

## Overview

Every production deployment must follow this process to maintain deployment history and share knowledge.

## Process Steps

### 1. Initialize Deployment Record

```bash
# Create timestamped checklist
mise run deployment-start

# This creates: deployments/checklists/YYYY-MM-DD-HH-MM-deployment.md
```

### 2. Execute Deployment

Work through the checklist, updating statuses as you go:

- ✅ for completed steps
- ❌ for failed/skipped steps
- 🔄 for in-progress
- ⏭️ for skipped (intentionally)

### 3. Document Results

Add these sections to the bottom of your checklist:

```markdown
## Deployment Notes

### What Went Well

-

### Issues Encountered

-

### Lessons Learned

-

### Tips for Next Deployment

-

### Deployment Metrics

- Start Time:
- End Time:
- Total Duration:
- Deployed By:
```

### 4. Commit Record

```bash
# Add and commit the deployment record
git add deployments/checklists/
git commit -m "docs: deployment record for jump-man $(date +%Y-%m-%d)"
```

## Why This Process?

1. **Audit Trail**: Track who deployed what and when
1. **Knowledge Sharing**: Learn from each deployment
1. **Troubleshooting**: Reference past issues and solutions
1. **Continuous Improvement**: Identify patterns and improve process
1. **Onboarding**: New team members can review past deployments

## Deployment Record Retention

- Keep all deployment records
- Review quarterly for patterns
- Update main checklist template based on lessons learned

## Example Usage

```bash
# Start deployment
mise run deployment-start
# Opens: deployments/checklists/2024-08-31-14-30-deployment.md

# Work through deployment...
# Edit file as you go...

# After deployment
vim deployments/checklists/2024-08-31-14-30-deployment.md
# Add notes, lessons learned, etc.

# Commit
git add deployments/checklists/
git commit -m "docs: successful jump-man deployment with Docker fix notes"
```

## Templates Location

- **Template**: `docs/deployment-checklist.md`
- **Records**: `deployments/checklists/`
- **Process**: `docs/deployment-process.md` (this file)
