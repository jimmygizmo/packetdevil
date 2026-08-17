#!/usr/bin/env bash
# Script: scripts/linux/install-test-tool-prereqs.sh
# Purpose: install/verify all tools used by scripts/linux/tests/*.sh
#          (ad-hoc, manually-run detection-validation scripts).
# Requires: root, Debian/Ubuntu with apt
# Rollback: sudo apt remove --purge nmap (and any other tools added here later)
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "error: must run as root" >&2
  exit 1
fi

echo "==> installing test-tool prerequisites: nmap"
apt-get update
apt-get install -y nmap

echo "==> verifying installation"
nmap --version

echo "done. See scripts/linux/tests/README.md for available test scripts."
