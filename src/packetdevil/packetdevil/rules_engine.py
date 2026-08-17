"""Classify Suricata alerts into an action, and track TTLs for temporary blocks.

Severity in Suricata convention: 1 = highest priority (most severe) ... 3 = lowest.
"""

from __future__ import annotations

import logging
import time
from dataclasses import dataclass
from enum import Enum, auto

from packetdevil.config import BlockingConfig, TelegramConfig
from packetdevil.suricata_eve import SuricataAlert

logger = logging.getLogger(__name__)

# Alert categories treated as "most serious" regardless of numeric severity
# (e.g. malware phoning home / command-and-control) — always block + notify.
SEVERE_CATEGORIES = {
    "A Network Trojan was detected",
    "Malware Command and Control Activity Detected",
    "Attempted Administrator Privilege Gain",
}


class Action(Enum):
    IGNORE = auto()
    BLOCK = auto()
    BLOCK_AND_NOTIFY = auto()


@dataclass
class Decision:
    action: Action
    alert: SuricataAlert
    reason: str


def classify(alert: SuricataAlert, blocking: BlockingConfig, telegram: TelegramConfig) -> Decision:
    """Decide what action to take for a single alert. Pure function — no I/O."""
    if alert.category in SEVERE_CATEGORIES:
        return Decision(Action.BLOCK_AND_NOTIFY, alert, reason=f"severe category: {alert.category}")

    if alert.severity <= blocking.max_severity_to_block:
        if alert.severity <= telegram.min_severity:
            return Decision(
                Action.BLOCK_AND_NOTIFY,
                alert,
                reason=f"severity {alert.severity} <= notify threshold",
            )
        return Decision(Action.BLOCK, alert, reason=f"severity {alert.severity} <= block threshold")

    return Decision(Action.IGNORE, alert, reason=f"severity {alert.severity} below block threshold")


@dataclass
class ManagedRule:
    rule_id: str
    src_address: str
    created_at: float
    ttl_seconds: float

    @property
    def expires_at(self) -> float:
        return self.created_at + self.ttl_seconds

    @property
    def is_expired(self) -> bool:
        return time.monotonic() >= self.expires_at


class TemporaryRuleTracker:
    """In-process tracker of rules this app created, so it knows what to expire.

    This is intentionally in-memory + simple for v0.1; if the app restarts,
    already-created RouterOS rules are recovered by listing rules with the
    configured comment prefix on startup (see cli.py) rather than persisted
    to disk here.
    """

    def __init__(self) -> None:
        self._rules: dict[str, ManagedRule] = {}

    def track(self, rule_id: str, src_address: str, ttl_seconds: float) -> None:
        self._rules[rule_id] = ManagedRule(
            rule_id=rule_id,
            src_address=src_address,
            created_at=time.monotonic(),
            ttl_seconds=ttl_seconds,
        )

    def pop_expired(self) -> list[ManagedRule]:
        expired = [rule for rule in self._rules.values() if rule.is_expired]
        for rule in expired:
            del self._rules[rule.rule_id]
        return expired
