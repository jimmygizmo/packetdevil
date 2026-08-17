"""Tail Suricata's eve.json and yield parsed alert events.

Handles log rotation (reopens the file if it's truncated/replaced) the way
`tail -F` does, since Suricata/logrotate may rotate eve.json underneath a
long-running process.
"""

from __future__ import annotations

import json
import logging
import time
from collections.abc import Iterator
from dataclasses import dataclass
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)


@dataclass
class SuricataAlert:
    timestamp: str
    src_ip: str
    src_port: int | None
    dest_ip: str
    dest_port: int | None
    proto: str
    signature: str
    signature_id: int
    category: str
    severity: int
    raw: dict[str, Any]

    @classmethod
    def from_eve_record(cls, record: dict[str, Any]) -> SuricataAlert | None:
        if record.get("event_type") != "alert":
            return None
        alert = record.get("alert", {})
        try:
            return cls(
                timestamp=record["timestamp"],
                src_ip=record["src_ip"],
                src_port=record.get("src_port"),
                dest_ip=record["dest_ip"],
                dest_port=record.get("dest_port"),
                proto=record.get("proto", "UNKNOWN"),
                signature=alert["signature"],
                signature_id=alert["signature_id"],
                category=alert.get("category", "unknown"),
                severity=alert["severity"],
                raw=record,
            )
        except KeyError:
            logger.warning("skipping malformed alert record missing required fields")
            return None


def tail_eve_json(path: Path, poll_interval_seconds: float = 1.0) -> Iterator[SuricataAlert]:
    """Yield SuricataAlert objects as new lines are appended to `path`.

    Blocks/polls forever; intended to run in the main app loop or a
    dedicated thread.
    """
    inode = None
    fh = None
    try:
        while True:
            try:
                stat = path.stat()
            except FileNotFoundError:
                time.sleep(poll_interval_seconds)
                continue

            if fh is None or stat.st_ino != inode:
                if fh is not None:
                    fh.close()
                fh = path.open("r", encoding="utf-8")
                fh.seek(0, 2)  # start at end; don't replay old alerts on (re)start
                inode = stat.st_ino
                logger.info("opened %s for tailing (inode=%s)", path, inode)

            line = fh.readline()
            if not line:
                time.sleep(poll_interval_seconds)
                continue

            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                logger.warning("skipping non-JSON line in %s", path)
                continue

            alert = SuricataAlert.from_eve_record(record)
            if alert is not None:
                yield alert
    finally:
        if fh is not None:
            fh.close()
