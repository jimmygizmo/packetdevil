---
title: "Scenario: Single-WAN Home Lab (Baseline)"
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - RouterOS 7.x
  - Debian 12 / Ubuntu 22.04+
owner_domain: architecture
---

# Scenario: Single-WAN Home Lab (Baseline)

## Summary

One RB5009, one WAN interface, one Linux box running `tzsp2pcap` +
Suricata + `packetdevil` on the same host. This is the reference
deployment the numbered [docs/setup/](../setup/) guides describe directly
— this scenario doc exists mainly as an index/checklist, not new content.

## When to use this scenario

Default choice for a single-internet-connection home or small-office lab
with one dedicated (or virtualized) Linux box available.

## Topology

See [docs/architecture/network-topology.md](../architecture/network-topology.md)
"Baseline topology" section — unchanged for this scenario.

## Build order

1. [docs/setup/00-prerequisites.md](../setup/00-prerequisites.md)
2. [docs/setup/01-mikrotik-rb5009-port-mirroring.md](../setup/01-mikrotik-rb5009-port-mirroring.md)
3. [docs/setup/02-linux-dummy-interface.md](../setup/02-linux-dummy-interface.md)
4. [docs/setup/03-tzsp2pcap-install.md](../setup/03-tzsp2pcap-install.md)
5. [docs/setup/04-suricata-install.md](../setup/04-suricata-install.md)
6. [docs/setup/05-python-app-install.md](../setup/05-python-app-install.md)
7. [docs/setup/06-telegram-bot-setup.md](../setup/06-telegram-bot-setup.md)

## Deltas from baseline

None — this scenario *is* the baseline.

## See also

- [docs/scenarios/scenario-dual-wan-failover.md](scenario-dual-wan-failover.md)
- [docs/scenarios/scenario-high-traffic-tuning.md](scenario-high-traffic-tuning.md)
