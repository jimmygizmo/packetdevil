# packetdevil (Python app)

## Purpose

Tails Suricata's `eve.json`, classifies alerts, creates temporary RouterOS
firewall blocks for qualifying threats, and sends Telegram alerts for the
most severe categories (e.g. malware C2 / phone-home).

Full narrative docs live under [docs/](../../docs/) — start with
[docs/architecture/data-flow.md](../../docs/architecture/data-flow.md) and
[docs/setup/05-python-app-install.md](../../docs/setup/05-python-app-install.md).
This README covers only how to work on the code itself.

## Layout

```
packetdevil/
  __init__.py
  config.py             # loads/validates YAML config + env overrides
  suricata_eve.py        # tails eve.json, yields parsed alert events
  rules_engine.py         # classifies alerts -> ignore / block / block+notify, TTL logic
  firewall_client.py       # RouterOS REST API client (create/list/remove temp rules)
  telegram_notifier.py      # Telegram Bot API client, rate-limited
  cli.py                    # wires everything together; entry point
tests/
```

## Development

This package is managed with [uv](https://docs.astral.sh/uv/). uv resolves
dependencies, creates/manages `.venv`, and runs tools — no manual
`python -m venv` or `pip install` steps.

```bash
cd src/packetdevil
uv sync                 # creates .venv, installs project + dev dependency group

uv run ruff check .
uv run black --check .
uv run pytest
```

Adding a dependency: `uv add <package>` (runtime) or
`uv add --dev <package>` (dev-only). Commit the updated `pyproject.toml`
and `uv.lock` together.

## Running locally against a real Suricata log (dry run)

```bash
uv run packetdevil --config configs/packetdevil/config.example.yaml --dry-run
```
`--dry-run` classifies alerts and logs the actions it *would* take without
calling the RouterOS API or Telegram — always test new config/thresholds
this way first.

## Testing conventions

- All RouterOS API and Telegram calls are mocked in tests — see
  `tests/test_rules_engine.py` for the pattern (dependency-injected client
  objects, not module-level network calls).
- New alert-classification behavior needs a test in
  `tests/test_rules_engine.py` covering both the "should block" and
  "should not block" boundary.

## See also

- [.github/instructions/python.instructions.md](../../.github/instructions/python.instructions.md)
- [docs/reference/firewall-api-reference.md](../../docs/reference/firewall-api-reference.md)
