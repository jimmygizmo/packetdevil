---
applyTo: "src/packetdevil/**/*.py"
---

# Python Coding Instructions — packetdevil app

- Target Python 3.11+. Use built-in generic types (`list[str]`, `dict[str, int]`)
  not `typing.List`/`typing.Dict`.
- Type hints are required on all function signatures (params + return).
- Package/dependency management is [uv](https://docs.astral.sh/uv/) — never
  use bare `pip install` or `python -m venv` in this package. Run:
  ```
  cd src/packetdevil
  uv sync                # install/update .venv from pyproject.toml + uv.lock
  uv run ruff check .
  uv run black --check .
  ```
  Or use [scripts/python/run-checks.sh](../../scripts/python/run-checks.sh)
  (works from anywhere in the repo; `--fix` to auto-fix/reformat,
  `--no-tests` to skip pytest, `--help` for details) instead of running
  each `uv` command by hand.
  Add dependencies with `uv add <pkg>` / `uv add --dev <pkg>` (never edit
  `dependencies`/`dependency-groups` in `pyproject.toml` by hand and then
  forget to run `uv lock`/`uv sync` — the lock file must stay in sync).
  Commit `uv.lock` alongside `pyproject.toml` changes.
- Tests: `pytest` via `uv run pytest`, colocated under
  `src/packetdevil/tests/`, named `test_<module>.py`. Network calls
  (RouterOS API, Telegram) must be mocked in tests — never hit real endpoints.
- Config: all runtime configuration (RouterOS host/credentials, Telegram
  token/chat id, alert thresholds) is loaded via
  `packetdevil/config.py` from environment variables or a local
  untracked YAML file. Never hardcode secrets or example real IPs/tokens.
  Templates live in `configs/packetdevil/config.example.yaml`.
- Logging: use the standard `logging` module, not `print()`. Each module
  gets its own logger via `logging.getLogger(__name__)`.
- External calls (RouterOS REST API, Telegram Bot API) must:
  - have a timeout,
  - retry with backoff on transient network errors only,
  - never retry on 4xx auth errors,
  - be wrapped so a failure never crashes the alert-processing loop.
- Firewall rule creation (`rules_engine.py`) must always attach an
  expiry/TTL and rely on a scheduled cleanup path — no permanent rule
  creation without an explicit, separately reviewed code path.
- Prefer dataclasses (`@dataclass`) for structured records (alerts, rules)
  over bare dicts once a shape stabilizes.
- Docstrings: module- and public-function-level docstrings are expected;
  skip docstrings on obvious private helpers.
