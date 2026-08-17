---
applyTo: "**/*.rsc"
---

# RouterOS Script Instructions

- Target syntax: RouterOS 7.x CLI/script language (`.rsc` files run via
  `/import` or pasted into terminal).
- Every script starts with a header comment block:
  ```
  # Script: <name>
  # Purpose: <one line>
  # Target: RB5009 (RouterOS 7.x)
  # Blast radius: <what live config this touches>
  # Rollback: <how to undo, or reference to a companion *-rollback.rsc>
  ```
- Never hardcode real WAN IPs, public IPs, passwords, or API tokens. Use
  clearly-named placeholders like `<WAN_INTERFACE>`, `<API_USER>` and
  document them in the accompanying setup doc.
- Prefer scripts that are **idempotent**: check whether a rule/interface
  already exists (`:if ([/interface find where name="dummy1"] = "")`)
  before creating it, so re-running the script is safe.
- Any script that adds firewall rules must place them with an explicit
  `comment="packetdevil:<purpose>"` tag so they're identifiable and
  scriptable to remove later (the Python app relies on this convention for
  its temporary rules — see
  [src/packetdevil/packetdevil/rules_engine.py](../../src/packetdevil/packetdevil/rules_engine.py)).
- Document every script's commands in
  [docs/reference/routeros-commands.md](../../docs/reference/routeros-commands.md)
  rather than leaving RouterOS syntax knowledge only inside the `.rsc` file.
- Port mirroring / traffic capture scripts must clearly document
  performance impact (RB5009 CPU/switch-chip offload implications) since
  mirroring can disable hardware fast-path offloading for affected ports.
