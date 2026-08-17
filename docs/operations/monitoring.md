---
title: Monitoring
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
  - packetdevil Python app
owner_domain: architecture
---

# Monitoring

## Purpose

What to watch to know the whole pipeline (mirror → tzsp2pcap → Suricata →
packetdevil → RouterOS/Telegram) is healthy, and what "healthy" looks like.

## Key signals, by component

| Component | Signal | Healthy | Unhealthy indicates |
|---|---|---|---|
| RouterOS mirror/sniffer | `/tool sniffer print` packet count increasing | Increasing while WAN traffic flows | Mirror stopped — check config, router reboot |
| `tzsp2pcap` | systemd `active (running)`; `dummy0` packet counters increasing | Steady increase | Service crashed/restarted; check `journalctl -u tzsp2pcap` |
| Suricata | EVE `stats` events: `capture.kernel_drops`, `capture.kernel_packets` | `kernel_drops` near zero relative to `kernel_packets` | Box undersized — see [scenario-high-traffic-tuning.md](../scenarios/scenario-high-traffic-tuning.md) |
| Suricata | Alert rate (`event_type: alert` count/min) | Consistent with historical baseline | Sudden spike = possible real incident *or* broken/noisy rule; sudden drop to zero = pipeline broken upstream |
| `packetdevil` | Detection-to-block latency (alert timestamp → firewall rule created timestamp) | Low, stable (seconds) | Rising latency = RouterOS API slow/unreachable, or app backlog |
| `packetdevil` | RouterOS API call failures (logged) | Rare, transient | Sustained failures = credentials/network/API service issue |
| `packetdevil` | Telegram send failures (logged) | Rare, transient | Sustained failures = bot token revoked / network issue — blocking must continue regardless |
| `packetdevil` | Active temporary firewall rule count | Bounded, trending to zero absent active threats | Continuously growing = cleanup task not running/failing |

## Recommended checks

```bash
# Absence-of-traffic check — silent blind spot if this goes to zero unexpectedly
sudo tcpdump -ni dummy0 -c 1 -w /dev/null && echo "traffic flowing"

# Suricata stats
sudo tail -n 50 /var/log/suricata/eve.json | jq 'select(.event_type=="stats") | .stats.capture'

# packetdevil app health
sudo journalctl -u packetdevil --since "10 minutes ago"

# Current packetdevil-created firewall rules
```
```routeros
/ip firewall filter print where comment~"packetdevil:"
```

## See also

- [docs/architecture/data-flow.md](../architecture/data-flow.md) — failure-mode notes
- [docs/operations/troubleshooting.md](troubleshooting.md)
- [docs/operations/runbooks/](runbooks/)
