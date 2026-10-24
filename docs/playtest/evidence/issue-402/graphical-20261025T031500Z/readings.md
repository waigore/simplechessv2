# Readings

Published build `c5b8189` (run `40118381611`), 390×844 CSS, DPR 2, touch, headless Chrome
on SwiftShader. Raw data in `logs/`.

## Load time — cold open

3 cold opens, HTTP cache disabled. Paint times are the browser's own
`PerformancePaintTiming`; "card painted" is read from a screenshot at 9 s.

| Run | first paint | FCP | DOMContentLoaded | card by 9 s |
|---|---|---|---|---|
| 1 | 5540 ms | 8160 ms | 5459 ms | yes |
| 2 | 6116 ms | 8716 ms | 6086 ms | yes |
| 3 | 5568 ms | 8748 ms | 5545 ms | yes |

First content lands at 5.5–6.1 s on this host — past 3 s, but the idle frame data below
shows this host is roughly 3× slower than a GPU desktop, so these seconds are not used
alone. The row fails on input (#845).

## Performance — move window

`requestAnimationFrame` deltas for the session; move window is `mark − 200 ms …
mark + 1400 ms` around the gesture committing e2–e4. A 1500 ms idle window is the control.

| Repeat | idle p50 / p95 | move p50 / p95 | move max | frames > 16.7 ms | committed |
|---|---|---|---|---|---|
| 1 | 66.7 / 83.3 ms | 66.7 / 83.4 ms | 99.9 ms | 24 / 24 | yes |
| 2 | 50.0 / 66.7 ms | 50.0 / 66.7 ms | 133.3 ms | 28 / 28 | yes |

Idle is as slow as the move, so 60 fps cannot be reached and a move hitch cannot be
isolated. The move is not lost: both repeats show Black to move with the pawn on e4.

## Reliability — reopen

`Page.crash` mid-session, then reopen the same profile.

- Reopen lands on mode pick (`reliability-01-reopen-after-renderer-crash.png`).
- Stored document after reopen:
  `{"last_mode":"puzzle","player_elo":1000.0,"recent_solved":[],"version":1}` — unchanged.

**Pass** for the recovery half. The soak is #558's and was not run.

## Save durability

| Step | `simplechessv2.persist.v1` |
|---|---|
| Fresh profile | absent |
| After opening Puzzle stream | `last_mode=puzzle`, `player_elo=1000.0` |
| After reload | identical |
| After forced `setItem` throw + commit | identical (prior commit intact) |

**Pass** (`durability-01`, `durability-02`).

## Board touch mapping (#845)

Tapping the painted e2 square (CSS 219, 654) rings the painted e1 square (649.5–688 CSS).
Tapping 14 px higher (219, 640) rings the rank-2 square (610.5–649). The e-file matches.

The board accepts touch; the square under the finger is not the square selected.

## Localization — attempted, not exercised

The locale control never changed locale: title ink signature stayed `125,113,68` and the
control kept reading "English" across three runs and up to four clicks per step. It is
reachable by keyboard focus, so it shows the focus-without-activation behaviour of #833.
No `zh-Hant` or `ja` copy was rendered.

## Limits

These readings do not judge the soak, advice readiness, piece-shape naming,
colour-independence, phone-width legibility, or translated copy. Device results belong to
#625/#626/#627.
