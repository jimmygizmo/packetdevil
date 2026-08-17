---
title: "ADR 0001: tzsp2pcap fork/vendor strategy"
status: accepted
last_verified: 2026-08-16
applies_to:
  - tzsp2pcap
owner_domain: tzsp2pcap
---

# ADR 0001: tzsp2pcap fork/vendor strategy

## Status

Accepted

## Context

`tzsp2pcap` is a small third-party open-source tool that decapsulates TZSP
(RouterOS mirror protocol) UDP packets into pcap. We need to modify its
source (e.g. to add filtering, output modes, metrics/health endpoints, or
fix compatibility issues) while still tracking upstream fixes. Three
options exist for how our modifications relate to the upstream project:

1. **Patch-on-top**: vendor an unmodified upstream snapshot plus a set of
   versioned patch files applied on top at build time.
2. **Hard fork**: copy the source into this repo and edit it directly,
   with no formal patch boundary from upstream.
3. **Rewrite**: write our own TZSP-to-pcap tool from scratch in Python or Go,
   dropping the upstream dependency entirely.

## Decision

We use **option 1: vendor + patch-on-top**, stored at
[vendor/tzsp2pcap/](../../../vendor/tzsp2pcap/).

- `vendor/tzsp2pcap/upstream/` holds an unmodified snapshot of the upstream
  source at a pinned commit/tag (recorded in
  [vendor/tzsp2pcap/README.md](../../../vendor/tzsp2pcap/README.md)).
- `vendor/tzsp2pcap/patches/` holds numbered `.patch` files (standard
  `git diff`/`git format-patch` format) applied in order on top of the
  upstream snapshot to produce our working build.
- A build script applies patches into a `vendor/tzsp2pcap/build/` output
  (gitignored) that is what actually gets compiled/run.

## Options considered

1. **Patch-on-top** — Pros: clean separation of "upstream" vs "ours",
   trivial to re-diff against a newer upstream release, patches are small
   and reviewable, matches how distros (Debian, Alpine) commonly manage
   vendored+patched C sources. Cons: patch files can go stale/conflict if
   upstream changes significantly; requires a build step to apply them.
2. **Hard fork** — Pros: simplest to edit, no patch-application step.
   Cons: upstream changes become very hard to merge in later (git history
   diverges immediately); harder for an agent or human to tell "what did
   we change" without a diff against a specific external commit.
3. **Rewrite** — Pros: full control, could be pure Python matching the
   rest of the app's language, no upstream C toolchain dependency.
   Cons: highest effort/risk, reinvents a solved, narrow problem
   (TZSP decapsulation is simple, but a full rewrite still needs to match
   or exceed upstream's performance and correctness under real WAN load
   before we'd trust it in place of a maintained tool).

## Consequences

- Any change to `tzsp2pcap` behavior must be expressed as a new patch file
  in `vendor/tzsp2pcap/patches/`, numbered sequentially, with a one-line
  description file alongside it (see
  [vendor/tzsp2pcap/README.md](../../../vendor/tzsp2pcap/README.md) for the
  exact convention).
- Upgrading upstream means: update the pinned commit/tag, re-apply patches
  in order, resolve any conflicts by editing the patch files, re-test.
- If patch maintenance becomes too costly (frequent conflicts, upstream
  abandoned), revisit this ADR and consider option 3 (rewrite) as a
  superseding decision.

## See also

- [vendor/tzsp2pcap/README.md](../../../vendor/tzsp2pcap/README.md)
- [docs/setup/03-tzsp2pcap-install.md](../../setup/03-tzsp2pcap-install.md)
- [docs/reference/tzsp2pcap-config-reference.md](../../reference/tzsp2pcap-config-reference.md)
