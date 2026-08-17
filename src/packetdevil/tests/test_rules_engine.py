from packetdevil.config import BlockingConfig, TelegramConfig
from packetdevil.rules_engine import Action, TemporaryRuleTracker, classify
from packetdevil.suricata_eve import SuricataAlert


def make_alert(severity: int, category: str = "Generic Protocol Command Decode") -> SuricataAlert:
    return SuricataAlert(
        timestamp="2026-08-16T00:00:00.000000+0000",
        src_ip="203.0.113.10",
        src_port=443,
        dest_ip="198.51.100.5",
        dest_port=51000,
        proto="TCP",
        signature="test signature",
        signature_id=1000001,
        category=category,
        severity=severity,
        raw={},
    )


def test_low_severity_is_ignored():
    decision = classify(
        make_alert(severity=3), BlockingConfig(max_severity_to_block=2), TelegramConfig()
    )
    assert decision.action is Action.IGNORE


def test_qualifying_severity_blocks_without_notify_above_notify_threshold():
    decision = classify(
        make_alert(severity=2),
        BlockingConfig(max_severity_to_block=2),
        TelegramConfig(min_severity=1),
    )
    assert decision.action is Action.BLOCK


def test_high_severity_blocks_and_notifies():
    decision = classify(
        make_alert(severity=1),
        BlockingConfig(max_severity_to_block=2),
        TelegramConfig(min_severity=1),
    )
    assert decision.action is Action.BLOCK_AND_NOTIFY


def test_severe_category_always_blocks_and_notifies_regardless_of_severity():
    decision = classify(
        make_alert(severity=3, category="Malware Command and Control Activity Detected"),
        BlockingConfig(max_severity_to_block=2),
        TelegramConfig(min_severity=1),
    )
    assert decision.action is Action.BLOCK_AND_NOTIFY


def test_tracker_expires_rules_after_ttl():
    tracker = TemporaryRuleTracker()
    tracker.track("rule-1", "203.0.113.10", ttl_seconds=-1)  # already expired
    expired = tracker.pop_expired()
    assert [r.rule_id for r in expired] == ["rule-1"]
    assert tracker.pop_expired() == []
