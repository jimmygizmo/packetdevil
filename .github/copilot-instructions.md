# GitHub Copilot Instructions

> Read [AGENTS.md](../AGENTS.md) at the repo root first — it is the
> canonical entry point for all agents, not just Copilot. This file adds
> Copilot/VS Code-specific operating notes on top of it.

## Operating modes this repo expects

This repo is worked on both by **Copilot in Auto mode** (most common — pick
the model, run largely unattended across multi-step tasks) and by advanced
developers steering specific models manually. Write every doc, comment, and
script so it works well for the *unattended* case:

- Prefer explicit, self-contained instructions over "as discussed above" —
  Auto mode may not retain long context across a long session.
- Prefer many small, well-named files over few large ones. Auto mode agents
  navigate by filename and headings; keep [docs/README.md](../docs/README.md)
  as the always-current index.
- Every setup/runbook doc must be independently executable: assume the agent
  has *not* read any other doc unless this one links to it.

## Before making changes

1. Check `docs/README.md` for the doc that owns this topic. If one exists,
   update it — don't create a duplicate/competing doc.
2. Check `.github/instructions/*.instructions.md` for scoped rules matching
   the file(s) you're editing (matched via `applyTo` front matter globs).
3. Check `/memories/repo/` (repo memory) for previously recorded, verified
   facts about this codebase (build commands, gotchas, hardware specifics).

## High-risk actions requiring explicit human confirmation

Do not execute (only draft/document) commands in these categories unless the
human has explicitly asked you to run them right now:

- Any RouterOS command under `/ip firewall`, `/interface`, `/system` that
  mutates live config on the RB5009.
- Any Linux command that changes network interfaces, iptables/nftables, or
  systemd services on the Suricata box.
- Anything that would send a real Telegram message or call the real
  RouterOS API (use dry-run/mock modes in tests — see
  `src/packetdevil/README.md`).

## Python app conventions (quick reference)

See [.github/instructions/python.instructions.md](instructions/python.instructions.md)
for full detail. Quick facts: package lives in `src/packetdevil/packetdevil/`,
managed with `uv` (never bare `pip`/`venv`), use `ruff` + `black`, tests in
`src/packetdevil/tests/`, run everything at once via
`scripts/python/run-checks.sh` (or `uv run pytest` from `src/packetdevil/`).

## Documentation conventions (quick reference)

See [.github/instructions/markdown.instructions.md](instructions/markdown.instructions.md).
Every doc under `docs/` uses the standard front matter block (status, owner
domain, last-verified date, applies-to hardware/software versions) so an
agent can judge whether a doc might be stale before trusting it.
