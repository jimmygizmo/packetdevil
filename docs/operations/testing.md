---
title: Manual Detection Testing
status: draft
last_verified: 2026-08-17
applies_to:
  - Suricata 7.x
  - Debian 12 / Ubuntu 22.04+
owner_domain: architecture
---

# Manual Detection Testing

## Purpose

How to validate, end to end, that the detection pipeline actually works —
by generating real (authorized, harmless) attack-shaped traffic against
your own infrastructure and confirming Suricata alerts and `packetdevil`
reacts correctly. This complements, but is separate from, the automated
`pytest` suite in
[src/packetdevil/tests/](../../src/packetdevil/tests/), which only tests
the Python app's logic in isolation with mocked network calls.

## Why these are manual/ad-hoc, not automated tests (for now)

Exercising the full pipeline (RouterOS mirror → `tzsp2pcap` → Suricata →
`packetdevil` → RouterOS block / Telegram) requires real network traffic
against real (or lab) hardware. That's valuable but environment-dependent
and slower than a unit test, so — as of this writing — these scripts are
run by hand when validating a deployment or a rule/config change, not
wired into CI or `scripts/python/run-checks.sh`. If/when this project adds
a repeatable lab environment (e.g. containerized), revisit this decision.

## Prerequisites

```bash
sudo scripts/linux/install-test-tool-prereqs.sh
```

Installs every tool the scripts in
[scripts/linux/tests/](../../scripts/linux/tests/) depend on (currently
`nmap`). Add new tools there, not ad hoc, as new test scripts are added.

## Safety — read before running anything here

**Only ever target infrastructure you own or are explicitly authorized to
test** (your own RB5009's public WAN IP, your own lab hosts). See the
full warning in
[scripts/linux/tests/README.md](../../scripts/linux/tests/README.md) —
every script in that directory enforces this with a required target
argument, a printed warning, and an interactive confirmation prompt.

## Available test scripts

| Script | Simulates | Expected result |
|---|---|---|
| [scripts/linux/tests/simulate-port-scan.sh](../../scripts/linux/tests/simulate-port-scan.sh) | External recon: `nmap -sS -sV -Pn <ip>` against your own public IP. | Suricata logs a recon/port-scan category alert in `eve.json`; depending on configured thresholds, `packetdevil` may create a temporary block against the scanning host (in this case, your own testing machine — remove the rule afterward, see [docs/operations/runbooks/incident-response.md](runbooks/incident-response.md)). |

## Running a test end to end

1. Confirm the baseline pipeline is healthy first —
   [docs/operations/monitoring.md](monitoring.md).
2. Run the test script from the box that has `nmap` installed (does not
   need to be the Suricata box itself, as long as it can reach your public
   IP — running it from *outside* your own network more realistically
   simulates external recon).
3. Watch for the alert:
   ```bash
   sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
   ```
4. Check `packetdevil`'s reaction:
   ```bash
   sudo journalctl -u packetdevil -f
   ```
5. If a block rule was created against your own testing host, remove it
   manually rather than waiting out the TTL if you need connectivity back
   immediately — see
   [docs/reference/routeros-commands.md](../reference/routeros-commands.md).

## See also

- [scripts/linux/tests/README.md](../../scripts/linux/tests/README.md)
- [docs/operations/monitoring.md](monitoring.md)
- [docs/operations/troubleshooting.md](troubleshooting.md)
