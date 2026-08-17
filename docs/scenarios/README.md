# Scenarios

## Purpose

Each doc in this directory describes one **complete, end-to-end deployment
configuration** — a specific combination of topology, hardware, and tuning
choices. The numbered guides in [docs/setup/](../setup/) describe the
*baseline* single-WAN, single-Linux-box path; scenarios document variants
and non-default configurations without cluttering the baseline docs with
conditionals.

## Why scenarios are separated from setup docs

This project has many valid configurations (single vs dual WAN, tuning for
high-throughput links, multiple capture boxes, etc.). Mixing all variants
into the baseline setup docs makes them hard for an agent (or human) to
follow linearly and increases the chance of applying the wrong branch of
instructions. Instead: **setup docs are the default path; scenarios are
named, self-contained deltas/extensions on top of that path.**

## Index

| Scenario | Summary |
|---|---|
| [scenario-single-wan-home-lab.md](scenario-single-wan-home-lab.md) | The baseline deployment: one WAN, one RB5009, one Linux box. Fully worked reference matching `docs/setup/00`–`06`. |
| [scenario-dual-wan-failover.md](scenario-dual-wan-failover.md) | Two WAN interfaces with failover; mirroring/monitoring both. |
| [scenario-high-traffic-tuning.md](scenario-high-traffic-tuning.md) | Tuning Suricata/tzsp2pcap for high-throughput WAN links where the baseline config drops packets. |

## Adding a new scenario

1. Copy the structure of [scenario-single-wan-home-lab.md](scenario-single-wan-home-lab.md).
2. State clearly which baseline setup docs/steps it modifies or replaces,
   and which it leaves unchanged.
3. Add a row to the index table above.
4. If the scenario reveals a genuinely better default, consider updating
   the baseline setup docs instead of only documenting it as a variant —
   but do this deliberately, not as a side effect.
