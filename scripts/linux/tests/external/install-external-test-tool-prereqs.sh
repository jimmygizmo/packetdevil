#!/usr/bin/env bash
# Script: scripts/linux/tests/external/install-external-test-tool-prereqs.sh
# Purpose: install the tools needed to run scripts/linux/tests/external/*.sh
#          — simulations of attacks/recon arriving from the Internet
#          against your packetdevil deployment's public IP.
# Requires: root, Debian/Ubuntu with apt. Run this ON THE EXTERNAL HOST
#           (e.g. a VPS/cloud shell you control) — NOT on your
#           packetdevil/Suricata box — see
#           scripts/linux/tests/external/README.md for why.
# Rollback: sudo apt remove --purge nmap dnsutils (and any other tools
#           added here later)
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "error: must run as root" >&2
  exit 1
fi

echo "NOTE: these tools are for simulating attacks arriving FROM the Internet."
echo "Run this script on an external host you control (VPS, cloud shell, etc.),"
echo "not on your packetdevil/Suricata box. See scripts/linux/tests/external/README.md."

# Assume a bare/minimal host: install every tool used by scripts in this
# directory explicitly, rather than assuming any of them are preinstalled.
#   nmap     - scripts/linux/tests/external/simulate-port-scan.sh
#   dnsutils - provides `dig`, kept installed here for future external
#              DNS-based simulation scripts
echo "==> installing external test-tool prerequisites: nmap, dnsutils (dig)"
apt-get update
apt-get install -y nmap dnsutils

echo "==> verifying installation"
nmap --version
dig -v

echo "done. See scripts/linux/tests/external/README.md for available scripts."
