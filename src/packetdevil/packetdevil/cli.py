"""CLI entry point: wires config, eve.json tailing, classification, and actions together."""

from __future__ import annotations

import argparse
import logging
import threading
import time

from packetdevil.config import load_config
from packetdevil.firewall_client import FirewallClient, FirewallClientError
from packetdevil.rules_engine import Action, TemporaryRuleTracker, classify
from packetdevil.suricata_eve import tail_eve_json
from packetdevil.telegram_notifier import TelegramNotifier, TelegramNotifierError

logger = logging.getLogger("packetdevil")


def _cleanup_loop(
    tracker: TemporaryRuleTracker,
    firewall: FirewallClient,
    comment_prefix: str,
    dry_run: bool,
    poll_interval_seconds: float = 30.0,
) -> None:
    while True:
        for rule in tracker.pop_expired():
            if dry_run:
                logger.info(
                    "[dry-run] would remove expired rule %s (%s)", rule.rule_id, rule.src_address
                )
                continue
            try:
                firewall.remove_rule(rule.rule_id, comment_prefix)
            except FirewallClientError:
                logger.exception("failed to remove expired rule %s", rule.rule_id)
        time.sleep(poll_interval_seconds)


def run(config_path: str, dry_run_override: bool) -> None:
    config = load_config(config_path)
    dry_run = config.dry_run or dry_run_override

    firewall = FirewallClient(config.routeros)
    telegram = TelegramNotifier(config.telegram)
    tracker = TemporaryRuleTracker()

    cleanup_thread = threading.Thread(
        target=_cleanup_loop,
        args=(tracker, firewall, config.blocking.comment_prefix, dry_run),
        daemon=True,
    )
    cleanup_thread.start()

    logger.info("watching %s (dry_run=%s)", config.eve_json_path, dry_run)
    for alert in tail_eve_json(config.eve_json_path):
        decision = classify(alert, config.blocking, config.telegram)
        logger.info(
            "alert sid=%s severity=%s src=%s -> %s (%s)",
            alert.signature_id,
            alert.severity,
            alert.src_ip,
            decision.action.name,
            decision.reason,
        )

        if decision.action in (Action.BLOCK, Action.BLOCK_AND_NOTIFY):
            comment = f"{config.blocking.comment_prefix}:{alert.signature_id}:{int(time.time())}"
            if dry_run:
                logger.info("[dry-run] would block %s (%s)", alert.src_ip, comment)
            else:
                try:
                    rule_id = firewall.create_temporary_block(alert.src_ip, comment)
                    tracker.track(rule_id, alert.src_ip, config.blocking.ttl_minutes * 60)
                except FirewallClientError:
                    logger.exception("failed to create block for %s", alert.src_ip)

        if decision.action is Action.BLOCK_AND_NOTIFY:
            text = (
                f"packetdevil alert: {alert.signature}\n"
                f"category={alert.category} severity={alert.severity}\n"
                f"{alert.src_ip}:{alert.src_port} -> {alert.dest_ip}:{alert.dest_port} ({alert.proto})"
            )
            if dry_run:
                logger.info("[dry-run] would send Telegram alert:\n%s", text)
            else:
                try:
                    telegram.send_alert(text)
                except TelegramNotifierError:
                    logger.exception("failed to send Telegram alert (blocking still applied)")


def main() -> None:
    parser = argparse.ArgumentParser(description="packetdevil: Suricata alert triage")
    parser.add_argument("--config", required=True, help="path to config YAML")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="classify and log actions without calling RouterOS or Telegram",
    )
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s"
    )
    run(args.config, args.dry_run)


if __name__ == "__main__":
    main()
