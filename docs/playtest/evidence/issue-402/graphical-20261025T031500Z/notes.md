# Notes — #402 re-record, 2026-10-25

## What this replaces

The 2026-10-24 record could not judge most rows: the served build never left `Loading…`.
Today's build reaches mode pick, so reachable rows were read and the rest name their seat
([builds.md](builds.md)).

## Judged

- **Save durability — pass.** `last_mode`/`player_elo` survive reload; a forced write
  failure leaves the prior commit intact.
- **Reliability (recovery) — pass.** Renderer crash then reopen lands on mode pick with
  the stored document unchanged.
- **Load time (board-playable) — fail.** The board is not playable by touch (#845), so no
  legal first move is reachable. Cold open is also 5.5–6.1 s to first paint; recorded but
  not decisive alone, since idle frames take 50–67 ms here.

## Not judged

| Row part | Seat | Why |
|---|---|---|
| Performance | this gate | Idle frames as slow as move frames (p50 50–66.7 ms both) |
| Advice ready ≤ 2000 ms | #559 | Measured in that run's folder; release has no advice peer |
| Sitting soak | #558 | Not run in this window |
| Observability | playtest build | `TEL.*` lives on the playtest build (`H1`) |
| Piece shape / colour-only | #640, #641 | Verified outside playtest |
| Smallest text, phone width | #546 | Seam still pending implementation |
| Localization | this gate | Locale control not switched (below) |

## Defects

- **#845 — board taps hit one rank above the finger.** Filed here. On published `c5b8189`
  and on `0019e75`, tapping the painted e2 pawn rings the painted e1 king. The rank sweep
  (only CSS y 620–680 select) and the full e2–e4 completion were run on the `0019e75`
  fallback, not re-run on the published build.
- **#833 — focused label nearly invisible.** On first open, the focused `Shared game ·
  Last` row renders almost white on cream while `Puzzle stream` renders normally:
  `screenshots/published-01-mode-pick-cold-open-focused-label-invisible.png`. Already
  filed; this run adds shipped-build evidence rather than re-filing.

## Why Localization is not a `fail`

The locale control sits rightmost in the card's bottom row ("English", CSS ≈ 253, 248).
Across three runs and up to four clicks per step the title ink signature never changed
(`125,113,68`), so no `zh-Hant` or `ja` copy rendered. Keyboard focus still reaches the
control, so the screen is not dead.

A `fail` needs proof the copy is missing. The switch never happened, and #833 hides which
control is focused, so a pointer-only pass cannot separate missing translation from an
unpressed button. The row is `not-judged` with that blocker named.

## Method notes

- Controls are located from the current screenshot (`locator.mjs`), never hard-coded;
  each transition is screenshot-verified. Two early attempts recorded "no move" while
  still on shared setup; those captures are excluded.
- Entry: `Enter` activates the focused mode row; `Start` is clicked at its gold fill.

## Superseded

The 2026-10-24 folder stays; its stall reading is superseded and its attribution replaced
by [builds.md](builds.md). No row here is copied from it.
