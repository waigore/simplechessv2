# Protocol verdict and `not-judged` rows — headless-20261025T015431Z

Back to [`manifest.md`](manifest.md). Verdict rule: [`evidence.md`](../../../../../specs/playtest/evidence.md) — a protocol is `pass` only when every cited story passes, `fail` if any fails, `not-judged` if any is.

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

## `not-judged` rows and their reasons

| Story row | Protocol | Why it is `not-judged` |
|---|---|---|
| `entities/pieces/common-attack.md#PS2`, `king-castling.md#PS1`, `officers.md#PS1`, `pawn.md#PS1` | `pieces-common`, `pieces-king`, `pieces-officers`, `pieces-pawn` | all four need a crafted position the build offers no seam for: `I5`/`I6` attacked squares, castling with a cleared `f1`/`g1`, the officers' long rays (blocked by the orthodox opening), and en passant plus promotion. |
| `screens/puzzle-play-place.md#US3` | `puzzle-play` | `US3.13` promotion and `US3.14` the lapsed confirm need a last-rank pawn; no reachable deal offers one and the build offers no position seam. |
| `controls-point.md#US3` | `controls` | pointing needs a display; the graphical run judges it. |
| `exceptions.md#US1` | `exceptions` | `US1.6` needs a non-touch Web device (unsupported input), which neither environment is; the other cells of the row are judged. |
| `exceptions-play.md#US1` | `exceptions` | `US1.8`/`US1.9` promotion needs a crafted position; the other cells of the row are judged. |
| `localization.md#US1` | `localization` | `LOC.US1.1` (key names) is a spec review, not a run state, per `specs/playtest/ux/localization.md` §Evidence; the protocol reads `LOC.US1` as its three scenarios, so the row stays `not-judged` while `LOC.US1.2`/`LOC.US1.3` pass. |

## Row-level `none`

| Story row | Recorded | Linked defect |
|---|---|---|
| `localization.md#US2` | none — `LOC.US2` is out of playtest scope; judged by spec read | [#788](https://github.com/waigore/simplechessv2/issues/788) |

Every design row is judged on the map, so the design run records no other row-level `none`.
