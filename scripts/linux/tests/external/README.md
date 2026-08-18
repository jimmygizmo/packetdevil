# scripts/linux/tests/external/ — Simulated External Attacker

## Purpose

Scripts here simulate an attacker on the **Internet** probing or attacking
your public IP — recon scans, exploit attempts, etc. — so you can confirm
Suricata/`packetdevil` detect and react to *inbound* threats the way they
would from a real external attacker.

## ⚠️ Run from OUTSIDE your own network

Every script here **must be run from a host outside your own network**
(an external VPS, a cloud shell, etc.) — SSH into it and run the script
from there, targeting your own public IP. If you run these from inside
your LAN or from the Suricata box itself, the traffic never crosses the
RB5009's WAN interface, so it is **never mirrored to Suricata** and the
test proves nothing.

No external host available? Use this free web service to trigger a
one-off nmap scan of your public IP instead:
<http://hackertarget.com/nmap-online-port-scanner/>

## ⚠️ Safety

Only ever target an IP address **you own or are explicitly authorized to
test** (e.g. your own RB5009's public WAN IP). Port scanning or attacking
systems you don't control without authorization can be illegal (e.g.
under the US Computer Fraud and Abuse Act or equivalent laws elsewhere)
and may violate your ISP's terms of service. Every script here:

- requires an explicit target argument (never a hardcoded/guessed IP),
- prints this warning in its `--help` output and again at runtime,
- requires interactive confirmation before running, unless `-y`/`--yes`
  is passed for scripted use.

## Prerequisites

Run this **on the external host**, not on your packetdevil/Suricata box:

```bash
sudo scripts/linux/tests/external/install-external-test-tool-prereqs.sh
```

Assumes a bare/minimal host and installs every tool the scripts below
depend on explicitly (currently `nmap`, plus `dnsutils` for `dig` ahead of
future DNS-based external scripts) rather than assuming any of them are
preinstalled. Add new tool dependencies here as new external test scripts
are added.

## Available scripts

| Script | What it does |
|---|---|
| [simulate-port-scan.sh](simulate-port-scan.sh) | `nmap -sS -sV -Pn <ip>` — SYN + version scan against your public IP, to trigger/verify recon-style Suricata alerts. |

Run any script with `-h`/`--help` for full usage.

## See also

- [../README.md](../README.md) — general internal-vs-external overview
- [docs/operations/testing.md](../../../../docs/operations/testing.md)
