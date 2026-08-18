#!/usr/bin/env bash
# Script: scripts/linux/tests/internal/simulate-tech-support-scammer.sh
# Purpose: simulate the network check-in of a freshly installed AnyDesk
#          remote-access client — the pattern a tech-support-scam victim's
#          machine generates after being talked into installing it — to
#          confirm Suricata's remote-access-tool detection rules fire and
#          packetdevil reacts.
# Requires: openssl installed (see
#           scripts/linux/tests/internal/install-internal-test-tool-prereqs.sh);
#           MUST be run from a host INSIDE your own LAN, behind the RB5009
#           (see usage/README) — not from an external host.
# Rollback: N/A — read-only TLS handshake, no session is established,
#           nothing local to undo.
set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
DEFAULT_HOST="boot.net.anydesk.com"
DEFAULT_PORT="443"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-y|--yes] [--host <host>] [--port <port>]

Runs: echo | openssl s_client -connect <host>:<port> -servername <host>
      (default host: ${DEFAULT_HOST}, default port: ${DEFAULT_PORT})

Performs a TLS handshake (ClientHello + certificate exchange only, no data
sent) against AnyDesk's real "boot"/relay infrastructure — the same
check-in a newly installed AnyDesk client performs. Tech-support scammers
frequently talk victims into installing AnyDesk (a legitimate remote
support tool) to gain remote control of their machine, so recognizing
this connection pattern is a useful home-network detection signal even
though AnyDesk itself is legitimate, widely-used software.

No remote-access session is established and no software is installed —
this only opens and immediately closes a TLS connection to observe the
handshake, then exits.

  IMPORTANT — RUN THIS FROM A HOST INSIDE YOUR OWN LAN, behind the
  RB5009 — not from an external host. The point is to simulate an
  internal host's outbound traffic being mirrored and inspected;
  running it from outside your network does not exercise that path.

  NOTE — Suricata's WAN mirror sees this request only AFTER your
  router's NAT rewrites the source address, so the resulting alert's
  src_ip will be your network's public (NAT'd) IP, not the internal
  host's private IP. Keep this in mind if packetdevil creates a
  temporary block from this alert (see
  docs/architecture/data-flow.md).

Options:
  --host <host>   Override the target host (advanced use).
  --port <port>   Override the target port (default: ${DEFAULT_PORT}).
  -y, --yes       Skip the interactive confirmation prompt (for
                  scripted/non-interactive use).
  -h, --help      Show this help and exit.

Example:
  ${SCRIPT_NAME}
EOF
}

skip_confirm=0
target_host="${DEFAULT_HOST}"
target_port="${DEFAULT_PORT}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) skip_confirm=1; shift ;;
    --host)
      [[ $# -ge 2 ]] || { echo "error: --host requires an argument" >&2; exit 1; }
      target_host="$2"
      shift 2
      ;;
    --port)
      [[ $# -ge 2 ]] || { echo "error: --port requires an argument" >&2; exit 1; }
      target_port="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

echo "About to open a TLS handshake to ${target_host}:${target_port}"
echo "(simulating an AnyDesk client check-in used in tech-support scams)."
echo "This must be run from INSIDE your own LAN (behind the RB5009), not from"
echo "an external host — see ${SCRIPT_NAME} --help for why."
if [[ "${skip_confirm}" -ne 1 ]]; then
  read -r -p "Continue? [y/N] " reply
  if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
    echo "aborted: confirmation not given"
    exit 1
  fi
fi

if ! command -v openssl &>/dev/null; then
  echo "error: openssl is not installed. Run scripts/linux/tests/internal/install-internal-test-tool-prereqs.sh first." >&2
  exit 1
fi

echo "==> echo | openssl s_client -connect ${target_host}:${target_port} -servername ${target_host}"
echo | openssl s_client -connect "${target_host}:${target_port}" -servername "${target_host}"

