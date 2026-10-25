# `PER.R1` naming record — #640 accessibility review

Sheet: [`silhouette-sheet.png`](silhouette-sheet.png) · transcript: [`../logs/reader-transcript.md`](../logs/reader-transcript.md)
· key: [`../logs/key.md`](../logs/key.md) · twelve-row trace: [`asset-trace.md`](asset-trace.md)

**One claim, one artefact.** Judged here: `PER.R1`'s first two clauses — each type named
from a solid-black silhouette at its `FRM.P2` height, and the King at `FRM.P1`'s `0.85`
unit in a `PRJ.V1` 9:16 frame. The other two clauses are **not judged** here
([`../per-r1.md`](../per-r1.md)).

## The judged read

The sheet carries six solid-black silhouettes in the `FRM.L1` lineup on one ground line,
each with one anonymous label and nothing else. The reader had no access to the key and
did not view any other artefact.

| Label | Silhouette image path | Reader's named type | `pass`/`fail` |
|---|---|---|---|
| A | `screenshots/silhouette-sheet.png` (figure A) | King | `pass` |
| B | `screenshots/silhouette-sheet.png` (figure B) | Queen | `pass` |
| C | `screenshots/silhouette-sheet.png` (figure C) | Bishop | `pass` |
| D | `screenshots/silhouette-sheet.png` (figure D) | Knight | `pass` |
| E | `screenshots/silhouette-sheet.png` (figure E) | Rook | `pass` |
| F | `screenshots/silhouette-sheet.png` (figure F) | Pawn | `pass` |

Written before the key was joined. The key is stated below, after the verdict column.

## Key (stated after the six verdicts)

| Label | Type | `FRM.P2` (units) | Rendered opaque height | Verdict |
|---|---|---|---|---|
| A | King | 0.85 | 102 px | `pass` |
| B | Queen | 0.79 | 95 px | `pass` |
| C | Bishop | 0.76 | 91 px | `pass` |
| D | Knight | 0.75 | 89 px | `pass` |
| E | Rook | 0.68 | 82 px | `pass` |
| F | Pawn | 0.62 | 74 px | `pass` |

Every row is `pass`; `PER.R1`'s shape clause is **`pass`** for the six types.

## How the sheet was drawn

`render.mjs` + `label.mjs` render it; `sheet.json` records the geometry.

- **Lineup and heights:** the six types in `FRM.L1` order at their `FRM.P2` opaque
  heights on one ground line, under **one uniform scale** (`FRM.P1`) — not a per-sprite
  box fit — so the rendered heights keep the `FRM.P2` ratios.
- **Fill:** solid black over the whole opaque body, including the band `SRF.O1` would
  outline; alpha is the only mask, so no contour or highlight survives.
- **Frame:** `PRJ.V1` 9:16, unit 120 px, so the notional frame is 1 200 × 2 136 px and
  the King's 102 px is `1/20.94` of frame height (`FRM.L1` ≥ about 1/21).
- **Labels only:** six bitmap glyphs A–F below the ground line. No type name, side word,
  filename, or asset ID appears on the sheet.
