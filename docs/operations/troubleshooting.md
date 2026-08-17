---
title: Troubleshooting
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - Suricata 7.x
  - tzsp2pcap
  - packetdevil Python app
owner_domain: architecture
---

# Troubleshooting

## Purpose

Symptom-indexed troubleshooting guide across the whole pipeline. Start here
when something is broken but you don't yet know which component is at
fault; each entry links to the deeper doc for that component.

## "No alerts are firing at all"

1. Check traffic is reaching `dummy0`:
   ```bash
   sudo tcpdump -ni dummy0 -c 10
   ```
   - **Nothing arrives** → check `tzsp2pcap` service
     (`sudo systemctl status tzsp2pcap`), then check TZSP is arriving on
     the real NIC (`sudo tcpdump -ni <nic> udp port 37008`), then check
     RouterOS mirror/sniffer config — see
     [docs/setup/01-mikrotik-rb5009-port-mirroring.md](../setup/01-mikrotik-rb5009-port-mirroring.md).
   - **Traffic arrives fine** → check Suricata is actually capturing from
     `dummy0` (`suricata.yaml` `af-packet.interface`) and that a loaded
     rule should match your test traffic — see
     [docs/reference/suricata-config-reference.md](../reference/suricata-config-reference.md).

## "Suricata alerts but no firewall rule is created"

1. `sudo journalctl -u packetdevil -f` while triggering a test alert.
2. Check the alert's severity/category actually crosses your configured
   block threshold (see `configs/packetdevil/config.example.yaml`).
3. Check for RouterOS API auth/network errors in the log — see
   [docs/reference/firewall-api-reference.md](../reference/firewall-api-reference.md).

## "Firewall rules are created but never expire"

The cleanup task isn't running or is failing. Check
`sudo journalctl -u packetdevil -f` for cleanup-cycle log lines, and
manually inspect current rules:
```routeros
/ip firewall filter print where comment~"packetdevil:"
```
See [runbooks/rotate-logs.md](runbooks/rotate-logs.md) if disk pressure
from logs is a contributing symptom, or
[runbooks/incident-response.md](runbooks/incident-response.md) if you need
to manually clear a stuck rule right now.

## "No Telegram alerts"

See verification steps in
[docs/setup/06-telegram-bot-setup.md](../setup/06-telegram-bot-setup.md).
Remember: blocking is designed to continue working even if Telegram is
fully broken — a missing Telegram alert does not imply blocking failed.

## "Suricata dropping packets / high CPU"

See [docs/scenarios/scenario-high-traffic-tuning.md](../scenarios/scenario-high-traffic-tuning.md).

## See also

- [docs/operations/monitoring.md](monitoring.md)
- [docs/operations/runbooks/](runbooks/)
