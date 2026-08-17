"""Telegram Bot API client with basic rate limiting.

Notification failures must never block or delay firewall actions — callers
should treat exceptions here as best-effort and continue.
"""

from __future__ import annotations

import logging
import time

import requests

from packetdevil.config import TelegramConfig

logger = logging.getLogger(__name__)


class TelegramNotifierError(RuntimeError):
    """Raised on Telegram API failure. Callers should catch and log, not crash."""


class TelegramNotifier:
    def __init__(self, config: TelegramConfig, min_seconds_between_messages: float = 2.0) -> None:
        self._config = config
        self._min_interval = min_seconds_between_messages
        self._last_sent_at: float = 0.0

    def send_alert(self, text: str) -> None:
        if not self._config.enabled:
            logger.debug("telegram not configured; skipping notification")
            return

        elapsed = time.monotonic() - self._last_sent_at
        if elapsed < self._min_interval:
            time.sleep(self._min_interval - elapsed)

        url = f"https://api.telegram.org/bot{self._config.bot_token}/sendMessage"
        try:
            response = requests.post(
                url,
                data={"chat_id": self._config.chat_id, "text": text},
                timeout=5.0,
            )
            response.raise_for_status()
        except requests.RequestException as exc:
            raise TelegramNotifierError("failed to send Telegram alert") from exc
        finally:
            self._last_sent_at = time.monotonic()
