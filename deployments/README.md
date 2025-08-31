# Deployment Records 📚

This directory contains historical deployment records for audit and learning purposes.

## Structure

```
deployments/
├── checklists/          # Timestamped deployment checklists with notes
│   └── YYYY-MM-DD-HH-MM-deployment.md
└── README.md           # This file
```

## Usage

1. **Start a deployment**: `mise run deployment-start`
2. **View history**: `mise run deployment-history`
3. **Review past deployments**: Browse files in `checklists/`

## What's Captured

Each deployment record includes:
- Pre-flight, take-off, and post-flight checklists
- What went well
- Issues encountered
- Lessons learned
- Tips for next deployment
- Deployment metrics (time, duration, operator)

## Why We Do This

- **Audit Trail**: Compliance and accountability
- **Knowledge Transfer**: Learn from each deployment
- **Continuous Improvement**: Identify patterns
- **Troubleshooting**: Reference past solutions
- **Onboarding**: New team members learn from history

See `docs/deployment-process.md` for the full process documentation.
