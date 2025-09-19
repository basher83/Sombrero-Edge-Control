---
Task: Development Tools Installation
Task ID: ANS-004
Priority: P1 (Important)
Estimated Time: 2 hours
Dependencies: ANS-001
Status: ⏸️ Blocked
---

## Objective

Install and configure essential development tools on the jump host including Git, tmux, Python tools (uv), Node.js, and other utilities required for DevOps operations. This provides a complete development environment for infrastructure management tasks.

## Prerequisites

- [ ] ANS-001 completed (Bootstrap playbook)
- [ ] VM accessible via Ansible
- [ ] Internet connectivity for package downloads

## Implementation Steps

### 1. **Create Development Tools Role**

```bash
cd ansible_collections/basher83/automation_server/roles
ansible-galaxy role init development_tools
```

### 2. **Define Tool Variables**

Create `roles/development_tools/defaults/main.yml`:

```yaml
---
# Python configuration
python_version: "3"  # Use python3 (Ubuntu 24.04 default is 3.12)
# Note: For Python 3.11 specifically, add deadsnakes PPA:
# sudo add-apt-repository ppa:deadsnakes/ppa
# Then set python_version: "3.11" and use python3.11 package
python_packages:
  - python3-pip
  - python3-venv
  - python3-dev
  - build-essential

# UV (Python package manager)
uv_version: "0.4.20"  # Pin to specific version for security and reproducibility
uv_install_path: /usr/local/bin

# Node.js configuration
nodejs_version: "20"  # LTS version
npm_global_packages:
  - yarn
  - pnpm
  - typescript
  - eslint

# Development tools
dev_tools_packages:
  - git
  - tmux
  - vim
  - nano
  - wget
  - curl
  - jq
  - tree
  - htop
  - ncdu
  - rsync
  - unzip
  - make
  - gcc
  - g++
  - net-tools
  - dnsutils
  - traceroute
  - mtr-tiny
  - iperf3
  - tcpdump
  - nmap
  - telnet

# Git configuration
git_config:
  - { name: 'init.defaultBranch', value: 'main' }
  - { name: 'color.ui', value: 'auto' }
  - { name: 'pull.rebase', value: 'false' }

# Tmux configuration
tmux_config_enabled: true
tmux_plugins:
  - tmux-sensible
  - tmux-resurrect
  - tmux-continuum
```

### 3. **Create Package Installation Tasks**

Create `roles/development_tools/tasks/packages.yml`:

```yaml
---
- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Install development packages
  apt:
    name: "{{ dev_tools_packages }}"
    state: present

- name: Install Python packages
  apt:
    name: "{{ python_packages }}"
    state: present
```

### 4. **Create Python/UV Installation Tasks**

Create `roles/development_tools/tasks/python.yml`:

