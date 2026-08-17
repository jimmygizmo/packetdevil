# AGENTS.md — Start Here

This file is the primary entry point for any AI coding agent (GitHub Copilot,
Claude, or other tools) working in this repository. Read this file first,
in full, before making changes. It links out to everything else you need.

## 1. What this project is

`packetdevil` is a DIY, enterprise-grade Network IDS/IPS built from:

- **MikroTik RB5009 + RouterOS** — mirrors all WAN traffic to a dummy
  interface, and exposes a firewall API used to add temporary block rules.
- **Linux box** — receives mirrored traffic via `tzsp2pcap`, runs **Suricata**
  against it.
- **tzsp2pcap** — converts RouterOS TZSP-encapsulated mirror traffic into a
  pcap stream/file that Suricata (or a pipe) can consume. We vendor and patch
  this project; see [vendor/tzsp2pcap/README.md](vendor/tzsp2pcap/README.md).
- **Suricata** — IDS/IPS engine doing the actual deep packet inspection and
  alerting (EVE JSON output is the integration point).
- **Custom Python app** (`src/packetdevil/`) — tails Suricata's `eve.json`,
  and for qualifying alerts:
  1. Calls the RouterOS REST/API to create a **temporary** firewall block rule.
  2. Sends a **Telegram** alert for the most serious threats (e.g. malware
     command-and-control / phone-home behavior).

This is a home/small-business lab project but is built to production
engineering standards. Contributors are senior engineers; documentation is
optimized for **AI agents first**, humans second — but both must be excellent.

> **Standing meta-directive:** this repo is also a deliberate case study in
> structuring a complex project for agentic AI development. When given a
> general (not task-specific) instruction about how to optimize this repo
> for AI-agent development, capture it durably (ADR, this file, a scoped
> `.instructions.md` rule, or a `docs/` convention) in addition to applying
> it — don't let it live only in chat history. See
> [ADR 0003](docs/architecture/decisions/0003-ai-engineering-case-study.md).

## 2. Repo map (read docs, not just code)

```
AGENTS.md                     ← you are here (root instructions)
.github/copilot-instructions.md   ← Copilot-specific operational rules
.github/instructions/*.instructions.md  ← scoped rules (applyTo globs)
docs/                         ← ALL project knowledge lives here. See docs/README.md.
  architecture/               ← system design, network topology, data flow, ADRs
  setup/                      ← ordered, numbered setup guides (00 → 06)
  operations/                 ← runbooks, monitoring, troubleshooting
  reference/                  ← command references, config references, glossary
  scenarios/                  ← end-to-end configuration scenarios/profiles
vendor/tzsp2pcap/              ← vendored upstream tzsp2pcap + our patches
src/packetdevil/               ← the Python application (installable package)
configs/                      ← example/template config files (never real secrets)
scripts/                      ← helper scripts (linux shell, RouterOS .rsc)
```

**Rule: if you learn something reusable about this project while working,
write it down in `docs/` (or repo memory) instead of only using it once.**
This repo is intentionally documentation-heavy because configurations vary
a lot between deployment scenarios (single WAN vs dual WAN, hardware
variants, rule tuning, etc.) — see [docs/scenarios/README.md](docs/scenarios/README.md).

## 3. How to navigate as an agent

1. Identify the task domain (RouterOS config? Suricata rules? Python app?
   tzsp2pcap patch? Documentation?).
2. Go to [docs/README.md](docs/README.md) — it is the index/map of all
   documentation and tells you exactly which file to read for that domain.
3. Check `.github/instructions/` — one of the scoped instruction files may
   `applyTo` the file type you're editing (e.g. `*.py`, `*.rsc`, `*.md`).
4. Check `docs/reference/glossary.md` for any unfamiliar term
   (TZSP, EVE JSON, RB5009, dummy interface, etc.) before guessing.
5. Prefer editing/adding a doc over leaving undocumented tribal knowledge in
   commit messages or chat.

## 4. Non-negotiable safety rules

This project issues **real commands against real network hardware** (a
router that provides the user's internet + LAN) and a Python service that
can **create live firewall rules automatically**. Treat these with care:

- **Never commit secrets.** RouterOS API credentials, Telegram bot tokens,
  and chat IDs go in a local `.env` / untracked config only. All checked-in
  config files under `configs/` are `*.example.*` templates with placeholder
  values. Verify `.gitignore` covers your new config paths.
- **Never write RouterOS/Linux commands that assume `sudo`/admin without
  clearly flagging them as privileged and requiring human confirmation** in
  docs/scripts — see [docs/reference/routeros-commands.md](docs/reference/routeros-commands.md)
  and [docs/reference/linux-commands.md](docs/reference/linux-commands.md)
  for the documented, reviewed command set. Don't invent new destructive
  commands (e.g. `/ip firewall filter remove`, `system reset-configuration`)
  without adding a clearly labeled "DESTRUCTIVE" callout and a rollback note.
- **Firewall rules created by the Python app must always be temporary**
  (carry an expiry/TTL and a scheduled removal), never permanent, unless a
  human explicitly changes that design — see
  [src/packetdevil/packetdevil/rules_engine.py](src/packetdevil/packetdevil/rules_engine.py).
- **Rate-limit and dedupe Telegram alerts.** Never let a code path allow an
  alert storm (e.g. one Telegram message per Suricata event with no
  batching/throttling).
- When unsure whether an action is reversible or safe to automate, stop and
  ask the human instead of guessing.

## 5. Coding conventions (summary — full detail in scoped instructions)

- Python: 3.11+, type hints everywhere, managed with `uv` (dependencies,
  venv, and running tools all go through `uv sync`/`uv run`/`uv add` — no
  bare `pip`/`venv`), `ruff` + `black` formatting, `pytest` for tests. Full
  detail:
  [.github/instructions/python.instructions.md](.github/instructions/python.instructions.md)
- Markdown/docs: see
  [.github/instructions/markdown.instructions.md](.github/instructions/markdown.instructions.md)
  for required structure (front matter, headings, "Verified on" dates, etc.)
- RouterOS scripts (`.rsc`): see
  [.github/instructions/routeros.instructions.md](.github/instructions/routeros.instructions.md)
- Shell scripts: see
  [.github/instructions/shell.instructions.md](.github/instructions/shell.instructions.md)

## 6. Definition of done for any change

- [ ] Code/config changes have a corresponding doc updated (setup guide,
      reference, or ADR if it's an architectural decision).
- [ ] New scripts are idempotent where possible and documented with a
      "what this does / how to verify / how to undo" section.
- [ ] Secrets are not present anywhere in the diff.
- [ ] Python changes pass `scripts/python/run-checks.sh` (or the
      equivalent `uv run pytest`/`uv run ruff check .`/`uv run black --check .`),
      and `uv.lock` is committed if dependencies changed (see
      [src/packetdevil/README.md](src/packetdevil/README.md)).
- [ ] If behavior affects a documented scenario in `docs/scenarios/`, that
      scenario doc is updated.
