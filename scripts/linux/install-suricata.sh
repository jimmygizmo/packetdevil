#!/usr/bin/env bash
# Script: scripts/linux/install-suricata.sh
# Purpose: install Suricata and common support tooling required for this
#          project while leaving tzsp2pcap build/install to the dedicated
#          step documented in docs/setup/03-tzsp2pcap-install.md.
# Requires: root, Debian/Ubuntu with add-apt-repository available
# Rollback: sudo apt-get purge -y suricata jq tcpreplay git build-essential libpcap-dev
# See also: docs/setup/04-suricata-install.md, docs/setup/03-tzsp2pcap-install.md
set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
PPA_REPO="ppa:oisf/suricata-stable"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [--help]

Installs Suricata and the Linux-side support tools this project expects for
IDS monitoring and ad-hoc validation traffic.

This script intentionally does not rebuild or install tzsp2pcap; the
project's vendored tzsp2pcap flow is handled separately in
`docs/setup/03-tzsp2pcap-install.md` and `vendor/tzsp2pcap/build.sh`.

Options:
  -h, --help  Show this help and exit.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "error: must run as root" >&2
  exit 1
fi

echo "==> adding Suricata stable PPA: ${PPA_REPO}"
add-apt-repository -y "${PPA_REPO}"

echo "==> installing Suricata and support packages"
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  suricata \
  jq \
  tcpreplay \
  git \
  build-essential \
  libpcap-dev

echo "==> updating Suricata rules"
suricata-update

echo "==> verifying Suricata installation"
suricata -V

echo "==> Suricata is installed; tzsp2pcap is intentionally installed in docs/setup/03-tzsp2pcap-install.md"
echo "==> next: configure /etc/suricata/suricata.yaml to listen on dummy0 and enable the service"
echo "==> then: systemctl enable --now suricata"
