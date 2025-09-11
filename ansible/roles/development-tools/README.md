# Ansible Role: Development Tools

Comprehensive development tools installation role based on research-driven approach using community.general + custom tasks for modern tools.

## Research Foundation

This role was built following the ansible-research strategy, evaluating existing collections:

### Research Findings
- **Tier 1**: `community.general` (95/100) - Production-ready for standard tools
- **Custom Implementation**: Required for modern tools (mise, uv) - no quality collections exist
- **Hybrid Approach**: Best balance of reliability and modern tool support

## Overview

Installs and configures a comprehensive development environment including:
- **Standard Tools**: Node.js, Python, git, vim, tmux, curl, wget, jq
- **Modern Tools**: mise (version manager), uv (Python package manager)
- **DevOps Tools**: Docker Compose, lazygit, delta, ripgrep, bat, fd
- **Shell Enhancement**: Custom prompt, aliases, readline, history settings
- **Editor Config**: vim, tmux configurations for development

## Requirements

- Ubuntu 20.04 LTS or later (22.04, 24.04)
- Ansible 2.9 or higher
- Root or sudo privileges
- Internet connection for downloads

## Dependencies

- `community.general` (>=8.0.0) - For standard package management

## Role Variables

### Core Settings

```yaml
devtools_enabled: true
devtools_user: "{{ ansible_user }}"  # Target user for tools
devtools_install_path: "/opt/devtools"  # Installation directory
```

### Standard Tools

```yaml
devtools_standard_packages:
  - nodejs
  - npm
  - python3
  - python3-pip
  - curl
  - wget
  - jq
  - tmux
  - vim
  - git
  - unzip
  - build-essential
```

### Node.js Configuration

```yaml
devtools_nodejs_version: "20"  # LTS version
devtools_npm_global_packages:
  - yarn
  - "@angular/cli"
  - typescript
  - eslint
  - prettier
```

### Python Configuration

```yaml
devtools_python_version: "3.11"
devtools_pip_packages:
  - requests
  - pyyaml
  - jinja2
  - ansible
  - black
  - flake8
  - pytest
```

### Modern Tools

```yaml
# mise version manager
devtools_mise_enabled: true
devtools_mise_version: "latest"
devtools_mise_config_dir: "/home/{{ devtools_user }}/.config/mise"

# uv Python package manager
devtools_uv_enabled: true
devtools_uv_version: "latest"
```

### Additional Tools

```yaml
devtools_docker_compose_enabled: true
devtools_docker_compose_version: "2.24.0"

devtools_additional_tools:
  - name: "fzf"
    description: "Fuzzy finder"
    package: "fzf"
  - name: "ripgrep"
    description: "Fast text search"
    package: "ripgrep"
  # ... more tools
```

### Shell Configuration

```yaml
devtools_configure_shell: true
devtools_shell_additions:
  - "export PATH=\"/usr/local/bin:$PATH\""
  - "eval \"$(mise activate bash)\""
```

### Validation

```yaml
devtools_validate_installation: true
devtools_validation_commands:
  - command: "node --version"
    expected_pattern: "^v[0-9]+\\."
    description: "Node.js version check"
  # ... more validation commands
```

## Dependencies

None. This role manages its own dependencies through `community.general`.

## Example Playbook

### Basic Usage

```yaml
---
- hosts: jump_hosts
  become: true
  roles:
    - role: development-tools
      vars:
        devtools_user: ansible
```

### Advanced Configuration

```yaml
---
- hosts: developers
  become: true
  roles:
    - role: development-tools
      vars:
        devtools_user: developer
        devtools_nodejs_version: "18"
        devtools_npm_global_packages:
          - yarn
          - "@vue/cli"
          - typescript
          - nodemon
        devtools_pip_packages:
          - django
          - fastapi
          - pytest
          - black
        devtools_mise_enabled: true
        devtools_uv_enabled: true
        devtools_additional_tools:
          - name: "gh"
            description: "GitHub CLI"
            package: "gh"
```

### Minimal Installation

```yaml
---
- hosts: basic_servers
  become: true
  roles:
    - role: development-tools
      vars:
        devtools_mise_enabled: false
        devtools_uv_enabled: false
        devtools_docker_compose_enabled: false
        devtools_npm_global_packages: []
```

## Features

### 1. Standard Development Tools
- Node.js with npm package manager
- Python 3 with pip and virtual environments
- Essential CLI tools (git, vim, tmux, curl, wget, jq)
- Build tools for compiling native packages

### 2. Modern Version Management
- **mise**: Multi-language version manager (replaces nvm, pyenv, rbenv)
- Automatic activation in shell
- Support for .mise.toml project configurations

### 3. Fast Python Package Management
- **uv**: Ultra-fast Python package installer
- Drop-in replacement for pip with better performance
- Proper configuration for user installations

### 4. Enhanced Shell Environment
- Custom bash prompt with git branch display
- Comprehensive aliases for development workflows
- Better history management and search
- Readline configuration for improved command editing

