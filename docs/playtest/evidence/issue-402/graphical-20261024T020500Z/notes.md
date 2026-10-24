# Notes — #402 quality-row re-record, run `graphical-20261024T020500Z`

Unattended `issue-workflow-implement-agent` run (parallel id 3, `Assigned issue: 402`). Re-reads every
`specs/definition/quality.md` row under the **Build under test** field this issue landed in its refine pass.

Builds and attribution: [builds.md](builds.md). Numbers: [readings.md](readings.md). Rows: [manifest.md](manifest.md).

## Row judgements

**2 `fail`, 8 `not-judged`, 0 `pass`** on the published reading; the fallback control agrees on every row it
was read for.

`not-judged` is chosen, not `fail`, for rows the build never reached: per `specs/playtest/evidence.md` a row
the run could not judge is `not-judged`, never `pass`. Rows that ran and misbehaved — board playable,
Observability — are `fail`.

## What the re-read establishes

- **The repair reaches the build but not the screen.** The fallback's pack carries `35/35 cataloged
  game_assets/ file(s)` (`--check-assets` exit 0) and the browser still cannot open `res://game_assets/…`, so
  `EX.loading` persists. That is the read-path question ADR-0014 records; #715 owns proving it.
- **Observability is independent of #630.** No `TEL.*` line appears on either build (`game/session_router.gd:99–117`:
  `_emit_tel` is a no-op without the seam), so that row fails on its own and is filed as **#729**.
- **Verdicts are unchanged from the superseded `98d3473` reading.** The rows now name their build; the old
  folder [`../graphical-20261024T011500Z/`](../graphical-20261024T011500Z/manifest.md) stays as the superseded record.
- **Frame numbers are reported, not judged** — see [readings.md](readings.md).

## Defects filed

- **#630** — shipped release never leaves `EX.loading`; the screen-wide cause, and the cited defect for Load
  time — board playable. Not re-filed: these readings do not change it, and a second defect for one
  observation would fork the owner.
- **#729** — release export emits no `TEL.*`; the Observability row fails. Filed because no open defect owned
  the row (#506 is a planning task), and it has now failed on `98d3473`, `dd15479`, and `bccdb1c`. Sub-issue of #37.

Nothing was fixed inside the gate: no code, spec, or asset changed; the run folder is the only artefact.

## Re-record rules followed

- Every row names its build, so a later record on a repaired build compares like with like.
- The superseded reading stays in the tree, with what the re-read found unchanged per row.
- A fallback row is labelled as such everywhere and never written into a published reading.
