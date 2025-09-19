---
Task: Monitoring Stack Setup
Task ID: ANS-005
Priority: P1 (Important)
Estimated Time: 3 hours
Dependencies: ANS-002
Status: ⏸️ Blocked
---

## Objective

Deploy a comprehensive monitoring stack on the jump host using Docker containers. This includes Prometheus for metrics collection, Grafana for visualization, Node Exporter for system metrics, and Alertmanager for notifications. The stack will monitor both the jump host and can be extended to monitor other infrastructure components.

## Prerequisites

- [ ] ANS-002 completed (Docker installed)
- [ ] VM accessible via Ansible
- [ ] Docker and Docker Compose functional
- [ ] Understanding of monitoring requirements

## Implementation Steps

### 1. **Create Monitoring Role**

```bash
cd ansible_collections/basher83/automation_server/roles
ansible-galaxy role init monitoring_stack
```

### 2. **Define Monitoring Variables**

Create `roles/monitoring_stack/defaults/main.yml`:

```yaml
---
# Monitoring stack versions
prometheus_version: "2.48.0"
grafana_version: "10.2.3"
node_exporter_version: "1.7.0"
alertmanager_version: "0.26.0"

# Network configuration
monitoring_network: monitoring
monitoring_base_path: /opt/monitoring

# Prometheus configuration
prometheus_port: 9090
prometheus_retention: "30d"
prometheus_scrape_interval: "15s"
prometheus_evaluation_interval: "15s"

# Grafana configuration
grafana_port: 3000
grafana_admin_user: admin
grafana_admin_password: "{{ vault_grafana_admin_password | default('changeme') }}"
grafana_anonymous_enabled: false

# Node Exporter configuration
node_exporter_port: 9100

# Alertmanager configuration
alertmanager_port: 9093
alertmanager_slack_webhook: "{{ vault_alertmanager_slack_webhook | default('') }}"
alertmanager_email_to: "{{ vault_alertmanager_email_to | default('admin@example.com') }}"

# Scrape targets
prometheus_scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'docker'
    static_configs:
      - targets: ['localhost:9323']
```

### 3. **Create Directory Structure Tasks**

Create `roles/monitoring_stack/tasks/setup.yml`:

```yaml
---
- name: Create monitoring directories
  file:
    path: "{{ item }}"
    state: directory
    owner: ansible
    group: docker
    mode: '0755'
  loop:
    - "{{ monitoring_base_path }}"
    - "{{ monitoring_base_path }}/prometheus"
    - "{{ monitoring_base_path }}/prometheus/data"
    - "{{ monitoring_base_path }}/grafana"
    - "{{ monitoring_base_path }}/grafana/data"
    - "{{ monitoring_base_path }}/grafana/provisioning"
    - "{{ monitoring_base_path }}/grafana/provisioning/dashboards"
    - "{{ monitoring_base_path }}/grafana/provisioning/datasources"
    - "{{ monitoring_base_path }}/alertmanager"
    - "{{ monitoring_base_path }}/alertmanager/data"

- name: Set permissions for Prometheus data
  file:
    path: "{{ monitoring_base_path }}/prometheus/data"
    owner: "65534"  # nobody user for Prometheus container
    group: "65534"
    mode: '0755'

- name: Set permissions for Grafana data
  file:
    path: "{{ monitoring_base_path }}/grafana/data"
    owner: "472"  # Grafana user in container
    group: "472"
    mode: '0755'
```

### 4. **Create Configuration Templates**

Create `roles/monitoring_stack/templates/prometheus.yml.j2`:

```yaml
global:
  scrape_interval: {{ prometheus_scrape_interval }}
  evaluation_interval: {{ prometheus_evaluation_interval }}
  external_labels:
    monitor: 'jump-man'
    environment: 'production'

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

rule_files:
  - /etc/prometheus/alerts/*.yml

scrape_configs:
{{ prometheus_scrape_configs | to_nice_yaml(indent=2) }}
```

Create `roles/monitoring_stack/templates/alertmanager.yml.j2`:

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'default'

