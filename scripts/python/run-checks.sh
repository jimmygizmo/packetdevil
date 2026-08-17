#!/usr/bin/env bash
# Script: scripts/python/run-checks.sh
# Purpose: run packetdevil's Python test suite, ruff lint, and black format
#          check (or auto-fix) via `uv`, callable from anywhere in the repo.
# Requires: uv installed (https://docs.astral.sh/uv/); no root; no network
#           changes; no package installs beyond `uv sync` managing .venv.
# Rollback: read-only by default (no mutation). `--fix` mutates tracked
#           source files under src/packetdevil — review with `git diff`
#           and `git checkout -- <file>` to revert if unwanted.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/../../src/packetdevil" && pwd)"

run_tests=1
fix=0

usage() {
  cat <<'EOF'
Usage: scripts/python/run-checks.sh [options]

Runs (via `uv run`, against src/packetdevil regardless of caller cwd):
  1. uv sync            - install/update .venv from pyproject.toml + uv.lock
  2. pytest              - the test suite (unless --no-tests)
  3. ruff check           - lint
  4. black --check         - format check

Options:
  --fix         Auto-fix ruff findings and reformat with black instead of
                just checking (mutates files under src/packetdevil).
  --no-tests    Skip pytest; only lint/format (check or --fix).
  -h, --help    Show this help and exit.

Examples:
  scripts/python/run-checks.sh              # what CI/AGENTS.md "definition of done" expects
  scripts/python/run-checks.sh --fix         # auto-fix lint + formatting before committing
  scripts/python/run-checks.sh --no-tests    # quick lint/format-only pass while iterating
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix) fix=1; shift ;;
    --no-tests) run_tests=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

cd "${PACKAGE_DIR}"

echo "==> uv sync (${PACKAGE_DIR})"
uv sync --quiet

if [[ "${run_tests}" -eq 1 ]]; then
  echo "==> uv run pytest -q"
  uv run pytest -q
else
  echo "==> skipping tests (--no-tests)"
fi

if [[ "${fix}" -eq 1 ]]; then
  echo "==> uv run ruff check --fix ."
  uv run ruff check --fix .
  echo "==> uv run black ."
  uv run black .
else
  echo "==> uv run ruff check ."
  uv run ruff check .
  echo "==> uv run black --check ."
  uv run black --check .
fi

echo "all checks passed"
