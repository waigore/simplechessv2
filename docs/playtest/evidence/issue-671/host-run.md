# Issue #671 — served-snapshot I1 run on the catalog host

Residue of [issue-329 acceptance.md §3](../issue-329/acceptance.md) AC5: the
deploy path and gate are proved against a slice; the run against the real
6,157,341-record `2026-10-05` snapshot is an operator step on the host that
stores the Lichess export (ADR-0008 keeps it host-side).

## Outcome: not produced — AC3 fallback

This session is an agent session with no catalog host. The fallback the issue
body defines for that case follows: the gap is dated, owned, and its
consequence stated, rather than left to go quiet.

| Field | Value |
|---|---|
| Date | 2026-10-25 |
| Repo commit under test | `437ecf2fe776067ad8a316285173d1c96591b138` (`main`, `origin/main` at the time of this record) |
| Session | unattended `issue-workflow-implement-agent`, parallel id 3 |
| Owner of the gap | **the operator who holds the served host** — whoever has shell access to the machine that stores the export and runs `.github/scripts/deploy_advice_backend.sh`; naming falls to whoever deployment designates under [ADR-0008](../../../../specs/adr/decisions/0008-puzzle-catalog-storage.md) / [ADR-0010](../../../../specs/adr/decisions/0010-advice-backend-stack.md) |
| Consequence | **#329 AC5 stays unrealised.** No action on #329: `status:accepted` is terminal ([terminal-states.md](../../../issues/terminal-states.md)). Nothing else is affected — the wire contract and `DIF.Y1` were accepted against a slice, and the route refuses a wrong-count snapshot either way. |

## Why the run could not be produced here

1. **No export, no snapshot, no serving host.** A search for `lichess*`,
   `puzzle_snapshot*` and `*puzzles.csv*` outside the repo returns nothing,
   `/srv` does not exist, and `PUZZLE_CATALOG_CSV`, `PUZZLE_CATALOG_PATH` and
   `ADVICE_API_KEY` are unset in this session.
2. **The repository cannot stand in for it.** A synthetic file padded to
   6,157,341 rows would pass `check` without proving anything: `snapshot_id` is
   the `SNAPSHOT_ID` constant in
   [`advice_backend/catalog.py`](../../../../advice_backend/catalog.py), never read
   back from the built file.
3. **AC2's facts describe another machine.** The served file's path, size,
   mtime and SHA-256, the `build` line, and a `snapshot_id` from the serving
   process cannot be read here, and a recorded value that was not read there
   would be fiction the reviewer could not falsify.

## What closes this

On the host, from a clean checkout of the commit above, run
`python3 advice_backend/serve_i1_run.py <lichess-export.csv> <served path>`.
It refuses an existing served file (L2–L3), builds once, runs the default-count
check, and writes the transcript rows AC2 asks for — command, commit, elapsed
times, `build` stdout, `check` exit, path/bytes/mtime/SHA-256 — ending in
placeholders for the server start line and a deal's `snapshot_id`. Paste those
in, replace this outcome section, and AC2 is the test on the result. The slice
rehearsal to be told apart from is
[acceptance-served-slice.md §1](../issue-329/acceptance-served-slice.md).
