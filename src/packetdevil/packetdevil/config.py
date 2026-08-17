"""Load and validate packetdevil's runtime configuration.

Config is loaded from a YAML file (see
configs/packetdevil/config.example.yaml for the template) with environment
variable overrides for secrets, so credentials never need to live on disk
in plaintext if the deployment prefers env-based secret injection.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

import yaml


@dataclass
class RouterOSConfig:
    host: str
    username: str
    password: str
    verify_tls: bool = True
    timeout_seconds: float = 5.0


@dataclass
class TelegramConfig:
    bot_token: str | None = None
    chat_id: str | None = None
    min_severity: int = 1
    """Only alerts classified at or below this Suricata severity number
    (lower = more severe in Suricata's convention) trigger a Telegram
    message, in addition to being blocked."""

    @property
    def enabled(self) -> bool:
        return bool(self.bot_token and self.chat_id)


@dataclass
class BlockingConfig:
    max_severity_to_block: int = 2
    """Suricata alerts with severity <= this value are blocked (Suricata
    severity: 1=high priority ... lower number is more severe)."""
    ttl_minutes: int = 60
    comment_prefix: str = "packetdevil:block"


@dataclass
class Config:
    eve_json_path: Path
    routeros: RouterOSConfig
    telegram: TelegramConfig = field(default_factory=TelegramConfig)
    blocking: BlockingConfig = field(default_factory=BlockingConfig)
    dry_run: bool = False


def _env_override(value: str | None, env_var: str) -> str | None:
    return os.environ.get(env_var, value)


def load_config(path: str | Path) -> Config:
    """Load config from a YAML file, applying environment overrides for secrets."""
    data = yaml.safe_load(Path(path).read_text(encoding="utf-8")) or {}

    routeros_raw = data.get("routeros", {})
    routeros = RouterOSConfig(
        host=routeros_raw["host"],
        username=_env_override(routeros_raw.get("username"), "PACKETDEVIL_ROUTEROS_USERNAME"),
        password=_env_override(routeros_raw.get("password"), "PACKETDEVIL_ROUTEROS_PASSWORD"),
        verify_tls=routeros_raw.get("verify_tls", True),
        timeout_seconds=routeros_raw.get("timeout_seconds", 5.0),
    )

    telegram_raw = data.get("telegram", {})
    telegram = TelegramConfig(
        bot_token=_env_override(telegram_raw.get("bot_token"), "PACKETDEVIL_TELEGRAM_BOT_TOKEN"),
        chat_id=_env_override(telegram_raw.get("chat_id"), "PACKETDEVIL_TELEGRAM_CHAT_ID"),
        min_severity=telegram_raw.get("min_severity", 1),
    )

    blocking_raw = data.get("blocking", {})
    blocking = BlockingConfig(
        max_severity_to_block=blocking_raw.get("max_severity_to_block", 2),
        ttl_minutes=blocking_raw.get("ttl_minutes", 60),
        comment_prefix=blocking_raw.get("comment_prefix", "packetdevil:block"),
    )

    return Config(
        eve_json_path=Path(data["eve_json_path"]),
        routeros=routeros,
        telegram=telegram,
        blocking=blocking,
        dry_run=data.get("dry_run", False),
    )
