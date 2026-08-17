---
title: Telegram Bot Setup
status: draft
last_verified: 2026-08-16
applies_to:
  - Telegram Bot API
owner_domain: python-app
---

# 06 — Telegram Bot Setup

## Purpose

Create a Telegram bot and chat used to deliver high-severity threat alerts
(e.g. malware command-and-control / phone-home detections) from the
`packetdevil` app.

## Prerequisites

- A Telegram account.

## Steps

1. **Create the bot** via [@BotFather](https://t.me/BotFather) in
   Telegram: send `/newbot`, follow the prompts, and save the returned
   **bot token** (format `123456789:AA...`).

2. **Start a chat with your new bot** (search for its username and send
   `/start`), or add it to a private group/channel you control if you want
   alerts to go there instead of a 1:1 chat.

3. **Get your chat id.** Send any message to the bot, then call:
   ```bash
   curl -s "https://api.telegram.org/bot<BOT_TOKEN>/getUpdates" | python3 -m json.tool
   ```
   Find `message.chat.id` in the response — this is your `TELEGRAM_CHAT_ID`.

4. **Add both values to your local `packetdevil` config**
   (`/etc/packetdevil/config.yaml`, from step 05):
   ```yaml
   telegram:
     bot_token: "<BOT_TOKEN>"
     chat_id: "<TELEGRAM_CHAT_ID>"
   ```
   Never commit real values — only `configs/packetdevil/config.example.yaml`
   with placeholders is tracked in git.

## Verification

```bash
curl -s -X POST "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" \
  -d chat_id="<TELEGRAM_CHAT_ID>" -d text="packetdevil test alert"
```
Confirm the message arrives in Telegram.

## Rollback / Undo

Revoke the bot token via BotFather (`/revoke`) if it needs to be
invalidated; remove the `telegram` section from the config to disable
notifications (blocking continues to work independently).

## Troubleshooting

- `getUpdates` returns empty: send a fresh message to the bot after
  starting the chat, then retry — Telegram only returns *recent* unread
  updates.
- 403 Forbidden on `sendMessage`: the bot hasn't been started by that chat,
  or was blocked/removed.

## Next

Return to [05-python-app-install.md](05-python-app-install.md) to finish
configuring and starting the app, or proceed to
[docs/operations/monitoring.md](../operations/monitoring.md) for day-2
operations.

## See also

- [src/packetdevil/packetdevil/telegram_notifier.py](../../src/packetdevil/packetdevil/telegram_notifier.py)
