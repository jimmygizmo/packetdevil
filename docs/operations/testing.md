---
title: Manual Detection Testing
status: draft
last_verified: 2026-08-18
applies_to:
  - Suricata 7.x
  - Debian 12 / Ubuntu 22.04+
owner_domain: architecture
---

# Manual Detection Testing

## Purpose

This is how to validate the end-to-end detection pipeline with real traffic
that is explicitly authorized and harmless. The project now uses a single
Python runner at [scripts/linux/tests/simulations.py](../../scripts/linux/tests/simulations.py)
for all host setup and simulation commands, rather than maintaining separate
shell scripts in internal/external subdirectories.

This complements the automated `pytest` suite in
[src/packetdevil/tests/](../../src/packetdevil/tests/), which exercises the
Python app's logic in isolation.

## Why this remains manual/ad-hoc

The full path still depends on real network traffic crossing the RB5009's
WAN interface (see [docs/architecture/data-flow.md](../architecture/data-flow.md)).
That makes it environment-dependent and slower than a unit test, but it is
still the best way to confirm that Suricata sees the traffic and that
`packetdevil` reacts appropriately.

## Two kinds of validation traffic

The RB5009 only mirrors traffic that crosses its **WAN** interface, so the
location of the host matters:

| Category | Simulates | Run from |
|---|---|---|
| **External** | Internet-side recon / attack patterns against your public IP. | A host **outside** your own network (VPS, cloud shell). |
| **Internal** | Misbehaving or compromised host behavior inside your LAN. | A host **inside** your own LAN, behind the RB5009. |

The unified runner covers both cases in one place: see
[scripts/linux/tests/README.md](../../scripts/linux/tests/README.md).

## Setup and prerequisites

Use the Python runner to check and repair prerequisites for the correct host
category:

```bash
python3 scripts/linux/tests/simulations.py --setup
```

This checks the required tools, installs missing packages when necessary,
and creates the local setup directory state used by the runner.

For external tests, it will also store and reuse a public IP address that
it finds or the user provides. The stored path is:

```text
/tmp/packetdevil-test-hosts/external/public_ip.txt
```

## Safety — read before running anything here

- External tests must only target an IP you own or are explicitly
  authorized to test.
- Internal tests must be run from a host inside your own LAN and must use
  controlled, dummy, or public test endpoints only.
- Never send real credentials or attack third-party infrastructure without
  explicit permission.

## Available simulation actions

| Mode | Purpose |
|---|---|
| `--internal-tor` | Simulate outbound Tor-related DNS activity from an internal host. |
| `--internal-crypto` | Simulate outbound crypto-mining DNS activity from an internal host. |
| `--internal-scammer` | Simulate a tech-support scammer remote-control check-in pattern from an internal host. |
| `--internal-password` | Simulate cleartext credentials over HTTP Basic Auth from an internal host. |
| `--internal-all` | Run the internal outbound simulations. |
| `--external-scan` | Simulate inbound port scanning against your public IP from an external host. |
| `--external-all` | Run the external inbound simulations. |

## Example commands

```bash
python3 scripts/linux/tests/simulations.py --internal-all
python3 scripts/linux/tests/simulations.py --external-scan --public-ip=203.0.113.10
python3 scripts/linux/tests/simulations.py --external-all
```

## Running a test end to end

1. Confirm the baseline pipeline is healthy first —
   [docs/operations/monitoring.md](monitoring.md).
2. Run the correct command from the correct host vantage point (internal
   LAN host or external VPS/cloud shell).
3. Watch the Suricata alert stream:
   ```bash
   sudo scripts/linux/tail-suricata-eve-alerts.sh
   ```
4. Check `packetdevil`'s reaction:
   ```bash
   sudo journalctl -u packetdevil -f
   ```
5. If a temporary block rule was created, remove it manually rather than
   waiting out the TTL once validation is complete — see
   [docs/reference/routeros-commands.md](../reference/routeros-commands.md).

## See also

- [scripts/linux/tests/README.md](../../scripts/linux/tests/README.md)
- [docs/operations/monitoring.md](monitoring.md)
- [docs/operations/troubleshooting.md](troubleshooting.md)
