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

## Run from OUTSIDE your own network

Scripts that target your public WAN IP — `simulate-port-scan.sh` — **must
be run from a host outside your own network**: SSH into an external
VPS/cloud host you control (or use a cloud shell) and run the script from
there. Traffic generated from inside your own LAN, or from the Suricata
box itself, never crosses the RB5009's WAN interface, so it is never
mirrored to Suricata — the test would silently prove nothing.

No external host available? Use this free web service to trigger a
one-off nmap scan of your public IP instead:
<http://hackertarget.com/nmap-online-port-scanner/>

## Available test scripts

| Script | Simulates | Expected result |
|---|---|---|
| [scripts/linux/tests/simulate-port-scan.sh](../../scripts/linux/tests/simulate-port-scan.sh) | External recon: `nmap -sS -sV -Pn <ip>` against your own public IP, run from an external host. | Suricata logs a recon/port-scan category alert in `eve.json`; depending on configured thresholds, `packetdevil` may create a temporary block against the scanning host (the external host you ran it from, or hackertarget.com's scanning IP if you used the web service — remove the rule afterward, see [docs/operations/runbooks/incident-response.md](runbooks/incident-response.md)). |

## Running a test end to end

1. Confirm the baseline pipeline is healthy first —
   [docs/operations/monitoring.md](monitoring.md).
2. SSH into a host **outside your own network** (external VPS, cloud
   shell, etc.) that has `nmap` installed — see
   [scripts/linux/install-test-tool-prereqs.sh](../../scripts/linux/install-test-tool-prereqs.sh)
   — or use the hackertarget.com web service above if you don't have one.
3. From that external host, run the test script (or trigger the web scan)
   against your public IP.
4. Watch for the alert, back on the Suricata box:
   ```bash
   sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
   ```
5. Check `packetdevil`'s reaction:
   ```bash
   sudo journalctl -u packetdevil -f
   ```
6. If a block rule was created against the external host/service you
   tested from, remove it manually rather than waiting out the TTL once
   you've confirmed detection worked — see
   [docs/reference/routeros-commands.md](../reference/routeros-commands.md).

## See also

- [scripts/linux/tests/README.md](../../scripts/linux/tests/README.md)
- [docs/operations/monitoring.md](monitoring.md)
- [docs/operations/troubleshooting.md](troubleshooting.md)
