#!/bin/bash

# Markdown Linting Fix Helper Script
# Helps automate common markdown linting fixes

set -e

echo "🔧 Markdown Linting Fix Helper"
echo "=============================="

if [ $# -lt 1 ]; then
    echo "Usage: $0 <file.md> [fix-type]"
    echo ""
    echo "Fix types:"
    echo "  list-spacing    - Add blank lines around lists (MD032)"
    echo "  code-spacing    - Add blank lines around code blocks (MD031)"
    echo "  heading-spacing - Add blank lines around headings (MD022)"
    echo "  ol-numbering    - Fix ordered list numbering (MD029)"
    echo "  all             - Apply all fixes"
    echo ""
    echo "Examples:"
    echo "  $0 docs/README.md all"
    echo "  $0 docs/README.md list-spacing"
    exit 1
fi

FILE="$1"
FIX_TYPE="${2:-all}"

if [ ! -f "$FILE" ]; then
    echo "❌ File not found: $FILE"
    exit 1
fi

echo "📄 Processing: $FILE"
echo "🎯 Fix type: $FIX_TYPE"
echo ""

# Create backup
cp "$FILE" "${FILE}.backup"

# Function to add blank lines around lists
fix_list_spacing() {
    echo "📝 Fixing list spacing (MD032)..."

    # Pattern: text immediately followed by - or * without blank line
    # Add blank line before lists
    sed -i 's/^\([^-*#0-9].*\)$\n\([-*]\)/\1\n\n\2/g' "$FILE"

    # Add blank line before numbered lists
    sed -i 's/^\([^-*#0-9].*\)$\n\d\./\1\n\n&/g' "$FILE"

    # Add blank line after lists (more complex, needs better pattern)
    # This is a simplified version - would need more sophisticated parsing
}

# Function to add blank lines around code blocks
fix_code_spacing() {
    echo "📝 Fixing code block spacing (MD031)..."

    # Add blank line before code blocks that don't have one
    sed -i 's/^\([^-#`].*\)$\n```/\1\n\n```/g' "$FILE"

    # Add blank line after code blocks that don't have one
    sed -i 's/```\n\([^-#`].*\)$/```\n\n\1/g' "$FILE"

    # Handle cases where code blocks are right after headings
    sed -i 's/^###.*$\n```/###\n\n```/g' "$FILE"
    sed -i 's/^####.*$\n```/####\n\n```/g' "$FILE"
}

# Function to add blank lines around headings
fix_heading_spacing() {
    echo "📝 Fixing heading spacing (MD022)..."

    # Add blank line before headings that don't have one
    sed -i 's/^\([^-#`].*\)$\n#/#\n/g' "$FILE"

    # Add blank line after headings that don't have one
    sed -i 's/^#.*$\n\([^-#`].*\)$/#\n\n\1/g' "$FILE"
}

# Function to fix ordered list numbering
fix_ol_numbering() {
    echo "📝 Fixing ordered list numbering (MD029)..."

    # Fix common patterns of continuation numbering that should be 1
    # Pattern: multiple consecutive ordered list items starting with different numbers
    # This is a simplified approach - complex lists may need manual review

    # Replace 2. with 1. when it appears after 1.
    sed -i 's/\(1\..*\)\n2\./\1\n1\./g' "$FILE"

    # Replace 3. with 1. when it appears after 1.
    sed -i 's/\(1\..*\)\n3\./\1\n1\./g' "$FILE"

    # Replace 4. with 1. when it appears after 1.
    sed -i 's/\(1\..*\)\n4\./\1\n1\./g' "$FILE"

    # Replace 5. with 1. when it appears after 1.
    sed -i 's/\(1\..*\)\n5\./\1\n1\./g' "$FILE"

    echo "✅ Applied automated ordered list fixes"
    echo "⚠️  Complex nested lists may still need manual review"
}

# Apply fixes based on type
case "$FIX_TYPE" in
    "list-spacing")
        fix_list_spacing
        ;;
    "code-spacing")
        fix_code_spacing
        ;;
    "heading-spacing")
        fix_heading_spacing
        ;;
    "ol-numbering")
        fix_ol_numbering
        ;;
    "all")
        fix_list_spacing
        fix_code_spacing
        fix_heading_spacing
        fix_ol_numbering
        ;;
    *)
        echo "❌ Unknown fix type: $FIX_TYPE"
        exit 1
        ;;
esac

echo ""
echo "✅ Fixes applied to: $FILE"
echo "💾 Backup created: ${FILE}.backup"
echo ""
echo "🔍 Run markdownlint to check results:"
echo "   markdownlint-cli2 \"$FILE\""