```yaml
---
- name: Ensure Python 3 is installed
  apt:
    name: python3
    state: present

- name: Ensure Python venv and pip are available
  apt:
    name: "{{ python_packages }}"
    state: present

- name: Install UV (Python package manager)
  block:
    - name: Get system architecture
      command: dpkg --print-architecture
      register: system_arch
      changed_when: false

    - name: Set UV download variables
      set_fact:
        uv_binary: "uv-x86_64-unknown-linux-gnu.tar.gz"
        uv_checksum_file: "uv-x86_64-unknown-linux-gnu.tar.gz.sha256"
      when: system_arch.stdout == "amd64"

    - name: Set UV download variables for ARM64
      set_fact:
        uv_binary: "uv-aarch64-unknown-linux-gnu.tar.gz"
        uv_checksum_file: "uv-aarch64-unknown-linux-gnu.tar.gz.sha256"
      when: system_arch.stdout == "arm64"

    - name: Fail on unsupported architecture
      fail:
        msg: "Unsupported architecture: {{ system_arch.stdout }}"
      when: uv_binary is not defined

    - name: Download UV binary
      get_url:
        url: "https://github.com/astral-sh/uv/releases/download/{{ uv_version }}/{{ uv_binary }}"
        dest: "/tmp/{{ uv_binary }}"
        mode: '0644'

    - name: Download UV checksum
      get_url:
        url: "https://github.com/astral-sh/uv/releases/download/{{ uv_version }}/{{ uv_checksum_file }}"
        dest: "/tmp/{{ uv_checksum_file }}"
        mode: '0644'

    - name: Verify UV checksum
      command: "cd /tmp && sha256sum -c {{ uv_checksum_file }}"
      args:
        chdir: /tmp

    - name: Extract UV binary
      unarchive:
        src: "/tmp/{{ uv_binary }}"
        dest: /tmp/
        remote_src: yes

    - name: Install UV binary
      copy:
        src: "/tmp/uv"
        dest: "{{ uv_install_path }}/uv"
        mode: '0755'
        remote_src: yes
      become: yes

    - name: Clean up temporary files
      file:
        path: "{{ item }}"
        state: absent
      loop:
        - "/tmp/{{ uv_binary }}"
        - "/tmp/{{ uv_checksum_file }}"
        - "/tmp/uv"
  rescue:
    - name: Fail on UV installation error
      fail:
        msg: "UV installation failed - checksum verification or download error"

- name: Verify UV installation
  command: uv --version
  register: uv_version_check
  changed_when: false
  failed_when: uv_version_check.rc != 0

- name: Create Python virtual environment directory
  file:
    path: /opt/venvs
    state: directory
    owner: ansible
    group: ansible
    mode: '0755'

- name: Install global Python tools with UV
  become_user: ansible
  shell: |
    uv tool install ruff
    uv tool install black
    uv tool install mypy
    uv tool install poetry
  args:
    creates: /home/ansible/.local/bin/ruff
```

### 5. **Create Node.js Installation Tasks**

Create `roles/development_tools/tasks/nodejs.yml`:

```yaml
---
- name: Ensure apt keyring dir exists
  file:
    path: /etc/apt/keyrings
    state: directory
    mode: '0755'

- name: Install NodeSource GPG key
  get_url:
    url: https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key
    dest: /etc/apt/keyrings/nodesource.gpg
    mode: '0644'

- name: Add NodeSource repository
  apt_repository:
    repo: "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_{{ nodejs_version }}.x {{ ansible_distribution_release }} main"
    state: present
    update_cache: yes

- name: Install Node.js
  apt:
    name: nodejs
    state: present

- name: Install global npm packages
  become: yes
  npm:
    name: "{{ item }}"
    global: yes
    state: present
  loop: "{{ npm_global_packages }}"

- name: Configure npm
  become: yes
  shell: |
    npm config set prefix /usr/local
    npm config set fund false
    npm config set audit false
  changed_when: false
```

### 6. **Create Git Configuration Tasks**

Create `roles/development_tools/tasks/git.yml`:

```yaml
---
- name: Configure Git globally
  git_config:
    name: "{{ item.name }}"
    value: "{{ item.value }}"
    scope: system
  loop: "{{ git_config }}"

- name: Create Git aliases
  git_config:
    name: "alias.{{ item.key }}"
    value: "{{ item.value }}"
    scope: system
  loop:
    - { key: 'st', value: 'status' }
    - { key: 'co', value: 'checkout' }
    - { key: 'br', value: 'branch' }
    - { key: 'ci', value: 'commit' }
    - { key: 'unstage', value: 'reset HEAD --' }
    - { key: 'last', value: 'log -1 HEAD' }
    - { key: 'visual', value: '!gitk' }
```

### 7. **Create Tmux Configuration**

Create `roles/development_tools/templates/tmux.conf.j2`:

```bash
# Tmux configuration
# Remap prefix from 'C-b' to 'C-a'
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file
bind r source-file ~/.tmux.conf

# Fast pane switching
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse mode
set -g mouse on

# Don't rename windows automatically
set-option -g allow-rename off

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Set scrollback buffer
set -g history-limit 10000

# Visual notification of activity in other windows
setw -g monitor-activity on
set -g visual-activity on

# Set status bar
set -g status-bg black
set -g status-fg white
set -g status-left '#[fg=green]#H '
set -g status-right '#[fg=yellow]#(uptime | cut -d "," -f 3-)'
```

