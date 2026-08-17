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
- `scripts/linux/tests/`: ad-hoc, manually-run detection-validation
  scripts, split into `external/` (run from outside your network, e.g.
  `simulate-port-scan.sh`) and `internal/` (run from inside your LAN,
  e.g. `simulate-password-in-clear.sh`), each with its own prereqs and
  README, plus [docs/operations/testing.md](docs/operations/testing.md)
  and a `tail-suricata-eve-alerts.sh` helper.
- [ADR 0003](docs/architecture/decisions/0003-ai-engineering-case-study.md):
  recorded the standing directive that this repo is also a case study in
  agentic AI software engineering, and that general AI-optimization
  instructions should be captured durably (ADR/AGENTS.md/instructions/docs
  convention), not just applied once.
