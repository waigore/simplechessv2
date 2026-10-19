# Screen: Puzzle play controls

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

Part of [`puzzle-play.md`](puzzle-play.md). Control rows for `UI-puzzle-play`.

## Shows

N/A — [`puzzle-play.md`](puzzle-play.md).

## Regions

N/A — [`puzzle-play.md`](puzzle-play.md).

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Select piece | `IN.select` | Puzzle open; not in confirm; not S4 | Sets selection |
| C2 | Place move | `IN.move` | Selection set; not S4; not in confirm | Legal place is judged by the puzzle. Last-rank pawn → S4 first. A place the piece rules refuse → S5 and is not a wrong puzzle move |
| C3 | Reveal | `IN.activate` | Puzzle open; not S4 | → `EX.confirm` reveal |
| C4 | Abandon | `IN.activate` | Puzzle open; not S4 | → `EX.confirm` abandon |
| C5 | Leave stream | `IN.activate` | Not S4 | → `EX.confirm` leave → `mode-pick` (NAV.T9) |
| C6 | Promotion piece | `IN.activate` | S4 | Commits tapped Q, R, B, or N ([I33](../../design/entities/pieces/pawn.md)); the puzzle then judges that move |

## States

N/A — [`puzzle-play.md`](puzzle-play.md).

## Copy

N/A — [`puzzle-play.md`](puzzle-play.md).

## Experience intent

N/A — [`puzzle-play.md`](puzzle-play.md).
