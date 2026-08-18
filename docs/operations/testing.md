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
by generating real (authorized, harmless) attack-shaped traffic and
confirming Suricata alerts and `packetdevil` reacts correctly. This
complements, but is separate from, the automated `pytest` suite in
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

## Two kinds of test: external vs. internal

The RB5009's mirror only sees traffic that crosses its **WAN** interface
(see [docs/architecture/data-flow.md](../architecture/data-flow.md)), so
*where a test is run from* determines what it actually exercises:

| Category | Simulates | Run from | Scripts |
|---|---|---|---|
| **External** | An attacker on the Internet probing/attacking your public IP. | A host **outside** your own network (VPS, cloud shell). | [scripts/linux/tests/external/](../../scripts/linux/tests/external/) |
| **Internal** | A compromised/misbehaving host inside your LAN (cleartext credentials, phoning home, etc.). | A host **inside** your own LAN, behind the RB5009. | [scripts/linux/tests/internal/](../../scripts/linux/tests/internal/) |

See [scripts/linux/tests/README.md](../../scripts/linux/tests/README.md)
for the full rationale and safety rules common to both, and each
subdirectory's own README for category-specific details.

## Prerequisites

**External** tests: install tools **on the external host** you'll run them
from, not on your packetdevil/Suricata box — assume a bare/minimal host
and install everything explicitly, never rely on preinstalled tools:
```bash
sudo scripts/linux/tests/external/install-external-test-tool-prereqs.sh
```

**Internal** tests: install tools **on the internal test host**, inside
your own LAN behind the RB5009 — same assume-nothing-is-installed
approach:
```bash
sudo scripts/linux/tests/internal/install-internal-test-tool-prereqs.sh
```

See each subdirectory's README
([external](../../scripts/linux/tests/external/README.md),
[internal](../../scripts/linux/tests/internal/README.md)) for exactly
which tools each installs and why.

## Safety — read before running anything here

**External** scripts must only ever target an IP you own or are
explicitly authorized to test. **Internal** scripts only ever send
dummy/test data to public services designed for that purpose (e.g.
httpbun.com's Basic Auth test endpoint) — never real credentials. See
[scripts/linux/tests/README.md](../../scripts/linux/tests/README.md) and
the relevant subdirectory README for full details — every script enforces
this with printed warnings and an interactive confirmation prompt.

## Run from the correct vantage point

- **External** scripts (e.g. `simulate-port-scan.sh`) **must be run from
  a host outside your own network** — SSH into an external VPS/cloud host
  you control and run them from there. From inside your own LAN, traffic
  never crosses the RB5009's WAN interface, so it's never mirrored to
  Suricata and the test proves nothing. No external host available? Use
  this free web service to trigger a one-off nmap scan of your public IP
  instead: <http://hackertarget.com/nmap-online-port-scanner/>
- **Internal** scripts (e.g. `simulate-password-in-clear.sh`) **must be
  run from a host inside your own LAN**, behind the RB5009, so the
  outbound traffic gets NAT'd and mirrored the way a real internal host's
  traffic would be. Note: the resulting alert's `src_ip` will be your
  network's public (NAT'd) IP, not the internal host's private IP — see
  [docs/architecture/data-flow.md](../architecture/data-flow.md).

## Available test scripts

| Script | Category | Simulates | Expected result |
|---|---|---|---|
| [scripts/linux/tests/external/simulate-port-scan.sh](../../scripts/linux/tests/external/simulate-port-scan.sh) | External | `nmap -sS -sV -Pn <ip>` against your own public IP, run from an external host. | Suricata logs a recon/port-scan category alert in `eve.json`; `packetdevil` may create a temporary block against the scanning host (the external host you ran it from, or hackertarget.com's scanning IP if you used the web service). |
| [scripts/linux/tests/internal/simulate-password-in-clear.sh](../../scripts/linux/tests/internal/simulate-password-in-clear.sh) | Internal | `curl -su user:pass <url>` — dummy HTTP Basic Auth credentials sent in cleartext, run from inside your LAN. | Suricata logs a cleartext-credential/policy-violation alert; `packetdevil` may create a temporary block against your network's public (NAT'd) IP. |
| [scripts/linux/tests/internal/simulate-browser-crypto-mining.sh](../../scripts/linux/tests/internal/simulate-browser-crypto-mining.sh) | Internal | `dig +short <domain> @<resolver>` — DNS lookup of a known cryptocurrency mining-pool domain, run from inside your LAN. | Suricata logs a DNS reputation/threat-intel alert; `packetdevil` may create a temporary block against your network's public (NAT'd) IP. |
| [scripts/linux/tests/internal/simulate-tor-activity.sh](../../scripts/linux/tests/internal/simulate-tor-activity.sh) | Internal | `dig +short <domain> @<resolver>` — DNS lookup of a `.onion` (Tor hidden service) address, run from inside your LAN. | Suricata logs a Tor-usage policy alert (query is expected to return NXDOMAIN — the lookup attempt itself is the signal); `packetdevil` may create a temporary block against your network's public (NAT'd) IP. |
| [scripts/linux/tests/internal/simulate-tech-support-scammer.sh](../../scripts/linux/tests/internal/simulate-tech-support-scammer.sh) | Internal | `openssl s_client` TLS handshake against AnyDesk's real check-in host, run from inside your LAN. | Suricata logs a remote-access-tool detection alert; `packetdevil` may create a temporary block against your network's public (NAT'd) IP. |

Remove any resulting rule afterward rather than waiting out the TTL if you
need connectivity restored immediately — see
[docs/operations/runbooks/incident-response.md](runbooks/incident-response.md).

## Running a test end to end

1. Confirm the baseline pipeline is healthy first —
   [docs/operations/monitoring.md](monitoring.md).
2. Position yourself at the correct vantage point (external host or
   internal LAN host, per the table above) and run the relevant script
   (or trigger the hackertarget.com web scan for external tests without a
   VPS).
3. Watch for the alert, back on the Suricata box:
   ```bash
   sudo scripts/linux/tail-suricata-eve-alerts.sh
   ```
4. Check `packetdevil`'s reaction:
   ```bash
   sudo journalctl -u packetdevil -f
   ```
5. If a block rule was created, remove it manually rather than waiting
   out the TTL once you've confirmed detection worked — see
   [docs/reference/routeros-commands.md](../reference/routeros-commands.md).


## See also

- [scripts/linux/tests/README.md](../../scripts/linux/tests/README.md)
- [docs/operations/monitoring.md](monitoring.md)
- [docs/operations/troubleshooting.md](troubleshooting.md)
