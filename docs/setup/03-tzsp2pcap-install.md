---
title: tzsp2pcap Build & Install
status: draft
last_verified: 2026-08-16
applies_to:
  - tzsp2pcap
  - Debian 12 / Ubuntu 22.04+
owner_domain: tzsp2pcap
---

# 03 — tzsp2pcap Build & Install

## Purpose

Build our vendored + patched copy of `tzsp2pcap` (see
[ADR 0001](../architecture/decisions/0001-tzsp2pcap-fork-strategy.md)) and
install it as a systemd service that decapsulates incoming TZSP traffic
onto the `dummy0` interface created in step 02.

## Prerequisites

- [02-linux-dummy-interface.md](02-linux-dummy-interface.md) completed.
- Build toolchain installed (`build-essential` or equivalent — see
  [00-prerequisites.md](00-prerequisites.md)).

## Steps

1. **Build the patched binary.**
   ```bash
   cd vendor/tzsp2pcap
   ./build.sh
   ```
   This applies all patches in `patches/` on top of `upstream/` and
   compiles the result into `build/` (gitignored). See
   [vendor/tzsp2pcap/README.md](../../vendor/tzsp2pcap/README.md) for how
   the build script works and how to add new patches.

2. **Install the binary.**
   ```bash
   sudo install -m 755 vendor/tzsp2pcap/build/tzsp2pcap /usr/local/bin/tzsp2pcap
   ```

3. **Install and enable the systemd unit.**
   ```bash
   sudo cp configs/tzsp2pcap/tzsp2pcap.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now tzsp2pcap
   ```
   The unit runs `tzsp2pcap` bound to UDP `37008`, writing decapsulated
   frames onto `dummy0`. Adjust listen port/interface via
   `configs/tzsp2pcap/tzsp2pcap.conf.example` (copy to a real, untracked
   config path referenced by the unit) — see
   [docs/reference/tzsp2pcap-config-reference.md](../reference/tzsp2pcap-config-reference.md).

## Verification

```bash
sudo systemctl status tzsp2pcap
sudo tcpdump -ni dummy0 -c 10
```
Expect to see decapsulated traffic (real WAN packets, not TZSP-wrapped)
appearing on `dummy0`.

## Rollback / Undo

```bash
sudo systemctl disable --now tzsp2pcap
sudo rm /etc/systemd/system/tzsp2pcap.service /usr/local/bin/tzsp2pcap
sudo systemctl daemon-reload
```

## Troubleshooting

- No traffic on `dummy0` but TZSP arriving on the NIC (confirmed in step
  01): check `tzsp2pcap`'s configured output interface matches `dummy0`
  exactly, and that the service has permission (capability
  `CAP_NET_ADMIN`/`CAP_NET_RAW`, or run as root) to write to it.
- See [docs/operations/troubleshooting.md](../operations/troubleshooting.md).

## Next

Continue to [04-suricata-install.md](04-suricata-install.md).

## See also

- [vendor/tzsp2pcap/README.md](../../vendor/tzsp2pcap/README.md)
- [docs/architecture/decisions/0001-tzsp2pcap-fork-strategy.md](../architecture/decisions/0001-tzsp2pcap-fork-strategy.md)
- [docs/reference/tzsp2pcap-config-reference.md](../reference/tzsp2pcap-config-reference.md)
