# ADR-2024-08-31: Use iptables Instead of nftables for Docker Compatibility

![Status](https://img.shields.io/badge/Status-Accepted-green)
![Date](https://img.shields.io/badge/Date-2024--08--31-lightgrey)
![GitHub last commit](https://img.shields.io/github/last-commit/basher83/Sombrero-Edge-Control?path=docs%2Fdecisions%2FADR-2024-08-31-docker-iptables-firewall.md&display_timestamp=author&style=plastic&logo=github)

## Status

Accepted

## Context

While implementing the jump host infrastructure with Docker support, we discovered a critical compatibility issue:
Docker does not support pure nftables firewall rules. According to Docker's official documentation, Docker is only
compatible with `iptables-nft` and `iptables-legacy`. Firewall rules created with the `nft` command are not supported
on systems with Docker installed.

Initially, our cloud-init configuration included nftables setup, which would have caused Docker networking to
malfunction or firewall rules to be bypassed entirely, creating security vulnerabilities.

## Decision

We will use iptables (specifically `iptables-nft`) for firewall management on the jump host VM instead of pure nftables.
This ensures full compatibility with Docker's networking stack while maintaining security.

Key implementation details:

- Remove all pure nftables configurations
- Use iptables commands for firewall rules
- Install `iptables-persistent` for rule persistence
- Follow Docker's official installation method exactly
- Document that custom rules must be added to the `DOCKER-USER` chain

## Consequences

### Positive

- **Docker compatibility**: Full compatibility with Docker's automatic network management
- **Security maintained**: Docker's port exposure and isolation features work correctly
- **Official support**: Following Docker's recommended approach ensures long-term stability
- **Clear documentation**: Team members understand the constraint and proper rule placement
- **Automatic management**: Docker handles its own chains (DOCKER, DOCKER-ISOLATION, DOCKER-USER)

### Negative

- **Legacy technology**: iptables is older than nftables (though `iptables-nft` uses nftables backend)
- **Learning curve**: Team members familiar with nftables syntax must learn iptables
- **Less modern features**: Some advanced nftables features are not available
- **Docker lock-in**: This decision ties our firewall choice to Docker's requirements

### Risks

- **Migration complexity**: If Docker adds nftables support in the future, migration might be needed
- **Rule conflicts**: Improperly placed rules could be bypassed by Docker's chains
- **Debugging complexity**: Understanding interaction between Docker's automatic rules and custom rules

## Alternatives Considered

### Alternative 1: Pure nftables with Docker workarounds

- **Description**: Use nftables and attempt various workarounds for Docker compatibility
- **Why we didn't choose it**: Officially unsupported by Docker, likely to break with updates, security risks

### Alternative 2: Podman with nftables

- **Description**: Replace Docker with Podman, which has better nftables support
- **Why we didn't choose it**: Docker is a project requirement, Podman has different ecosystem/tooling

### Alternative 3: Disable firewall entirely

- **Description**: Rely solely on network segmentation and external firewalls
- **Why we didn't choose it**: Reduces defense-in-depth, violates security best practices

### Alternative 4: Separate Docker and firewall hosts

- **Description**: Run Docker on different VMs than those with strict firewall requirements
- **Why we didn't choose it**: Increases infrastructure complexity, defeats purpose of consolidated jump host

## Implementation

Key steps to implement this decision:

1. Remove nftables package from cloud-init packages list
1. Replace with iptables and iptables-persistent packages
1. Create firewall setup script using iptables commands
1. Ensure Docker installation follows official Ubuntu documentation
1. Document the DOCKER-USER chain for custom rules
1. Add comprehensive documentation about the compatibility issue
1. Update cloud-init to execute scripts in correct order

## References

- [Docker Documentation - Firewall limitations](https://docs.docker.com/engine/install/ubuntu/#firewall-limitations)
- [Docker and iptables](https://docs.docker.com/engine/network/packet-filtering-firewalls/)
- [Docker Installation for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Issue discovered during implementation](https://github.com/basher83/Sombrero-Edge-Control/discussions) (if applicable)
