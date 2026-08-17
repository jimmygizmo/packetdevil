---
title: Linux Dummy Interface Setup
status: draft
last_verified: 2026-08-16
applies_to:
  - Debian 12 / Ubuntu 22.04+
owner_domain: linux
---

# 02 — Linux Dummy Interface Setup

## Purpose

Create a persistent `dummy` network interface on the Suricata box that
`tzsp2pcap` writes decapsulated packets onto, and that Suricata captures
from — decoupling Suricata entirely from TZSP/UDP details.

## Prerequisites

- [01-mikrotik-rb5009-port-mirroring.md](01-mikrotik-rb5009-port-mirroring.md)
  completed and verified (TZSP packets arriving at the Linux box).

## Steps

1. **Load the `dummy` kernel module and create the interface.**
   ```bash
   # Mutates: Linux box network stack — adds a new virtual interface
   sudo modprobe dummy
   sudo ip link add dummy0 type dummy
   sudo ip link set dummy0 up
   ```

2. **Persist across reboots** via a systemd-networkd or netplan config
   (adjust for your init system — see
   [scripts/linux/setup-dummy-interface.sh](../../scripts/linux/setup-dummy-interface.sh)
   for an idempotent script version of steps 1–2 plus persistence).

3. **Confirm no IP address is needed** — `dummy0` is used purely as a
   capture target; it does not need routable addressing unless a specific
   scenario requires it.

## Verification

```bash
ip link show dummy0
# expect: state UP (or UNKNOWN, which is normal for dummy interfaces)
```

## Rollback / Undo

```bash
sudo ip link delete dummy0
```

## Troubleshooting

- Interface disappears after reboot: persistence step (2) wasn't applied —
  see the script referenced above.
- `RTNETLINK answers: File exists`: `dummy0` already exists; either reuse
  it or pick a different name consistently across all docs/config.

## Next

Continue to [03-tzsp2pcap-install.md](03-tzsp2pcap-install.md).

## See also

- [scripts/linux/setup-dummy-interface.sh](../../scripts/linux/setup-dummy-interface.sh)
- [docs/architecture/data-flow.md](../architecture/data-flow.md)
