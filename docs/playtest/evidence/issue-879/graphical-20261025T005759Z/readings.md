# Readings — #879 mode-pick presses

Coordinates are CSS px at 390×844, DPR 3, read from a frame taken **in the same session** as the
press (`scripts/boxes.py`, full-width painted border rows).

## Button boxes

| Control | Painted box (CSS px) | Centre pressed |
|---|---|---|
| Panel | x 87.3–302.3, y 24.5–271.5 | — |
| C1 Shared game | x 87.3–302.3, **y 144.83–181.67** | (195, 163) |
| C2 Puzzle stream | x 87.3–302.3, **y 185.83–223.00** | (195, 204) |
| Seam between C1 and C2 | y **181.67–185.83** (4.16 px) | — |

The published frame (`published-00-mode-pick.png`, sha256 `c20b06d2ce78…4b90`) is **byte-identical**
to the frame the issue cites, and to the local export's frame (`export-00-mode-pick.png`), so both
legs paint the same layout and the same coordinates apply.

## Published `69a03d4`, touch (6 arms per button, 200 ms hold)

| Arm | Point | Result | `last_mode` after |
|---|---|---|---|
| ×6 | C1 (195,163) | **6/6 advanced** | `shared` |
| ×6 | C2 (195,204) | **6/6 advanced** | `puzzle` |
| ×1 | outside panel (40,163) | no change | — |
| ×1 | outside panel (195,400) | no change | — |

`logs/published-centre-readings.json`. `published-01-shared-advanced.png` shows "Shared game
setup"; `published-02-puzzle-advanced.png` shows the puzzle-play screen with `Elo 1000`.

## Local `Web Release` of `69a03d4`, touch (6 arms per button)

**6/6** C1, **6/6** C2, 0/1 outside panel, 0/2 seam — the published leg repeated on the export.
`logs/export-centre-readings.json`.

## Published `69a03d4`, plain mouse, no touch emulation (3 arms per button)

**3/3** C1, **3/3** C2, 0/1 seam. The page saw `pointerdown → pointerup → click` and no
`touchstart`, so the loss is not in the touch-emulation path either.
`logs/published-mouse-readings.json`.

The boundary sweep, the delivery note on every arm, and what the totals say about an intermittent
loss are in [boundary-and-totals.md](boundary-and-totals.md).
