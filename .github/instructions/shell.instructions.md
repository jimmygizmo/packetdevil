---
applyTo: "**/*.sh"
---

# Shell Script Instructions

- `#!/usr/bin/env bash` shebang, `set -euo pipefail` at the top of every
  script.
- Target distro: Debian/Ubuntu (document explicitly if a script assumes
  something else).
- Scripts that require root must check (`if [[ $EUID -ne 0 ]]`) and exit
  with a clear message rather than silently failing partway through.
- Prefer idempotent scripts: check current state before acting (e.g. does
  the `dummy0` interface already exist, is the systemd unit already
  installed) so re-running is safe.
- Every script starts with a header comment:
  ```
  # Script: <name>
  # Purpose: <one line>
  # Requires: root? network changes? package installs?
  # Rollback: <how to undo>
  ```
- No embedded secrets. Read credentials from environment variables or a
  path passed as an argument, never hardcoded.
- Long-running/daemon-style behavior belongs in a systemd unit, not a
  backgrounded shell script with `&`.
- Document what the script does and how to verify success in a companion
  doc under `docs/setup/` or `docs/operations/runbooks/` — link to it in a
  comment at the top of the script.
