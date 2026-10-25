# Manifest

- **Issue**: 795 — Puzzle-play S4 promotion chooser shows no readable Q/R/B/N labels
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, macOS Metal
  (Apple M5, Compatibility renderer), shipped playtest scene `game/main.tscn`
- **Build**: the fix branch `defect/795-s4-promotion-labels` off `task/334-acceptance-headless`
  (`05b2752`, itself off `origin/main` with #794). Probe `TEL.3`
  `sess-1792858870079-99039-playtest-402199` from the first run of this folder.
- **Coverage mode**: partial — one defect, one state. Only `UI-puzzle-play` S4/C6 is judged
  here; the #333 acceptance run owns the whole screen (its `PTU-puzzle-play` S6–S8 row is the
  one this work answers).
- **Deal source**: `DBG.3` — a dealt record injected into the live session, as
  `game/puzzle_play_test.gd` does. The entry path is the real `C2` control.
- **Before reference**: `screenshots/s4-before-1280x720.png`, copied from
  [`../issue-333/graphical-20261024T150000Z/screenshots/puzzle-play-s4-promotion.png`](../../issue-333/graphical-20261024T150000Z/screenshots/puzzle-play-s4-promotion.png),
  `origin/main` `39fb372`. Not re-shot: the named-strip state could not be reproduced off the
  fixed branch (see `notes.md`).

## Results

| Row | Outcome | Notes |
|-----|---------|-------|
| `UI-puzzle-play` S4 — C6 carries its four visible names (`US3.1`, `US3.4`, `US3.8`, `US3.9`) | **pass** | Queen, Rook, Bishop, Knight read on one line each inside R2, in the C6 table order (`logs/s4-rects.log`) |
| `UI-puzzle-play` S4 — names are legible, not clipped (`UIS.T2`, `PAL.K4`) | **pass** | 18 px at 1280×720 (≥ 16), each box at least its text's minimum size, clear of R1 |
| `UI-puzzle-play` S4 — a name never covers the board (`PRJ.A1`) | **pass** | board top 219.375 = S4 reserve; every name above it |
| `UI-puzzle-play` S4 — the state reflows at another frame (`SIT.6`) | **pass** | 720×1280: names still inside the strip, 48 px |
| `UI-puzzle-play` S6 — the commit itself | not-judged | Unchanged logic; `game/puzzle_play_test.gd` covers the commit and #333 exercised it |

## Defects

- **#795** — the defect this folder answers. No new defect found in the S4 chooser.
  Out-of-scope rendering work still open from the same #333 run: **#793** (S2 confirm paints
  nothing). #793's own dialog geometry is unaffected — this change only sizes the puzzle strip
  and touches no confirm/save box.

## Paths

- `notes.md`, `logs/s4-rects.log`, `probe/zz_accept795_rects.gd`, `screenshots/` (3 frames)
