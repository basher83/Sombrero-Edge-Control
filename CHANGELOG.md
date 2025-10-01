## [unreleased]

### 🚀 Features

- Implement symlink organization strategy for linter configs
- *(ci)* Add terraform-docs validation to pre-commit hooks
- *(ci)* Implement thoughts directory protection system
- Add MegaLinter runner script and Claude command definitions
- *(deps)* Enhance Renovate configuration for infrastructure dependencies
- *(tools)* Add ADR creation slash command for Claude Code
- Add deployment timing metrics to mise tasks
- Update MegaLinter configuration and add CSpell support
- Add support for unsecured environment variables in Terraform TFLint configuration
- Add Terraform TFLint pre-commands for initialization
- Add BASH_SHFMT linter to the enabled linters list
- *(tools)* Add Ansible development tools to mise.toml
- *(collection)* Create Ansible collection structure
- Address CodeRabbit review issues and restructure collection
- *(docker)* Enhance security validation and socket permission checks
- *(docker)* Improve daemon configuration with error handling and backup
- *(docker)* Add comprehensive Molecule test structure
- Update collection metadata and migration documentation
- Add Infisical secret management integration playbooks
- Add Claude execute-task command configuration
- Implement comprehensive task management system
- *(packer)* Implement minimal Ubuntu 24.04 template for SEP-001
- Optimize CodeRabbit configuration for infrastructure automation
- Enhance CodeRabbit config and packer golden image docs
- [**breaking**] Update ansible collection configuration
- Add Cursor IDE configuration files
- Integrate mise tasks with pre-commit hooks
- *(pipeline)* Add complete pipeline orchestration scripts
- *(sep-005)* Complete pipeline integration implementation
- *(ans-001)* Implement bootstrap roles with DebOps patterns
- *(ansible)* Add jump_hosts inventory group variables
- *(test)* Add bootstrap validation playbook
- *(ansible)* Integrate bootstrap roles into main site.yml
- *(ansible)* Implement netdata monitoring stack (ANS-005)

### 🐛 Bug Fixes

- Reorder properties in devcontainer.json for better structure
- *(terraform)* Remove duplicate terraform version requirement
- *(ci)* Remove unused generate-ansible-inventory.sh script
- Resolve MegaLinter workflow failures and improve error handling
- Resolve workflow syntax issues causing CI failures
- Simplify MegaLinter workflow configuration
- Optimize MegaLinter performance with fast mode and non-blocking errors
- Remove duplicate mega-linter-local.yml workflow
- Update token handling and refine exclusion filters in MegaLinter configuration
- Address CodeRabbit review feedback
- Revert workflow location - keep ansible_collections/.github/ as intended
- Restore .github/workflows/release.yml to ansible_collections directory
- Move galaxy.yml to correct collection structure
- Restructure collection as standalone ansible_collections directory
- Correct collection structure to ansible_collections/basher83/automation_server/
- *(docker)* Add missing variable definitions and fix variable precedence
- *(docker)* Add ansible.builtin FQCN prefix for Ansible compliance
- *(docker)* Update Ansible version requirement and documentation paths
- Add ansible.builtin FQCN prefix across all roles for compliance
- Update namespace references and improve CHANGELOG clarity
- Remove reference to non-existent secrets management document
- Secure UV installation and Python version handling
- *(terraform)* Add ssh_authorized_keys support to VM module

### 💼 Other

- Update documentation numbering and formatting

### 🚜 Refactor

- *(docs)* Standardize terraform-docs configuration
- Synchronize test playbooks between main and collection directories
- Update planning docs for pipeline separation implementation
- [**breaking**] Simplify cloud-init and update terraform modules
- *(pr_template)* Streamline pull request template for clarity and conciseness
- *(terraform)* [**breaking**] Simplify infrastructure architecture and update tooling
- *(mise)* [**breaking**] Simplify configuration from 1324 to 495 lines

### 📚 Documentation

- *(terraform)* Regenerate documentation with updated configuration
- Add thoughts directory knowledge management system
- Add quick reference summary for MegaLinter fixes
- Add ADR for Renovate configuration enhancement
- Add Ansible collection structure migration planning document
- Add ADR for Ansible collection structure adoption
- Add comprehensive Ansible collection migration guide
- Add comprehensive project analysis and roadmap documentation
- Fix broken links, update dates, and maintain documentation consistency
- Update namespace references in documentation
- Add namespace decision documentation
- Update changelog for recent Ansible collection work
- Improve PR template for Ansible collection development
- Add Docker log rotation documentation and update .gitignore
- Update CHANGELOG with Docker role improvements
- Update Proxmox validation role documentation
- Update standards, examples, and README documentation
- Add comprehensive pipeline separation architecture
- Update infrastructure guides and research reports
- Update CHANGELOG and ROADMAP for pipeline separation
- *(packer)* Update README for minimal template and cloud image approach
- *(tasks)* Mark SEP-001 as complete and update progress tracking
- *(claude)* Update execute-task command for current project structure
- Tighten quality metrics with CI enforcement points
- Clarify SLA metric boundaries in pipeline separation ADR
- Add version pinning strategy to ansible collections research
- [**breaking**] Update task documentation with completion status
- [**breaking**] Cleanup and formatting improvements
- *(pipeline)* Add comprehensive pipeline documentation
- *(tasks)* Update SEP-004 task status to complete
- *(ans-001)* Update bootstrap task with research findings and mark complete
- *(tasks)* Update task tracker to reflect actual implementation status
- Update CHANGELOG with comprehensive 48-hour activity summary
- *(research)* Add comprehensive netdata ansible collection analysis
- Update project status to reflect completed ansible implementation
- *(changelog)* Document completion of ANS-001 and ANS-005 tasks
- *(roadmap)* Update project completion status to 85%
- *(changelog)* Document terraform and mise refactoring changes
- Fix comprehensive markdown linting violations

### ⚙️ Miscellaneous Tasks

- Update MegaLinter configuration and documentation
- Optimize MegaLinter configuration and fix workflow issues
- Add Ansible cache directory
- Remove linter config symlinks
- Update TFLint configuration to use core Terraform rules
- Refine MegaLinter and TFLint configurations
- Remove linter config symlinks
- Update TFLint configuration to use core Terraform rules
- Update MegaLinter and Terrascan configurations
- Simplify TFLint configuration by consolidating commands into arguments
- Update tool configurations and scripts
- [**breaking**] Remove legacy ansible directory structure
- Remove .cursor/ from .gitignore
- Ignore cloud-init backup file
- Remove ansible backup archive and update .gitignore
