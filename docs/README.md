# docs/ — Documentation Index

## Purpose

This is the map of all project documentation. Before writing a new doc,
check here for an existing owner of that topic and update it instead.
Before trusting a doc, check its front matter `status` (see
[.github/instructions/markdown.instructions.md](../.github/instructions/markdown.instructions.md)).

## Start here

- [../AGENTS.md](../AGENTS.md) — primary entry point for any agent working
  in this repo.
- [architecture/overview.md](architecture/overview.md) — what the system
  is and why, before touching setup/config.

## architecture/ — system design

| Doc | Covers |
|---|---|
| [overview.md](architecture/overview.md) | Components, why this design, high-level diagram. |
| [network-topology.md](architecture/network-topology.md) | Physical/logical interface layout, RB5009 + Linux box. |
| [data-flow.md](architecture/data-flow.md) | Packet path and alert path, end to end, with failure-mode notes. |
| [decisions/](architecture/decisions/) | ADRs — why significant choices were made (tzsp2pcap strategy, passive IDS deployment, etc.). |

## setup/ — ordered build-out guides

Follow in order for the baseline single-WAN scenario (each links to the
next):

| # | Doc | Covers |
|---|---|---|
| 00 | [prerequisites.md](setup/00-prerequisites.md) | Hardware/software/access needed before starting. |
| 01 | [mikrotik-rb5009-port-mirroring.md](setup/01-mikrotik-rb5009-port-mirroring.md) | RouterOS TZSP mirror configuration. |
| 02 | [linux-dummy-interface.md](setup/02-linux-dummy-interface.md) | `dummy0` capture interface. |
| 03 | [tzsp2pcap-install.md](setup/03-tzsp2pcap-install.md) | Build/install vendored `tzsp2pcap`. |
| 04 | [suricata-install.md](setup/04-suricata-install.md) | Suricata install, capture config, EVE output. |
| 05 | [python-app-install.md](setup/05-python-app-install.md) | `packetdevil` app install (via `uv`) and systemd unit. |
| 06 | [telegram-bot-setup.md](setup/06-telegram-bot-setup.md) | Telegram bot creation for severe-alert notifications. |

## reference/ — command and config references

| Doc | Covers |
|---|---|
| [routeros-commands.md](reference/routeros-commands.md) | Every RouterOS command used, by task, with blast-radius notes. |
| [linux-commands.md](reference/linux-commands.md) | Every Linux command used, by task. |
| [suricata-config-reference.md](reference/suricata-config-reference.md) | `suricata.yaml` settings this project relies on, sizing notes. |
| [tzsp2pcap-config-reference.md](reference/tzsp2pcap-config-reference.md) | `tzsp2pcap` runtime configuration surface. |
| [firewall-api-reference.md](reference/firewall-api-reference.md) | RouterOS REST API setup + contract the Python client relies on. |
| [glossary.md](reference/glossary.md) | Every project-specific term, defined once. |

## operations/ — running it day to day

| Doc | Covers |
|---|---|
| [monitoring.md](operations/monitoring.md) | What to watch, per component, and what healthy looks like. |
| [troubleshooting.md](operations/troubleshooting.md) | Symptom-indexed troubleshooting across the whole pipeline. |
| [testing.md](operations/testing.md) | Manual/ad-hoc detection validation scripts (e.g. simulated port scans) and how to run them safely. |
| [runbooks/](operations/runbooks/) | Restart Suricata, rotate logs, update rules, incident response. |

## scenarios/ — deployment variants

| Doc | Covers |
|---|---|
| [scenario-single-wan-home-lab.md](scenarios/scenario-single-wan-home-lab.md) | Baseline deployment (matches `setup/` docs directly). |
| [scenario-dual-wan-failover.md](scenarios/scenario-dual-wan-failover.md) | Two WAN interfaces with failover. |
| [scenario-high-traffic-tuning.md](scenarios/scenario-high-traffic-tuning.md) | Tuning for high-throughput WAN links. |

## Other topic-owning docs outside `docs/`

| Doc | Covers |
|---|---|
| [../vendor/tzsp2pcap/README.md](../vendor/tzsp2pcap/README.md) | Vendoring/patching procedure for `tzsp2pcap`. |
| [../src/packetdevil/README.md](../src/packetdevil/README.md) | Python app dev workflow (`uv`, tests, layout). |
| [../configs/README.md](../configs/README.md) | Config template conventions. |
| [../scripts/README.md](../scripts/README.md) | Helper script conventions. |
| [../scripts/linux/tests/README.md](../scripts/linux/tests/README.md) | Unified Python simulation runner and setup workflow for internal/external validation traffic. |

## Maintenance rule

Whenever a doc is added, moved, or removed anywhere in this repo, update
this index in the same change.
