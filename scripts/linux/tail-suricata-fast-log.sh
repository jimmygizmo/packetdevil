
#!/usr/bin/env bash
# Script: scripts/linux/tail-suricata-fast-log.sh
# Purpose: tail Suricata's plain-text fast.log stream for quick manual
#          monitoring of alerts as they are written.
# Requires: read access to /var/log/suricata/fast.log (root/sudo, or a group
#           that allows reads to that file).
# Rollback: N/A — read-only.
# See also: docs/reference/linux-commands.md
set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
DEFAULT_FAST_LOG_PATH="/var/log/suricata/fast.log"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [-f <path>]

Tails Suricata's fast.log and prints each line as it is written.

Options:
  -f <path>   Path to fast.log (default: ${DEFAULT_FAST_LOG_PATH}).
  -h, --help  Show this help and exit.

This log is plain text and is useful for quick manual triage and grepping
when you want the raw alert stream without the JSON formatting from eve.json.

Example:
  ${SCRIPT_NAME}
  sudo ${SCRIPT_NAME} -f /var/log/suricata/fast.log
EOF
}

fast_log_path="${DEFAULT_FAST_LOG_PATH}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f)
      [[ $# -ge 2 ]] || { echo "error: -f requires an argument" >&2; exit 1; }
      fast_log_path="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ ! -r "${fast_log_path}" ]]; then
  echo "error: cannot read ${fast_log_path}; run with sudo or ensure the file is readable." >&2
  exit 1
fi

echo "==> tailing ${fast_log_path}" >&2
tail -F "${fast_log_path}"
