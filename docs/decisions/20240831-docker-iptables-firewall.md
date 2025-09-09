# Use iptables Instead of nftables for Docker Compatibility

- Status: accepted
- Date: 2024-08-31
- Tags: docker, firewall, iptables, nftables

## Context and Problem Statement

While implementing the jump host infrastructure with Docker support, we discovered a critical compatibility issue: Docker does not support pure nftables firewall rules. According to Docker's official documentation, Docker is only compatible with `iptables-nft` and `iptables-legacy`. Firewall rules created with the `nft` command are not supported on systems with Docker installed.

Initially, our cloud-init configuration included nftables setup, which would have caused Docker networking to malfunction or firewall rules to be bypassed entirely, creating security vulnerabilities.

## Decision Outcome

Chosen option: "Use iptables for firewall management", because we needed to ensure full Docker compatibility while maintaining security, and iptables provides the necessary compatibility layer that pure nftables cannot offer.

### Positive Consequences

- **Docker compatibility**: Full compatibility with Docker's automatic network management
- **Security maintained**: Docker's port exposure and isolation features work correctly
- **Official support**: Following Docker's recommended approach ensures long-term stability
- **Clear documentation**: Team members understand the constraint and proper rule placement
- **Automatic management**: Docker handles its own chains (DOCKER, DOCKER-ISOLATION, DOCKER-USER)

### Negative Consequences

- **Legacy technology**: iptables is older than nftables (though `iptables-nft` uses nftables backend)
- **Learning curve**: Team members familiar with nftables syntax must learn iptables
- **Less modern features**: Some advanced nftables features are not available
- **Docker lock-in**: This decision ties our firewall choice to Docker's requirements

## Considered Options

### Pure nftables with Docker workarounds

**Description**: Use nftables and attempt various workarounds for Docker compatibility

- Good, because: Modern firewall technology with advanced features
- Good, because: Familiar syntax for team members
- Bad, because: Officially unsupported by Docker
- Bad, because: Likely to break with Docker updates
- Bad, because: Creates security vulnerabilities through bypassed rules

### Podman with nftables

**Description**: Replace Docker with Podman, which has better nftables support

- Good, because: Better nftables compatibility
- Good, because: Alternative container runtime option
- Bad, because: Docker is a project requirement
- Bad, because: Podman has different ecosystem and tooling
- Bad, because: Requires testing and validation of entire container strategy

### Disable firewall entirely

**Description**: Rely solely on network segmentation and external firewalls

- Good, because: Simplifies infrastructure configuration
- Good, because: No compatibility issues with container runtimes
- Bad, because: Reduces defense-in-depth security approach
- Bad, because: Violates security best practices
- Bad, because: Increases reliance on external network controls

### Separate Docker and firewall hosts

**Description**: Run Docker on different VMs than those with strict firewall requirements

- Good, because: Allows use of preferred firewall technology
- Good, because: Isolates container runtime from firewall concerns
- Bad, because: Increases infrastructure complexity
- Bad, because: Defeats purpose of consolidated jump host
- Bad, because: Requires additional VMs and resources

## Links

- [Docker Documentation - Firewall limitations](https://docs.docker.com/engine/install/ubuntu/#firewall-limitations)
- [Docker and iptables](https://docs.docker.com/engine/network/packet-filtering-firewalls/)
- [Docker Installation for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
