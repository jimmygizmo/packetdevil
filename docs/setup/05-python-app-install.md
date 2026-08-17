---
title: packetdevil Python App Install
status: draft
last_verified: 2026-08-16
applies_to:
  - Debian 12 / Ubuntu 22.04+
  - Python 3.11+
owner_domain: python-app
---

# 05 — packetdevil Python App Install

## Purpose

Install and configure the `packetdevil` Python app, which tails Suricata's
`eve.json`, calls the RouterOS firewall API to create temporary blocks, and
sends Telegram alerts for severe threats.

## Prerequisites

- [04-suricata-install.md](04-suricata-install.md) completed and verified
  (`eve.json` producing alerts).
- [uv](https://docs.astral.sh/uv/) installed on the Linux box (this
  project uses `uv` exclusively for Python dependency/venv management —
  never bare `pip`/`venv`):
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```
- RouterOS REST API enabled and an API user created — see
  [docs/reference/firewall-api-reference.md](../reference/firewall-api-reference.md).
- A Telegram bot token — complete
  [06-telegram-bot-setup.md](06-telegram-bot-setup.md) first if you want
  notifications working immediately (the app runs fine with Telegram
  disabled/unconfigured; blocking still works).

## Steps

1. **Install the package.**
   ```bash
   cd src/packetdevil
   uv sync
   ```
   This creates `.venv` and installs project + dev dependencies pinned by
   `uv.lock`.

2. **Create your local config** from the template:
   ```bash
   cp ../../configs/packetdevil/config.example.yaml /etc/packetdevil/config.yaml
   ```
   Fill in RouterOS host/credentials, Telegram token/chat id, and alert
   thresholds. This file contains secrets — it must never be committed;
   confirm your path is covered by [.gitignore](../../.gitignore).

3. **Install the systemd unit.**
   ```bash
   sudo cp ../../configs/packetdevil/packetdevil.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now packetdevil
   ```
   The unit runs the app via `uv run packetdevil ...` inside
   `src/packetdevil`, so `uv` must be on the service's `PATH` (or invoked
   by absolute path) — see
   [configs/packetdevil/packetdevil.service](../../configs/packetdevil/packetdevil.service).

## Verification

```bash
sudo systemctl status packetdevil
sudo journalctl -u packetdevil -f
```
Trigger a test Suricata alert (as in step 04) and confirm the app logs
that it classified the alert and (if above threshold) called the RouterOS
API.

## Rollback / Undo

```bash
sudo systemctl disable --now packetdevil
```

## Troubleshooting

- App logs auth errors calling RouterOS API: verify credentials/permissions
  per [docs/reference/firewall-api-reference.md](../reference/firewall-api-reference.md).
- No Telegram messages: confirm bot token/chat id in config, and see
  [06-telegram-bot-setup.md](06-telegram-bot-setup.md) verification steps.

## Next

Continue to [06-telegram-bot-setup.md](06-telegram-bot-setup.md) if not
already done, then see
[docs/operations/monitoring.md](../operations/monitoring.md) for ongoing
operation.

## See also

- [src/packetdevil/README.md](../../src/packetdevil/README.md)
- [docs/reference/firewall-api-reference.md](../reference/firewall-api-reference.md)
