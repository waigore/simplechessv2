# Sweep summary — #550, wave 2

**Build**: `26b07af` (`origin/main`, 2026-10-25), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2.stable.official.ed1daf0bf`. One build across both folders: `TEL.3` sessions `sess-1792893272248-94361-playtest-807719` (headless) and `sess-1792893281479-94581-playtest-643849` (graphical).

**Coverage mode**: `full`, intersected with #550's scope — 8 design protocols (headless) and 7 UX protocols (headless and graphical). View stories excluded.

**Story rows**: copied from `specs/playtest/traceability/story-protocol/protocols-design.md` and `protocols-ux.md` at `26b07af` — 44 rows (26 design, 18 UX), one manifest row each.

**Runs**: [`headless-20261025T015431Z/manifest.md`](headless-20261025T015431Z/manifest.md) and [`graphical-20261025T015431Z/manifest.md`](graphical-20261025T015431Z/manifest.md).

## Verdicts

- **Design, headless**: 4 pass, 4 not-judged, 0 fail — pass: `PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression`, `PTD-game-state`. Not-judged: `PTD-pieces-common`, `PTD-pieces-king`, `PTD-pieces-officers`, `PTD-pieces-pawn`.
- **UX, headless**: 3 pass, 4 not-judged, 0 fail — pass: `PTU-puzzle-session`, `PTU-mode-pick`, `PTU-navigation`. Not-judged: `PTU-puzzle-play`, `PTU-controls`, `PTU-exceptions`, `PTU-localization`.
- **UX, graphical**: 4 pass, 3 not-judged, 0 fail — pass: `PTU-puzzle-session`, `PTU-mode-pick`, `PTU-navigation`, `PTU-controls`. Not-judged: `PTU-puzzle-play`, `PTU-exceptions`, `PTU-localization`.

No row failed anywhere, so no `type:defect` was filed.

## `not-judged` rows

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

## The deal source, stated once

Every judged deal came from the `Web Playtest` export's simulated catalog peer (`FakeCatalogTransport` through `PlaytestSeams`, ADR-0013 Testability). The shipped build itself deals nothing: `T9`/`T10` are never supplied (`game/session_router.gd:33-34`), the boot read fails, and `https://waigore.github.io/catalog/deal` answered 404 on 2026-10-25. That is [#655](https://github.com/waigore/simplechessv2/issues/655) / [#892](https://github.com/waigore/simplechessv2/issues/892) / [#878](https://github.com/waigore/simplechessv2/issues/878), not this task's, and this task changed no code. `notes.md` in each folder says what that means for AC 1/AC 4.

## Superseded pair

[`headless-20261024T000000Z/`](headless-20261024T000000Z/manifest.md) and [`graphical-20261024T000000Z/`](graphical-20261024T000000Z/manifest.md) are **superseded** by this pair. That run derived its rows from each protocol's `Cites` line, because the map was not on `main` yet, and recorded `dealt=false`; this pair copies rows from the landed map and judges the deal through the same playtest peer #478 and #400 used. Both pairs stay in the tree under `evidence.md` §Retention.
