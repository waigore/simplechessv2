# Manifest — #550 wave-2 sweep, headless run

- **Issue**: #550 (Wave 2 — Adaptive Puzzle stream)
- **Environment**: `headless` (`ENV.1`)
- **Build / session id**: `26b07af` (`origin/main`, 2026-10-25), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session `sess-1792893272248-94361-playtest-807719`
- **Build source**: the `26b07af` tree run in-process from a detached worktree (`godot --headless --path game`) — the [`procedures.md`](../../../specs/playtest/procedures.md) fallback, not a published reading: ADR-0009 publishes the seam-free `Web Release` only, and this sweep needs `DBG.*` / `TEL.*`. Both folders name the same commit.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run — no timing row is judged here; the one `SIT.6` step (`PTU-mode-pick` S6) reads text size, not frame time.
- **Coverage mode**: `full`, intersected with #550's scope: 8 design + 7 UX protocols. Design protocols are headless only; the 7 UX protocols run in both environments. No view story is in the set.
- **Story-row source**: [`protocols-design.md`](../../../specs/playtest/traceability/story-protocol/protocols-design.md) and [`protocols-ux.md`](../../../specs/playtest/traceability/story-protocol/protocols-ux.md) at `26b07af`; no row re-derived from a protocol's `Cites` line. **44 rows**: 26 design + 18 UX.
- **`PTU-localization` `Cites` line**, verbatim from `specs/playtest/ux/localization.md` at `26b07af`: **Cites**: `UI-mode-pick.US1`, `LOC.US1`.
- **Screenshots**: none — headless run; every screenshot path is waiting on [`../graphical-20261025T015431Z/screenshots/`](../graphical-20261025T015431Z/screenshots/), the same build.
- **Driver**: [`logs/w550_sweep.gd`](logs/w550_sweep.gd) — kept with the run so the readings can be reproduced. It is the #400 sweep driver (`logs/w400_sweep.gd`), with the wave-2 changes `notes.md` §Driver lists.
- **Defects**: none filed — no story row failed. The shipped-path deal is #655 / #892's, not this run's finding.

## Results

**44 rows** — 35 pass, 0 fail, 9 not-judged. **15 protocols** — 7 pass, 0 fail, 8 not-judged. A protocol is `pass` only when every cited story passes, `fail` if any fails, `not-judged` if any is ([`evidence.md`](../../../specs/playtest/evidence.md)).

## Protocol verdicts

- **Design**: 4 pass, 4 not-judged, 0 fail — pass: `PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression`, `PTD-game-state`. Not-judged: `PTD-pieces-common`, `PTD-pieces-king`, `PTD-pieces-officers`, `PTD-pieces-pawn`.
- **UX**: 3 pass, 4 not-judged, 0 fail — pass: `PTU-puzzle-session`, `PTU-mode-pick`, `PTU-navigation`. Not-judged: `PTU-puzzle-play`, `PTU-controls`, `PTU-exceptions`, `PTU-localization`.

## Results by protocol

| Protocol | Verdict | Rows | pass | fail | not-judged |
|---|---|---|---|---|---|
| `PTD-puzzle-stream` | **pass** | 5 | 5 | 0 | 0 |
| `PTD-difficulty` | **pass** | 2 | 2 | 0 | 0 |
| `PTD-progression` | **pass** | 2 | 2 | 0 | 0 |
| `PTD-game-state` | **pass** | 9 | 9 | 0 | 0 |
| `PTD-pieces-common` | **not-judged** | 4 | 3 | 0 | 1 |
| `PTD-pieces-king` | **not-judged** | 2 | 1 | 0 | 1 |
| `PTD-pieces-officers` | **not-judged** | 1 | 0 | 0 | 1 |
| `PTD-pieces-pawn` | **not-judged** | 1 | 0 | 0 | 1 |
| `PTU-puzzle-session` | **pass** | 1 | 1 | 0 | 0 |
| `PTU-puzzle-play` | **not-judged** | 5 | 4 | 0 | 1 |
| `PTU-mode-pick` | **pass** | 2 | 2 | 0 | 0 |
| `PTU-navigation` | **pass** | 2 | 2 | 0 | 0 |
| `PTU-controls` | **not-judged** | 3 | 2 | 0 | 1 |
| `PTU-exceptions` | **not-judged** | 2 | 0 | 0 | 2 |
| `PTU-localization` | **not-judged** | 3 | 2 | 0 | 1 |

