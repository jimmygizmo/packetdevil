---
title: "Scenario: Dual-WAN Failover"
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - RouterOS 7.x
owner_domain: routeros
---

# Scenario: Dual-WAN Failover

## Summary

RB5009 configured with two WAN interfaces (e.g. primary fiber + LTE/cable
backup) using RouterOS failover (e.g. `netwatch`-based or recursive
routing with distance metrics). Both WAN interfaces must be mirrored so
Suricata retains visibility regardless of which link is currently active.

## When to use this scenario

You have two internet connections configured for failover/load balancing
and need detection coverage on both, not just the primary.

## Deltas from baseline

- **Topology**: mirror **both** WAN interfaces (e.g. `ether1` and
  `ether2`) to the same Linux box, or note in your own fork of this
  scenario if you use separate collectors.
  ```routeros
  # Mutates: RB5009 — mirrors a second WAN-facing interface in addition to the primary
  /interface ethernet switch port set [find where name="<WAN_INTERFACE_2>"] mirror-source=yes
  ```
  If using `/tool sniffer` streaming instead of switch-chip mirroring,
  note that `filter-interface` accepts only one interface at a time in
  some RouterOS versions — verify on your firmware and document the
  actual working approach here once tested (currently `status: draft`).
- **Suricata**: add a second `af-packet` capture interface (a second
  `dummy` interface, e.g. `dummy1`, fed by a second `tzsp2pcap` instance
  bound to a second UDP port, or by extending `tzsp2pcap` to accept
  traffic from two sources onto one output — decide and record this
  choice here once implemented).
- **`packetdevil`**: no changes required — it only consumes `eve.json`,
  which already aggregates alerts regardless of which capture interface
  produced them.

## Open questions (resolve before marking this scenario `verified`)

- Does the RB5009 switch chip support mirroring two source ports to the
  same target simultaneously, or is a second physical mirror port/stream
  needed?
- Should failover state (which WAN is currently active) be exposed to
  `packetdevil` so it can tag alerts by originating link? Not implemented
  yet — would require an ADR if pursued.

## See also

- [docs/scenarios/scenario-single-wan-home-lab.md](scenario-single-wan-home-lab.md)
- [docs/architecture/network-topology.md](../architecture/network-topology.md)
