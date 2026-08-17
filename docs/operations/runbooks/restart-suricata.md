---
title: "Runbook: Restart Suricata"
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
owner_domain: suricata
---

# Runbook: Restart Suricata

## Purpose

Safely restart Suricata (e.g. after a config/rule change) with minimal
detection blind-spot time.

## Steps

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml   # test config first
sudo systemctl restart suricata
sudo systemctl status suricata
```

## Verification

```bash
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="stats")' | head -n 1
```
Confirms Suricata is running and emitting stats again.

## Rollback

If the new config is broken, restore the previous `suricata.yaml` (keep a
dated backup before every edit) and repeat the steps above.

## See also

- [docs/reference/suricata-config-reference.md](../../reference/suricata-config-reference.md)
- [docs/operations/troubleshooting.md](../troubleshooting.md)
