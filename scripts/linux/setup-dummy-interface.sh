#!/usr/bin/env bash
# Script: scripts/linux/setup-dummy-interface.sh
# Purpose: idempotently create and persist the dummy0 capture interface
# Requires: root
# Rollback: sudo ip link delete dummy0 (and remove the systemd-networkd file this script writes)
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "error: must run as root" >&2
  exit 1
fi

IFACE="dummy0"

modprobe dummy

if ! ip link show "${IFACE}" &>/dev/null; then
  ip link add "${IFACE}" type dummy
  echo "created ${IFACE}"
else
  echo "${IFACE} already exists, skipping creation"
fi

ip link set "${IFACE}" up

NETDEV_FILE="/etc/systemd/network/10-${IFACE}.netdev"
if [[ ! -f "${NETDEV_FILE}" ]]; then
  mkdir -p /etc/systemd/network
  cat > "${NETDEV_FILE}" <<EOF
[NetDev]
Name=${IFACE}
Kind=dummy
EOF
  echo "wrote ${NETDEV_FILE} for persistence across reboots"
  systemctl restart systemd-networkd || true
else
  echo "${NETDEV_FILE} already present, skipping"
fi

echo "verify with: ip link show ${IFACE}"
