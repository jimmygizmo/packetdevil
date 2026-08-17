---
title: RouterOS Port Mirroring on RB5009
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - RouterOS 7.x
owner_domain: routeros
---

# 01 — MikroTik RB5009 Port Mirroring (WAN → TZSP)

## Purpose

Configure the RB5009 to mirror all traffic seen on the WAN interface and
send it, TZSP-encapsulated, to the Linux box that will run `tzsp2pcap` +
Suricata.

## Prerequisites

- [00-prerequisites.md](00-prerequisites.md) completed.
- Know your WAN interface name (e.g. `ether1`) and the Linux box's static
  IP (referred to below as `<SURICATA_HOST_IP>`).

## Steps

1. **Confirm the WAN interface name.**
   ```routeros
   /interface print
   ```
   Note the `name` column for your WAN-facing interface.

2. **Enable port mirroring on the switch chip (RB5009 uses a switch chip
   for hardware offload; mirroring is configured per switch, not per
   logical interface, on many MikroTik models).**
   ```routeros
   # Mutates: RB5009 switch config — enables mirroring of WAN port traffic
   /interface ethernet switch port
   set [find where name="<WAN_INTERFACE>"] mirror-source=yes
   /interface ethernet switch
   set 0 mirror-target=<MIRROR_TARGET_PORT_OR_SETTING>
   ```
   > `status: draft` — the exact `mirror-target` mechanics differ between
   > "mirror to a physical port" (dedicated cable to the Linux box) vs.
   > "mirror via TZSP over the routed/bridged network" (RouterOS
   > `/tool sniffer` with `streaming-enabled=yes` and
   > `streaming-server=<SURICATA_HOST_IP>`). This doc must be updated to
   > `status: verified` with the exact commands once tested against real
   > hardware — do not treat the block above as final until then.

3. **Alternative (software-based) approach: `/tool sniffer` streaming.**
   RouterOS's built-in packet sniffer can stream captured packets as TZSP
   to a remote host without needing a dedicated hardware mirror port —
   useful if you don't have a spare physical port for mirroring:
   ```routeros
   # Mutates: RB5009 — starts continuous packet sniffing on WAN interface
   /tool sniffer set streaming-enabled=yes streaming-server=<SURICATA_HOST_IP> filter-interface=<WAN_INTERFACE>
   /tool sniffer start
   ```
   Tradeoff: this uses CPU (not hardware-offloaded like switch-chip
   mirroring) and may not keep up at very high WAN throughput — see
   [docs/reference/routeros-commands.md](../reference/routeros-commands.md)
   for the full command reference and performance notes.

4. **Verify TZSP packets are arriving at the Linux box** before proceeding
   to install `tzsp2pcap` (step 03):
   ```bash
   sudo tcpdump -ni <linux-nic> udp port 37008
   ```
   (RouterOS default TZSP port is `37008`; confirm in
   [docs/reference/tzsp2pcap-config-reference.md](../reference/tzsp2pcap-config-reference.md).)

## Verification

- `tcpdump` above shows a steady stream of UDP packets on port `37008`
  while WAN traffic is flowing.
- `/tool sniffer print` (if using the streaming approach) shows
  `running: yes` with a nonzero packet count.

## Rollback / Undo

```routeros
# Mutates: RB5009 — disables mirroring/sniffer streaming
/tool sniffer set streaming-enabled=no
/tool sniffer stop
/interface ethernet switch port set [find where name="<WAN_INTERFACE>"] mirror-source=no
```

## Troubleshooting

- No packets seen on the Linux box: check RouterOS firewall isn't dropping
  outbound UDP 37008 from the router itself; check the Linux box's own
  host firewall (`ufw`/`nftables`) isn't dropping inbound UDP 37008.
- See [docs/operations/troubleshooting.md](../operations/troubleshooting.md).

## Next

Continue to [02-linux-dummy-interface.md](02-linux-dummy-interface.md).

## See also

- [docs/reference/routeros-commands.md](../reference/routeros-commands.md)
- [docs/architecture/network-topology.md](../architecture/network-topology.md)
