# Checks — issue #616, graphical acceptance run (re-recorded for #742)

Index: [`manifest.md`](manifest.md) · What was run: [`run.md`](run.md) · Rendered pixels:
[`images.md`](images.md) · Build and CI checks: [`build-checks.md`](build-checks.md).

This folder exists because #742 rejected the superseded one as "a headless session labelled graphical".
Every claim a reader would otherwise take on trust is a number or a command output from this run.

## Environment

The drive's first log line is recorded from the engine, not written by hand
(`logs/graphical-drive.log`):

```
STEP env display=X11 adapter=llvmpipe (LLVM 20.1.2, 256 bits) api=4.5 (Core Profile) Mesa 25.2.8-0ubuntu0.24.04.2 method=gl_compatibility headless=false
```

`DisplayServer` is `X11`, not `headless`, so this is `ENV.2`: a real rendered session, on a software
rasteriser under `xvfb-run` because this host has no physical display. The render loop reports
`fps=54.0 process_ms=35.72 draw_calls=32` at 390×844 — a live loop, which a headless session does not
have.

The superseded folder's `macOS` / `Metal` lines do not reproduce on this host and are not claimed here.
The manifest records the host that ran this run.

## Drive

`drive_graphical.gd` is the superseded run's drive with two changes, both so a folder cannot name an
environment it did not run in:

1. `OUT_DIR` derives from this run's own `RUN_ID`, so the drive cannot write into another run's
   `screenshots/` (the superseded drive had that folder hard-coded).
2. `_environment()` logs the real `DisplayServer` / adapter / method, and `_run()` fails instead of
   capturing when `DisplayServer.get_name() == "headless"`.

That the two drives are otherwise the same driver is checkable: they produce the same 18 geometry rows
and `RESULT fails=0`. `run_graphical.sh` wraps the run in `xvfb-run` when `DISPLAY` is unset.
