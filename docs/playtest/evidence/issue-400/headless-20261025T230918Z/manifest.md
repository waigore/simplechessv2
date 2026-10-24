# Manifest — #400 full-coverage sweep, headless run

- **Issue**: #400
- **Environment**: `headless` (`ENV.1`)
- **Build / session id**: `820f202` (`origin/main` + the `#846` fix branch), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session `sess-1792879521801-55149-playtest-466860`
- **Build source**: the `820f202` tree run in-process from a detached worktree — the `procedures.md` fallback, not a published reading: ADR-0009 publishes the seam-free `Web Release`, and this sweep needs `DBG.*` / `TEL.*`. Both folders name one commit (AC3).
- **Timing (`SIT.4` runs)**: not a `SIT.4` run.
- **Coverage mode**: `full` — the 23 protocols of `playtest.md` §Index.
- **Modes recorded**: Shared game, Puzzle stream and Advice all reachable; none failed or was deferred for a missing mode (AC4).

## Results

**52 pass, 0 fail, 15 not-judged** over the 67 rows this run recorded; **11 pass, 0 fail, 12 not-judged** over the 23 protocols (a protocol is `pass` only when every cited row is `pass`, `fail` if any fails, `not-judged` if any is; `evidence.md`).

**Why `not-judged` rows exist.** Each is a judged row left `not-judged`, with its reason in its `rows-<protocol>.md`: a crafted position with no seam, a headless reading, or a spec review. The **run** is complete with them; the **issue** is not accepted while one exists.

## Protocol verdicts

- **Design** (headless only): `PTD-shared-game` **not-judged**; `PTD-puzzle-stream` **pass**; `PTD-move-advice` **pass**; `PTD-mode-and-config` **not-judged**; `PTD-end-conditions` **not-judged**; `PTD-game-state` **pass**; `PTD-pieces-common` **not-judged**; `PTD-pieces-king` **not-judged**; `PTD-pieces-officers` **not-judged**; `PTD-pieces-pawn` **not-judged**; `PTD-difficulty` **pass**; `PTD-progression` **pass**.
- **UX** (headless + graphical): `PTU-shared-session` **pass**; `PTU-puzzle-session` **pass**; `PTU-mode-pick` **pass**; `PTU-shared-setup` **pass**; `PTU-shared-play` **not-judged**; `PTU-shared-result` **pass**; `PTU-puzzle-play` **not-judged**; `PTU-controls` **not-judged**; `PTU-navigation` **pass**; `PTU-exceptions` **not-judged**; `PTU-localization` **not-judged**.

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

**None filed by this sweep.** No protocol reached `fail`: `#846` was fixed by `820f202` before this run, and every readable row passed. A `not-judged` row files no defect (`evidence.md`).

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson), [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json)
- Driver: [`logs/w400_sweep.gd`](logs/w400_sweep.gd) — the sweep driver, kept with the run so the readings can be reproduced.
- Notes: [`notes.md`](notes.md)
- Rows: [`rows/README.md`](../rows/README.md) — one file per protocol
- Screenshots: none — headless run; waiting on the [graphical run](../graphical-20261025T231024Z/manifest.md)