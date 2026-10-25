# How the advice fields were read — `DBG.2` on a build with no seams

## The limitation

The release export carries **no `PlaytestSeams`** (ADR-0004 `G2`), so `DBG.2` cannot be called on
the shipped build at all. The seam exists only on the playtest-certified build, and running the
soak there would not read the shipped build #558 names.

## What this run did instead

`logs/probe_release_state.gd` is a headless **release-graph probe**. It:

1. loads the same `res://main_release.tscn` the `Web Release` preset exports;
2. asserts `PlaytestSeams` is absent from that scene;
3. drives it through `Presentation`'s control path (mode pick → Shared setup → Start);
4. reads `SharedGameSession.play_state()` — the data `DBG.2` returns on a playtest build.

It changes nothing: the session is built by the shipped router from the shipped configuration,
with the empty advice endpoint the release ships. Result: **26 checks, 0 failures**
(`logs/probe-release-state.log`), covering the Advice-Off start and after-move reads, the
online-On unavailable case, and the offline-and-On after-move read.

## Carrying the limit into acceptance

The field values come from the release scene graph, not from a `DBG.2` call on a playtest build.
The screen evidence — `advice_off` copy, no marks, no S3 error — comes from the same build in the
same sitting, so the two agree. This is the one method substitution #558's reading asks the
accepting run to weigh.

The probe emits one `ObjectDB instances were leaked at exit` warning when the headless harness
shuts down. That is the probe's own `SceneTree` teardown, not a game crash, and it falls outside
the sitting window.
