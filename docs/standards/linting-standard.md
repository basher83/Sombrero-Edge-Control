# Repo Linting Standards

## Why MegaLinter

- MegaLinter centralizes linting for Markdown, Terraform, Ansible, YAML, JSON, and Shell, plus built-in Markdown link checks, reducing fragmentation and CI complexity in a single, configurable workflow.[^2][^4]
- It supports "apply fixes" modes, multiple reporters (including JSON/SARIF), and repo-wide excludes/filters to keep runs focused and fast in large IaC repositories.[^5][^2]

## Drop-in GitHub Action

- The workflow below runs MegaLinter on pull requests, uses repository-aware filtering, and can optionally apply fixes via environment variables documented by MegaLinter's configuration reference.[^3][^2]

```yaml
# .github/workflows/mega-linter.yml
name: MegaLinter

on:
  pull_request:
    paths:
      - "**/*.md"
      - "**/*.tf"
      - "**/*.hcl"
      - "**/*.yaml"
      - "**/*.yml"
      - "**/*.json"
      - "**/*.sh"
      - "ansible/**"
      - "infrastructure/**"
      - "packer/**"
      - "docs/**"

jobs:
  megalinter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: MegaLinter
        uses: oxsecurity/megalinter@v8
        env:
          # Scope linting to this repo’s layout
          FILTER_REGEX_INCLUDE: "(docs/|README.md|infrastructure/|ansible/|packer/)"
          FILTER_REGEX_EXCLUDE: '(\.git/|\.github/|node_modules/|build/|dist/|vendor/)'

          # Limit to IaC + docs linters to keep runtime lean
          ENABLE_LINTERS: >
            MARKDOWN_MARKDOWNLINT,
            MARKDOWN_MARKDOWN_LINK_CHECK,
            TERRAFORM_TFLINT,
            TERRAFORM_TERRAFORM_FMT,
            TERRAFORM_TERRASCAN,
            ANSIBLE_ANSIBLE_LINT,
            YAML_YAMLLINT,
            JSON_ESLINT_PLUGIN_JSONC,
            BASH_SHFMT

          # Rules live under .github/linters
          LINTER_RULES_PATH: .github/linters

          # Reporters and outputs
          PRINT_ALPACA: "false"
          REPORT_OUTPUT_FOLDER: "${{ github.workspace }}/report"

          # Optional: auto-fixes (off by default)
          # APPLY_FIXES: "all"
          # APPLY_FIXES_EVENT: "pull_request"
          # APPLY_FIXES_MODE: "pull_request"
```

Notes:

- The enabled linter keys align to MegaLinter's descriptors where Markdown includes markdownlint and markdown-link-check, Terraform includes tflint/terraform-fmt/terrascan, Ansible uses ansible-lint, YAML uses yamllint, JSON uses eslint-plugin-jsonc, and Shell uses shfmt.[^6][^4][^7][^8]
- Filters target the actual paths in this repository structure (infrastructure/, ansible/, packer/, docs/), matching the attached project layout for Terraform, Packer, and Ansible content.[^1]

## .mega-linter.yml (Repo-level Config)

- Place this at the repository root to standardize behavior and point linters to rule files under .github/linters as recommended by MegaLinter.[^2]

```yaml
# .mega-linter.yml
# Central MegaLinter configuration

# Focus on the repo’s IaC + docs
ENABLE_LINTERS:
  - MARKDOWN_MARKDOWNLINT
  - MARKDOWN_MARKDOWN_LINK_CHECK
  - TERRAFORM_TFLINT
  - TERRAFORM_TERRAFORM_FMT
  - TERRAFORM_TERRASCAN
  - ANSIBLE_ANSIBLE_LINT
  - YAML_YAMLLINT
  - JSON_ESLINT_PLUGIN_JSONC
  - BASH_SHFMT

# Global include/exclude filters
FILTER_REGEX_INCLUDE: "(docs/|README.md|infrastructure/|ansible/|packer/)"
FILTER_REGEX_EXCLUDE: '(\.git/|\.github/|node_modules/|build/|dist/|vendor/)'

# Keep rules in-repo for portability
LINTER_RULES_PATH: .github/linters

# Reporters and outputs
REPORT_OUTPUT_FOLDER: report
PRINT_ALPACA: false
SHOW_SKIPPED_LINTERS: true
VALIDATE_ALL_CODEBASE: true
# Optional: enable fixes via env in the workflow (kept off by default)
# APPLY_FIXES: all
```

Notes:

- For Packer templates in HCL, terraform-fmt will format files but tflint does not lint Packer-specific constructs; this setup gains consistent formatting with terraform-fmt across .tf/.hcl while keeping tflint focused on Terraform code.[^8][^2]

## Markdown Rules and Link Checks

