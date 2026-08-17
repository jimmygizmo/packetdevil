# scripts/linux/tests/ — Ad-hoc Detection Validation Scripts

## Purpose

Small, manually-run scripts that generate real (but harmless/authorized)
attack-shaped traffic against your own infrastructure, so you can confirm
Suricata detects it and `packetdevil` reacts (block + Telegram alert where
expected). These are **not** part of the automated `pytest` suite in
[src/packetdevil/tests/](../../../src/packetdevil/tests/) — they touch a
real network/router and are run ad-hoc by a human when validating an
end-to-end deployment or a rule/config change.

## ⚠️ Safety — read before running anything here

Every script in this directory must only ever be pointed at
infrastructure **you own or are explicitly authorized to test**
(your own RB5009 WAN IP, your own lab hosts). Scanning or attacking
systems you don't control without authorization can be illegal (e.g.
under the US Computer Fraud and Abuse Act or equivalent laws elsewhere)
and may violate your ISP's terms of service. Each script:

- prints this warning in its `--help` output and again at runtime,
- requires an explicit target argument (never a hardcoded/guessed IP),
- requires interactive confirmation before running, unless `-y`/`--yes`
  is passed for scripted use.

## Prerequisites

Install every tool these scripts depend on (currently: `nmap`) via:

```bash
sudo scripts/linux/install-test-tool-prereqs.sh
```

This script is the single, standard place new tool dependencies for this
directory get added — see its header before installing anything by hand.

## Available scripts

| Script | What it does |
|---|---|
| [simulate-port-scan.sh](simulate-port-scan.sh) | `nmap -sS -sV -Pn <ip>` — SYN + version scan against one IP, to trigger/verify recon-style Suricata alerts. |

Run any script with `-h`/`--help` for full usage.

## Adding a new ad-hoc test script

1. Add the script here, following
   [.github/instructions/shell.instructions.md](../../../.github/instructions/shell.instructions.md)
   (header comment, `set -euo pipefail`, idempotent where applicable).
2. If it targets a live IP/host, copy the safety pattern from
   [simulate-port-scan.sh](simulate-port-scan.sh): explicit required
   target argument, warning in `--help`, interactive confirmation with a
   `-y`/`--yes` bypass for scripted use.
3. Add any new tool dependency to
   [install-test-tool-prereqs.sh](../install-test-tool-prereqs.sh).
4. Add a row to the table above.
5. Note it in [docs/operations/testing.md](../../../docs/operations/testing.md).

## See also

- [docs/operations/testing.md](../../../docs/operations/testing.md)
- [docs/operations/monitoring.md](../../../docs/operations/monitoring.md)
