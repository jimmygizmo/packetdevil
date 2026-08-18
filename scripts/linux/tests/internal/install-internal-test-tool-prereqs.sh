#!/usr/bin/env bash
# Script: scripts/linux/tests/internal/install-internal-test-tool-prereqs.sh
# Purpose: install the tools needed to run scripts/linux/tests/internal/*.sh
#          — simulations of a compromised/misbehaving host inside your LAN.
# Requires: root, Debian/Ubuntu with apt. Run this ON THE INTERNAL TEST
#           HOST (inside your own LAN, behind the RB5009) — see
#           scripts/linux/tests/internal/README.md.
# Rollback: sudo apt remove --purge curl dnsutils openssl (and any other
#           tools added here later)
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "error: must run as root" >&2
  exit 1
fi

echo "NOTE: these tools are for simulating a compromised/misbehaving host"
echo "INSIDE your own LAN. Run this on a host behind the RB5009, not on an"
echo "external host. See scripts/linux/tests/internal/README.md."

# Assume a bare/minimal host: install every tool used by scripts in this
# directory explicitly, rather than assuming any of them are preinstalled.
#   curl     - simulate-password-in-clear.sh
#   dnsutils - provides `dig`, used by simulate-browser-crypto-mining.sh
#              and simulate-tor-activity.sh
#   openssl  - used by simulate-tech-support-scammer.sh
echo "==> installing internal test-tool prerequisites: curl, dnsutils (dig), openssl"
apt-get update
apt-get install -y curl dnsutils openssl

echo "==> verifying installation"
curl --version
dig -v
openssl version

echo "done. See scripts/linux/tests/internal/README.md for available scripts."
