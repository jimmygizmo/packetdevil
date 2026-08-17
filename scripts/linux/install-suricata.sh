#!/usr/bin/env bash
# Script: scripts/linux/install-suricata.sh
# Purpose: install Suricata from the OISF stable PPA and run suricata-update
# Requires: root, Debian/Ubuntu with add-apt-repository available
# Rollback: sudo apt remove --purge suricata
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "error: must run as root" >&2
  exit 1
fi

add-apt-repository -y ppa:oisf/suricata-stable
apt-get update
apt-get install -y suricata

suricata-update

echo "next: configure /etc/suricata/suricata.yaml per configs/suricata/suricata.yaml.example"
echo "then: systemctl enable --now suricata"
