# Readings — #879 acceptance run

Independent re-derivation of the arm logs in
[`../graphical-20261025T005759Z/logs/`](../graphical-20261025T005759Z/logs/), plus this run's
cold-open frame.

Coordinates are CSS px at 390×844, DPR 3. Boxes read from
`screenshots/mode-pick-published-00.png` with `scripts/boxes.py` (full-width painted rows: 24.5,
144.83, 181.67, 185.83, 223.0, 271.5).

| Control | Painted box (CSS px) | Centre pressed | Centre outcome |
|---|---|---|---|
| C1 Shared game | y 144.83–181.67 | (195, 163) | activates → `shared` |
| C2 Puzzle stream | y 185.83–223.00 | (195, 204) | activates → `puzzle` |
| Seam | y 181.67–185.83 (4.16 px) | (150,185), (195,183) | nothing |
| Off panel | x < 87.3 / below the panel | (40,163), (195,400) | nothing |

## Frame identity

| Frame | sha256 (prefix) | Note |
|---|---|---|
| `screenshots/mode-pick-published-00.png` (this run, cold open) | `c20b06d2ce78…4b90` | identical to the issue's `boardtap-69a03d4-00-mode-pick.png` |
| impl `published-00-mode-pick.png` | `c20b06d2ce78…4b90` | same bytes |
| impl `export-00-mode-pick.png` | `c20b06d2ce78…4b90` | same bytes |
| impl `published-01-shared-advanced.png` | `bbefbb38e45a…` | C1 advanced |
| impl `published-02-puzzle-advanced.png` | `bb8d41b112f7…` | C2 advanced |
| impl `published-03-seam-150-185-unmoved.png` | `c20b06d2ce78…4b90` | seam press, no change |

The advanced digests are exactly the `postSha` values recorded for the corresponding arms, so the
arm logs and the committed frames agree.

## Per-arm cross-check (all legs)

| Leg | Arms | Inside a control | Advanced | Seam / off panel |
|---|---|---|---|---|
| published, touch (`logs/published-centre-readings.json`) | 14 | 12 | **12** | 0/2 (off panel) |
| export of `69a03d4`, touch (`logs/export-centre-readings.json`) | 15 | 12 | **12** | 0/3 (2 seam, 1 off panel) |
| published, plain mouse (`logs/published-mouse-readings.json`) | 7 | 6 | **6** | 0/1 (seam) |
| published, boundary sweep (`logs/published-boundary-readings.json`) | 6 | 4 | **4** | 0/2 (seam) |

Totals: **34/34 presses inside a painted control activated; 8/8 presses in the seam or off the panel
did nothing.** Every arm, acting or not, carried a page gesture log, so delivery never differed
between them.
