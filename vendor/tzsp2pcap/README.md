# vendor/tzsp2pcap

## Provenance

- Upstream project: `tzsp2pcap` (TZSP-to-pcap decapsulator for RouterOS
  mirror traffic).
- Vendoring/patch strategy: see
  [docs/architecture/decisions/0001-tzsp2pcap-fork-strategy.md](../../docs/architecture/decisions/0001-tzsp2pcap-fork-strategy.md).
- Pinned upstream reference: **TODO** — record the exact upstream repo URL
  and commit/tag once vendored (`upstream/UPSTREAM_COMMIT` file below is
  the source of truth; keep this section in sync with it).

## Layout

```
vendor/tzsp2pcap/
  README.md            ← this file
  upstream/             ← unmodified upstream source snapshot (pinned)
    UPSTREAM_COMMIT     ← upstream repo URL + commit hash/tag, one line each
  patches/               ← our modifications, as numbered patch files
    0001-<short-description>.patch
    0001-<short-description>.md   ← one-paragraph rationale per patch
  build.sh              ← applies patches to upstream/, builds into build/
  build/                 ← gitignored build output (binary + intermediate files)
```

## Adding or changing a patch

1. Make your change against a clean checkout of `upstream/` (or edit
   `build/` and re-diff — either way, the patch must apply cleanly to
   `upstream/` alone).
2. Generate the patch:
   ```bash
   cd vendor/tzsp2pcap
   diff -u upstream/<file> build/<file> > patches/000N-short-description.patch
   ```
   or, if working from a git clone of upstream, prefer
   `git format-patch`/`git diff` for proper patch headers.
3. Add a `000N-short-description.md` file alongside it: one paragraph
   explaining *why* this patch exists (link an ADR if it's a significant
   design choice, not just a bugfix/port).
4. Update [docs/reference/tzsp2pcap-config-reference.md](../../docs/reference/tzsp2pcap-config-reference.md)
   if the patch changes user-facing configuration/behavior.
5. Re-run `./build.sh` and verify per
   [docs/setup/03-tzsp2pcap-install.md](../../docs/setup/03-tzsp2pcap-install.md).

## Upgrading the pinned upstream version

1. Fetch the new upstream source into a scratch directory (do not
   overwrite `upstream/` yet).
2. Diff the new upstream against the old `upstream/` to understand what
   changed.
3. Replace `upstream/` with the new snapshot; update `UPSTREAM_COMMIT`.
4. Re-apply each patch in `patches/` in order; resolve conflicts by editing
   the patch files directly.
5. Rebuild and re-verify before committing.

## See also

- [docs/architecture/decisions/0001-tzsp2pcap-fork-strategy.md](../../docs/architecture/decisions/0001-tzsp2pcap-fork-strategy.md)
- [docs/setup/03-tzsp2pcap-install.md](../../docs/setup/03-tzsp2pcap-install.md)
- [docs/reference/tzsp2pcap-config-reference.md](../../docs/reference/tzsp2pcap-config-reference.md)
