# Notes — #626 mobile-browser sitting

Judgement index. Builds: [builds.md](builds.md). Seat: [seat.md](seat.md). Readings:
[manifest.md](manifest.md).

## What this run is, and what it is not

The issue asks for a reading *where the sitting actually happens* — a phone browser. This run
reached that with the strongest environment available to it: the published release build, at a
**phone-class viewport** (390×844 CSS px, DPR 2, touch emulation), driven through the browser's
own input and lifecycle. It is not a physical phone, and the rows that need phone hardware say
so instead of guessing. [seat.md](seat.md) lists exactly what the seat reaches and what it does
not.

## Advice-Off: what was observed

`F-move-advice` R2 (*advice runs only when Advice is On and the browser is online*), read at
`PTD-move-advice` S4/F2 on the board:

- The board's advice control toggles and settles to the `Advice Off` label
  (`screenshots/sit-05-advice-off-settled.png`).
- With Advice Off, a tile tap selects and shows **no advice marks** — no best-move arrow, no
  eval text — across the stillness windows after it (`screenshots/sit-06-*`, `sit-07-*`).
- What this run could **not** do is the offline half of S4/F2: no advice backend is published
  for this build, so there is no online advice stream to compare against. R2's "offline" arm is
  therefore `not-judged` here; the "Advice Off" arm is observed.

The protocol verdict is `not-judged` for the protocol as a whole (it cites R1–R9, and this run
did not read them all); the observed arm is recorded as its own row.

## Board interaction: measured, and not this issue's row

Board taps were exercised many times. On this build (frame reads in `logs/`):

- A tile tap **selects a piece**: the tile gets the ochre selection ring and its destination
  squares get green diamonds (`screenshots/control-*`, `screenshots/touch-*`).
- A tap mapped to a rank-1 square (the map #403's `touch-mapping.md` records) selected the
  **f1 bishop**, while the frame's row 8 sits at CSS y≈403 — the tap landed about a rank above
  the finger, which is **#845**'s symptom (open, `pending-implementation`).
- Some taps on the board **dismiss the whole panel back to mode pick** (a full-screen
  "click away from the panel" region). That is how the panel behaves under a tap outside its
  shape, not a crash.

None of this is a mobile-browser-only behaviour, so it is **recorded here and not filed as a new
defect**: #845 already owns the mapping, and this issue's scope is the sitting, the durability
legs, and the Advice-Off observation. It does mean the sitting's liveness reading is taken as
"the tile answers with a selection", which the frames show.

## Further reading

- [notes-method.md](notes-method.md) — method findings kept for the next run, and the lifecycle
  freeze that was abandoned as a background leg.
- [notes-durability.md](notes-durability.md) — the Elo caveat on the durability rows and what a
  physical-phone run still owes.
