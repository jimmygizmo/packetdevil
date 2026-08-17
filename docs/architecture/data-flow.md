---
title: Data Flow
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
  - tzsp2pcap
  - packetdevil Python app
owner_domain: architecture
---

# Data Flow

## Purpose

Traces a single packet, and a single alert, end to end through the system.
Use this to reason about where to add logging, where latency matters, and
where a bug in one component could hide a symptom in another.

## Packet path (network layer)

1. A packet crosses the RB5009's WAN interface (inbound or outbound).
2. RouterOS's mirroring feature clones the frame and encapsulates it in a
   **TZSP (TaZmen Sniffer Protocol)** header, sent as UDP to the configured
   mirror destination (the Linux box).
3. `tzsp2pcap` on the Linux box receives the UDP packet, strips the TZSP
   header, and re-emits the original Ethernet frame — either onto a `dummy`
   interface, into a named pipe, or appended to a pcap file, depending on
   configured mode (see
   [docs/reference/tzsp2pcap-config-reference.md](../reference/tzsp2pcap-config-reference.md)).
4. Suricata, configured to capture from that `dummy` interface/pipe/file,
   parses the frame, reassembles flows/streams, and evaluates it against
   loaded rulesets.
5. On a rule match, Suricata appends a JSON record to `eve.json`
   (`event_type: alert`), including signature id, severity, source/dest
   IP:port, protocol, and metadata.

## Alert path (application layer)

1. `packetdevil`'s log tailer
   ([`suricata_eve.py`](../../src/packetdevil/packetdevil/suricata_eve.py))
   watches `eve.json` (tail -f style, handling log rotation) and parses new
   `alert` events as they're written.
2. Each alert is classified by
   [`rules_engine.py`](../../src/packetdevil/packetdevil/rules_engine.py)
   using severity, signature category, and any allow/deny lists into one of:
   - **Ignore** — below threshold, no action.
   - **Block** — create a temporary RouterOS firewall rule against the
     offending source/destination IP via
     [`firewall_client.py`](../../src/packetdevil/packetdevil/firewall_client.py).
   - **Block + Notify** — block *and* send a Telegram alert via
     [`telegram_notifier.py`](../../src/packetdevil/packetdevil/telegram_notifier.py)
     for the most severe categories (e.g. malware C2 / phone-home,
     confirmed exploit activity).
3. Temporary firewall rules carry a TTL; a scheduled task (in-process timer
   or a periodic cleanup pass) removes expired rules and logs the removal.
4. All actions taken (block created, block expired/removed, notification
   sent, notification suppressed by rate limit) are logged locally for
   audit — see
   [docs/operations/monitoring.md](../operations/monitoring.md).

## Failure-mode notes

- If `tzsp2pcap` dies, Suricata simply sees no traffic — no crash, but
  silent blind spot. Monitoring must alert on **absence** of traffic, not
  just presence of errors (see monitoring doc).
- If the Python app can't reach the RouterOS API, alerts must still be
  logged locally and (if configured) still trigger Telegram notification —
  blocking is best-effort, alerting is not allowed to depend on blocking
  succeeding.
- If Telegram is unreachable, blocking must still proceed — notification
  failures must never suppress a defensive action.
- Alerts triggered by traffic *originating* inside your own LAN (e.g. a
  compromised internal host phoning home) are only visible to Suricata
  after the RB5009's NAT rewrites the source address on the WAN mirror —
  so `src_ip` on such an alert is your network's public (NAT'd) IP, not
  the internal host's private IP. Keep this in mind when interpreting
  alerts or reasoning about what a resulting temporary block actually
  covers — see
  [docs/operations/testing.md](../operations/testing.md) for a concrete
  example (`scripts/linux/tests/internal/simulate-password-in-clear.sh`).

## See also

- [overview.md](overview.md)
- [docs/reference/suricata-config-reference.md](../reference/suricata-config-reference.md)
- [docs/reference/firewall-api-reference.md](../reference/firewall-api-reference.md)
