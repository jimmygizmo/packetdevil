# scripts/

## Purpose

Helper scripts referenced from `docs/setup/` and `docs/operations/`. Every
script here is documented in a companion doc (see headers), and is written
to be idempotent — safe to re-run.

## Layout

```
scripts/
  linux/
    setup-dummy-interface.sh   # see docs/setup/02-linux-dummy-interface.md
    install-suricata.sh        # see docs/setup/04-suricata-install.md
    tail-suricata-eve-alerts.sh # tail eve.json alerts, compactly; see docs/reference/linux-commands.md
    tests/                     # ad-hoc, manually-run detection validation scripts
      README.md                  # internal vs external testing concept, see docs/operations/testing.md
      external/                  # run from a host OUTSIDE your network
        install-external-test-tool-prereqs.sh
        simulate-port-scan.sh
      internal/                  # run from a host INSIDE your LAN
        simulate-password-in-clear.sh
  python/
    run-checks.sh              # pytest + ruff + black via uv; --fix / --no-tests / --help
  routeros/
    configure-port-mirror.rsc  # see docs/setup/01-mikrotik-rb5009-port-mirroring.md
    remove-port-mirror.rsc     # rollback for the above
```

## Conventions

- Shell scripts: [.github/instructions/shell.instructions.md](../.github/instructions/shell.instructions.md).
- RouterOS scripts: [.github/instructions/routeros.instructions.md](../.github/instructions/routeros.instructions.md).
- Every mutating script states its blast radius in a header comment and has
  a documented rollback path (either inline or a companion `remove-*`/
  `rollback-*` script).
- Every script accepts `-h`/`--help` and prints what it's about to do
  (`echo "==> ..."` before each real command) rather than running silently
  — this matters most for auto-mode agents, which don't see a human
  reading along in real time.

## Capturing new commands as scripts

When you (human or agent) run an ad hoc sequence of commands more than
once during a session (build/test/lint loops, verification checks, etc.),
capture it here as a small, documented, idempotent script instead of
letting it live only in shell history or chat transcripts — see
[python/run-checks.sh](python/run-checks.sh) for the pattern: options for
common variations (`--fix`, `--no-tests`), `-h`/`--help`, and a header
comment explaining purpose/requirements/rollback.
