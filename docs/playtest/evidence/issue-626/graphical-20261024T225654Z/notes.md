# Notes — #626 mobile-browser sitting

Judgement text for [manifest.md](manifest.md). Builds: [builds.md](builds.md).

## What this run is, and what it is not

The issue asks for a reading *where the sitting actually happens* — a phone browser. This run
reached that with the strongest environment available to it: the published release build, at a
**phone-class viewport** (390×844 CSS px, DPR 2, touch emulation), driven through the browser's
own input and lifecycle. It is not a physical phone, and the rows that need phone hardware say
so instead of guessing.

## The seat, stated plainly

**No phone is attached to this machine.** What the seat does reach:

- the published build's own layout at a phone viewport and its touch hit areas;
- one continuous sitting with real time passing;
- **background → foreground** through the browser's tab lifecycle (a second tab takes the
  foreground, the game tab is activated again);
- **quit → reopen** in a persistent origin store, and a **reload**;
- a **renderer death** (`chrome://crash`) — that leg is read in #557's desktop folder, not here.

What it does **not** reach, because only handset hardware can: the mobile OS suspending the
browser process, `localStorage` eviction under device storage pressure, tab discard under memory
pressure, battery/thermal throttling. Those readings stay `not-judged` — never `pass`.

## Why `Page.setWebLifecycleState` is not the background leg

The first two attempts froze the page with `Page.setWebLifecycleState: frozen` and resumed with
`active`. That path **does not resume in this headless build**: after resume the page keeps
`document.hidden: true`, `requestAnimationFrame` never fires, and every later input dispatch
hangs (`logs/probes/resume-path.json`). Once that was measured, the driver switched to a real
second-tab backgrounding (`logs/probes/background-tab.json`), which is what a phone's app switch
looks like from the page's side. Neither attempt is used as a row: they are recorded as method
findings in `logs/`.

## The build's asset state, measured on this commit

The boot group resolves (`Preload boot left 0`), but this commit predates the audio-route repair
(`d21bbf6`, #785's fix, merged after `c5b8189`):

```
ERROR: Cannot open file 'res://game_assets/sound-effects/touch-select.ogg'.   (×5 cues)
ERROR: Preload play left 5 approved IDs unresolved
ERROR: Preload ambient left 2 approved IDs unresolved
```

So the board's cues and the café ambience are silent on this build. That is **#785's repair
already merged and not yet published on this commit**, not a new defect, and it is not re-filed.
It does affect what Advice-Off can show by ear: audibility is #627's row, not this one.

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

## Save durability: the Elo caveat

The committed document was read in the page's own origin store (`localStorage`, key
`simplechessv2.persist.v1`) after each cycle — never through a desktop devtools path.

`last_mode` is the value a quitting session commits, and it survived every cycle unchanged. The
**Elo half stays at its starting `1000`** because nothing on this build can change it: Elo moves
only at a puzzle-result commit (`SEQ-puzzle-result-commit`), and the release build deals no
puzzles (**#655**, open). So this run shows that a committed document survives the three
mobile cycles; it does not show a *changed* Elo surviving them, because no Elo change can exist
on this build. #557's leg 1 records the same limit from the desktop side.

## Method findings kept for the next run

- `Page.setWebLifecycleState` frozen→active does not resume (above).
- Repeated `Page.reload` alone leaves touch working (243–379 ms taps); the wedge came from the
  freeze, not from reloading.
- The board's control row has no puzzle-stream entry; the puzzle stream is reached from mode
  pick only, and #655 keeps it from dealing.

## What a physical-phone run still owes

Tab discard, `localStorage` eviction, OS suspension, and a real network's latency. Those are the
residual risk this run names rather than covers.
