---
title: "ADR 0002: Suricata deployed as passive IDS (mirror), not inline IPS"
status: accepted
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
  - RB5009
owner_domain: architecture
---

# ADR 0002: Suricata deployed as passive IDS (mirror), not inline IPS

## Status

Accepted

## Context

Suricata can run inline (as an IPS, actively dropping packets in the data
path) or passively (as an IDS, watching a copy of traffic and only
detecting/alerting). Running inline typically requires the traffic to
physically traverse the box running Suricata (e.g. as a transparent bridge
or routed hop between modem and router), which introduces a single point of
failure for all internet connectivity if that box or its NIC/Suricata
process fails or falls behind under load.

## Decision

Suricata runs **passively**, reading a **mirrored copy** of WAN traffic via
RouterOS port mirroring + `tzsp2pcap`. Active response (blocking) is
achieved out-of-band via the `packetdevil` Python app calling the RouterOS
firewall API to add temporary block rules — not via Suricata's own
inline `IPS`/`NFQUEUE` drop capability.

## Options considered

1. **Passive IDS + external API-based blocking (chosen)** — Pros: zero
   risk to WAN uptime from Suricata/Linux box failures (worst case: loss of
   detection, not loss of internet); simpler network topology (no bridging,
   no becoming a routed hop); RB5009 keeps full hardware-offload routing
   performance on the primary path. Cons: response is not instantaneous
   (there's a detect → alert → API call → rule-applied latency window, on
   the order of seconds); doesn't stop the very first malicious packet of a
   flow, only subsequent ones from that source.
2. **Inline IPS (bridge/NFQUEUE) on the Linux box** — Pros: can drop
   malicious packets immediately, including the first one. Cons: Linux box
   becomes a hard dependency for all internet connectivity; requires
   careful fail-open/fail-closed hardware bypass planning; more complex to
   set up and much higher blast radius for bugs or performance issues.
3. **RouterOS-native IDS features only (no Suricata)** — Pros: no extra
   Linux box needed. Cons: RouterOS lacks Suricata's signature ecosystem,
   protocol coverage, and depth of inspection; explicitly insufficient for
   the "enterprise-level" detection goal of this project.

## Consequences

- Detection-to-block latency is a first-class metric to monitor (see
  [docs/operations/monitoring.md](../../operations/monitoring.md)) — large
  latency spikes indicate a problem in the alert pipeline, not just noise.
- The design accepts that a fast single-packet attack (e.g. one exploit
  packet) may not be blocked before delivery; mitigations for that gap
  (e.g. reputation-based pre-blocking, threat-intel feeds applied directly
  in RouterOS) are out of scope for this ADR and would need their own ADR
  if pursued.
- If future hardware/requirements change (e.g. willingness to accept WAN
  dependency on the Linux box for stronger inline protection), a new ADR
  should supersede this one rather than silently drifting the
  implementation.

## See also

- [docs/architecture/overview.md](../overview.md)
- [docs/architecture/data-flow.md](../data-flow.md)
- [docs/setup/01-mikrotik-rb5009-port-mirroring.md](../../setup/01-mikrotik-rb5009-port-mirroring.md)
