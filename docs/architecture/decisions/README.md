# Architecture Decision Records (ADRs)

## Purpose

Each file in this directory records one significant architectural decision:
the context, the options considered, the choice made, and the consequences.
ADRs are **immutable once accepted** — if a decision changes, write a new
ADR that supersedes the old one (link both ways) rather than editing history.

## Why ADRs matter for agentic development

An AI agent reading only current code/config cannot recover *why* something
is the way it is. ADRs give agents (and humans) the reasoning trail needed
to avoid "fixing" an intentional tradeoff, and to know when a past decision
should be revisited (e.g. because a stated assumption changed).

## Index

| ADR | Title | Status |
|---|---|---|
| [0001](0001-tzsp2pcap-fork-strategy.md) | tzsp2pcap fork/vendor strategy | Accepted |
| [0002](0002-suricata-deployment.md) | Suricata deployed as passive IDS (mirror), not inline IPS | Accepted |

## Creating a new ADR

Copy [template.md](template.md) to `NNNN-short-title.md` (next sequential
number, zero-padded to 4 digits) and fill it in. Add a row to the index
table above.
