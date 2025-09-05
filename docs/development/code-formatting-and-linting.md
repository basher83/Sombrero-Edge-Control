# Code Formatting and Linting Guide

This document explains how we use `.editorconfig` and specialized linting tools together to maintain code quality
and consistency across the Sombrero Edge Control project.

## TL;DR

- **`.editorconfig`** = Universal formatting (indentation, line endings, whitespace)
- **Linting tools** = Language-specific validation and quality rules
- **Use both together** for best results

## The Two-Layer Approach

### Layer 1: Editor Formatting (`.editorconfig`)

**Purpose**: Consistent basic formatting across all editors and team members

**What it controls**:

- Indentation style and size
- Line endings (LF vs CRLF)
- Character encoding
- Trailing whitespace trimming
- Final newlines
- Line length limits

**Benefits**:

- ✅ Works in VS Code, Vim, IntelliJ, Sublime Text, etc.
- ✅ Applied automatically while editing
- ✅ Version controlled with the project
- ✅ No extension or plugin required
- ✅ Prevents "formatting wars" between team members

### Layer 2: Code Quality Validation (Linting Tools)

**Purpose**: Enforce language-specific best practices and catch errors

**Examples in this project**:

- `.yamllint` - YAML structure and syntax validation
- `yamlfmt` - Automatic YAML formatting and standardization
- `.terraform-docs.yml` - Terraform documentation standards
- `.infisical-scan.toml` - Secret scanning configuration
- Pre-commit hooks - Multi-tool validation pipeline

**What they control**:

- Language-specific syntax rules
- Code structure and organization
- Security and best practices
- Documentation requirements
- Complex validation logic

## Our Configuration Strategy

### Coordinated Settings

Our linting tools are configured to **complement** rather than conflict with `.editorconfig`:

```yaml
# From .yamllint
indentation:
  spaces: 2 # ← Matches .editorconfig
line-length:
  max: 120 # ← Matches .editorconfig
```

```yaml
# From .yamlfmt
formatter:
  indent: 2 # ← Matches .editorconfig
  max_line_length: 120 # ← Matches .editorconfig
  line_ending: lf # ← Matches .editorconfig
```

```toml
# From .editorconfig
[*.{yml,yaml}]
indent_style = space
indent_size = 2
max_line_length = 120
```

### Special Cases

Some files need special handling:

```toml
# Infisical config needs gentle treatment
[.infisical-scan.toml]
max_line_length = off  # Prevents breaking complex inline objects
```

## File-by-File Breakdown

| File Type              | `.editorconfig` Rules         | Linting Tool    | Purpose                    |
| ---------------------- | ----------------------------- | --------------- | -------------------------- |
| `*.tf`                 | 2-space indent, 120 chars     | `terraform fmt` | Terraform formatting       |
| `*.yaml`               | 2-space indent, 120 chars     | `yamlfmt` + `.yamllint` | YAML formatting + validation |
| `*.md`                 | 2-space indent, no line limit | None            | Markdown flexibility       |
| `*.sh`                 | 2-space indent, 120 chars     | `shellcheck`    | Shell script validation    |
| `.infisical-scan.toml` | 2-space indent, no line limit | None            | Preserve complex structure |

## VS Code Integration

### Automatic Support

Modern VS Code (1.63+) has built-in `.editorconfig` support. No extension needed!

### Recommended Extensions

- **EditorConfig for VS Code** - Enhanced `.editorconfig` support
- **Even Better TOML** - TOML syntax highlighting and formatting
- **YAML** - YAML language support
- **Terraform** - HashiCorp language support

### Important Global Setting

Set this in your VS Code user settings to protect regex patterns:

```json
{
  "files.trimTrailingWhitespaceInRegexAndStrings": false
}
```

## Workflow Integration

### During Development

1. **Edit files** → `.editorconfig` applies formatting automatically
1. **Save files** → Editor respects formatting rules
1. **Format code** → Run `mise run yaml-fmt` or `mise run fmt-all`
1. **Commit changes** → Pre-commit hooks run linters

### In CI/CD

1. **Code pushed** → Automated linting runs
1. **Formatting checked** → Consistent with `.editorconfig`
1. **Quality gates** → Linting tools validate standards

## Troubleshooting

### Common Issues

**Problem**: Extension auto-formats and breaks complex structures
**Solution**: Configure the extension to respect `.editorconfig` or exclude specific files

**Problem**: Linting tool conflicts with `.editorconfig`
**Solution**: Update linting config to defer to `.editorconfig` for basic formatting

**Problem**: Different team members have different formatting
**Solution**: Ensure `.editorconfig` is properly configured and editors support it

### Debugging Steps

1. **Check if `.editorconfig` is working**:

   - Add extra whitespace to a line
   - Save the file
   - Whitespace should be trimmed (if `trim_trailing_whitespace = true`)

1. **Check linting tool compatibility**:

   - Run linter manually: `yamllint .github/workflows/`
   - Compare output with `.editorconfig` rules

1. **Verify editor support**:
   - Most modern editors support `.editorconfig` natively
   - Install official EditorConfig extension if needed

## Best Practices

### Do This ✅

- Configure linting tools to defer to `.editorconfig` for basic formatting
- Use `.editorconfig` for universal rules (indentation, line endings)
- Use linting tools for language-specific validation
- Set consistent line length limits across both systems
- Version control both configuration files

### Avoid This ❌

- Don't duplicate formatting rules between systems
- Don't set conflicting line length limits
- Don't override `.editorconfig` with editor-specific settings for shared rules
- Don't ignore linting failures in CI/CD

## Contributing

When adding new file types or linting tools:

1. **Update `.editorconfig`** with basic formatting rules
1. **Configure linting tool** to complement (not conflict with) `.editorconfig`
1. **Test integration** with your editor and CI/CD pipeline
1. **Update this documentation** with new file type rules

---

## References

- [EditorConfig Official Documentation](https://editorconfig.org/)
- [yamllint Documentation](https://yamllint.readthedocs.io/)
- [Terraform Formatting](https://developer.hashicorp.com/terraform/language/style)
- [Pre-commit Framework](https://pre-commit.com/)
