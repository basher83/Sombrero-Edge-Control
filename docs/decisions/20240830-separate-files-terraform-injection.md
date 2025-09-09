# Separate Files for Terraform-Injected Configurations

- Status: accepted
- Date: 2024-08-30
- Tags: terraform, configuration, infrastructure

## Context and Problem Statement

Currently, configuration files (nftables rules, README documentation) are embedded directly within cloud-init YAML files using heredoc syntax (cat > file << EOF). This approach mixes different file types and syntaxes within a single YAML file, making them difficult to maintain, validate, and version control effectively.

As the infrastructure grows and more complex configurations are needed, this embedded approach becomes increasingly problematic:

- No proper syntax highlighting for embedded configs
- Difficult to validate nftables rules independently
- YAML escaping issues with special characters
- Poor diff visibility in version control
- Cannot reuse configurations across different VM types

## Decision Outcome

Chosen option: "Separate configuration files with Terraform injection", because we needed a clean separation of concerns that would improve maintainability while preserving the benefits of Terraform's templating capabilities.

### Positive Consequences

- **Better developer experience**: Each file type gets proper IDE support, syntax highlighting, and linting
- **Improved validation**: Can validate nftables rules with `nft -c -f`, preview markdown, shellcheck scripts
- **Cleaner version control**: Diffs show actual config changes, not YAML formatting changes
- **Reusability**: Configurations can be shared across different VM types or environments
- **Templating support**: Can use Terraform variables within configs using `templatefile()`
- **Modularity**: Easy to compose different configurations for different VM roles
- **Testing**: Can unit test configurations independently

### Negative Consequences

- **Additional complexity**: More files to manage in the repository
- **Indirection**: Need to look in multiple places to understand full VM configuration
- **Template syntax**: Developers need to understand Terraform template syntax for variable substitution

## Considered Options

### Keep Embedded Configurations (Current Approach)

**Description**: Continue embedding all configurations directly in cloud-init YAML using heredoc syntax

- Good, because: Simple to understand - everything in one place
- Good, because: No additional file management overhead
- Bad, because: Poor maintainability and validation capabilities
- Bad, because: Difficult to reuse configurations
- Bad, because: Messy version control diffs
- Bad, because: No syntax highlighting or linting

### Configuration Management Tool

**Description**: Use Ansible, Puppet, or Chef to configure VMs post-deployment instead of cloud-init

- Good, because: Excellent validation and testing capabilities
- Good, because: Industry-standard configuration management
- Bad, because: Adds operational complexity
- Bad, because: Requires additional infrastructure
- Bad, because: Delays initial VM readiness

### Custom VM Images

**Description**: Bake configurations directly into VM images using Packer

- Good, because: Configurations are immutable and tested
- Good, because: Fast deployment times
- Bad, because: Reduces flexibility for configuration changes
- Bad, because: Requires image rebuild for config updates
- Bad, because: Increases maintenance overhead

## Links

- [Terraform templatefile function documentation](https://www.terraform.io/language/functions/templatefile)
- [Cloud-init write_files module](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files)
- [Best practices for cloud-init configurations](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)
