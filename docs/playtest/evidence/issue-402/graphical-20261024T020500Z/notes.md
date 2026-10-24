# Notes — #402 quality-row re-record, run `graphical-20261024T020500Z`

Unattended `issue-workflow-implement-agent` run (parallel id 3, `Assigned issue: 402`). Re-reads every
`specs/definition/quality.md` row under the **Build under test** field this issue landed in its refine pass.

Builds and attribution: [builds.md](builds.md). Numbers: [readings.md](readings.md). Rows: [manifest.md](manifest.md).

## Row judgements

**2 `fail`, 8 `not-judged`, 0 `pass`** on the published reading; the fallback control agrees on every row it
was read for.

`not-judged` is chosen, not `fail`, for rows the build never reached: per `specs/playtest/evidence.md` a row
the run could not judge is `not-judged`, never `pass`. Rows that ran and misbehaved — board playable — are `fail`.
Observability is `not-judged` for a different reason: the row does not describe these builds at all (see below).

## What the re-read establishes

- **The repair reaches the build but not the screen.** The fallback's pack carries `35/35 cataloged
  game_assets/ file(s)` (`--check-assets` exit 0) and the browser still cannot open `res://game_assets/…`, so
  `EX.loading` persists. That is the read-path question ADR-0014 records; #715 owns proving it.
- **Observability was read on the wrong build (corrected by #729).** No `TEL.*` line appears on either build
  (`game/session_router.gd:98–117`: `_emit_tel` is a no-op without the seam). That silence is **specified** for a
  release build, not a failure: `CTR-playtest-drive` G2 and `CMP-playtest-seams` R3 put the seam — and `E1` — on
  playtest builds only, and `verification.md` H1/I3 strip or no-op `S7` (telemetry emit) in release. The row's
  *How checked* cell reads `SIT.5`, which `S12` realizes over `E1`; the row therefore judges the
  **playtest-certified build** (`main.tscn`), which this run did not read. It is `not-judged` here — build out of
  envelope — and is **not** independent of the build, contrary to what this note first claimed.
- **Verdicts are unchanged from the superseded `98d3473` reading.** The rows now name their build; the old
  folder [`../graphical-20261024T011500Z/`](../graphical-20261024T011500Z/manifest.md) stays as the superseded record.
- **Frame numbers are reported, not judged** — see [readings.md](readings.md).

## Defects filed

- **#630** — shipped release never leaves `EX.loading`; the screen-wide cause, and the cited defect for Load
  time — board playable. Not re-filed: these readings do not change it, and a second defect for one
  observation would fork the owner.
- **#729** — the Observability row was judged here on the wrong build. It names the playtest-certified build
  (`SIT.5` over `E1`), not the release builds this run read, and release-side silence is specified. #729 owns the
  record correction; `#506` owns the row's build envelope. Sub-issue of #37.

Nothing was fixed inside the gate: no code, spec, or asset changed; the run folder is the only artefact.

## Re-record rules followed

- Every row names its build, so a later record on a repaired build compares like with like.
- The superseded reading stays in the tree, with what the re-read found unchanged per row.
- A fallback row is labelled as such everywhere and never written into a published reading.
