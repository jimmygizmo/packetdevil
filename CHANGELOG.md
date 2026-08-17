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
