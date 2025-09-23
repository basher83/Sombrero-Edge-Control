# Ansible Collection Research Report: Netdata Monitoring Solution

## Executive Summary

- Research scope: Ansible collections and roles for Netdata monitoring deployment on Ubuntu 24.04 LTS
- Key findings: Official Netdata Ansible repository exists with production-ready roles, multiple quality community alternatives available, Docker-based deployments well-supported
- Top recommendation: Use official Netdata Ansible repository for native installation, or boutetnico.netdata role for more advanced configuration

## Research Methodology

### API Calls Executed

1. `search_repositories(q="ansible netdata collection role")` - 4 results found
2. `search_repositories(q="netdata ansible deployment docker")` - 1 result found
3. `search_code(q="galaxy.yml ansible netdata")` - 11 results found
4. `search_repositories(q="netdata language:yaml")` - 1 result found
5. `search_repositories(q="org:netdata ansible")` - 1 result found (Official)
6. `get_repository(owner="metajiji", repo="ansible_netdata")` - Community role analysis
7. `get_repository(owner="boutetnico", repo="ansible-role-netdata")` - Recent role analysis
8. `get_repository(owner="netdata", repo="ansible")` - Official repository analysis
9. `get_repository(owner="Djuuu", repo="ansible-role-netdata-docker")` - Docker-based role analysis
10. `list_commits` calls for activity assessment on all repositories

### Search Strategy

- Primary search: Official Netdata organization repositories and established community roles
- Secondary search: Docker-based solutions and recent developments
- Validation: Code examination, commit history analysis, and documentation review

### Data Sources

- Total repositories examined: 6
- API rate limit status: Well within limits
- Data freshness: Real-time as of 2025-09-22 21:36:39

## Collections Discovered

### Tier 1: Production-Ready (80-100 points)

**netdata/ansible** - Score: 85/100

- Repository: https://github.com/netdata/ansible
- **Metrics**: 17 stars `get_repository`, 8 forks `get_repository`
- **Activity**: Last commit 2024-12-09 `list_commits`
- **Contributors**: Official Netdata team maintained `list_commits`
- Strengths: Official support, comprehensive role structure, recent updates, tested on multiple distributions
- Use Case: Native Netdata installation with official support
- Example:
  ```yaml
  - name: Install Netdata agent
    hosts: all
    become: true
    roles:
      - { role: install_netdata_repository }
      - { role: install_netdata_agent }
  ```

**boutetnico.netdata** - Score: 82/100

- Repository: https://github.com/boutetnico/ansible-role-netdata
- Namespace: boutetnico.netdata
- **Metrics**: 1 star `get_repository`, 0 forks `get_repository`
- **Activity**: Last commit 2025-08-14 `list_commits`
- **Contributors**: 1 active maintainer `list_commits`
- Strengths: Ubuntu 24.04 explicitly supported, comprehensive configuration options, CI/CD testing, streaming support
- Use Case: Advanced Netdata configuration with extensive customization
- Example:
  ```yaml
  - hosts: all
    roles:
      - role: boutetnico.netdata
        netdata_conf:
          global:
            update every: 10
          web:
            bind to: "*"
  ```

### Tier 2: Good Quality (60-79 points)

**Djuuu.netdata_docker** - Score: 75/100

- Repository: https://github.com/Djuuu/ansible-role-netdata-docker
- Namespace: djuuu.netdata_docker
- **Metrics**: 0 stars `get_repository`, 0 forks `get_repository`
- **Activity**: Last commit 2025-06-03 `list_commits`
- **Contributors**: 1 `list_commits`
- Strengths: Docker-based deployment, Traefik integration, cloud claiming support, recent activity
- Use Case: Containerized Netdata deployment with Docker Compose
- Example:
  ```yaml
  - hosts: all
    roles:
      - djuuu.netdata_docker
    vars:
      netdata_version: stable
      netdata_claim_token: "your-cloud-token"
  ```

**metajiji.ansible_netdata** - Score: 70/100

- Repository: https://github.com/metajiji/ansible_netdata
- Namespace: metajiji.netdata
- **Metrics**: 4 stars `get_repository`, 0 forks `get_repository`
- **Activity**: Last commit 2024-11-21 `list_commits`
- **Contributors**: 1 `list_commits`
- Strengths: Multiple installation types (Docker, tarball, package), KSM support, flexible configuration
- Use Case: Flexible Netdata deployment with multiple installation options
- Example:
  ```yaml
  - hosts: all
    roles:
      - netdata
    vars:
      netdata_installation_type: docker
      netdata_telemetry: false
  ```

