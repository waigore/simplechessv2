# Cues and bed switching (AC 3 / AC 4) — #627 phone listening run

Part of [`manifest.md`](manifest.md). Neither AC could be graded on this run: no cue was
reached, and no bed switch was standing long enough.

## Bed switching `M1 → M2 → M1` (AC 4) — **stop**, not graded

| Observation | Build | Reading |
|---|---|---|
| Second bed reachable within a sitting | published `69a03d4` | **no** — `_start_ambient()` plays one bed and only advances in `_on_music_finished`; the bed is 180.036 s, so a switch needs ≈3 min 0 s of *uninterrupted* play |
| Standing in this run | published `69a03d4` | no sitting of that length was taken; the switch is `not-judged` |

## Each shipped cue (AC 3) — **not-judged**, and why

| Cue | `SND.X` element | Reached in the run? | Graph reading | Judgement |
|---|---|---|---|---|
| pick-up | `SND.X1` touch/select | **no** — board never reached | no `source.start` shorter than the bed | `not-judged` |
| place / settle | `SND.X2` movement | **no** | — | `not-judged` |
| check | `SND.X3` impact | **no** | — | `not-judged` |
| end (checkmate/resign/clock loss) | `SND.X4` | **no** | — | `not-judged` |
| wrong puzzle move | `SND.X5` puzzle fail | **no** — puzzle entry not reached on `69a03d4` | — | `not-judged` |
| distinguishability between cues | AC 3 | — | — | `not-judged` |

## Why no cue was reached — a reachability stop, recorded once and not blamed on sound

On the published frame a press inside "Shared game" (inside the measured button box,
y 150–190) is delivered to the page — the gesture trace shows `pointerdown` at
(150,185) — but the mode pick does not advance:

| Session | Build | Presses inside the button | Advanced? |
|---|---|---|---|
| hold probe, 6 arms × 450 ms | export `c5b8189` | 6 | **2** (the frame that moved shows "Shared game setup") |
| cue driver | published `c5b8189`, unlocked autoplay | 2 | 0 |
| cue driver | published `69a03d4`, unlocked autoplay | 2 | 0 |
| board-tap probe | published `69a03d4`, 120 ms | 2 | 0 |

So the stop is **inside the Web build's control handling**, not in audio, and not in
this run's pointer injection (the same injection advanced the control on the export).
It is filed as **#879**.

This is **not** a mix failure against `SND.X` / `SND.M` / `SND.L`; it is a separate
build defect cited here. On the `c5b8189` published build, before the `943d5f0` route
fix reached Pages, the same presses *did* reach the puzzle screen and the console
showed every audio asset failing to open
(`Preload play left 5 approved IDs unresolved`); that snapshot is in
`logs/published-c5b8189-console.log` and is superseded on `69a03d4`.

Raw logs: `logs/boardtap-69a03d4-boardtap.json`, `screenshots/boardtap-69a03d4-0*.png`.