Create `roles/development_tools/tasks/tmux.yml`:

```yaml
---
- name: Install tmux
  apt:
    name: tmux
    state: present

- name: Create tmux configuration
  template:
    src: tmux.conf.j2
    dest: /home/ansible/.tmux.conf
    owner: ansible
    group: ansible
    mode: '0644'
  when: tmux_config_enabled

- name: Create tmux plugin directory
  file:
    path: /home/ansible/.tmux/plugins
    state: directory
    owner: ansible
    group: ansible
    mode: '0755'

- name: Install tmux plugin manager
  git:
    repo: https://github.com/tmux-plugins/tpm
    dest: /home/ansible/.tmux/plugins/tpm
    version: master
  become_user: ansible
```

### 8. **Create Main Task File**

Create `roles/development_tools/tasks/main.yml`:

```yaml
---
- name: Install development packages
  include_tasks: packages.yml
  tags: [dev, packages]

- name: Setup Python and UV
  include_tasks: python.yml
  tags: [dev, python]

- name: Install Node.js
  include_tasks: nodejs.yml
  tags: [dev, nodejs]

- name: Configure Git
  include_tasks: git.yml
  tags: [dev, git]

- name: Setup tmux
  include_tasks: tmux.yml
  tags: [dev, tmux]

- name: Create development directories
  file:
    path: "{{ item }}"
    state: directory
    owner: ansible
    group: ansible
    mode: '0755'
  loop:
    - /home/ansible/projects
    - /home/ansible/scripts
    - /home/ansible/.local/bin

- name: Add local bin to PATH
  lineinfile:
    path: /home/ansible/.bashrc
    line: 'export PATH="$HOME/.local/bin:$PATH"'
    state: present
```

### 9. **Create Validation Tasks**

Create `roles/development_tools/tasks/validate.yml`:

```yaml
---
- name: Check installed tools
  command: "{{ item }} --version"
  register: tool_versions
  changed_when: false
  failed_when: false
  loop:
    - git
    - tmux
    - python3
    - node
    - npm
    - uv
    - jq

- name: Display tool versions
  debug:
    msg: "{{ item.cmd | basename }}: {{ item.stdout_lines[0] | default('Not installed') }}"
  loop: "{{ tool_versions.results }}"
  loop_control:
    label: "{{ item.cmd }}"
```

## Success Criteria

- [ ] Ansible-lint passes with no errors
- [ ] All development packages installed
- [ ] Python 3+ with UV available (Ubuntu 24.04 default: 3.12)
- [ ] Node.js 20 LTS installed with npm
- [ ] Git configured with aliases
- [ ] tmux configured with custom settings
- [ ] All tools accessible from PATH
- [ ] ansible user can use all tools

## Validation

### Test Installation

```bash
cd ansible_collections/basher83/automation_server

# MANDATORY: Run ansible-lint first
ansible-lint playbooks/development.yml
ansible-lint roles/development_tools/
# Must pass production linting rules

# Check syntax
ansible-playbook -i inventory/ansible_inventory.json playbooks/development.yml --syntax-check

# Run installation
ansible-playbook -i inventory/ansible_inventory.json playbooks/development.yml

# Verify tools
ssh ansible@192.168.10.250 "which git python3 node npm uv tmux"

# Check versions
ssh ansible@192.168.10.250 "git --version && node --version && uv --version"

# Test UV
ssh ansible@192.168.10.250 "uv pip list"

# Test tmux
ssh ansible@192.168.10.250 "tmux new-session -d && tmux list-sessions"
```

Expected output:

- All tools found in PATH
- Version numbers displayed
- tmux session created successfully

## Notes

- UV is the modern Python package manager (faster than pip)
- UV installed securely via direct binary download with checksum verification
- Node.js LTS version for stability
- Python 3 uses Ubuntu 24.04 default (3.12); for Python 3.11 specifically, add deadsnakes PPA
- tmux configuration enhances productivity
- Consider adding user-specific dotfiles
- Tools can be customized per environment

## References

- [UV Documentation](https://github.com/astral-sh/uv)
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [tmux Documentation](https://github.com/tmux/tmux/wiki)
- [Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)
