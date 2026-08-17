---
title: "Runbook: Update Rules"
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
owner_domain: suricata
---

# Runbook: Update Suricata Rules

## Purpose

Safely pull updated detection rules and reload Suricata without extended
detection downtime.

## Steps

```bash
sudo suricata-update
sudo suricata -T -c /etc/suricata/suricata.yaml   # validate before reload
sudo systemctl reload suricata   # reload, not restart, where supported
```

## Verification

```bash
sudo journalctl -u suricata --since "5 minutes ago" | grep -i "rule"
```
Confirm rule count loaded matches expectations and no parse errors are
logged.

## Rollback

`suricata-update` keeps prior rule sets; use
`sudo suricata-update list-sources` / restore from
`/var/lib/suricata/rules` backups if a new ruleset causes problems (e.g.
false-positive storm triggering excessive blocks — see
[incident-response.md](incident-response.md)).

## See also

- [docs/reference/suricata-config-reference.md](../../reference/suricata-config-reference.md)
- [restart-suricata.md](restart-suricata.md)
