# Boundary sweep and totals — #879 mode-pick presses

Moved out of [readings.md](readings.md); the button boxes and the centre-grid legs are there.

## Published `69a03d4`, boundary sweep (one arm per point)

| Point | y against the painted boxes | Result |
|---|---|---|
| (195,170) — the issue's own C1 point | 11.7 px inside C1 | **advanced** (`shared`) |
| (195,180) | 1.7 px inside C1, above its bottom border | **advanced** (`shared`) |
| (195,187) | 1.2 px inside C2, below its top border | **advanced** (`puzzle`) |
| (195,217) — the issue's own C2 point | 6 px inside C2 | **advanced** (`puzzle`) |
| (150,185) — the issue's recorded failing point | **in the seam** | no change |
| (195,183) | **in the seam** | no change |

`logs/published-boundary-readings.json`. The two seam arms ran **first** in the session that then
advanced on (195,170); a press 3 px away activated the same engine 1.2 s later.

## Delivery on every arm

Every arm — advancing or not — recorded `pointerdown`, `touchstart`, `pointerup`, `touchend` in the
page's capture-phase log (`logs/*-readings.json`, field `pageGestures`), so delivery never
differed between the arms that advanced and the arms that did not.

## Is the activation intermittent?

No loss in 34 presses inside a painted control (30 centre-grid arms plus 4 boundary points), across three legs, fresh and reopened sessions,
and two input paths. All 7 presses that did not act were in the seam or outside the panel.
