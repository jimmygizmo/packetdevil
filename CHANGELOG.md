# Changelog

All notable changes to this project are documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/); dates are
`YYYY-MM-DD`.

## [Unreleased]

### Added

- Initial project structure optimized for agentic AI development:
  `AGENTS.md`, scoped `.github/instructions/*.instructions.md`, and a
  `docs/` tree (`architecture/`, `setup/`, `reference/`, `operations/`,
  `scenarios/`) covering the RB5009 + RouterOS mirror → `tzsp2pcap` →
  Suricata → `packetdevil` pipeline.
- `vendor/tzsp2pcap/` scaffold for vendoring + patching upstream
  `tzsp2pcap` (see ADR 0001).
- `src/packetdevil/` Python app skeleton (config loading, `eve.json`
  tailing, alert classification, RouterOS firewall client, Telegram
  notifier, CLI), managed with `uv`, with an initial test suite.
- `configs/` and `scripts/` templates for Suricata, `tzsp2pcap`,
  `packetdevil`, and RouterOS mirror configuration.
- `scripts/python/run-checks.sh`: consolidated, documented wrapper around
  `uv run pytest`/`ruff`/`black` (with `--fix`/`--no-tests`/`--help`),
  callable from anywhere in the repo. Replaces two ad hoc, overlapping
  shell one-offs.
- `scripts/linux/tests/simulations.py`: unified Python runner for the
  project's internal/external validation traffic, including prerequisite
  setup, host repair, and stored public-IP logic for external scans.
- [docs/operations/testing.md](docs/operations/testing.md): rewritten to
  describe the unified runner and its safety model instead of the old
  shell-script-per-host workflow.
- `tail-suricata-eve-alerts.sh` helper retained as part of the Linux
  command set, while the old shell-based test scripts were retired from
  the project tree.
- [ADR 0003](docs/architecture/decisions/0003-ai-engineering-case-study.md):
  recorded the standing directive that this repo is also a case study in
  agentic AI software engineering, and that general AI-optimization
  instructions should be captured durably (ADR/AGENTS.md/instructions/docs
  convention), not just applied once.