receivers:
  - name: 'default'
{% if alertmanager_slack_webhook %}
    slack_configs:
      - api_url: '{{ alertmanager_slack_webhook }}'
        channel: '#alerts'
        title: 'Alert: {{ "{{ .GroupLabels.alertname }}" }}'
        text: '{{ "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}" }}'
{% endif %}
{% if alertmanager_email_to %}
    email_configs:
      - to: '{{ alertmanager_email_to }}'
        from: 'alertmanager@jump-man.local'
        smarthost: 'localhost:25'
        require_tls: false
{% endif %}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'cluster', 'service']
```

Create `roles/monitoring_stack/templates/docker-compose.yml.j2`:

```yaml
version: '3.8'

networks:
  {{ monitoring_network }}:
    driver: bridge

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:

services:
  prometheus:
    image: prom/prometheus:v{{ prometheus_version }}
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "{{ prometheus_port }}:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time={{ prometheus_retention }}'
      - '--web.enable-lifecycle'
    volumes:
      - {{ monitoring_base_path }}/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - {{ monitoring_base_path }}/prometheus/alerts:/etc/prometheus/alerts:ro
      - prometheus_data:/prometheus
    networks:
      - {{ monitoring_network }}

  grafana:
    image: grafana/grafana:{{ grafana_version }}
    container_name: grafana
    restart: unless-stopped
    ports:
      - "{{ grafana_port }}:3000"
    environment:
      - GF_SECURITY_ADMIN_USER={{ grafana_admin_user }}
      - GF_SECURITY_ADMIN_PASSWORD={{ grafana_admin_password }}
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_AUTH_ANONYMOUS_ENABLED={{ grafana_anonymous_enabled }}
    volumes:
      - grafana_data:/var/lib/grafana
      - {{ monitoring_base_path }}/grafana/provisioning:/etc/grafana/provisioning:ro
    networks:
      - {{ monitoring_network }}

  node-exporter:
    image: prom/node-exporter:v{{ node_exporter_version }}
    container_name: node-exporter
    restart: unless-stopped
    ports:
      - "{{ node_exporter_port }}:9100"
    command:
      - '--path.rootfs=/host'
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run|var/lib/docker)($|/)'
    volumes:
      - /:/host:ro,rslave
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
    networks:
      - {{ monitoring_network }}
    pid: host

  alertmanager:
    image: prom/alertmanager:v{{ alertmanager_version }}
    container_name: alertmanager
    restart: unless-stopped
    ports:
      - "{{ alertmanager_port }}:9093"
    volumes:
      - {{ monitoring_base_path }}/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    networks:
      - {{ monitoring_network }}
