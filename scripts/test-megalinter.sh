#!/bin/bash

# MegaLinter Local Testing Script
# This script helps test MegaLinter configuration locally before pushing to CI

echo "🧹 MegaLinter Local Test Script"
echo "================================"

# Function to show elapsed time
start_time=$(date +%s)

# Check if mega-linter-runner is installed
if ! command -v mega-linter-runner &> /dev/null; then
    echo "📦 Installing mega-linter-runner..."
    npm install -g mega-linter-runner
fi

# Check if docker is running (required for MegaLinter)
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker and try again."
    echo "💡 Tip: Start Docker Desktop or run 'sudo systemctl start docker'"
    exit 1
fi

echo "🐳 Docker is running ✅"

# Create report directory if it doesn't exist
mkdir -p report

echo "🔍 Starting MegaLinter scan..."
echo "📁 Repository: $(pwd)"
echo "🎯 Flavor: terraform (includes multiple linters)"
echo "⏱️  This may take 5-15 minutes depending on your system..."
echo ""

# Show system info
echo "📊 System Information:"
echo "  - CPU: $(nproc) cores"
echo "  - Memory: $(free -h | awk '/^Mem:/ {print $2}') total"
echo "  - Docker: $(docker --version)"
echo ""

# Run MegaLinter locally with verbose output
echo "🚀 Executing MegaLinter..."
echo "   (Use Ctrl+C to interrupt if needed)"
echo ""

# Use timeout to prevent hanging (30 minutes max)
echo "⏳ Starting MegaLinter (will timeout after 30 minutes if hanging)..."
timeout 1800 mega-linter-runner \
    --flavor terraform \
    --remove-container \
    2>&1 | tee megalinter.log || true

exit_code=$?

# Calculate elapsed time
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

echo ""
echo "⏱️  Total execution time: $((elapsed_time / 60))m $((elapsed_time % 60))s"
echo ""

# Check results
if [ $exit_code -eq 124 ]; then
    echo "⚠️  MegaLinter timed out after 30 minutes"
    echo "💡 This is normal for large codebases. The partial results are still useful."
elif [ $exit_code -eq 0 ]; then
    echo "✅ MegaLinter completed successfully!"
else
    echo "⚠️  MegaLinter completed with exit code: $exit_code"
fi

echo ""
echo "📊 Results Summary:"
echo "==================="

# Check for report files
if [ -f "report/mega-linter-report.sarif" ]; then
    echo "✅ SARIF report generated: report/mega-linter-report.sarif"
    echo "   📄 Size: $(du -h report/mega-linter-report.sarif | cut -f1)"
else
    echo "❌ No SARIF report found"
fi

if [ -f "report/mega-linter-report.json" ]; then
    echo "✅ JSON report generated: report/mega-linter-report.json"
    echo "   📄 Size: $(du -h report/mega-linter-report.json | cut -f1)"
fi

if [ -f "megalinter.log" ]; then
    echo "✅ Execution log saved: megalinter.log"
    echo "   📄 Size: $(du -h megalinter.log | cut -f1)"
fi

# Show top issues if log exists
if [ -f "megalinter.log" ]; then
    echo ""
    echo "🔍 Top Issues Found:"
    echo "===================="

    # Count errors and warnings
    errors=$(grep -c "ERROR" megalinter.log 2>/dev/null || echo "0")
    warnings=$(grep -c "WARNING" megalinter.log 2>/dev/null || echo "0")

    echo "  - Errors: $errors"
    echo "  - Warnings: $warnings"

    # Show some sample issues
    echo ""
    echo "📋 Sample Issues:"
    grep -E "(ERROR|WARNING)" megalinter.log | head -5 | sed 's/^/  - /'
fi

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Review the report/ directory for detailed results"
echo "2. Check megalinter.log for execution details"
echo "3. Upload SARIF to GitHub Security tab if desired"
echo ""
echo "💡 Pro Tips:"
echo "  - For faster testing, use specific file patterns: --files \"docs/*.md\""
echo "  - Skip slow linters with: --disable-linters SHELLCHECK"
echo "  - Use --help to see all options"
echo ""
echo "🚀 Quick Test Commands:"
echo "======================="
echo "# Test only markdown files (fast):"
echo "mega-linter-runner --flavor terraform --remove-container --files \"docs/**/*.md\""
echo ""
echo "# Test only terraform files:"
echo "mega-linter-runner --flavor terraform --remove-container --files \"infrastructure/**/*.tf\""
echo ""
echo "# Skip slow linters:"
echo "mega-linter-runner --flavor terraform --remove-container --disable-linters SHELLCHECK,TERRAFORM_TERRASCAN"
