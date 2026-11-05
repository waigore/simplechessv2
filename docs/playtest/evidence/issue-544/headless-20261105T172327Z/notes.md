# Notes — headless (`ENV.1`) — AC 7 repeat record

## What was judged

AC 7's repeat requirement as reopened by the 2026-11-01 verification: the repeat count must come from **two actual runs of the same window**, recorded beside the seam's own `session_id` pair. Both runs below are the same cold `loading_ready` window (armed at `EX.loading`, closed at `mode-pick`, story `PTU-mode-pick`), one process each, on the same build, read late through the public `measure()` path — the read sequence the 2026-10-25 verification identified as the driver-real path.

Method, per run: a throwaway `SceneTree` probe (not committed) loads the real `main.tscn`, frees the `ENV.1` smoke harness node so the boot is not auto-quit, and calls `start_measurement("loading_ready")` through the public seam API the moment the whole `main` subtree is ready — inside the natural cold load, before the deferred Boot outcome settles. Nothing jumps; the close is the natural `boot_ready` → `mode-pick` transition. Four frames after the window closed by itself, the probe reads `measure("loading_ready")` and then `dump_state()["measurement"]`, and a second `measure()` ask is taken to show the once-only handover. A method-check run during probe development preceded the two recorded repeats (same method; it is not evidence and its session is not counted).

## The two runs

| Repeat | `session_id` (`TEL.3`) | Status | Samples | `max_ms` | `sample_count` | Late read |
|---|---|---|---|---|---|---|
| 1 | `sess-1793899355680-95364-playtest-198860` | `ok` | `[148.057333333333]` | 148.06 | 1 | 4 frames after close |
| 2 | `sess-1793899356024-95365-playtest-193003` | `ok` | `[149.407333333333]` | 149.41 | 1 | 4 frames after close |

**Repeat 1, verbatim `late_read`:**

```json
{"kind":"loading_ready","mode":"","status":"ok","solver":"","samples":[148.057333333333],"sample_count":1,"max_ms":148.057333333333,"events":{"start":{"TEL.1":"measure.start","TEL.2":1793899355695,"TEL.3":"sess-1793899355680-95364-playtest-198860","TEL.5":"pass","TEL.4":"PTU-mode-pick"},"end":{"TEL.1":"measure.end","TEL.2":1793899355739,"TEL.3":"sess-1793899355680-95364-playtest-198860","TEL.5":"pass","TEL.4":"PTU-mode-pick"}},"detail":""}
```

**Repeat 2, verbatim `late_read`:**

```json
{"kind":"loading_ready","mode":"","status":"ok","solver":"","samples":[149.407333333333],"sample_count":1,"max_ms":149.407333333333,"events":{"start":{"TEL.1":"measure.start","TEL.2":1793899356039,"TEL.3":"sess-1793899356024-95365-playtest-193003","TEL.5":"pass","TEL.4":"PTU-mode-pick"},"end":{"TEL.1":"measure.end","TEL.2":1793899356084,"TEL.3":"sess-1793899356024-95365-playtest-193003","TEL.5":"pass","TEL.4":"PTU-mode-pick"}},"detail":""}
```

Each run carries both halves of `TEL.1` (`measure.start` / `measure.end`) under its own session id, so the two repeats are distinguishable in the events themselves (the `TEL.2` spans are 44 ms and 45 ms respectively). Device, browser, build id, and the repeat count are recorded in [the manifest](manifest.md), never inside the report (D2).

**Handover checks in both runs:** a second `measure()` ask after the late read returned `{"status":"refused","detail":"no window"}`, and `dump_state()["measurement"]` kept the closed report readable — the late-read and once-only behaviour from the #950 round, on two real runs.

## What this run does not judge

- `frame_times` live repeats: the shared-play close predicate reading was already exercised live in the earlier rounds; a relative live sweep belongs to the #400 / #402 protocol run.
- Story-level release absence (`R3`) stays with the release-export smoke and the `Web release` publish leg (`D3`).
- No `game/` file is in this run's change set; the seam code is as verified on `58edbf6`.
