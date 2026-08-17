# scripts/linux/tests/ — Ad-hoc Detection Validation Scripts

## Purpose

Small, manually-run scripts that generate real (but harmless/authorized)
attack-shaped traffic so you can confirm Suricata detects it and
`packetdevil` reacts (block + Telegram alert where expected). These are
**not** part of the automated `pytest` suite in
[src/packetdevil/tests/](../../../src/packetdevil/tests/) — they touch a
real network/router and are run ad hoc by a human when validating an
end-to-end deployment or a rule/config change.

## Two kinds of test, two subdirectories

The mirror this whole project is built on only sees traffic that actually
crosses the RB5009's **WAN** interface (see
[docs/architecture/data-flow.md](../../../docs/architecture/data-flow.md)).
That means *where a test script must be run from* is part of what it's
testing, not incidental — so scripts here are split by required vantage
point:

| Subdirectory | Simulates | Must be run from |
|---|---|---|
| [external/](external/) | An attacker on the Internet probing/attacking your public IP (recon, exploit attempts). | A host **outside** your own network (external VPS, cloud shell). |
| [internal/](internal/) | A compromised or misbehaving host *inside* your LAN doing something it shouldn't (cleartext credentials, phoning home, prohibited protocols). | A host **inside** your own LAN, behind the RB5009. |

Read the README in whichever subdirectory matches what you're testing —
each has its own safety notes, prerequisites, and script index.

## ⚠️ Safety — applies to every script here

Every script in this directory tree must only ever be pointed at
infrastructure/services **you own or are explicitly authorized to test**
against dummy/test data, never real credentials or third-party systems
without permission. See [external/README.md](external/README.md) and
[internal/README.md](internal/README.md) for the specific rules and
guardrails each category enforces (required arguments, printed warnings,
interactive confirmation with a `-y`/`--yes` bypass for scripted use).

## Adding a new ad-hoc test script

1. Decide which vantage point the test requires (external attacker vs.
   internal misbehaving host) and add it to that subdirectory — see that
   subdirectory's README for its specific conventions.
2. Follow
   [.github/instructions/shell.instructions.md](../../../.github/instructions/shell.instructions.md)
   (header comment, `set -euo pipefail`, `-h`/`--help`, idempotent where
   applicable).
3. Add any new tool dependency to that subdirectory's prereqs installer.
4. Add a row to that subdirectory's README table.
5. Update [docs/operations/testing.md](../../../docs/operations/testing.md).

## See also

- [docs/operations/testing.md](../../../docs/operations/testing.md)
- [docs/operations/monitoring.md](../../../docs/operations/monitoring.md)
- [docs/architecture/data-flow.md](../../../docs/architecture/data-flow.md)