### 5. Editor and Terminal Configuration
- vim setup with development-friendly defaults
- tmux configuration with better keybindings
- Modern CLI tools (bat, fd, ripgrep, fzf)

### 6. Development Workspace
- Organized directory structure
- Development environment setup script
- Proper user permissions and ownership

## Files Created/Modified

### Configuration Files
- `/home/{user}/.bashrc` - Shell environment and aliases
- `/home/{user}/.vimrc` - vim editor configuration
- `/home/{user}/.tmux.conf` - tmux terminal multiplexer
- `/home/{user}/.inputrc` - readline configuration
- `/home/{user}/.npmrc` - npm configuration
- `/home/{user}/.pip/pip.conf` - pip configuration
- `{mise_config_dir}/config.toml` - mise configuration
- `/home/{user}/.config/uv/uv.toml` - uv configuration

### Directories Created
- `/home/{user}/workspace` - Main workspace
- `/home/{user}/projects` - Project directory
- `/home/{user}/scripts` - Custom scripts
- `/home/{user}/.local/bin` - User binaries
- `/home/{user}/.config/mise` - mise configuration
- `/home/{user}/.cache/uv` - uv cache

### Scripts and Tools
- `/home/{user}/setup-dev-env.sh` - Environment setup script
- `/usr/local/bin/mise` - mise version manager
- `/usr/local/bin/uv` - uv package manager
- `/usr/local/bin/docker-compose` - Docker Compose

## Usage After Installation

### Shell Environment
Log out and back in to load the new shell configuration:
```bash
# Or source manually
source ~/.bashrc
```

### Project Setup
Use the development environment script in project directories:
```bash
cd my-project
source ~/setup-dev-env.sh
```

### Version Management with mise
```bash
# Install and use Node.js 18
mise use node@18

# Install and use Python 3.11
mise use python@3.11

# View available runtimes
mise ls-remote node
```

### Fast Python Packages with uv
```bash
# Install packages (much faster than pip)
uv pip install django fastapi

# Create virtual environment
python -m venv venv && source venv/bin/activate
uv pip install -r requirements.txt
```

## Validation

The role includes comprehensive validation:
- Tool version checks
- Package installation verification
- Shell configuration testing
- Functionality tests for modern tools

Run validation separately:
```bash
ansible-playbook -i inventory site.yml --tags validation
```

## Tags

- `devtools` - All development tools tasks
- `standard` - Standard package installation
- `nodejs` - Node.js and npm setup
- `python` - Python and pip setup
- `mise` - mise version manager
- `uv` - uv package manager
- `shell` - Shell configuration
- `additional` - Additional tools
- `validation` - Validation checks
- `summary` - Generate summary report

Examples:
```bash
# Only install Node.js and Python
ansible-playbook -i inventory site.yml --tags nodejs,python

# Only modern tools
ansible-playbook -i inventory site.yml --tags mise,uv

# Skip validation
ansible-playbook -i inventory site.yml --skip-tags validation
```

## Generated Reports

A comprehensive installation summary is generated at:
- `/var/log/development-tools-summary.txt`

Contains:
- Installed tool versions
- Package counts and lists
- Configuration locations
- Usage instructions
- Troubleshooting tips

## Research Documentation

This role was built using the research-first approach documented in:
- `../../../docs/planning/ansible-refactor/research-strategy.md`
- Complete research findings in `.claude/research-reports/`

### Why This Approach?
1. **Quality**: Uses production-ready community.general for standard tools
2. **Modern**: Custom implementation for tools without quality collections
3. **Reliable**: Avoids abandoned or low-quality community collections
4. **Maintainable**: Hybrid approach balances stability and innovation

## Compatibility

### Operating Systems
- Ubuntu 20.04 LTS (Focal)
- Ubuntu 22.04 LTS (Jammy)
- Ubuntu 24.04 LTS (Noble)

### Integration
- Works with existing security and firewall roles
- Compatible with Docker environments
- Integrates with CI/CD pipelines

## Troubleshooting

### Tools Not in PATH
```bash
# Check PATH
echo $PATH

# Reload shell configuration
source ~/.bashrc

# Verify tool locations
which node npm python3 pip3 mise uv
```

### mise Issues
```bash
# Check mise status
mise doctor

# Verify configuration
cat ~/.config/mise/config.toml

# Reinstall runtime
mise uninstall node@18 && mise install node@18
```

### uv Issues
```bash
# Check uv configuration
uv pip --help

# Clear cache
rm -rf ~/.cache/uv
```

## Contributing

1. Follow the research-first approach
2. Update validation commands for new tools
3. Document configuration changes
4. Test on all supported Ubuntu versions

## License

MIT

## Author

DevOps Team - Sombrero Edge Control

## References

- [Research Strategy Documentation](../../../docs/planning/ansible-refactor/research-strategy.md)
- [mise Documentation](https://mise.jdx.dev/)
- [uv Documentation](https://github.com/astral-sh/uv)
- [community.general Collection](https://docs.ansible.com/ansible/latest/collections/community/general/)
