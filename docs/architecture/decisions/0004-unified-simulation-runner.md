---
title: "ADR 0004: Consolidate all simulation setup and execution into a single Python runner"
status: accepted
last_verified: 2026-08-18
applies_to:
  - Debian 12 / Ubuntu 22.04+
  - Suricata 7.x
  - Python 3.11+
owner_domain: architecture
---

# ADR 0004: Consolidate all simulation setup and execution into a single Python runner

## Status

Accepted

## Context

The project had grown a split test workflow for simulated traffic: one set of
shell scripts for internal suspicious behavior and another set for external
attack traffic. Each set duplicated prerequisite checks, install commands, and
host-specific assumptions. The result was operational drift: the same workflow
was described in multiple places, setup steps were inconsistent, and the repo's
actual test story was harder to reason about than the underlying IDS pipeline.

This problem was amplified by the real-world constraints of the project:

- the internal host and external host are different deployment contexts
- both require a careful setup phase before traffic generation
- the external workflow depends on the user's public IP address and should be
  reproducible without repeated manual prompting
- the tooling should be predictable for agents and humans alike, even when the
  exact simulation target changes from lab to lab

The old shell-script layout also made it difficult to maintain the project as a
single coherent system: every new test or setup change meant editing multiple
small scripts and keeping several READMEs synchronized.

## Decision

We will use a single Python CLI entrypoint, [scripts/linux/tests/simulations.py](../../../scripts/linux/tests/simulations.py), to perform all simulation setup and execution tasks for both internal and external hosts, and retire the fragmented shell-script model.

## Options considered

1. **Keep the split shell-script approach** — Pros: feels familiar and simple for one-off testing. Cons: repeated prerequisite logic, duplicated install instructions, fragmented documentation, inconsistent setup paths, and a high maintenance burden as the project grows.
2. **Create a hybrid model with some Python and some shell scripts** — Pros: incremental migration path. Cons: still leaves two mental models and keeps the same duplication problem; each additional script adds more places for drift.
3. **Use a single Python runner with setup and simulation commands (chosen)** — Pros: one implementation for all setup tasks, one place to document prerequisites, one CLI surface for both internal and external hosts, easier automation, easier docs maintenance, and a natural place to add persistent public-IP resolution logic. Cons: a little more initial design work and a deliberate migration step from the old scripts.

## Consequences

- Simulation setup and traffic generation now follow a single, documented flow.
- Prerequisite checks live in one place instead of being repeated across host-specific shell scripts.
- The project can more easily add new internal/external simulation patterns without creating another shell-script silo.
- The external workflow can use a stored public IP and a clear override path via `--public-ip`, which reduces repeated manual work and makes validation more reproducible.
- Documentation no longer needs to describe parallel shell-script families or duplicate instructions across multiple README files.
- The migration intentionally removes the old split model as a tradeoff: this is more maintainable, but it requires contributors to learn the centralized runner instead of the older script-per-host layout.

## See also

- [scripts/linux/tests/README.md](../../../scripts/linux/tests/README.md)
- [docs/operations/testing.md](../../operations/testing.md)
- [docs/architecture/decisions/README.md](README.md)
