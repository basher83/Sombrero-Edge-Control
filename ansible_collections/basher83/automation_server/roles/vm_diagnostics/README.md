# VM Diagnostics Role

This role provides comprehensive VM diagnostics and troubleshooting capabilities
for the Sombrero Edge Control infrastructure. It replaces manual diagnostic commands
with automated Ansible tasks for systematic problem analysis and resolution.

## Research Background

Based on comprehensive research of Ansible collections for VM diagnostics:

### Primary Collections Used

- **nodiscc.xsrv v1.27.0** (Score: 92/100) - Complete monitoring and diagnostic infrastructure
- **deltabg.extended_facts v1.0.6** (Score: 78/100) - Advanced hardware and system fact gathering
- **community.general v11.2.1** (Score: 75/100) - General system management and diagnostic utilities
- **ansible.posix v3.0.0** (Score: 70/100) - POSIX system diagnostics and configuration analysis

### Collection Quality Assessment

Research conducted using ansible-research subagent with 100-point scoring system evaluating:

- Diagnostic and troubleshooting capabilities
- Log collection and analysis modules
- System information gathering tools
- Network and service debugging features
- Performance analysis and monitoring integration

## Role Overview

This role implements comprehensive VM diagnostics across six key areas:

1. **System Diagnostics** - Hardware, resources, kernel, boot analysis
1. **Log Collection & Analysis** - Centralized collection, parsing, trend analysis
1. **Network Diagnostics** - Connectivity, DNS, routing, firewall analysis
1. **Service Diagnostics** - Status, dependencies, performance, configuration
1. **Performance Analysis** - Resource trends, bottlenecks, I/O testing
1. **Troubleshooting Automation** - Workflows, reports, remediation

## Features

### System Diagnostics

- Hardware information gathering (CPU, memory, disk, RAID)
- System resource analysis and utilization monitoring
- Kernel configuration and parameter validation
- Boot and startup diagnostic analysis
- IPMI hardware monitoring integration
- SMART disk diagnostics and health checking

### Log Collection & Analysis

- Centralized log collection from multiple sources
- Cloud-init and provisioning log analysis
- System log parsing and error pattern detection
- Historical log analysis and trend identification
- Log rotation and retention management
- Interactive log exploration with advanced tools

### Network Diagnostics

- Network connectivity troubleshooting and validation
- DNS resolution and routing analysis
- Firewall configuration diagnostics
- Network performance testing and monitoring
- Bandwidth utilization analysis
- Network interface diagnostics

### Service Diagnostics

- Service status and dependency analysis
- Configuration validation and troubleshooting
- Performance monitoring and bottleneck detection
- Docker container diagnostics integration
- Service restart and recovery automation
- Inter-service communication validation

### Performance Analysis

- Resource utilization trend analysis over time
- Performance bottleneck identification and reporting
- I/O performance testing and validation
- Memory leak and resource exhaustion detection
- Real-time performance monitoring integration
- Historical performance data collection

### Troubleshooting Automation

- Automated diagnostic workflow execution
- Common issue detection and remediation
- Comprehensive diagnostic report generation
- Integration with monitoring and alerting systems
- Automated log analysis and error correlation
- Self-healing capabilities for common issues

## Usage

### Basic Usage

```yaml
- name: VM Diagnostics
  hosts: problem_vms
  roles:
    - role: vm_diagnostics
```

### Advanced Configuration

```yaml
- name: Comprehensive VM Diagnostics
  hosts: problem_vms
  roles:
    - role: vm_diagnostics
      vars:
        diagnostic_categories:
          - system
          - network
          - services
          - logs
          - performance
          - troubleshooting
        diagnostic_depth: "comprehensive" # basic, standard, comprehensive
        collect_logs: true
        log_collection_paths:
          - /var/log/cloud-init.log
          - /var/log/cloud-init-output.log
          - /var/log/syslog
          - /var/log/auth.log
          - /var/log/docker.log
        diagnostic_output_dir: "/tmp/diagnostics"
        compress_output: true
        generate_report: true
        enable_monitoring_tools: true
        performance_testing: true
        network_diagnostics: true
        service_analysis: true
        automated_remediation: false # Enable cautiously
        retain_diagnostics_days: 7
```

### Targeted Diagnostics

```yaml
- name: Network-Specific Diagnostics
  hosts: network_issues
  roles:
    - role: vm_diagnostics
      vars:
        diagnostic_categories: ["network"]
        network_tests:
          - connectivity
          - dns_resolution
          - routing_table
          - firewall_rules
          - bandwidth_test
        network_targets:
          - "8.8.8.8"
          - "github.com"
          - "registry.internal.com"
```

## Variables

See `defaults/main.yml` for all configurable variables including:

- Diagnostic categories and depth settings
- Log collection paths and retention policies
- Performance testing parameters
- Network diagnostic targets
- Report generation options
- Monitoring integration settings

## Dependencies

- nodiscc.xsrv (optional, for comprehensive monitoring)
- deltabg.extended_facts (for hardware diagnostics)
- community.general >= 8.0.0
- ansible.posix >= 1.5.0
- System tools: htop, nethogs, ncdu, lnav, lynis, bonnie++
- Python libraries: psutil, python-netaddr

## Testing

This role includes comprehensive testing scenarios:

```bash
# Run diagnostics tests
molecule test

# Test specific diagnostic category
molecule converge -s system-diagnostics
molecule converge -s network-diagnostics
molecule converge -s performance-analysis
```

## Integration

Designed to integrate with:

- VM deployment and provisioning workflows
- Monitoring systems (Prometheus, Grafana, Netdata)
- Alerting and incident response systems
- Log aggregation platforms (Loki, ELK Stack)
- Automated remediation systems

## Migration Notes

This role replaces the following manual operations:

- Direct SSH commands for system diagnostics
- Manual log file analysis and collection
- Shell-based network troubleshooting
- Manual service status checking
- Ad-hoc performance testing

All operations are now:

- ✅ **Systematic**: Comprehensive diagnostic workflows
- ✅ **Automated**: Repeatable diagnostic procedures
- ✅ **Structured**: JSON/YAML output for analysis
- ✅ **Integrated**: Works with monitoring and alerting
- ✅ **Historical**: Trend analysis and historical data

## Diagnostic Categories

### System Category

- Hardware inventory and health
- Resource utilization analysis
- Kernel configuration validation
- Boot sequence analysis
- File system health checking

### Network Category

- Connectivity testing
- DNS resolution validation
- Routing table analysis
- Firewall rule verification
- Bandwidth and latency testing

### Services Category

- Service status monitoring
- Configuration file validation
- Dependency analysis
- Performance metrics collection
- Error log analysis

### Logs Category

- Multi-source log collection
- Error pattern detection
- Historical trend analysis
- Log rotation validation
- Cloud-init diagnostics

### Performance Category

- CPU, memory, and I/O analysis
- Resource trend monitoring
- Bottleneck identification
- Performance benchmarking
- Capacity planning data

### Troubleshooting Category

- Automated issue detection
- Common problem remediation
- Diagnostic report generation
- Remediation recommendation
- Integration with monitoring

## Security Considerations

- Log collection respects file permissions and privacy
- Diagnostic output is secured with appropriate permissions
- Network testing avoids potentially disruptive operations
- Automated remediation requires explicit enablement
- All diagnostic data is retained according to policy

## Performance Impact

- Diagnostic operations designed to minimize system impact
- Performance testing can be resource-intensive (configurable)
- Log collection uses efficient streaming methods
- Historical data collection optimized for minimal overhead
- Real-time monitoring integration available for ongoing diagnostics