### Tier 3: Use with Caution (40-59 points)

**johanneskastl.netdata-agent** - Score: 45/100

- Repository: https://github.com/johanneskastl/ansible-role-netdata-agent
- **Activity**: Last commit 2023-02-24 `list_commits`
- **Contributors**: 1 `list_commits`
- Limitations: Stale (20+ months), minimal features, basic configuration only
- Use Case: Simple installations only, consider for reference patterns

### Tier 4: Not Recommended (Below 40 points)

**Nani-o/ansible-role-netdata** - Score: 25/100
- Last activity: 2021-03-30, abandoned, French documentation only

## Integration Recommendations

### Recommended Stack

1. **Primary choice**: netdata/ansible - Official support with proven stability
2. **Advanced configuration**: boutetnico.netdata - Modern role with Ubuntu 24.04 support
3. **Docker deployment**: djuuu.netdata_docker - For containerized environments
4. **Dependencies**: Standard Ubuntu repositories, official Netdata repositories

### Implementation Path

1. **For Sombrero-Edge-Control Project (ANS-005)**:

   **Option A: Official Netdata Roles**
   ```yaml
   # Add to requirements.yml
   - src: https://github.com/netdata/ansible.git
     name: netdata.ansible
     version: master

   # Integration in site.yml
   - name: Deploy Netdata monitoring
     hosts: jump_hosts
     become: true
     roles:
       - netdata.ansible.install_netdata_repository
       - netdata.ansible.install_netdata_agent
   ```

   **Option B: Advanced Community Role**
   ```yaml
   # Add to requirements.yml
   - src: boutetnico.netdata
     version: master

   # Integration with Docker monitoring
   - name: Deploy Netdata with Docker monitoring
     hosts: jump_hosts
     become: true
     roles:
       - role: boutetnico.netdata
         netdata_user_extra_groups:
           - docker
         netdata_conf:
           global:
             update every: 10
           plugins:
             cgroups: "yes"    # Enable Docker container monitoring
             apps: "yes"
   ```

2. **Configuration for jump-man VM**:
   - Web dashboard: http://192.168.10.250:19999
   - Docker monitoring: Automatic detection of containers
   - Security: Bind to localhost or specific network range
   - Firewall: Configure UFW rules for port 19999

3. **Testing approach**:
   - Deploy to test environment first
   - Validate Docker container monitoring
   - Test web dashboard accessibility
   - Verify system metrics collection

## Risk Analysis

### Technical Risks

- **Official repository**: Minimal configuration options, may require custom templates for advanced needs
- **Community roles**: Single maintainer dependency for boutetnico and djuuu roles
- **Docker approach**: Additional complexity but better isolation

### Maintenance Risks

- **Official Netdata**: Well-maintained by organization, lowest risk
- **boutetnico.netdata**: Active development but single contributor
- **Version compatibility**: Netdata evolves rapidly, roles may lag behind

## Next Steps

1. **Immediate actions**:
   - Add chosen role to `requirements.yml` in ansible/ directory
   - Create Netdata configuration templates in `group_vars/all.yml`
   - Plan firewall rules for port 19999

2. **Testing recommendations**:
   - Deploy on test VM first using `mise run test-deploy`
   - Validate Docker monitoring functionality
   - Test web dashboard security configuration

3. **Documentation needs**:
   - Update ROADMAP.md with Netdata deployment status
   - Document access URLs and monitoring capabilities
   - Add operational procedures for Netdata management

## Verification

### Reproducibility

To reproduce this research:

1. Query: `search_repositories(q="ansible netdata")`
2. Filter: Active repositories, official sources prioritized
3. Validate: Code analysis of tasks, documentation review, commit history

### Research Limitations

- API rate limiting encountered: No
- Repositories inaccessible: None encountered
- Search constraints: Some smaller/personal repositories may have been missed
- Time constraints: None, comprehensive search completed

---

**Recommendation for ANS-005**: Use the **official netdata/ansible repository** for initial deployment due to official support and stability, with **boutetnico.netdata** as backup option for advanced configuration needs. The official approach aligns with production requirements and provides the best long-term maintenance outlook.
