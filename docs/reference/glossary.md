---
title: Glossary
status: verified
last_verified: 2026-08-16
applies_to: []
owner_domain: architecture
---

# Glossary

| Term | Meaning |
|---|---|
| **RB5009** | MikroTik RB5009UG+S+IN, the router hardware used as the primary WAN gateway in this project. |
| **RouterOS** | MikroTik's router operating system (v7.x targeted here). |
| **TZSP** | TaZmen Sniffer Protocol — a simple encapsulation format (UDP-based, default port 37008) RouterOS uses to send mirrored/sniffed packets to a remote collector. |
| **Port mirroring / traffic mirroring** | Duplicating traffic seen on one interface to another destination (physical port or remote host) without affecting the original traffic's path. |
| **`tzsp2pcap`** | Third-party tool (vendored + patched in this repo) that receives TZSP UDP packets and re-emits the original frames as pcap / onto a local interface. |
| **`dummy` interface** | A Linux virtual network interface (kernel `dummy` driver) with no real hardware backing, used here purely as a local capture target for Suricata. |
| **Suricata** | Open-source IDS/IPS/NSM engine that inspects traffic against signature rules and protocol anomaly detection. |
| **EVE JSON (`eve.json`)** | Suricata's structured JSON log output format; `event_type: alert` records are what `packetdevil` consumes. |
| **IDS vs IPS** | IDS (Intrusion *Detection* System) passively observes and alerts; IPS (Intrusion *Prevention* System) sits inline and can drop traffic directly. This project runs Suricata as an IDS (see [ADR 0002](../architecture/decisions/0002-suricata-deployment.md)) with out-of-band active response. |
| **`packetdevil`** | This project's custom Python application: tails `eve.json`, decides on actions, calls the RouterOS firewall API, sends Telegram alerts. |
| **Temporary firewall rule** | A RouterOS `/ip firewall filter` (or `/ip/firewall/filter` REST) rule created by `packetdevil` with an attached TTL/expiry, auto-removed after a set duration rather than persisting indefinitely. |
| **C2 / phone-home** | "Command and control" traffic — a compromised host contacting an attacker-controlled server; among the highest-severity alert categories that trigger both a block and a Telegram notification. |
| **ADR** | Architecture Decision Record — see [docs/architecture/decisions/](../architecture/decisions/). |
| **Scenario doc** | A doc under `docs/scenarios/` describing one complete, end-to-end deployment configuration/variant (e.g. dual-WAN). |

## Adding new terms

If you (human or agent) had to guess or infer the meaning of a
project-specific term while working, add it here immediately afterward.
