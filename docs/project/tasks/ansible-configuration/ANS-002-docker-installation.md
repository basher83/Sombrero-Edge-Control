---
Task: Docker Installation Role
Task ID: ANS-002
Priority: P1 (Important)
Estimated Time: 2 hours
Dependencies: ANS-001
Status: ⏸️ Blocked
---

## Objective

Create an Ansible role to install and configure Docker CE with Docker Compose plugin on the jump host. This replaces the Docker installation previously handled by cloud-init, ensuring consistent and idempotent configuration management.

## Prerequisites

- [ ] ANS-001 completed (Bootstrap playbook)
- [ ] VM accessible via Ansible
- [ ] Internet connectivity for package downloads

## Implementation Steps

### 1. **Create Docker Role Structure**

```bash
cd ansible_collections/basher83/automation_server/roles
ansible-galaxy role init docker
```

### 2. **Define Role Variables**

Create `roles/docker/defaults/main.yml`:

```yaml
---
# Docker installation variables
docker_edition: ce
docker_version: latest
docker_users:
  - ansible

# Docker Compose
docker_compose_version: v2.24.0
docker_compose_path: /usr/local/lib/docker/cli-plugins

# Docker daemon configuration
docker_daemon_config:
  log-driver: "json-file"
  log-opts:
    max-size: "10m"
    max-file: "3"
  storage-driver: "overlay2"
  live-restore: true

# Repository settings
docker_apt_release_channel: stable
docker_apt_arch: amd64
docker_apt_repository: "deb [arch={{ docker_apt_arch }}] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} {{ docker_apt_release_channel }}"
docker_apt_gpg_key: https://download.docker.com/linux/ubuntu/gpg
```

### 3. **Create Installation Tasks**

Create `roles/docker/tasks/main.yml`:

```yaml
---
- name: Remove old Docker packages
  apt:
    name:
      - docker
      - docker-engine
      - docker.io
      - containerd
      - runc
    state: absent

- name: Install Docker dependencies
  apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
    state: present
    update_cache: yes

- name: Add Docker GPG key
  apt_key:
    url: "{{ docker_apt_gpg_key }}"
    state: present

- name: Add Docker repository
  apt_repository:
    repo: "{{ docker_apt_repository }}"
    state: present
    update_cache: yes

- name: Install Docker CE
  apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    state: present
    update_cache: yes

- name: Ensure Docker service is started and enabled
  systemd:
    name: docker
    state: started
    enabled: yes
    daemon_reload: yes

- name: Configure Docker daemon
  copy:
    content: "{{ docker_daemon_config | to_nice_json }}"
    dest: /etc/docker/daemon.json
    owner: root
    group: root
    mode: '0644'
  notify: restart docker

- name: Create docker group
  group:
    name: docker
    state: present

- name: Add users to docker group
  user:
    name: "{{ item }}"
    groups: docker
    append: yes
  loop: "{{ docker_users }}"

- name: Create Docker CLI plugins directory
  file:
    path: "{{ docker_compose_path }}"
    state: directory
    mode: '0755'

- name: Reset ssh connection to apply group changes
  meta: reset_connection
```

### 4. **Create Handlers**

Create `roles/docker/handlers/main.yml`:

```yaml
---
- name: restart docker
  systemd:
    name: docker
    state: restarted
    daemon_reload: yes

- name: reload docker
  systemd:
    name: docker
    state: reloaded
```

### 5. **Create Validation Tasks**

Create `roles/docker_validation/tasks/main.yml`:

```yaml
---
- name: Check Docker version
  command: docker --version
  register: docker_version
  changed_when: false

- name: Check Docker Compose version
  command: docker compose version
  register: compose_version
  changed_when: false

- name: Verify Docker service status
  systemd:
    name: docker
    state: started
  register: docker_service
  check_mode: yes

- name: Test Docker functionality
  docker_container:
    name: hello-world-test
    image: hello-world
    state: started
    auto_remove: yes
  register: docker_test

- name: Check user can run Docker without sudo
  command: docker ps
  become: no
  register: docker_user_test
  changed_when: false

- name: Display validation results
  debug:
    msg:
      - "Docker Version: {{ docker_version.stdout }}"
      - "Compose Version: {{ compose_version.stdout }}"
      - "Service Status: {{ 'Running' if docker_service.changed == false else 'Not Running' }}"
      - "Docker Test: {{ 'Passed' if docker_test is success else 'Failed' }}"
      - "User Access: {{ 'OK' if docker_user_test.rc == 0 else 'Failed' }}"
```

### 6. **Create Docker Playbook**

Create `playbooks/docker.yml`:

```yaml
---
- name: Install and Configure Docker
  hosts: jump_hosts
  become: yes

  roles:
    - docker
    - docker_validation

  post_tasks:
    - name: Prune Docker system (optional)
      docker_prune:
        containers: yes
        images: yes
        networks: yes
        volumes: yes
        builder_cache: yes
      tags: [never, prune]

    - name: Pull common Docker images
      docker_image:
        name: "{{ item }}"
        source: pull
      loop:
        - alpine:latest
        - nginx:alpine
        - python:3.11-slim
      tags: [never, pull_images]
```

### 7. **Create Molecule Test**

Create `roles/docker/molecule/default/molecule.yml`:

```yaml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: ubuntu:24.04
    pre_build_image: false
    privileged: true
    command: /lib/systemd/systemd
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
provisioner:
  name: ansible
  inventory:
    host_vars:
      instance:
        ansible_user: root
verifier:
  name: ansible
```

Create `roles/docker/molecule/default/converge.yml`:

```yaml
---
- name: Converge
  hosts: all
  tasks:
    - name: Include docker role
      include_role:
        name: docker
```

## Success Criteria

- [ ] Docker CE installed successfully
- [ ] Docker Compose plugin installed
- [ ] Docker service running and enabled
- [ ] ansible user can run Docker without sudo
- [ ] Docker daemon configured with proper settings
- [ ] Role is idempotent
- [ ] Validation tasks pass

## Validation

### Test Installation

```bash
cd ansible_collections/basher83/automation_server

# MANDATORY: Run ansible-lint first
ansible-lint playbooks/docker.yml
ansible-lint roles/docker/
ansible-lint roles/docker_validation/
# Must pass production linting rules

# Check syntax
ansible-playbook -i inventory/ansible_inventory.json playbooks/docker.yml --syntax-check

# Run Docker installation
ansible-playbook -i inventory/ansible_inventory.json playbooks/docker.yml

# Run validation only
ansible-playbook -i inventory/ansible_inventory.json playbooks/docker.yml --tags validation

# Test on target host
ssh ansible@192.168.10.250 "docker run hello-world"
ssh ansible@192.168.10.250 "docker compose version"
```

### Run Molecule Tests

```bash
cd roles/docker

# Lint the role first
ansible-lint .

# Run molecule tests
molecule test
```

Expected output:

- Docker and Compose versions displayed
- Hello-world container runs successfully
- All validation checks pass

## Notes

- Replaces Docker installation from cloud-init
- Ensures consistent version across deployments
- Includes Docker Compose as plugin (modern approach)
- Configures logging and storage best practices
- Consider adding Docker registry configuration if needed

## References

- [Docker Installation Guide](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Ansible Docker Module](https://docs.ansible.com/ansible/latest/collections/community/docker/)
