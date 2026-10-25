# Outcome — #627 phone listening run

Part of [`manifest.md`](manifest.md). What the run can and cannot claim, per AC.

## What this run can claim

**Ambience starts within one gesture of the first interaction, and the delay is
0.79 s.** Measured on the published build (`69a03d4`) with the browser's *own*
autoplay policy. The bin the bed waits in is the browser's, not a defect; the bed the
build plays is the right shape (one 180.036 s stereo start, matching `M1`).

Timeline and readings: [`ambience.md`](ambience.md).

## What this run cannot claim — and why it must not pass

The issue's whole point is a **phone speaker, at a café listening level, with a
person's ears on it**. This dispatch had no phone, no speaker, and no listener. So:

- **AC 1** (device, OS/browser, output route, volume) — `not-judged`: the device is
  Chrome phone-viewport emulation, the output route is the page's audio graph, and
  no listening volume exists.
- **AC 3** (each cue heard, distinguishable) — `not-judged`: no cue was reached, and
  none was heard.
- **AC 4** (`M1 → M2 → M1` heard) — `not-judged`: a switch needs ≈3 min of
  uninterrupted play and the run took no such sitting.
- **AC 5** (no cue lost, clipped, doubled) — `not-judged`: nothing was heard.
- **AC 6** (stop on an unopenable asset root) — not triggered: the build reaches mode
  pick and its pack carries all seven `res://audio_runtime/…` audio routes
  (`logs/published-69a03d4-pck-routes.txt`) and the catalog files are served (200).
- **AC 7** (no `specs/`, `game/`, `asset_catalog/`, `game_assets/` change) — met: this
  branch adds only `docs/playtest/evidence/issue-627/`.

Per `specs/playtest/evidence.md`, a `not-judged` row never counts as `pass`. The run
therefore reads as **AC 2 pass, AC 7 pass, AC 1 and AC 3–6 not-judged**, and the issue
is not acceptable on this evidence alone.

The reachability stop that blocked every cue is filed as **#879**; it is a build
control problem, not an audio one. Detail: [`cues.md`](cues.md).

## What a later run needs

1. A build where the mode pick takes a press (see #879), or a phone that taps it.
2. A physical phone at café volume, speakers not headphones, for AC 1 and AC 3.
3. One uninterrupted sitting of at least 3 min 30 s to hear `M1 → M2 → M1` for AC 4.
4. A finished Shared game (checkmate, resign, or clock loss) and one wrong puzzle
   move to hear `X3`, `X4`, `X5`.

The probes in `scripts/` are dependency-free CDP drivers; on a real phone the same
readings can be taken by hand with a recorder, and `screenshots/` + an audio file per
cue would replace the graph traces.