## Story rows

One file per protocol, one row per story row the map lists:

- **`PTD-puzzle-stream`** — [rows-puzzle-stream.md](rows-puzzle-stream.md)
- **`PTD-difficulty`** — [rows-difficulty.md](rows-difficulty.md)
- **`PTD-progression`** — [rows-progression.md](rows-progression.md)
- **`PTD-game-state`** — [rows-game-state.md](rows-game-state.md)
- **`PTD-pieces-common`** — [rows-pieces-common.md](rows-pieces-common.md)
- **`PTD-pieces-king`** — [rows-pieces-king.md](rows-pieces-king.md)
- **`PTD-pieces-officers`** — [rows-pieces-officers.md](rows-pieces-officers.md)
- **`PTD-pieces-pawn`** — [rows-pieces-pawn.md](rows-pieces-pawn.md)
- **`PTU-puzzle-session`** — [rows-puzzle-session.md](rows-puzzle-session.md)
- **`PTU-puzzle-play`** — [rows-puzzle-play.md](rows-puzzle-play.md)
- **`PTU-mode-pick`** — [rows-mode-pick.md](rows-mode-pick.md)
- **`PTU-navigation`** — [rows-navigation.md](rows-navigation.md)
- **`PTU-controls`** — [rows-controls.md](rows-controls.md)
- **`PTU-exceptions`** — [rows-exceptions.md](rows-exceptions.md)
- **`PTU-localization`** — [rows-localization.md](rows-localization.md)

## `not-judged` rows and their reasons

| Story row | Protocol | Why it is `not-judged` |
|---|---|---|
| `entities/pieces/common-attack.md#PS2` | `pieces-common` | `I5`/`I6` attacked-square scenarios need a crafted position, and the build offers no position seam for the puzzle or shared board. |
| `entities/pieces/king-castling.md#PS1` | `pieces-king` | castling needs a cleared `f1`/`g1`, reachable only through a crafted position. |
| `entities/pieces/officers.md#PS1` | `pieces-officers` | the queen's and rooks' long rays are blocked by the orthodox opening, so those scenarios need a crafted position. |
| `entities/pieces/pawn.md#PS1` | `pieces-pawn` | en passant and promotion need a crafted position. |
| `screens/puzzle-play-place.md#US3` | `puzzle-play` | `US3.13` promotion and `US3.14` the lapsed confirm need a last-rank pawn; no reachable deal offers one and the build offers no position seam. |
| `controls-point.md#US3` | `controls` | pointing needs a display; the graphical run judges it. |
| `exceptions.md#US1` | `exceptions` | `US1.6` needs a non-touch Web device (unsupported input), which neither environment is; the other cells of the row are judged. |
| `exceptions-play.md#US1` | `exceptions` | `US1.8`/`US1.9` promotion needs a crafted position; the other cells of the row are judged. |
| `localization.md#US1` | `localization` | `LOC.US1.1` (key names) is a spec review, not a run state, per `specs/playtest/ux/localization.md` §Evidence; the protocol reads `LOC.US1` as its three scenarios, so the row stays `not-judged` while `LOC.US1.2`/`LOC.US1.3` pass. |

## Row-level `none`

| Story row | Recorded | Linked defect |
|---|---|---|
| `localization.md#US2` | none — `LOC.US2` is out of playtest scope; judged by spec read | [#788](https://github.com/waigore/simplechessv2/issues/788) |

Every design row is judged on the map, so the design run records no row-level `none`.

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson), [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json), [`logs/w550_sweep.gd`](logs/w550_sweep.gd)
- Notes: [`notes.md`](notes.md)
- The [graphical run](../graphical-20261025T015431Z/manifest.md) records the other environment of this sweep.
