# scripts/linux/tests/internal/ — Simulated Internal Misbehavior

## Purpose

Scripts here simulate a host **inside your own LAN** doing something it
shouldn't — a compromised host phoning home, leaking credentials in
cleartext, using a prohibited protocol, etc. — so you can confirm
Suricata/`packetdevil` detect and react to *outbound/internal-origin*
threats, not just inbound ones.

## ⚠️ Run from INSIDE your own network

Every script here **must be run from a host inside your own LAN**, behind
the RB5009 — not from an external host. The point is to generate outbound
traffic that gets NAT'd and mirrored on the WAN interface, exercising the
same path a real compromised internal host's traffic would take.

**Important NAT caveat:** Suricata's WAN mirror only sees this traffic
*after* the RB5009 rewrites the source address (NAT). That means any
resulting alert's `src_ip` will be your network's public (NAT'd) IP, not
the internal host's private IP — see
[docs/architecture/data-flow.md](../../../../docs/architecture/data-flow.md)
("Failure-mode notes") before interpreting results or reasoning about what
a resulting temporary block actually covers.

## ⚠️ Safety

Scripts here only ever send dummy/test data to public services explicitly
designed for this kind of testing (e.g. httpbun.com's Basic Auth test
endpoint) — never real credentials, personal data, or requests against
infrastructure you don't control. Every script here:

- prints this warning in its `--help` output and again at runtime,
- requires interactive confirmation before running, unless `-y`/`--yes`
  is passed for scripted use.

## Prerequisites

Run this **on the internal test host**, inside your own LAN behind the
RB5009:

```bash
sudo scripts/linux/tests/internal/install-internal-test-tool-prereqs.sh
```

Assumes a bare/minimal host and installs every tool the scripts below
depend on explicitly (currently `curl`, `dnsutils` for `dig`, and
`openssl`) rather than assuming any of them are preinstalled. Add new
tool dependencies here as new internal test scripts are added.

## Available scripts

| Script | What it does |
|---|---|
| [simulate-password-in-clear.sh](simulate-password-in-clear.sh) | `curl -su user:pass <url>` (default: httpbun.com's Basic Auth test endpoint) — sends dummy credentials over plain HTTP, to trigger/verify cleartext-credential / policy-violation Suricata alerts. |
| [simulate-browser-crypto-mining.sh](simulate-browser-crypto-mining.sh) | `dig +short <domain> @<resolver>` (default: a known Monero mining-pool domain) — simulates the DNS lookup a cryptojacking browser tab/host would make, to trigger/verify DNS reputation Suricata alerts. |
| [simulate-tor-activity.sh](simulate-tor-activity.sh) | `dig +short <domain> @<resolver>` (default: a `.onion` test domain) — simulates a host attempting to resolve a Tor hidden service, to trigger/verify Tor-usage policy Suricata alerts. |
| [simulate-tech-support-scammer.sh](simulate-tech-support-scammer.sh) | `openssl s_client` TLS handshake against AnyDesk's real check-in host — simulates the network pattern of a tech-support-scam victim's freshly installed AnyDesk client, to trigger/verify remote-access-tool Suricata alerts. |

Run any script with `-h`/`--help` for full usage.

## See also

- [../README.md](../README.md) — general internal-vs-external overview
- [docs/operations/testing.md](../../../../docs/operations/testing.md)
- [docs/architecture/data-flow.md](../../../../docs/architecture/data-flow.md)
