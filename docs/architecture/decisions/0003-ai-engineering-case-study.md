---
title: "ADR 0003: This repo doubles as a case study in agentic AI software engineering"
status: accepted
last_verified: 2026-08-17
applies_to: []
owner_domain: architecture
---

# ADR 0003: This repo doubles as a case study in agentic AI software engineering

## Status

Accepted

## Context

This project has two audiences and two goals running in parallel: (1) a
real, working home/SMB IDS/IPS built on an RB5009 + Suricata +
`packetdevil`, and (2) a deliberate case study in structuring a complex,
multi-technology repository for **agentic AI software development**
(GitHub Copilot in Auto mode primarily, plus advanced developers steering
specific models manually). The project owner has stated this explicitly
and wants it treated as an ongoing, standing priority — not a one-time
setup task that was "done" when the initial scaffold was created.

Without recording this, future contributors (human or agent) might treat
AI-optimization choices (front matter conventions, ADRs, scoped
instruction files, the `docs/` structure itself) as incidental,
under-value them relative to "real" IDS/IPS feature work, or fail to
recognize when a new general-purpose instruction from the project owner
should be captured as a durable, reusable artifact rather than applied
once and forgotten.

## Decision

Every general, reusable instruction the project owner gives about
*how this project should be structured/documented/operated to work well
with AI coding agents* — not just one-off task requests — is captured as
a durable artifact in the repo (an ADR, an update to
[AGENTS.md](../../../AGENTS.md), a `.github/instructions/*.instructions.md`
rule, or a `docs/` convention), not left to live only in chat history.
Concretely, when given such a directive, an agent working in this repo
should:

1. Apply it to the current task, and
2. Also generalize it into the project's standing documentation/structure
   so it governs future work automatically, and
3. Prefer the most specific existing mechanism for capturing it (scoped
   `.instructions.md` file for a file-type rule, ADR for an architectural
   or process decision, `docs/` convention update for a documentation
   pattern) over inventing a new one-off location.

## Options considered

1. **Treat AI-optimization as a one-time initial scaffolding task** —
   Pros: simpler, less overhead per request. Cons: the project owner has
   explicitly said this is an ongoing priority; treating it as "done"
   would silently regress the project's core stated value proposition
   over time as normal feature work accumulates.
2. **Capture standing AI-optimization directives durably, as an explicit,
   ongoing responsibility (chosen)** — Pros: matches the stated priority;
   keeps the documentation/structure improving alongside the IDS/IPS
   functionality rather than drifting stale; makes the "case study" aspect
   of the project legible to anyone (human or agent) who reads it later.
   Cons: modest ongoing overhead — every general directive requires a
   moment of "where does this belong permanently," not just "did I do the
   task."

## Consequences

- [AGENTS.md](../../../AGENTS.md) carries a short, explicit pointer to this
  ADR so any agent reading the primary entry point immediately understands
  this is a standing responsibility, not a historical note.
- When in doubt about whether a piece of feedback is "just for this task"
  vs. "a general principle," prefer capturing it durably — the cost of an
  extra ADR/doc-update is low; the cost of silently losing a stated
  priority is high.
- This ADR itself is the template example: it exists because the
  directive that produced it *was itself* an instance of the pattern it
  describes.

## See also

- [AGENTS.md](../../../AGENTS.md)
- [docs/architecture/decisions/README.md](README.md)