```

### 5. **Create Alert Rules**

Create `roles/monitoring_stack/templates/alerts.yml.j2`:

```yaml
groups:
  - name: system
    rules:
      - alert: HighCPUUsage
        expr: (100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% (current value: {{ $value }}%)"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 80% (current value: {{ $value }}%)"

      - alert: DiskSpaceRunningLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 20
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk space on root partition is below 20% (current value: {{ $value }}%)"

      - alert: ServiceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "{{ $labels.job }} on {{ $labels.instance }} has been down for more than 2 minutes"
```

### 6. **Create Grafana Provisioning**

Create `roles/monitoring_stack/templates/datasource.yml.j2`:

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

Create `roles/monitoring_stack/templates/dashboard-provider.yml.j2`:

```yaml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
```

### 7. **Create Deployment Tasks**

Create `roles/monitoring_stack/tasks/deploy.yml`:

```yaml
---
- name: Deploy Prometheus configuration
  template:
    src: prometheus.yml.j2
    dest: "{{ monitoring_base_path }}/prometheus/prometheus.yml"
    owner: ansible
    group: docker
    mode: '0644'

- name: Deploy alert rules
  template:
    src: alerts.yml.j2
    dest: "{{ monitoring_base_path }}/prometheus/alerts/alerts.yml"
    owner: ansible
    group: docker
    mode: '0644'

- name: Deploy Alertmanager configuration
  template:
    src: alertmanager.yml.j2
    dest: "{{ monitoring_base_path }}/alertmanager/alertmanager.yml"
    owner: ansible
    group: docker
    mode: '0644'

- name: Deploy Grafana datasource provisioning
  template:
    src: datasource.yml.j2
    dest: "{{ monitoring_base_path }}/grafana/provisioning/datasources/prometheus.yml"
    owner: ansible
    group: docker
    mode: '0644'

- name: Deploy Grafana dashboard provisioning
  template:
    src: dashboard-provider.yml.j2
    dest: "{{ monitoring_base_path }}/grafana/provisioning/dashboards/provider.yml"
    owner: ansible
    group: docker
    mode: '0644'

- name: Deploy docker-compose file
  template:
    src: docker-compose.yml.j2
    dest: "{{ monitoring_base_path }}/docker-compose.yml"
    owner: ansible
    group: docker
    mode: '0644'

- name: Start monitoring stack
  docker_compose:
    project_src: "{{ monitoring_base_path }}"
    state: present
  become_user: ansible
```

### 8. **Create Main Task File**

Create `roles/monitoring_stack/tasks/main.yml`:

```yaml
---
- name: Setup monitoring directories
  include_tasks: setup.yml
  tags: [monitoring, setup]

- name: Deploy monitoring stack
  include_tasks: deploy.yml
  tags: [monitoring, deploy]

- name: Wait for services to be ready
  uri:
    url: "http://localhost:{{ item.port }}{{ item.path | default('') }}"
    status_code: 200
  register: result
  until: result.status == 200
  retries: 30
  delay: 10
  loop:
    - { port: "{{ prometheus_port }}", path: "/-/ready" }
    - { port: "{{ grafana_port }}", path: "/api/health" }
    - { port: "{{ node_exporter_port }}", path: "/metrics" }
    - { port: "{{ alertmanager_port }}", path: "/-/ready" }

- name: Display access information
  debug:
    msg:
      - "Monitoring stack deployed successfully!"
      - "Prometheus: http://{{ ansible_default_ipv4.address }}:{{ prometheus_port }}"
      - "Grafana: http://{{ ansible_default_ipv4.address }}:{{ grafana_port }}"
      - "Alertmanager: http://{{ ansible_default_ipv4.address }}:{{ alertmanager_port }}"
      - "Grafana credentials: {{ grafana_admin_user }} / {{ grafana_admin_password }}"
```

## Success Criteria

- [ ] Ansible-lint passes with no errors
- [ ] All monitoring containers running
- [ ] Prometheus scraping metrics successfully
- [ ] Grafana accessible with admin credentials
- [ ] Node Exporter providing system metrics
- [ ] Alertmanager configured and running
- [ ] Alert rules loaded and evaluated
- [ ] Services accessible from network

## Validation

### Test Deployment

```bash
cd ansible_collections/basher83/automation_server

# MANDATORY: Run ansible-lint first
ansible-lint playbooks/monitoring.yml
ansible-lint roles/monitoring_stack/
# Must pass production linting rules

# Check syntax
ansible-playbook -i inventory/ansible_inventory.json playbooks/monitoring.yml --syntax-check

# Deploy monitoring stack
ansible-playbook -i inventory/ansible_inventory.json playbooks/monitoring.yml

# Check container status
ssh ansible@192.168.10.250 "docker ps | grep -E 'prometheus|grafana|node-exporter|alertmanager'"

# Test Prometheus
curl http://192.168.10.250:9090/-/ready

# Test Grafana
curl http://192.168.10.250:3000/api/health

# Check metrics
curl http://192.168.10.250:9090/api/v1/targets
```

Expected output:

- All containers running
- Health checks return OK
- Targets showing as UP in Prometheus

## Notes

- Default Grafana password should be changed
- Consider adding authentication to Prometheus
- Add more dashboards for specific monitoring needs
- Configure proper alerting channels
- Regular backup of Grafana dashboards and Prometheus data

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter Documentation](https://github.com/prometheus/node_exporter)
- [Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
