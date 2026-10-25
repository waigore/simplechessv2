# Notes — Ambient load moved off the mode-pick frame (#856)

**What was judged:** nothing in the story rows. This run measures one layer of the release build's
cold open — the `AST.G3` Ambient group and the first `SND.M1` bed cue, which the parent record
([`../graphical-20261024T224751Z/`](../graphical-20261024T224751Z/)) put in the mode-pick frame at
0.25–0.4 s — before and after moving that read behind the paint. The **≤ 3 s** bar is
[`quality.md`](../../../../../specs/definition/quality.md) Load time and is not judged here.

**Headline:** the game-code share of the cold open is real and removable from the paint path.
Moving the Ambient group and the bed cue two frames past the mode-pick frame moves the first
painted screen **0.42 s earlier** (hardware GL, back to back: base mean 1899 ms → after mean
1476 ms, 3/3 after runs below 3/3 base runs). One frame is not enough in a single-threaded Web
build — the paint still landed after the bed work — so the shipped change waits two.

**What the shipped change is:** `SessionRouter._go_mode_pick` no longer calls `start_music()` on the
mode-pick frame; it defers two process frames. `AST.G3`'s trigger is unchanged (mode pick ready),
and [`access.md`](../../../../../specs/assets/access.md) `G3` records the ordering. Two unit
checks pin it: `asset_resolver_test` now fails if the Ambient group is loaded in the frame mode
pick became ready, and `presentation_audio_test`'s spine waits the third frame for the bed.

**What it does not fix, stated plainly.** Under the #403 instrument the cold open is still over the
bar on this host, and the rest of it is outside `game/`: the shell's WebGL2 capability probe and
the `index.wasm` (39.5 MB, 10.2 MB gzip) / `index.pck` (9.57 MB) downloads. **~6.3 MB of the pack is
still the two ambient beds**, and `ADR-0014` decides they are packed — serving them loose would cut
that download materially, but it is an architecture decision with a new ADR, not a defect fix, and
this run did not attempt it. The aligned reading puts this build's cold open at ~1.3–1.5 s on the
host's rendered GPU path and the swiftshader reading far above it; **which instrument governs the
Load time row is still not decided by this run** (the #856 verification pass raises it, and
[`tools-situational.md`](../../../../../specs/playtest/tools-situational.md) `SIT.4` names only "Graphical,
where a browser renders").

**Marks (non-blocking):**

- The two arms are local `Web Release` exports differing by one ordering change plus a two-`print()`
  measurement patch carried by both ([`logs/measurement-print.patch`](logs/measurement-print.patch)).
  Neither arm is the published page, which still carries the old ordering.
- The host sat at load 44–67 for the series (ten parallel agent worktrees); only back-to-back arms
  in one browser (the aligned runner) resolve the 0.4 s signal. The single-browser #403 arm resolves
  ordering only.
- `paint − banner` in the #403 arm does not separate the arms; the engine-download spread across
  fresh browsers is larger than the effect. Recorded so the next reader does not re-read it as noise
  in the change.
