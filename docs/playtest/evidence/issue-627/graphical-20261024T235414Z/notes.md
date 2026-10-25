# Notes — #627 phone listening run

## What this run can claim

**Ambience starts within one gesture of the first interaction, and the delay is
0.79 s.** Measured on the published build (`69a03d4`) with the browser's *own*
autoplay policy (no `--autoplay-policy` flag):

```
12.155 s  AudioContext created, state suspended
14.329 s  build requests bed M1 (buffer 180.036 s) — context still suspended
31.566 s  the run's single plain tap reaches the page
32.358 s  AudioContext → running (0.79 s after the gesture)
          the same start request now plays; context clock advances 12.83 s at +12 s
```

The bin the bed waits in is the browser's, not a defect: with autoplay already
unlocked (control, published and export builds) the bed starts at 17.6–18.7 s with
the context `running` from creation, i.e. the 0.79 s is exactly the gate.

**The bed the build plays is the right shape:** one 180.036 s stereo
`AudioBufferSourceNode` start, which matches catalog `music/cafe-ambient-a` (M1,
~180 s). No second bed, no doubling.

## What this run cannot claim — and why it must not pass

The issue's whole point is a **phone speaker, at a café listening level, with a
person's ears on it**. This dispatch had no phone, no speaker, and no listener.
So:

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

## The reachability stop that blocked the cues

On the published frame, a press inside the measured box of "Shared game" (y 150–190)
is **delivered** — the gesture trace shows `pointerdown` at (150,185) — but the mode
pick does not advance:

| Session | Build | Presses inside the button | Advanced? |
|---|---|---|---|
| hold probe, 6 arms × 450 ms | export `c5b8189` | 6 | **2** (the frame that moved shows "Shared game setup") |
| cue driver | published `c5b8189`, unlocked autoplay | 2 | 0 |
| cue driver | published `69a03d4`, unlocked autoplay | 2 | 0 |
| board-tap probe | published `69a03d4`, 120 ms | 2 | 0 |

That is a **build** problem, not an audio one, and not this run's pointer injection
(the same injection advanced the control on the export). It is filed as **#879**; no
`SND.X` / `SND.M` / `SND.L` failure is recorded from it.

The earlier published build (`c5b8189`, the deploy live when the run began) shows a
*second*, since-superseded symptom: presses did reach the puzzle screen, and the
console reported every audio asset unopenable
(`Can't open file … res://game_assets/music/cafe-ambient-a.ogg`, then
`Preload play left 5 approved IDs unresolved`). On `69a03d4` the same press reaches
nothing at all and the console reports no preload failure — so that asset-route
symptom is not carried forward as a defect against the current build.

## What a later run needs

1. A build where the mode pick takes a press (see #879), or a phone that taps it.
2. A physical phone at café volume, speakers not headphones, for AC 1 and AC 3.
3. One uninterrupted sitting of at least 3 min 30 s to hear `M1 → M2 → M1` for AC 4.
4. A finished Shared game (checkmate, resign, or clock loss) and one wrong puzzle
   move to hear `X3`, `X4`, `X5`.

The probes in `scripts/` are dependency-free CDP drivers; on a real phone the same
readings can be taken by hand with a recorder, and `screenshots/` + an audio file per
cue would replace the graph traces.
