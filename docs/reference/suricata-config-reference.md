---
title: Suricata Configuration Reference
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
owner_domain: suricata
---

# Suricata Configuration Reference

## Purpose

Documents the specific `suricata.yaml` settings this project relies on
(capture interface, EVE output, performance tuning knobs) beyond what
[docs/setup/04-suricata-install.md](../setup/04-suricata-install.md)
covers as a linear walkthrough.

## Capture configuration

```yaml
af-packet:
  - interface: dummy0
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
```

`dummy` interfaces don't support all `af-packet` features (e.g. some
offload-related options) — if Suricata logs warnings about unsupported
socket options on `dummy0`, they are expected and non-fatal; do not disable
core detection features to silence them without checking
[docs/operations/troubleshooting.md](../operations/troubleshooting.md) first.

## EVE JSON output (integration point for the Python app)

```yaml
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
      types:
        - alert:
            tagged-packets: yes
            metadata: yes
```

`packetdevil`'s `suricata_eve.py` parses `event_type: alert` records and
expects these fields to be present: `timestamp`, `src_ip`, `src_port`,
`dest_ip`, `dest_port`, `proto`, `alert.signature`, `alert.signature_id`,
`alert.category`, `alert.severity`. Do not remove `metadata`/fields the app
depends on without updating
[src/packetdevil/packetdevil/suricata_eve.py](../../src/packetdevil/packetdevil/suricata_eve.py)
in the same change.

## Ruleset

Managed via `suricata-update` (Emerging Threats Open by default). Document
any additional/custom ruleset sources here as they're added, including
license terms.

## Performance sizing notes

- Suricata's CPU/memory needs scale with sustained WAN throughput, not
  peak burst — size the Linux box for your actual ISP plan's throughput.
- Symptoms of an undersized box: `stats.log` / EVE `stats` events showing
  nonzero `capture.kernel_drops`; see
  [docs/operations/monitoring.md](../operations/monitoring.md) for what to
  watch, and
  [docs/scenarios/scenario-high-traffic-tuning.md](../scenarios/scenario-high-traffic-tuning.md)
  for tuning (multiple `af-packet` threads, `cluster-type`, rule
  optimization).

## See also

- [configs/suricata/suricata.yaml.example](../../configs/suricata/suricata.yaml.example)
- [docs/architecture/data-flow.md](../architecture/data-flow.md)
