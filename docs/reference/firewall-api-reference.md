---
title: RouterOS Firewall API Reference
status: draft
last_verified: 2026-08-16
applies_to:
  - RB5009
  - RouterOS 7.x
owner_domain: python-app
---

# RouterOS Firewall API Reference

## Purpose

Documents how `packetdevil` talks to the RB5009 to create and remove
temporary firewall block rules, and the RouterOS-side setup required
(REST API enablement, dedicated API user, permissions).

## RouterOS-side setup

1. Enable the REST API service over TLS (`api-ssl`, not the plaintext
   legacy `api`):
   ```routeros
   # Mutates: exposes a management API — restrict source addresses to the Linux box only
   /ip service set api-ssl disabled=no
   /ip service set api-ssl address=<SURICATA_HOST_IP>/32
   ```
2. Create a **dedicated, least-privilege API user** — never use the
   default `admin` account:
   ```routeros
   /user group add name=packetdevil-api policy=api,read,write,!local,!telnet,!ssh,!ftp,!reboot,!password,!sensitive,!romon
   /user add name=packetdevil-api group=packetdevil-api password=<STRONG_PASSWORD>
   ```
3. Restrict that user's rule-creation scope by convention (all rules must
   carry the `packetdevil:` comment prefix — see
   [routeros-commands.md](routeros-commands.md)); RouterOS permissions
   themselves are not granular enough to restrict *which* firewall rules
   a user can touch, so this is enforced at the application layer in
   [`firewall_client.py`](../../src/packetdevil/packetdevil/firewall_client.py)
   (it should refuse to remove any rule lacking that prefix).

## REST API endpoints used

| Action | Method | Path | Notes |
|---|---|---|---|
| List packetdevil rules | GET | `/rest/ip/firewall/filter?comment=packetdevil` | Used by the cleanup task to find expired rules. |
| Create block rule | PUT | `/rest/ip/firewall/filter` | Body includes `chain=forward`, `src-address=<ip>`, `action=drop`, `comment=packetdevil:block:<alert-id>`. |
| Remove rule | DELETE | `/rest/ip/firewall/filter/<.id>` | Called by the cleanup task once TTL expires. |

Authentication: HTTP Basic auth over TLS using the `packetdevil-api` user
created above. Credentials are supplied to the app via
`configs/packetdevil/config.example.yaml` → local, untracked
`/etc/packetdevil/config.yaml`.

## Client behavior contract

`firewall_client.py` must:
- Time out and raise a typed exception on network failure — never hang
  the alert-processing loop.
- Only ever create rules with the `packetdevil:` comment prefix and an
  associated TTL tracked locally (RouterOS rules themselves don't expire
  natively; expiry is enforced by `packetdevil`'s own scheduled cleanup,
  not by RouterOS).
- Never call the destructive "remove all rules" pattern — only ever
  target specific `.id`s returned by a prior list/create call.

## See also

- [docs/reference/routeros-commands.md](routeros-commands.md)
- [src/packetdevil/packetdevil/firewall_client.py](../../src/packetdevil/packetdevil/firewall_client.py)
- [docs/setup/05-python-app-install.md](../setup/05-python-app-install.md)
