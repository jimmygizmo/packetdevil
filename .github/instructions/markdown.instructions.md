---
applyTo: "**/*.md"
---

# Markdown / Documentation Instructions

All documentation in this repo (except this file, `AGENTS.md`, and root
`README.md`) must use this structure so agents can quickly judge relevance
and trustworthiness of a doc without reading it end-to-end.

## Required front matter

Every doc under `docs/`, `vendor/*/README.md`, `configs/**/README.md`, and
`scripts/**/README.md` starts with YAML front matter:

```yaml
---
title: Short human-readable title
status: draft | verified | needs-review
last_verified: YYYY-MM-DD
applies_to:
  - RouterOS 7.x
  - RB5009
  - Suricata 7.x
  - Debian 12 / Ubuntu 22.04+
owner_domain: routeros | linux | suricata | tzsp2pcap | python-app | architecture
---
```

- `status: draft` — written but not yet executed/tested end-to-end.
- `status: verified` — a human or agent has actually run these steps
  successfully on real (or documented lab) hardware; keep `last_verified`
  current.
- `status: needs-review` — known to be possibly stale (e.g. after a
  RouterOS/Suricata version bump).

An agent should treat `status: draft` docs as **untrusted hypotheses** to
verify, not ground truth.

## Required body structure for setup/runbook docs

1. **Purpose** — one paragraph, what this doc accomplishes and why.
2. **Prerequisites** — link to prior docs/state required (numbered setup
   docs should list the prior numbered doc).
3. **Steps** — numbered, copy-pasteable commands in fenced code blocks with
   the correct language tag (`bash`, `routeros`, `yaml`, etc.). Each
   nontrivial step explains *what it does* and *how to verify it worked*.
4. **Verification** — explicit commands/output showing success.
5. **Rollback / Undo** — how to reverse this doc's changes.
6. **Troubleshooting** — common failure modes and fixes, or a link into
   `docs/operations/troubleshooting.md`.
7. **See also** — links to related docs (reference pages, ADRs, scenarios).

## General rules

- One topic per file. If a doc grows past ~300 lines or covers two
  unrelated concerns, split it and update `docs/README.md`'s index.
- Never duplicate content between docs — link instead. Duplicated,
  drifting instructions are the #1 failure mode this structure exists to
  prevent.
- Use RouterOS command blocks tagged as ```routeros and Linux ones as
  ```bash so agents/tools can distinguish command dialects at a glance.
- Every command block that mutates live state (router config, firewall
  rules, systemd services) gets a one-line comment above it stating the
  blast radius, e.g. `# Mutates: RB5009 live firewall — affects all LAN/WAN traffic`.
- Update `docs/README.md` whenever you add, move, or remove a doc.
