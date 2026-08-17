"""RouterOS REST API client for creating/listing/removing temporary firewall rules.

See docs/reference/firewall-api-reference.md for the RouterOS-side setup
this client assumes (api-ssl enabled, dedicated least-privilege user).
"""

from __future__ import annotations

import logging

import requests

from packetdevil.config import RouterOSConfig

logger = logging.getLogger(__name__)


class FirewallClientError(RuntimeError):
    """Raised on any RouterOS API failure (network, auth, or unexpected response)."""


class FirewallClient:
    def __init__(self, config: RouterOSConfig) -> None:
        self._config = config
        self._base_url = f"https://{config.host}/rest"
        self._session = requests.Session()
        self._session.auth = (config.username, config.password)
        self._session.verify = config.verify_tls

    def create_temporary_block(self, src_address: str, comment: str) -> str:
        """Create a drop rule for src_address; returns the RouterOS rule id (.id)."""
        payload = {
            "chain": "forward",
            "src-address": src_address,
            "action": "drop",
            "comment": comment,
        }
        try:
            response = self._session.put(
                f"{self._base_url}/ip/firewall/filter",
                json=payload,
                timeout=self._config.timeout_seconds,
            )
            response.raise_for_status()
        except requests.RequestException as exc:
            raise FirewallClientError(f"failed to create block rule for {src_address}") from exc

        rule_id = response.json().get(".id")
        if not rule_id:
            raise FirewallClientError(f"RouterOS did not return a rule id for {src_address}")
        logger.info("created temporary block rule %s for %s", rule_id, src_address)
        return rule_id

    def list_managed_rules(self, comment_prefix: str) -> list[dict]:
        """List firewall rules whose comment starts with comment_prefix."""
        try:
            response = self._session.get(
                f"{self._base_url}/ip/firewall/filter",
                params={"comment": comment_prefix},
                timeout=self._config.timeout_seconds,
            )
            response.raise_for_status()
        except requests.RequestException as exc:
            raise FirewallClientError("failed to list managed firewall rules") from exc
        rules = response.json()
        # Defense in depth: never trust the server-side filter alone to scope
        # which rules we consider "ours" to remove.
        return [r for r in rules if str(r.get("comment", "")).startswith(comment_prefix)]

    def remove_rule(self, rule_id: str, comment_prefix: str) -> None:
        """Remove a rule by id, refusing to act on anything outside comment_prefix.

        Callers must have already fetched the rule via list_managed_rules
        (or otherwise verified its comment) to avoid this becoming a
        blanket-removal foot-gun.
        """
        try:
            response = self._session.get(
                f"{self._base_url}/ip/firewall/filter/{rule_id}",
                timeout=self._config.timeout_seconds,
            )
            response.raise_for_status()
        except requests.RequestException as exc:
            raise FirewallClientError(f"failed to fetch rule {rule_id} before removal") from exc

        comment = str(response.json().get("comment", ""))
        if not comment.startswith(comment_prefix):
            raise FirewallClientError(
                f"refusing to remove rule {rule_id}: comment {comment!r} "
                f"does not start with {comment_prefix!r}"
            )

        try:
            response = self._session.delete(
                f"{self._base_url}/ip/firewall/filter/{rule_id}",
                timeout=self._config.timeout_seconds,
            )
            response.raise_for_status()
        except requests.RequestException as exc:
            raise FirewallClientError(f"failed to remove rule {rule_id}") from exc
        logger.info("removed firewall rule %s", rule_id)
