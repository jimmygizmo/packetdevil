#!/usr/bin/env bash
# Script: scripts/linux/tests/internal/simulate-password-in-clear.sh
# Purpose: simulate a compromised/misbehaving internal host sending
#          credentials in cleartext (HTTP Basic Auth over plain HTTP) to an
#          external site, to confirm Suricata's cleartext-credential /
#          policy-violation rules fire and packetdevil reacts.
# Requires: curl installed (present by default on nearly all Debian/Ubuntu
#           installs); MUST be run from a host INSIDE your own LAN, behind
#           the RB5009 (see usage/README) — not from an external host.
# Rollback: N/A — read-only HTTP request against a public test endpoint,
#           nothing local to undo.
set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
DEFAULT_URL="http://httpbun.com/basic-auth/user/pass"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-y|--yes] [--url <url>]

Runs: curl -su user:pass <url>   (default url: ${DEFAULT_URL})

Sends HTTP Basic Auth credentials over plain (unencrypted) HTTP to a
public test endpoint, simulating an internal host leaking credentials in
cleartext (e.g. a compromised host, or a misconfigured legacy service) —
this is the kind of traffic a "cleartext credentials" / policy-violation
Suricata rule is meant to catch.

Only dummy credentials ("user"/"pass") are sent, against
httpbun.com's /basic-auth test endpoint, which is a public service
designed exactly for this kind of testing — it just verifies the
Basic Auth header and echoes success/failure. No real secrets are
involved and no request is made to your own infrastructure.

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
  --url <url>   Override the target test URL (advanced use; must be a
                URL you are authorized to send test credentials to).
  -y, --yes     Skip the interactive confirmation prompt (for scripted/
                non-interactive use).
  -h, --help    Show this help and exit.

Example:
  ${SCRIPT_NAME}
EOF
}

skip_confirm=0
url="${DEFAULT_URL}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) skip_confirm=1; shift ;;
    --url)
      [[ $# -ge 2 ]] || { echo "error: --url requires an argument" >&2; exit 1; }
      url="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

echo "About to send cleartext HTTP Basic Auth credentials to: ${url}"
echo "This must be run from INSIDE your own LAN (behind the RB5009), not from"
echo "an external host — see ${SCRIPT_NAME} --help for why."
if [[ "${skip_confirm}" -ne 1 ]]; then
  read -r -p "Continue? [y/N] " reply
  if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
    echo "aborted: confirmation not given"
    exit 1
  fi
fi

if ! command -v curl &>/dev/null; then
  echo "error: curl is not installed (sudo apt-get install -y curl)." >&2
  exit 1
fi

echo "==> curl -su user:pass ${url}"
curl -su user:pass "${url}"
echo

