---
title: "Scenario: High-Traffic Tuning"
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
  - tzsp2pcap
owner_domain: suricata
---

# Scenario: High-Traffic Tuning

## Summary

Adjustments needed when the baseline configuration shows Suricata dropping
packets (`capture.kernel_drops` rising in EVE `stats` — see
[docs/operations/monitoring.md](../operations/monitoring.md)) under
sustained high WAN throughput.

## When to use this scenario

You've confirmed (via monitoring) that packet drops correlate with traffic
volume, not a misconfiguration — start with
[docs/operations/troubleshooting.md](../operations/troubleshooting.md)
first to rule out simpler causes.

## Deltas from baseline

- **Multiple `af-packet` capture threads**, matching available CPU cores:
  ```yaml
  af-packet:
    - interface: dummy0
      threads: 4
      cluster-id: 99
      cluster-type: cluster_flow
  ```
- **Ruleset trimming**: disable rule categories irrelevant to a home/SMB
  environment (e.g. mainframe/SCADA protocol rules) to reduce per-packet
  inspection cost — document exactly which categories are disabled and
  why, since this is a detection-coverage tradeoff.
- **`tzsp2pcap` throughput**: confirm it isn't the bottleneck before
  tuning Suricata — check for drops/errors in its own logs
  (`journalctl -u tzsp2pcap`) and consider whether a patch adding
  multi-threaded decapsulation is warranted (would need a new entry under
  [vendor/tzsp2pcap/patches/](../../vendor/tzsp2pcap/patches/) and an ADR
  if it's a significant design change).
- **Hardware**: if tuning alone doesn't resolve drops, the Linux box is
  undersized for the WAN link — document actual measured throughput
  requirements here once known, rather than guessing a number in advance.

## Verification

Re-check `capture.kernel_drops` in EVE `stats` over a representative
traffic period (e.g. an evening peak-usage window) after each change,
changing one variable at a time.

## See also

- [docs/reference/suricata-config-reference.md](../reference/suricata-config-reference.md)
- [docs/operations/monitoring.md](../operations/monitoring.md)
