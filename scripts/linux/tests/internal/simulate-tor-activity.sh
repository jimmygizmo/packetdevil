#!/usr/bin/env bash
# Script: scripts/linux/tests/internal/simulate-tor-activity.sh
# Purpose: simulate the DNS lookup pattern of a host attempting to reach a
#          Tor hidden service (.onion address) — often flagged by policy/
#          threat-intel rules regardless of whether the lookup actually
#          resolves — to confirm Suricata's rules fire and packetdevil
#          reacts.
# Requires: dig installed (see
#           scripts/linux/tests/internal/install-internal-test-tool-prereqs.sh);
#           MUST be run from a host INSIDE your own LAN, behind the RB5009
#           (see usage/README) — not from an external host.
# Rollback: N/A — read-only DNS lookup, nothing local to undo.
set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
DEFAULT_DOMAIN="thisisatest.onion"
DEFAULT_RESOLVER="1.1.1.1"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-y|--yes] [--domain <domain>] [--resolver <ip>]

Runs: dig +short <domain> @<resolver>
      (default domain: ${DEFAULT_DOMAIN}, default resolver: ${DEFAULT_RESOLVER})

Looks up a .onion (Tor hidden service) address, simulating the DNS query
pattern a host attempting to use Tor would generate. Public DNS resolvers
cannot actually resolve .onion addresses (they require the Tor network),
so this lookup is expected to return nothing/NXDOMAIN — the point is the
query itself: many policy/threat-intel Suricata rules flag *any* .onion
lookup regardless of whether it resolves, since Tor usage is sometimes
associated with malicious, illegal, or otherwise unwanted activity on a
monitored network. Querying an explicit public resolver
(${DEFAULT_RESOLVER} by default) bypasses any local DNS cache so the
lookup actually goes out over the WAN every time.

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
  --domain <domain>   Override the .onion domain looked up (advanced use).
  --resolver <ip>     Override the DNS resolver queried (default: ${DEFAULT_RESOLVER}).
  -y, --yes           Skip the interactive confirmation prompt (for
                      scripted/non-interactive use).
  -h, --help          Show this help and exit.

Example:
  ${SCRIPT_NAME}
EOF
}

skip_confirm=0
domain="${DEFAULT_DOMAIN}"
resolver="${DEFAULT_RESOLVER}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) skip_confirm=1; shift ;;
    --domain)
      [[ $# -ge 2 ]] || { echo "error: --domain requires an argument" >&2; exit 1; }
      domain="$2"
      shift 2
      ;;
    --resolver)
      [[ $# -ge 2 ]] || { echo "error: --resolver requires an argument" >&2; exit 1; }
      resolver="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

echo "About to look up .onion domain ${domain} via ${resolver}."
echo "This must be run from INSIDE your own LAN (behind the RB5009), not from"
echo "an external host — see ${SCRIPT_NAME} --help for why."
if [[ "${skip_confirm}" -ne 1 ]]; then
  read -r -p "Continue? [y/N] " reply
  if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
    echo "aborted: confirmation not given"
    exit 1
  fi
fi

if ! command -v dig &>/dev/null; then
  echo "error: dig is not installed. Run scripts/linux/tests/internal/install-internal-test-tool-prereqs.sh first." >&2
  exit 1
fi

echo "==> dig +short ${domain} @${resolver}"
dig +short "${domain}" "@${resolver}"
