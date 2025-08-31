# Docker and Firewall Compatibility

## Important: Docker requires iptables, not nftables

Docker is **not compatible** with pure nftables firewall rules. According to the official Docker documentation:

> Docker is only compatible with `iptables-nft` and `iptables-legacy`.
> Firewall rules created with `nft` are not supported on a system with Docker installed.

## How Docker manages firewall rules

Docker automatically creates and manages several iptables chains:

- `DOCKER` - Docker's automatic rules for container networking
- `DOCKER-ISOLATION` - Isolates containers from each other
- `DOCKER-USER` - Where custom rules should be added

## Adding custom firewall rules

If you need to add custom firewall rules that affect Docker containers:

1. Add them to the `DOCKER-USER` chain, not the default chains
1. Use `iptables` or `ip6tables` commands
1. Do NOT use `nft` commands directly

Example:

```bash
# Block container access from specific IP
iptables -I DOCKER-USER -s 192.168.1.100 -j DROP

# Allow container access only from specific subnet
iptables -I DOCKER-USER -s 192.168.10.0/24 -j ACCEPT
iptables -A DOCKER-USER -j DROP
```

## Firewall persistence

Rules are saved using `iptables-persistent` and `netfilter-persistent` packages,
which are installed automatically during provisioning.

## Security notes

- Initial setup is permissive to ensure connectivity
- Production hardening will be applied via Ansible
- SSH (port 22) is always allowed for management access
- Docker manages its own port exposures through its chains

## References

- [Docker and iptables](https://docs.docker.com/engine/network/packet-filtering-firewalls/)
- [Docker Installation - Firewall limitations](https://docs.docker.com/engine/install/ubuntu/#firewall-limitations)
