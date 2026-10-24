# Manifest — #400 full-coverage sweep, graphical run

- **Issue**: #400
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: `820f202` (`origin/main` + the `#846` fix branch), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session `sess-1792879524222-55186-playtest-446768`
- **Build source**: the `820f202` tree run in-process from a detached worktree — the `procedures.md` fallback, not a published reading: ADR-0009 publishes the seam-free `Web Release`, and this sweep needs `DBG.*` / `TEL.*`. Both folders name one commit (AC3).
- **Timing (`SIT.4` runs)**: not a `SIT.4` run.
- **Coverage mode**: `full` — the 23 protocols of `playtest.md` §Index.
- **Modes recorded**: Shared game, Puzzle stream and Advice all reachable; none failed or was deferred for a missing mode (AC4).

## Results

**4 pass, 0 fail, 2 not-judged** over the 6 display rows this run recorded; **0 pass, 0 fail, 23 not-judged** over the 23 protocols (a protocol is `pass` only when every cited row is `pass`, `fail` if any fails, `not-judged` if any is; `evidence.md`).

## Protocol verdicts

- **Design** (headless only): not judged in this run — design protocols are headless (`playtest.md` §Levels), and the headless folder records their twelve verdicts.
- **UX** (headless + graphical): this run re-judged the display rows of `PTU-localization` (**pass** there), `PTU-controls` (**pass**) and `PTU-shared-play` (**not-judged** — `UI-shared-play.US3.13` stays unreachable) plus the tunables rows of `PTU-mode-and-config`. Every other UX protocol stays `not-judged` here because its rows were not re-judged on the display; its UX verdict is the headless one.

## Story rows

One file per protocol, listed at [`rows/README.md`](../rows/README.md).

## Row-level `none`

Copied from the story-to-protocol map, never recorded `not-judged`:

| Story row | Recorded | Linked defect |
|---|---|---|
| `localization.md#US2` | none — LOC.US2 is out of playtest scope; judged by spec read | [#788](https://github.com/waigore/simplechessv2/issues/788) |

Every design row is judged on the map (`design/index.md` §Row-level `none` — 0), so the design run records no `none` row.

## `PTU-localization` (AC6)

The run quotes the landed protocol: `ux/localization.md:8` reads **Cites**: `UI-mode-pick.US1`, `LOC.US1`, unchanged since `972e2a1`; its S1–S3 step set is what the run drove.

## Defects

This graphical run re-judges only the rows a display unblocks: `PTU-localization` `LOC.US1`, `UI-shared-play.US3.14`, `UI-shared-play.US4.9`/`US4.11`/`US4.12`, `CFG` advice tunables and `IN.US3`. Every other row stays `not-judged` here by the protocol rule, so all 23 graphical protocol verdicts are `not-judged`: the headless folder owns the design pass and the UX row set, and the same rows are recorded once.

**None filed by this sweep.** No protocol reached `fail`: `#846` was fixed by `820f202` before this run, and every readable row passed. A `not-judged` row files no defect (`evidence.md`).

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson), [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json)
- Driver: [`logs/w400_sweep.gd`](logs/w400_sweep.gd) — the sweep driver, kept with the run so the readings can be reproduced.
- Notes: [`notes.md`](notes.md)
- Rows: [`rows/README.md`](../rows/README.md) — one file per protocol
- Screenshots: [`screenshots/`](screenshots/) — 7 images of the rows this run judged on the display.