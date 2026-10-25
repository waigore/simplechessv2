# Manifest — #641 colour-blind reading of turn, clocks, side, and marks

- **Issue**: #641 — turn, clocks, player side, and marks under colour-blind simulation
- **Environment**: `graphical`. Headless Chrome 156, frame 390 × 844 CSS px, DPR 2, touch emulation over CDP (engine banner in [`build.md`](build.md)).
- **Build / session id**: served commit `69a03d4`, published by `Web release` run 40146630737, read from `https://waigore.github.io/simplechessv2/` at run time — **HTTP `200`**. No `TEL.3` session id ships (ADR-0004 `G2`), so the served commit is the build id. Digests: [`build.md`](build.md). **A local export is not the build under test and none was used.**
- **Timing (`SIT.4`)**: not a `SIT.4` run; no frame-time or load-time sample is claimed.
- **Coverage mode**: `critical-only`, scoped to #641's surface table.
- **Review run, not a playtest protocol run**: this folder is a **review run, not a `PTU-*` protocol run**; no playtest protocol or `SIT.*` row is claimed.
- **Defects**: #888 — shared play paints no last-move mark at all.

## Results

Judged on **non-colour redundancy** only, through full-severity protanopia and deuteranopia simulation
of the same frame. Detail: [`rows.md`](rows.md), [`gaps.md`](gaps.md).

| Signal | Element IDs | Non-colour cue | Verdict |
|---|---|---|---|
| Whose turn is active | `UI-shared-play.R2`, `PER.R6`, `PAL.K4` | the words `White to move` / `Black to move` | **pass** |
| Which clock is running | `UI-shared-play.R2`, `PER.R6` | running numerals (`W` 0:58 → 0:54, `B` holds) + `W`/`B` letters | **pass** |
| Selection | `PAL.K9`, `PER.R3`, `PAL.K5` (`C6`) | ring on the square edge, piece held | **pass** |
| Refused place | `PAL.K9`, `PER.R8`, `PAL.K5` (`C8`) | rim on the attempted square; selection kept | **pass** |
| Legal destinations, empty | `PAL.K9`, `PER.R4`, `PAL.K6` (`C11`) | diamond at the square centre | **pass** |
| Legal destinations, capture | `PAL.K9`, `PER.R4`, `PAL.K6` (`C11`) | ring around the opponent's piece | **pass** |
| Check | `PAL.K9`, `PER.R6`, `UI-shared-play.R2` | the word `Check` beside the L-frame on the king's square | **pass** |
| Last move | `PAL.K9` mark set, `PER.R2` | **none** — 9 captures from +0 ms to settled are pixel-identical | **fail → #888** |
| Advice best-move mark and eval | `PER.R5`, `F-move-advice` `R4` | not readable: no mark or eval paints with `Advice On` | `not-judged` (#505, `PER.R5`) |
| Puzzle play: player's side, both colours on the board | `PER.R1`, `PAL.K2`-adjacent | not readable: no puzzle deals, so no side is on the board | `not-judged` (#655, `PER.R1`) |

`K5`/`K6` reproduce at 2.01:1 on both squares; simulated readings and unjudged observations:
[`contrast.md`](contrast.md).

## Paths

- [`notes.md`](notes.md), [`rows.md`](rows.md), [`gaps.md`](gaps.md), [`contrast.md`](contrast.md), [`reproduction.md`](reproduction.md), [`build.md`](build.md)
- [`readings.json`](readings.json), `frames.json`, `logs/`
- `screenshots/` — row frames paired as `<frame>-protanopia.png` / `-deuteranopia.png`; bursts and context frames un-simulated
- Scripts: `capture.mjs`, `cdp.mjs`, `simulate.py`, `readings.py`

## Handoff

Posted on #402; #403 cites that comment for the ADR-0001 *Piece shape and color-blind readability* row.
