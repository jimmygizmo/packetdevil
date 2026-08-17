#!/usr/bin/env bash
# Script: scripts/linux/tests/simulate-port-scan.sh
# Purpose: run an nmap SYN/version scan against a single IP, to see your WAN
#          exposure the way an external attacker's recon scan would, and
#          confirm Suricata/packetdevil detect and react to it.
# Requires: nmap installed (see scripts/linux/install-test-tool-prereqs.sh);
#           root/CAP_NET_RAW for the SYN scan (-sS) to run as intended.
# Rollback: N/A — read-only network probe, nothing to undo.
set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} <YOUR_PUBLIC_IP> [-y|--yes]

Runs: nmap -sS -sV -Pn <YOUR_PUBLIC_IP>

  -sS   TCP SYN ("half-open") scan
  -sV   probe open ports to determine service/version
  -Pn   skip host discovery, treat the target as up (needed since the
        target's own firewall/IDS may otherwise appear to block a ping)

  WARNING — ONLY SCAN AN IP ADDRESS YOU OWN OR ARE EXPLICITLY AUTHORIZED
  TO TEST (e.g. your own RB5009's public WAN IP). Port scanning systems
  you do not own or control without permission may be illegal and may
  violate your ISP's terms of service. This script is for testing your
  own packetdevil/Suricata detection pipeline, nothing else.

Options:
  -y, --yes     Skip the interactive "is this your own IP" confirmation
                prompt (for scripted/non-interactive use).
  -h, --help    Show this help and exit.

Example:
  ${SCRIPT_NAME} 203.0.113.10
EOF
}

skip_confirm=0
target=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) skip_confirm=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
    *)
      if [[ -n "${target}" ]]; then
        echo "error: unexpected extra argument: $1" >&2; usage >&2; exit 1
      fi
      target="$1"
      shift
      ;;
  esac
done

if [[ -z "${target}" ]]; then
  echo "error: missing required <YOUR_PUBLIC_IP> argument" >&2
  usage >&2
  exit 1
fi

if ! [[ "${target}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo "error: '${target}' does not look like an IPv4 address" >&2
  exit 1
fi

echo "WARNING: about to port-scan ${target}."
echo "Only proceed if this is an IP address you own or are explicitly authorized to test."
if [[ "${skip_confirm}" -ne 1 ]]; then
  read -r -p "Is ${target} your own IP and are you authorized to scan it? [y/N] " reply
  if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
    echo "aborted: confirmation not given"
    exit 1
  fi
fi

if ! command -v nmap &>/dev/null; then
  echo "error: nmap is not installed. Run scripts/linux/install-test-tool-prereqs.sh first." >&2
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "note: not running as root — nmap will fall back to a TCP connect scan" \
       "instead of a true SYN scan (-sS needs raw-socket privileges). Re-run" \
       "with sudo for an accurate SYN scan."
fi

echo "==> nmap -sS -sV -Pn ${target}"
nmap -sS -sV -Pn "${target}"

