---
title: "Runbook: Rotate Logs"
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
  - Debian 12 / Ubuntu 22.04+
owner_domain: linux
---

# Runbook: Rotate Logs

## Purpose

Prevent `eve.json` and `packetdevil` logs from filling disk on the
Suricata box, which would otherwise silently kill detection (Suricata
typically stops writing, or the disk fills and other services fail).

## Steps

1. Confirm `logrotate` is configured for Suricata (usually installed by
   the package; verify):
   ```bash
   cat /etc/logrotate.d/suricata
   ```
2. Confirm `packetdevil`'s own logs (via `journald`, if using the systemd
   unit as documented) are bounded:
   ```bash
   sudo journalctl --disk-usage
   ```
   Configure `SystemMaxUse=` in `/etc/systemd/journald.conf` if unbounded.
3. Force a manual rotation/test:
   ```bash
   sudo logrotate -f /etc/logrotate.d/suricata
   ```

## Verification

```bash
df -h /var/log
```
Confirm free space is healthy and rotation produced a new `eve.json.1` (or
compressed equivalent).

## See also

- [docs/operations/monitoring.md](../monitoring.md)
