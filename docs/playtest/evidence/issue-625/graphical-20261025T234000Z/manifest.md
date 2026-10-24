# Manifest — #625 off-device run of the release build (`Web Release` export of `491554e`)

- **Issue**: #625 — record a funded, off-device run of the published release build
- **Environment**: `graphical`
- **Build under test**: **local `Web Release` export of `491554efae23a2235d1ebf1c087331912c00d7ed`**
  (`main` at dispatch time, the commit carrying #647's repair `bccdb1c`).
  - **Why the fallback**: the published URL does **not** carry #647's repair. `Web release`
    runs on `main` stop at run **`40118381611`** (`success`, commit `c5b8189`, 2026-10-24T17:56Z);
    `main` is at `491554e`, so the newest served commit is 26 commits behind and predates the
    asset-root route. Pages serves `c5b8189` (deployment check in [builds.md](builds.md)).
  - **Export**: `python3 .github/scripts/web_export.py --preset "Web Release"` in a clean
    `origin/main` worktree → `build/web/` (ADR-0007), then the run's own checks,
    `--check-boot` → `14 of 14 boot asset file(s) resolved`, `--check-assets` →
    `35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)`. The export falls back
    for the interval only and is never recorded as a published reading.
  - **Served to the run at**: `http://127.0.0.1:8625/` (see *Where the run stopped*).
  - **Correlation key**: export path
    `/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/opencode/wt625/build/web/`
    plus commit sha `491554efae23a2235d1ebf1c087331912c00d7ed`. **No `Web release` run id
    exists for this commit** (none has run on it), so the export path is the key.
- **No `TEL.3` session id: the release build strips the seam (ADR-0004 `G2`, #729); none is
  invented.** The probe looked for no `TEL.3` line and minted none: `logs/probe-console.log`
  contains **0** lines of the form `TEL.1`–`TEL.5`, consistent with #729. The missing
  telemetry is #729's; it is not a finding of this run.
- **Timing (`SIT.4` runs)**: **not measured on a device** — no physical phone or non-development
  low-end machine was attached to this run (see [notes.md](notes.md)). The only timed numbers
  here are from headless Chrome + SwiftShader on the dev machine over `127.0.0.1`, a
  desktop-class reading that cannot stand in for `SIT.4`'s device rows.
- **Coverage mode**: `critical-only` — the four rows named in the body were attempted; all four
  are `not-judged` for lack of an off-device reading.

## Results

| Row (quality claim read) | Device class required by #625 | Device class available | Verdict |
|---|---|---|---|
| Performance — 60 fps, no hitch > 1 frame during a move | phone (governs) / low-end laptop | none — dev machine, headless SwiftShader | `not-judged` |
| Load time — board playable within 3 s of opening | phone (governs) / low-end laptop | none — dev machine, loopback | `not-judged` |
| Reliability — background/return (reopen clause) | phone (governs) / low-end laptop | none | `not-judged` |
| Save durability — quit/reopen | phone (governs) / low-end laptop | none | `not-judged` |

**Totals: 0 `pass`, 0 `fail`, 4 `not-judged`.** Per the acceptance criteria, a row read only on
the laptop is `not-judged`; here no laptop reading was even taken, so the same rule applies
with no secondary observation to record.

What the run **could** read on this build, recorded as build identity rather than as a row:
mode pick renders over the asset root (`game_assets/` and `audio_runtime/` present in the
export), the scene is the seam-stripped release scene (0 `TEL.*` lines), and the console
carries **no error** — 2 WebGL performance warnings and 1 AudioContext autoplay warning, both
expected before a user gesture.

## Paths

- [notes.md](notes.md) — why the run stopped, what could not be reached, the environment facts
- [builds.md](builds.md) — build resolution, Pages state, export commands and their output
- [readings.md](readings.md) — the probe's samples, console and network numbers
- `screenshots/`: `probe-frame-01` … `probe-frame-06` — mode pick at 390×844 DPR 2, six
  samples 1.5 s apart, all identical (the loader has cleared; no white screen)
- `logs/`: `probe-console.log` (full console), `probe-network.log` (every response),
  `probe-result.json` (samples, final page state, `localStorage` empty)
- Drivers: `scripts/probe.mjs`

## Defects

- **None filed.** No row failed — nothing was measured on the device class the acceptance
  criteria require. The missing reading is this task's own gap (it cannot be taken without
  hardware the run does not have), not a defect of the build, and #856 already carries the
  desktop-measured load-time failure (#854, #855) that a phone reading would attach to.
