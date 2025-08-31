# ADR-2024-08-30: Separate Files for Terraform-Injected Configurations

![Status](https://img.shields.io/badge/Status-Accepted-green)
![Date](https://img.shields.io/badge/Date-2024--08--30-lightgrey)
![GitHub last commit](https://img.shields.io/github/last-commit/basher83/Sombrero-Edge-Control?path=docs%2Fdecisions%2FADR-2024-08-30-separate-files-terraform-injection.md&display_timestamp=author&style=plastic&logo=github)

## Status

Accepted

## Context

Currently, configuration files (nftables rules, README documentation) are embedded directly within cloud-init YAML
files using heredoc syntax (cat > file << EOF). This approach mixes different file types and syntaxes within a
single YAML file, making them difficult to maintain, validate, and version control effectively.

As the infrastructure grows and more complex configurations are needed, this embedded approach becomes increasingly problematic:

- No proper syntax highlighting for embedded configs
- Difficult to validate nftables rules independently
- YAML escaping issues with special characters
- Poor diff visibility in version control
- Cannot reuse configurations across different VM types

## Decision

We will extract configuration files from cloud-init YAML and maintain them as separate files in the repository,
then inject them into Terraform using the `templatefile()` function. This creates a clean separation of concerns
and improves maintainability.

Directory structure:

```text
infrastructure/environments/production/
├── files/
│   ├── nftables/
│   │   └── jump-host.nft
│   ├── docs/
│   │   └── jump-host-readme.md
│   └── scripts/
│       └── docker-install.sh
└── cloud-init.jump-man.yaml
```

The cloud-init will reference these files through Terraform's `write_files` section with content injected via variables.

## Consequences

### Positive

- **Better developer experience**: Each file type gets proper IDE support, syntax highlighting, and linting
- **Improved validation**: Can validate nftables rules with `nft -c -f`, preview markdown, shellcheck scripts
- **Cleaner version control**: Diffs show actual config changes, not YAML formatting changes
- **Reusability**: Configurations can be shared across different VM types or environments
- **Templating support**: Can use Terraform variables within configs using `templatefile()`
- **Modularity**: Easy to compose different configurations for different VM roles
- **Testing**: Can unit test configurations independently

### Negative

- **Additional complexity**: More files to manage in the repository
- **Indirection**: Need to look in multiple places to understand full VM configuration
- **Template syntax**: Developers need to understand Terraform template syntax for variable substitution

### Risks

- **Path management**: Need to ensure relative paths are correct when referencing files
- **Large files**: Very large configuration files might hit cloud-init size limits
- **Template errors**: Malformed templates could cause runtime failures

## Alternatives Considered

### Alternative 1: Keep Embedded Configurations (Current Approach)

- **Description**: Continue embedding all configurations directly in cloud-init YAML using heredoc syntax
- **Why we didn't choose it**: Poor maintainability, no syntax validation, difficult to reuse, messy version control

### Alternative 2: Configuration Management Tool

- **Description**: Use Ansible, Puppet, or Chef to configure VMs post-deployment instead of cloud-init
- **Why we didn't choose it**: Adds operational complexity, requires additional infrastructure, delays initial VM readiness

### Alternative 3: Custom VM Images

- **Description**: Bake configurations directly into VM images using Packer
- **Why we didn't choose it**: Reduces flexibility, requires image rebuild for config changes, increases maintenance overhead

## Implementation

Key steps to implement this decision:

1. Create directory structure under `infrastructure/environments/production/files/`
1. Extract embedded configurations from `cloud-init.jump-man.yaml` into separate files:
   - `files/nftables/jump-host.nft` - nftables rules
   - `files/docs/jump-host-readme.md` - README for jump host
1. Update VM module to support template file injection:

   ```hcl
   vendor_data_content = templatefile("${path.module}/cloud-init.jump-man.yaml", {
     nftables_config = file("${path.module}/files/nftables/jump-host.nft")
     readme_content  = file("${path.module}/files/docs/jump-host-readme.md")
   })
   ```

1. Modify cloud-init.yaml to use injected variables in `write_files` section
1. Add validation steps to CI/CD pipeline for configuration files
1. Document the new pattern in infrastructure README

## References

- [Terraform templatefile function documentation](https://www.terraform.io/language/functions/templatefile)
- [Cloud-init write_files module](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files)
- [Best practices for cloud-init configurations](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)
