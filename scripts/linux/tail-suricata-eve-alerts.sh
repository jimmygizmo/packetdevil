
#!/usr/bin/env bash
# Script: scripts/linux/tail-suricata-eve-alerts.sh
# Purpose: tail Suricata's eve.json and print only alert events, compactly,
#          for quick manual monitoring (e.g. while running a test/simulation
#          script from scripts/linux/tests/).
# Requires: jq installed (sudo apt-get install -y jq); read access to
#           /var/log/suricata/eve.json (root/sudo, or membership in
#           whatever group owns that file).
# Rollback: N/A — read-only.
set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
DEFAULT_EVE_PATH="/var/log/suricata/eve.json"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-f <path>] [-a]

Tails Suricata's eve.json and prints only event_type=="alert" records, one
compact JSON object per line, as they're written.

Options:
  -f <path>   Path to eve.json (default: ${DEFAULT_EVE_PATH}).
  -a          Print the full alert record instead of the summarized fields.
  -h, --help  Show this help and exit.

The most important fields in an alert are: src_ip, dest_ip,
alert.signature, and alert.severity — these are shown by default; pass
-a for the complete record (all fields Suricata included).

Example:
  ${SCRIPT_NAME}
  sudo ${SCRIPT_NAME} -f /var/log/suricata/eve.json
EOF
}

eve_path="${DEFAULT_EVE_PATH}"
full_record=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f)
      [[ $# -ge 2 ]] || { echo "error: -f requires an argument" >&2; exit 1; }
      eve_path="$2"
      shift 2
      ;;
    -a) full_record=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if ! command -v jq &>/dev/null; then
  echo "error: jq is not installed (sudo apt-get install -y jq)." >&2
  exit 1
fi

filter='select(.event_type=="alert")'
if [[ "${full_record}" -ne 1 ]]; then
  filter+=' | {timestamp, src_ip, dest_ip, signature: .alert.signature, severity: .alert.severity}'
fi

echo "==> tailing ${eve_path} for alerts (jq filter: ${filter})" >&2
tail -f "${eve_path}" | jq -c "${filter}"

