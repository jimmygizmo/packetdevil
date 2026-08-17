---
title: tzsp2pcap Configuration Reference
status: draft
last_verified: 2026-08-16
applies_to:
  - tzsp2pcap
owner_domain: tzsp2pcap
---

# tzsp2pcap Configuration Reference

## Purpose

Documents runtime configuration for our vendored + patched `tzsp2pcap`
build (see [vendor/tzsp2pcap/README.md](../../vendor/tzsp2pcap/README.md)
and [ADR 0001](../architecture/decisions/0001-tzsp2pcap-fork-strategy.md)).

## Configuration surface

| Setting | Purpose | Default (upstream) | This project's default |
|---|---|---|---|
| Listen UDP port | Port RouterOS TZSP streams arrive on | `37008` | `37008` (unchanged) |
| Output mode | Where decapsulated frames go: interface / FIFO / pcap file | interface | local `dummy0` interface |
| Output target | Interface name / file path | — | `dummy0` |
| Bind address | Local address to listen for TZSP UDP on | `0.0.0.0` | `0.0.0.0` (restrict via host firewall instead — see [linux-commands.md](linux-commands.md)) |

See [configs/tzsp2pcap/tzsp2pcap.conf.example](../../configs/tzsp2pcap/tzsp2pcap.conf.example)
for the exact file format once the patch adding config-file support (or CLI
flags) lands — track this in `vendor/tzsp2pcap/patches/`.

## Our patches (summary — see vendor README for the authoritative list)

Patches are numbered and stored in
[vendor/tzsp2pcap/patches/](../../vendor/tzsp2pcap/patches/). Do not
describe patch *content* in more than one place — this doc only points to
them; the patch files and their one-line description files are ground
truth.

## Verifying configuration is correct

```bash
sudo tcpdump -ni dummy0 -c 10
```
See [docs/setup/03-tzsp2pcap-install.md](../setup/03-tzsp2pcap-install.md)
for the full verification procedure.

## See also

- [vendor/tzsp2pcap/README.md](../../vendor/tzsp2pcap/README.md)
- [docs/architecture/decisions/0001-tzsp2pcap-fork-strategy.md](../architecture/decisions/0001-tzsp2pcap-fork-strategy.md)
