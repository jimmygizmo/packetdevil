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
