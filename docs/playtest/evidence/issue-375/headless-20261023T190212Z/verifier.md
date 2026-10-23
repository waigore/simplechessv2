# For the verifier

Back to [`notes.md`](notes.md) and [`verdicts.md`](verdicts.md).

## Re-running a phase

1. `python3 logs/peer.py --port 18495 --mode normal --log peer-normal.jsonl` (and a second instance `--port 18496 --mode fail --log peer-fail.jsonl`).
2. For each phase, from the repo root:

```
R375_ENDPOINT=http://127.0.0.1:18495/advice R375_KEY=accept-key R375_PHASE=play \
  godot --headless --path game --script <this-folder>/logs/drive.gd
```

Phases: `play`, `toggle` (peer `normal`), `telemetry`, `error` (peer `fail`). Each phase prints `R375 {json}` check lines and a `{"summary": {"checks","failed"}}` line; the exit code is the failed-check count.

**Exit status caveat.** `play` and `toggle` can fault on process **exit** (macOS headless, worker-thread teardown) *after* the summary line. Read the `R375` lines, not the exit status. `telemetry` and `error` exit cleanly. [`setup.md`](setup.md) explains the harness-only teardown join.

The drive points `SessionRouter.advice_endpoint` / `advice_api_key` (T9/T10) at the peer; a release export ships them empty, as the Pages deploy does.

## What is still owed

A **graphical** run of `PTU-shared-play`, `PTU-shared-setup`, and `PTU-exceptions`:

- `shared-play` with marks and eval, both seats, plus the S3 panel;
- `shared-setup` with the Advice row in both states;
- screenshots under `screenshots/`, and a `manifest.md` results row for each.

Judge AC4 against those frames: `PAL.C7` at ≥ 2:1 on both square colours (`PAL.K5`), eval text ≥ `UIS.T2`, marks + text ≤ 10% of any body, and piece silhouettes still readable (`PER.R1`). AC9's colour-alone and 44px legs are graphical too.

## What this folder already settles

The shipped-path half of AC11: `main_release.tscn` with no seams, the real `AdviceStreamTransport` over HTTP to a reachable peer, marks and eval arriving and clearing, and the S3 error path with play continuing.
