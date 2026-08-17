---
title: "Runbook: Incident Response"
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - packetdevil Python app
owner_domain: architecture
---

# Runbook: Incident Response

## Purpose

What to do when `packetdevil` has taken an action (block, alert) that
needs immediate human review — either a suspected real incident, or a
suspected false positive causing collateral damage (e.g. blocking a
legitimate service).

## If you suspect a real, active threat

1. Do **not** wait for the automated TTL — confirm the block is in place
   now:
   ```routeros
   /ip firewall filter print where comment~"packetdevil:block"
   ```
2. Review the originating alert in `eve.json` for full context (payload
   metadata, signature, category).
3. If broader/permanent blocking is warranted beyond the automated TTL,
   add a manually-reviewed permanent rule **outside** the `packetdevil:`
   comment namespace (so the cleanup task never touches it):
   ```routeros
   # Mutates: RB5009 — permanent, manually reviewed block, NOT managed by packetdevil
   /ip firewall filter add chain=forward src-address=<IP> action=drop comment="manual:incident:<date>:<reason>"
   ```
4. Document the incident (what, when, why, action taken) — add a dated
   entry to a local incident log (not tracked in git if it contains
   sensitive IPs/details; keep a template if you want one tracked).

## If a block appears to be a false positive

1. Identify and remove the specific rule (never a blanket removal):
   ```routeros
   /ip firewall filter remove [find where comment="packetdevil:block:<alert-id>"]
   ```
2. Check whether the triggering Suricata signature is known-noisy for your
   environment; consider a documented rule suppression/threshold
   adjustment rather than disabling detection broadly — see
   [docs/reference/suricata-config-reference.md](../../reference/suricata-config-reference.md).
3. If the false-positive rate suggests a threshold problem in the
   classification logic itself, review
   [src/packetdevil/packetdevil/rules_engine.py](../../src/packetdevil/packetdevil/rules_engine.py)
   and its tests before changing thresholds in production config.

## See also

- [docs/reference/routeros-commands.md](../../reference/routeros-commands.md)
- [docs/operations/troubleshooting.md](../troubleshooting.md)
