# Notes — #557 graphical run `20261024T204223Z`

## What was judged

Three legs on the published release build `c5b8189`:

1. **Quit/reload** — `not-judged`: no puzzle dealt, so no result committed.
2. **Crash** — `pass`: renderer killed mid-session; reopen held the last committed Last mode and Elo.
3. **Faulted session** — `pass`: one forced failed write; prior document intact, reopen matched.

## Blockers

- **#630** (release stuck in `EX.loading`) is **closed**; this run confirms mode pick and `puzzle-play` both render. It is the first #557 run to reach either.
- **The deal** blocks leg 1. The release ships `advice_endpoint` / `advice_api_key` empty, and only `game/advice_ui_test.gd` assigns them, which the export excludes. **#648** owns the catalog route (answer: enabled; delivery owed by **#479**). No defect filed — a `not-judged` row files none.

## Method notes, including what did not work

- Earlier #557 runs never pressed a control, so they never entered the stream or produced a write. This driver taps through the UI.
- **Sub-screens defeat blind taps.** `Shared game` opens `Shared game setup`; `Leave stream` opens a `Leave the puzzle stream?` confirm. A tap aimed at the screen behind hits the sub-screen instead.
- Earlier iterations of this driver therefore produced a spurious crash `fail`, a spurious leg-3 `not-judged` (0 writes), and one screenshot mislabelled as the quit path while showing puzzle play. All were tooling errors, not game behaviour; none is recorded as a result.
- The driver now classifies each screen from measured pixel bands before tapping, and refuses to save a quit-path capture unless the build is verifiably at mode pick.
- **Both mode-pick controls commit on press**, so "select a mode without committing" is impossible here. Leg 2 abandons setup-screen state instead.
- **A fault must target a changed value**: a commit equal to the stored payload still round-trips, so it proves nothing.

## Non-blocking marks

- `Preload ambient left 2 approved IDs unresolved` and unresolved audio under `game_assets/` — ambient audio belongs to #567.
- The published build is **12 commits behind `main`**; the focused-control label fix `c605ce3` (#833) is not in it. Already recorded on #833; it does not affect these legs, which read Last mode from the document.
- Legs 2 and 3 reopen captures are byte-identical to a cold open, the correct rendering of the same state. Flagged in `readings.md`.

## What a passing leg 1 needs

A published build that deals a puzzle. That is #479 / #648, not more effort here.
