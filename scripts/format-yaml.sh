#!/bin/bash
# YAML formatting script using yamlfmt
# This script formats YAML files using the project's yamlfmt configuration

set -euo pipefail

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Change to project root to ensure .yamlfmt is found
cd "$PROJECT_ROOT"

# Check if yamlfmt is available
if ! command -v yamlfmt >/dev/null 2>&1; then
    echo "Error: yamlfmt not found in PATH" >&2
    echo "Install it with: mise install yamlfmt" >&2
    exit 1
fi

# Check if .yamlfmt config exists
if [[ ! -f .yamlfmt ]]; then
    echo "Error: .yamlfmt configuration file not found in project root" >&2
    exit 1
fi

# Default to formatting all YAML files if no arguments provided
if [[ $# -eq 0 ]]; then
    echo "Formatting all YAML files in project..."
    yamlfmt -conf .yamlfmt .
else
    echo "Formatting specified files: $*"
    yamlfmt -conf .yamlfmt "$@"
fi

echo "YAML formatting complete!"
