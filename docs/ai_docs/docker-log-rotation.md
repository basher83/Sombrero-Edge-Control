Here are practical Ansible examples to configure Docker log rotation globally and per workload, using Docker’s built‑in drivers and best practices.[1][2][3]

### Global defaults (daemon.json)

Set a default logging driver and rotation limits for all new containers by managing /etc/docker/daemon.json and restarting the Docker daemon. Docker supports rotation options natively for the json-file and local drivers; when setting log-opts in daemon.json, values must be strings, and changes only apply to newly created containers.[2][4][1]

```yaml
# playbooks/docker-log-rotation.yml
- name: Configure Docker log rotation globally
  hosts: docker_hosts
  become: true
  vars:
    docker_log_driver: "json-file" # consider "local" for built-in rotation
    docker_log_opts:
      max-size: "10m"
      max-file: "3"
  tasks:
    - name: Ensure /etc/docker exists
      ansible.builtin.file:
        path: /etc/docker
        state: directory
        mode: "0755"

    - name: Write daemon.json with log rotation
      ansible.builtin.copy:
        dest: /etc/docker/daemon.json
        mode: "0644"
        content: |
          {
            "log-driver": "{{ docker_log_driver }}",
            "log-opts": {
              {% for k, v in docker_log_opts.items() %}
              "{{ k }}": "{{ v }}"{% if not loop.last %},{% endif %}
              {% endfor %}
            }
          }
      notify: Restart docker

  handlers:
    - name: Restart docker
      ansible.builtin.service:
        name: docker
        state: restarted
```

- Default logging driver is json-file; max-size and max-file enable rotation and must be quoted strings in daemon.json.[1][2]
- The local driver rotates by default (5 files x 20MB ≈ 100MB total), and also supports max-size and max-file if tighter limits are needed.[3]
- daemon.json lives at /etc/docker/daemon.json on Linux, and daemon-level changes affect only newly created containers after a daemon restart.[4][2]

### Per-container with Ansible’s docker_container

If some containers need different rotation limits, set log_driver and log_options in the community.docker.docker_container module. The module requires explicitly setting log_driver for log_options to take effect, even when using the default json-file driver.[5]

```yaml
- name: Run app with per-container log rotation
  hosts: docker_hosts
  become: true
  tasks:
    - name: Start/Update app container with json-file rotation
      community.docker.docker_container:
        name: myapp
        image: nginx:1.27
        restart_policy: unless-stopped
        log_driver: json-file
        log_options:
          max-size: "20m"
          max-file: "5"
```

- log_driver must be set for log_options to be applied; without it, options may be ignored.[5]
- json-file supports max-size and max-file, and rotated files are maintained by Docker without needing external logrotate.[1]

### Compose stacks via Ansible

When deploying with Compose, define logging in the compose file and apply it using the community.docker.docker_compose_v2 module or equivalent.[6][7]

docker-compose.yml:

```yaml
services:
  web:
    image: nginx:1.27
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Ansible task:

```yaml
- name: Deploy stack with Compose v2
  hosts: docker_hosts
  become: true
  tasks:
    - name: Apply compose project
      community.docker.docker_compose_v2:
        project_src: /opt/my_stack
```

- Compose supports a logging section per service; driver-specific options such as max-size and max-file are passed under logging.options.[7]
- Use the v2 Compose module for current Docker Compose deployments from Ansible.[6]

### Verifications and gotchas

Verify the daemon default driver with docker info and recreate containers to pick up new daemon defaults. For json-file and local, rotation is enforced by Docker; avoid external tools touching the internal log files to prevent corruption.[2][3][1]

- Check current default: docker info --format '{{.LoggingDriver}}' to confirm json-file or local.[2]
- Existing containers keep their original logging driver and options; recreate them to adopt new daemon.json settings.[2]
- Docker warns against external manipulation of json-file or local driver log files; rely on driver rotation options instead.[3][1]

### Driver choice tips

Use the local driver for automatic rotation with lower overhead, or json-file if raw JSON logs are required and rotation is configured. Both drivers support max-size and max-file via daemon.json or per container, with changes requiring a daemon restart for new containers at the global level.[3][1][2]

[1](https://docs.docker.com/engine/logging/drivers/json-file/)
[2](https://docs.docker.com/engine/logging/configure/)
[3](https://docs.docker.com/engine/logging/drivers/local/)
[4](https://docs.docker.com/reference/cli/dockerd/)
[5](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html)
[6](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_v2_module.html)
[7](https://docs.docker.com/reference/compose-file/services/)
[8](https://forums.docker.com/t/how-to-limit-or-rotate-docker-container-logs/112378)
[9](https://www.reddit.com/r/docker/comments/11aygnh/help_with_limiting_docker_jsonlog_file_size/)
[10](https://docs.logrhythm.com/OCbeats/docs/configure-docker-log-rotation)
[11](https://www.datadoghq.com/blog/docker-logging/)
[12](https://stackoverflow.com/questions/49083726/how-to-specify-log-opt-of-docker-run-in-ansible-to-limit-the-log-size-of-a-conta)
[13](https://dev.to/signoz/how-to-configure-docker-log-rotation-13p8)
[14](https://www.suse.com/support/kb/doc/?id=000020141)
[15](https://www.logicmonitor.com/blog/docker-logging-how-do-logs-work-with-docker-containers)
[16](https://forum.ansible.com/t/how-to-specify-log-opt-of-docker-run-in-ansible-to-limit-the-log-size-of-a-container/26905)
[17](https://stackoverflow.com/questions/58389314/logrotate-with-ansible-playbook)
[18](https://stackoverflow.com/questions/39078715/specify-max-log-json-file-size-in-docker-compose)
[19](https://stackoverflow.com/questions/62346527/how-to-change-the-logging-options-for-json-log)
[20](https://willsena.dev/strategies-for-rotating-docker-logs/)
[21](https://gist.github.com/paulgwebster-oe/b3eab23c5c369d659bf0f66f124f2715)
[22](https://docs.ansible.com/ansible/2.9/modules/docker_container_module.html)
[23](https://chenghsuan.me/posts/logrotate-with-ansible)
[24](https://dev.to/francoislp/limit-docker-logs-size-3lj)
[25](https://last9.io/blog/docker-compose-logs/)
[26](https://forums.docker.com/t/how-to-specify-max-log-json-file-size-in-docker-compose/20873)
[27](https://stackoverflow.com/questions/37195222/how-to-view-log-output-using-docker-compose-run)
[28](https://stackoverflow.com/questions/43689271/wheres-dockers-daemon-json-missing)
[29](https://www.squadcast.com/blog/docker-compose-logs)
[30](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_module.html)
[31](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon)
[32](https://betterstack.com/community/guides/logging/how-to-start-logging-with-docker/)
[33](https://ansible.readthedocs.io/projects/ansible/9/collections/community/docker/docker_compose_module.html)
[34](https://github.com/docker/docker.github.io/issues/15106)
[35](https://stackoverflow.com/questions/43486505/docker-compose-json-logging-driver-labels-env)
[36](https://signoz.io/blog/docker-logging/)
[37](https://spacelift.io/blog/docker-compose-logs)
[38](https://docs.docker.com/engine/logging/drivers/fluentd/)
[39](https://signoz.io/guides/docker-logs-location/)
[40](https://docs.docker.com/reference/compose-file/)
[41](https://spacelift.io/blog/ansible-docker)
