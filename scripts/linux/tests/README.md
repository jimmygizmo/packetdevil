---
title: Unified Linux Simulation Runner
status: draft
last_verified: 2026-08-18
applies_to:
  - Debian 12 / Ubuntu 22.04+
  - Suricata 7.x
owner_domain: linux
---

# Unified Linux Simulation Runner

## Purpose

This directory now hosts a single Python program,
[simulations.py](simulations.py), which replaces the old ad-hoc shell-based
simulation scripts. The tool is the canonical entry point for two kinds of
manual validation traffic:

- outbound simulations from a host inside your LAN
- inbound simulation traffic from an external host targeting your public IP

It is used to confirm the full path works end to end: RouterOS mirror →
`tzsp2pcap` → Suricata → `packetdevil` → temporary block behavior.

## What the runner does

`simulations.py` does all of the following in one place:

- validates and repairs prerequisites for the internal or external
  simulation host
- installs missing Linux tools as needed (for example: `curl`, `dig`,
  `openssl`, `nmap`)
- creates and maintains the local setup state for configured hosts
- runs the project’s known simulation commands without requiring separate
  shell scripts per scenario
- persists a stored external public IP for reuse across external tests
- supports a one-time `--public-ip` override and a stored-value workflow

This is intentionally a single, central entry point rather than
splitting the work into `internal/` and `external/` script trees.

## Command overview

### Setup mode

Use this to ensure the host is ready before running any simulation:

```bash
python3 scripts/linux/tests/simulations.py --setup
```

This checks the Linux tooling required for the relevant host type, installs
missing packages, and ensures the local setup directories/files are present.

### Internal simulations

These are outbound behaviors from a host inside your LAN, behind the
RB5009:

```bash
python3 scripts/linux/tests/simulations.py --internal-tor
python3 scripts/linux/tests/simulations.py --internal-crypto
python3 scripts/linux/tests/simulations.py --internal-scammer
python3 scripts/linux/tests/simulations.py --internal-password
python3 scripts/linux/tests/simulations.py --internal-all
```

The program runs the same kinds of real network actions the old shell
scripts performed, simplified into a single interface.

### External simulations

These are inbound recon/attack patterns aimed at your public IP, to be run
from an external host outside your LAN:

```bash
python3 scripts/linux/tests/simulations.py --external-scan
python3 scripts/linux/tests/simulations.py --external-all
```

For external tests, the runner uses a stored public IP when available:

```bash
python3 scripts/linux/tests/simulations.py --external-scan --public-ip=203.0.113.10
```

If no public IP has been stored yet, the user is prompted to enter it and
it is saved for future reuse. The stored value lives at:

```text
/tmp/packetdevil-test-hosts/external/public_ip.txt
```

To change it later, remove that file and rerun the command. The program
will notify the user when it is using the stored value.

## Safety notes

These tests still exercise real network behavior and must only be run
against infrastructure you own or are explicitly authorized to test.

- External simulations must target your own public IP or a clearly
  authorized test target.
- Internal simulations must be run from a host inside your own LAN,
  behind the RB5009, not from the packetdevil/Suricata box itself.
- The tool prints clear progress output with emoji indicators so the user
  can follow the setup and execution phases in a readable way.

## Files in this directory

- [simulations.py](simulations.py) — unified simulation runner and setup tool
- [README.md](README.md) — this document

## See also

- [docs/operations/testing.md](../../../docs/operations/testing.md)
- [docs/operations/monitoring.md](../../../docs/operations/monitoring.md)
- [docs/architecture/data-flow.md](../../../docs/architecture/data-flow.md)
