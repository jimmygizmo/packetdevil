---
title: Prerequisites
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - RouterOS 7.x
  - Debian 12 / Ubuntu 22.04+
owner_domain: architecture
---

# 00 — Prerequisites

## Purpose

Everything you need before starting the numbered setup sequence
(`01` → `06`). Confirm each item before proceeding — most later docs assume
these are already true and will not re-check them.

## Prerequisites

- **Hardware**
  - MikroTik RB5009 (or compatible RouterOS 7.x device with port
    mirroring support) as the primary router.
  - A dedicated Linux box (physical or VM) with at least 1 NIC reachable
    from the RB5009's LAN, sufficient CPU for Suricata at your WAN
    bandwidth (see [docs/reference/suricata-config-reference.md](../reference/suricata-config-reference.md)
    for sizing notes).
- **Access**
  - Admin access to RouterOS (WinBox, SSH, or `/ip/service` REST enabled).
  - Root/sudo access on the Linux box.
- **Software baseline on the Linux box**
  - Debian 12 or Ubuntu 22.04+ (other distros not yet documented — if you
    use one, add a new scenario doc rather than editing the baseline).
  - `git`, `build-essential` (for compiling `tzsp2pcap`), `python3.11+`,
    `pip`/`uv`, `jq` (used by
    [scripts/linux/tail-suricata-eve-alerts.sh](../../scripts/linux/tail-suricata-eve-alerts.sh)
    and throughout `docs/operations/` for inspecting `eve.json`).
- **Network planning decisions** (write these down before proceeding —
  they're referenced throughout later docs):
  - Which RouterOS interface is "WAN" (to be mirrored).
  - The Linux box's static IP (mirror target).
  - Whether you're following the baseline single-WAN topology or a variant
    — see [docs/scenarios/README.md](../scenarios/README.md).
- **Accounts**
  - A Telegram account + ability to create a bot via
    [@BotFather](https://t.me/BotFather) (needed in step 06).

## Verification

Run through this checklist and confirm each item is true:

```bash
# On the Linux box
python3 --version   # expect 3.11+
git --version
gcc --version        # or clang — needed to build tzsp2pcap
```

```routeros
# On the RB5009, over SSH/WinBox terminal
/system resource print
/interface print
```

## Next

Continue to
[01-mikrotik-rb5009-port-mirroring.md](01-mikrotik-rb5009-port-mirroring.md).

## See also

- [docs/architecture/overview.md](../architecture/overview.md)
- [docs/architecture/network-topology.md](../architecture/network-topology.md)
- [docs/operations/testing.md](../operations/testing.md) — optional, only
  needed once the pipeline is running end to end and you want to validate
  detection with ad-hoc test scripts under `scripts/linux/tests/`, not
  required up front.
