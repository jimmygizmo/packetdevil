---
title: RouterOS Command Reference
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - RouterOS 7.x
owner_domain: routeros
---

# RouterOS Command Reference

## Purpose

Canonical, documented reference for every RouterOS command this project
uses, organized by task. Setup guides link here instead of re-explaining
RouterOS syntax; scripts (`.rsc`) should also link back here in comments.

## Reading/inspection commands (safe, read-only)

```routeros
/system resource print
/interface print
/interface ethernet switch port print
/ip firewall filter print
/ip firewall address-list print
/tool sniffer print
/log print
```

## Port mirroring / traffic capture (mutating — see blast radius notes)

```routeros
# Blast radius: affects hardware offload on the named port; read-heavy CPU use for /tool sniffer streaming
/interface ethernet switch port set [find where name="<WAN_INTERFACE>"] mirror-source=yes
/interface ethernet switch set 0 mirror-target=<TARGET>
```

```routeros
# Blast radius: continuous CPU use on the router while streaming is enabled
/tool sniffer set streaming-enabled=yes streaming-server=<SURICATA_HOST_IP> filter-interface=<WAN_INTERFACE>
/tool sniffer start
/tool sniffer stop
/tool sniffer set streaming-enabled=no
```

See [docs/setup/01-mikrotik-rb5009-port-mirroring.md](../setup/01-mikrotik-rb5009-port-mirroring.md)
for full context and verification steps.

## Firewall rule management (mutating — used by the Python app)

The Python app manages rules via the REST API (see
[firewall-api-reference.md](firewall-api-reference.md)), but the equivalent
CLI commands are documented here for manual testing/debugging:

```routeros
# Blast radius: blocks all traffic to/from the given address immediately
/ip firewall filter add chain=forward src-address=<IP> action=drop comment="packetdevil:block:<alert-id>"
```

```routeros
# Remove a specific packetdevil-created rule by its comment tag
/ip firewall filter remove [find where comment="packetdevil:block:<alert-id>"]
```

```routeros
# List only packetdevil-created rules (for auditing/cleanup)
/ip firewall filter print where comment~"packetdevil:"
```

> All `packetdevil`-created rules **must** carry the `packetdevil:` comment
> prefix — this is how the cleanup task finds and expires them, and how a
> human can distinguish automated rules from manually created ones at a
> glance.

## Enabling the REST API

```routeros
# Blast radius: exposes a management API — restrict source addresses!
/ip service set www-ssl disabled=no certificate=<CERT_NAME>
/ip service set api-ssl disabled=no
```
See [firewall-api-reference.md](firewall-api-reference.md) for the full,
security-reviewed setup (TLS, dedicated low-privilege API user, source
address restriction).

## Destructive commands — never run without explicit human confirmation

```routeros
# DESTRUCTIVE — do not run from docs/scripts without explicit human request
/system reset-configuration
/ip firewall filter remove [find]   # removes ALL firewall rules, not just packetdevil's
```

## See also

- [docs/reference/firewall-api-reference.md](firewall-api-reference.md)
- [docs/setup/01-mikrotik-rb5009-port-mirroring.md](../setup/01-mikrotik-rb5009-port-mirroring.md)
- [.github/instructions/routeros.instructions.md](../../.github/instructions/routeros.instructions.md)
