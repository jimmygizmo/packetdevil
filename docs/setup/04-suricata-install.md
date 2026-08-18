---
title: Suricata Install & Configuration
status: draft
last_verified: 2026-08-16
applies_to:
  - Suricata 7.x
  - Debian 12 / Ubuntu 22.04+
owner_domain: suricata
---

# 04 — Suricata Install & Configuration

## Purpose

Install Suricata, point it at the `dummy0` interface, load a ruleset, and
confirm `eve.json` alert output is being produced — the integration point
the Python app depends on.

This repo intentionally keeps Suricata installation separate from the
`tzsp2pcap` build/install flow. The latter is already fully documented in
[03-tzsp2pcap-install.md](03-tzsp2pcap-install.md), and the script below
only manages the Suricata side plus the common Linux tooling used to
inspect and validate alerts.

## Prerequisites

- [03-tzsp2pcap-install.md](03-tzsp2pcap-install.md) completed and verified
  (real traffic visible on `dummy0`).
- The Linux box has the baseline development tools already in place (see
  [00-prerequisites.md](00-prerequisites.md)); `build-essential` and `git`
  are part of the system baseline even though they are not used here to
  rebuild `tzsp2pcap`.

## Steps

1. **Install Suricata and project support tooling** with the repo helper:
   ```bash
   sudo scripts/linux/install-suricata.sh
   ```
   This installs the Suricata PPA, `suricata`, `jq`, `tcpreplay`, and the
   build/packet tools commonly used in this repo. It does not duplicate the
   vendored `tzsp2pcap` build/install flow; that is intentionally covered
   only in [03-tzsp2pcap-install.md](03-tzsp2pcap-install.md).

   If you prefer to do it manually, the equivalent commands are:
   ```bash
   sudo add-apt-repository ppa:oisf/suricata-stable
   sudo apt update
   sudo apt install -y suricata jq tcpreplay git build-essential libpcap-dev
   sudo suricata-update
   ```

2. **Configure the capture interface** in `/etc/suricata/suricata.yaml`:
   ```yaml
   af-packet:
     - interface: dummy0
       cluster-id: 99
       cluster-type: cluster_flow
   ```
   Use [configs/suricata/suricata.yaml.example](../../configs/suricata/suricata.yaml.example)
   as the starting template rather than distro defaults.

3. **Enable EVE JSON alert output** (usually on by default in recent
   Suricata, confirm):
   ```yaml
   outputs:
     - eve-log:
         enabled: yes
         filetype: regular
         filename: eve.json
         types:
           - alert:
               tagged-packets: yes
   ```

4. **Update rules** (via `suricata-update`, pulling Emerging Threats Open
   or another documented ruleset):
   ```bash
   sudo suricata-update
   ```

5. **Start Suricata** and confirm it's running against `dummy0`:
   ```bash
   sudo systemctl enable --now suricata
   ```

## Verification

```bash
sudo systemctl status suricata
sudo tail -f /var/log/suricata/eve.json
```
Generate test traffic (e.g. visit `testmynids.org`'s test page from a LAN
client, if applicable to your ruleset) and confirm a corresponding
`event_type: alert` line appears.

## Rollback / Undo

```bash
sudo systemctl disable --now suricata
```

## Troubleshooting

- No alerts ever fire: confirm `dummy0` actually carries traffic (step 03
  verification), and that the ruleset includes signatures likely to match
  your test traffic.
- High CPU / dropped packets: see
  [docs/reference/suricata-config-reference.md](../reference/suricata-config-reference.md)
  sizing/tuning notes and
  [docs/scenarios/scenario-high-traffic-tuning.md](../scenarios/scenario-high-traffic-tuning.md).

## Next

Continue to [05-python-app-install.md](05-python-app-install.md).

## See also

- [docs/reference/suricata-config-reference.md](../reference/suricata-config-reference.md)
- [docs/architecture/data-flow.md](../architecture/data-flow.md)