- Keep markdownlint rules in .github/linters to be picked up automatically by the MARKDOWN descriptor, and configure markdown-link-check using its native JSON file so MegaLinter can apply it across docs and READMEs.[^9][^4]

Example rules folder:

```
# Repository root (symlinks for compatibility)
├── .yamllint → .github/linters/.yamllint.yaml 🔗
├── .yamlfmt → .github/linters/.yamlfmt 🔗
├── .markdownlint-cli2.jsonc → .github/linters/.markdownlint-cli2.jsonc 🔗
├── .mega-linter.yml → .github/linters/.mega-linter.yml 🔗
├── .ansible-lint → .github/linters/.ansible-lint 🔗
├── .tflint.hcl → .github/linters/.tflint.hcl 🔗
└── .terrascan.toml → .github/linters/.terrascan.toml 🔗

# Organized configuration location
.github/
  linters/
    .yamllint.yaml        # Consolidated YAML config
    .yamlfmt             # YAML formatter config
    .markdownlint-cli2.jsonc
    .markdown-link-check.json
    .mega-linter.yml     # Main MegaLinter config
    .ansible-lint
    .tflint.hcl
    .terrascan.toml
```

Example .markdownlint.json (robust defaults):

```json
{
  "default": true,
  "MD013": { "line_length": 120 },
  "MD024": { "siblings_only": true },
  "MD029": { "style": "ordered" },
  "MD033": false,
  "MD041": false,
  "MD040": true,
  "MD046": { "style": "fenced" },
  "MD007": { "indent": 2 },
  "MD022": { "lines_above": 1, "lines_below": 1 }
}
```

Example .markdown-link-check.json:

```json
{
  "ignorePatterns": [{ "pattern": "^mailto:" }, { "pattern": "github\\.com/.*/(issues|pull)/\\d+" }],
  "aliveStatusCodes": [200, 206, 429],
  "retryOn429": true,
  "retries": 3,
  "timeout": "20s"
}
```

## Tool-specific Rule Pointers

- Terraform: include .tflint.hcl and optionally enable terrascan via .terrascan.toml to catch IaC policy issues in the same run, managed by MegaLinter.[^8][^2]
- Ansible: include a .ansible-lint file with skip_list/warn_list/exclude_paths for repo‑wide posture under MegaLinter's ANSIBLE_ANSIBLE_LINT.[^10][^2]
- YAML/JSON/Shell: use consolidated `.yamllint.yaml` for linting and `.yamlfmt` for formatting, with JSONC rules for eslint-plugin-jsonc and shfmt formatting behavior under rules path for consistent enforcement.[^7][^6]

## Reports and Artifacts

- Enable JSON reporter to capture full run data at report/mega-linter-report.json, and add report/ to .gitignore to avoid committing artifacts generated by CI.[^5][^2]

Example .gitignore addition:

```
report/
```

## Local Usage

- Developers can run MegaLinter locally via the efrecon/mega-linter-runner for faster execution without downloading Node.js dependencies, or fall back to npx mega-linter-runner.[^11][^3]

Example local runs:

```bash
# Fast method (recommended) - uses GHCR, no Node.js deps
curl -s https://raw.githubusercontent.com/efrecon/mega-linter-runner/main/mega-linter-runner.sh -o /tmp/mega-linter-runner.sh && chmod +x /tmp/mega-linter-runner.sh
/tmp/mega-linter-runner.sh --flavor terraform

# Alternative method (slower) - downloads Node.js deps first
npx mega-linter-runner --flavor terraform
```

## Repo-specific Notes

- The filters and paths in the examples above match this repository's structure (infrastructure/, packer/, ansible/, docs/, README.md), ensuring the linter targets Terraform envs/modules, Packer HCL, Ansible playbooks/roles, and all documentation while excluding CI internals and dependency folders.[^1]

If desired, this content can replace the prior linting and link‑check sections in the standards file, and all references to markdownlint-cli2 and alex can be fully removed in favor of the unified MegaLinter configuration shown here.[^4][^2]

## References

[^1]: https://github.com/oxsecurity/megalinter
[^2]: http://megalinter.io/5.1.0/configuration/
[^3]: https://megalinter.io/8/quick-start/
[^4]: https://megalinter.io/8/descriptors/repository/
[^5]: https://megalinter.io/8/reporters/JsonReporter/
[^6]: https://megalinter.io/v8/descriptors/bash_shfmt/
[^7]: https://megalinter.io/8/descriptors/json_eslint_plugin_jsonc/
[^8]: https://megalinter.io/8/descriptors/csharp/
[^9]: https://www.npmjs.com/package/markdown-link-check
[^10]: https://stackoverflow.com/questions/79540889/ansible-lint-is-there-a-way-to-ignore-errors-in-all-files-without-specifying-f
[^11]: https://www.npmjs.com/package/mega-linter-runner
[^12]: https://github.com/efrecon/mega-linter-runner
