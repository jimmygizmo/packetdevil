---
title: Linux Command Reference
status: draft
last_verified: 2026-08-16
applies_to:
  - Debian 12 / Ubuntu 22.04+
owner_domain: linux
---

# Linux Command Reference

## Purpose

Canonical reference for Linux commands used across setup guides and
runbooks, grouped by task, so scripts/docs can link here instead of
re-explaining flags each time.

## Dummy interface management

```bash
sudo modprobe dummy
sudo ip link add dummy0 type dummy
sudo ip link set dummy0 up
sudo ip link show dummy0
sudo ip link delete dummy0   # rollback
```

## Capture / verification

```bash
sudo tcpdump -ni <nic> udp port 37008         # confirm TZSP arriving
sudo tcpdump -ni dummy0 -c 10                  # confirm tzsp2pcap output
```

## Service management (systemd)

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now <service>
sudo systemctl disable --now <service>
sudo systemctl status <service>
sudo journalctl -u <service> -f
```

Services managed this way in this project: `tzsp2pcap`, `suricata`,
`packetdevil`.

## Suricata log inspection

```bash
sudo tail -f /var/log/suricata/fast.log
sudo tail -f /var/log/suricata/eve.json
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```

Use the packaged helpers for the common views:

```bash
sudo scripts/linux/tail-suricata-fast-log.sh
sudo scripts/linux/tail-suricata-eve-alerts.sh
sudo scripts/linux/tail-suricata-eve-alerts.sh -a
```

## Firewall on the Linux box itself (host-level, not RouterOS)

The Linux box's own host firewall must permit inbound UDP 37008 (TZSP)
from the RB5009 and outbound HTTPS to the RouterOS API host and
`api.telegram.org`:

```bash
sudo ufw allow from <RB5009_IP> to any port 37008 proto udp
```

## See also

- [docs/reference/routeros-commands.md](routeros-commands.md)
- [.github/instructions/shell.instructions.md](../../.github/instructions/shell.instructions.md)
