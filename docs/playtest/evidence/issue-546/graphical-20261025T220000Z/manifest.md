# Manifest

- **Issue**: 546 — implement `SIT.6` phone-width legibility viewport (seam `S13`, op `O12`)
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, `macOS` Metal
  (`DisplayServer.get_name()` = `macOS`, Apple M5), shipped scene `game/main.tscn`
- **Build / session id**: `origin/main` `aa16e09`, clean detached worktree at that commit; `TEL.3`
  session `sess-1792883153140-87876-playtest-457570` (`logs/graphical-s6.log`).
  **Source**: the playtest scene built from `aa16e09`, not a published URL — `Web release` serves
  `https://waigore.github.io/simplechessv2/` ([ADR-0009](../../../../../specs/adr/decisions/0009-github-pages-client-host.md))
  and no release PR carries this commit. No `build/web/` export.
- **Coverage mode**: partial — `PTU-mode-pick` S6 only; S1–S5 stay with the #400 sweep
- **Screenshots**: `screenshots/s6-phone-390x844.png` — mode pick at a genuine 390×844 frame after
  `O12 set_viewport`, from this build (390×844 image, read in this run)

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `UI-mode-pick.US1` — S6 at 390×844 (`SIT.6`, `P5`/`F3`) | **pass** | All five visible strings ≥ `UIS.T2` (21 px at an 844 px frame), no clipping, none outside the frame, none under playtest chrome (0.0 px²). `logs/graphical-s6.log`, `screenshots/s6-phone-390x844.png` |
| `UI-mode-pick.US1` — S1–S5 | not-judged | Not driven; the #400 sweep judges them |
| `PTU-mode-pick` protocol verdict | **pass** (S6 scope) | S6 passed; S1–S5 are outside this issue's deliverable |

Per-control readings (`UIS.T2` need at 844 px = `16 × 844 / 640` = 21 px) and the seam report are in
`notes.md`, taken from `logs/graphical-s6.log`.

## Gates re-run on this build (no code changed by this run)

| Check | Result |
|---|---|
| `gdscript_tests.py test` | 32 headless unit test(s) passed |
| `spec_lint.py` | 0 errors, 1 pre-existing warning (`specs/view/glossary.md:14`, `Diagram`) |
| `gdscript_tests.py coverage` | **not re-measured here** — CI is the measurement for this commit |

Coverage is not claimed because the instrumented suite fails **nondeterministically in a different
file each run** on this machine (`chess_rules_test.gd`, `puzzle_play_test.gd`,
`advice_client_test.gd`, `chrome_paint_test.gd`, …), while the plain suite passes 32/32 every run. The
failures are timing/paint-shaped under the instrumented tree, none names a file this issue touches,
and the script stops before printing a figure. Tried the repo Python, the 3.11 interpreter owning
`gdtoolkit`, and a fresh venv with `gdtoolkit==4.5.0` as CI installs it. `Coverage` CI is green on
every delivering PR; the last local figure for this seam is `86.5%` at `161b4a9`, threshold 80.

## Repeatability

Two independent probe invocations on this build gave identical readings, reports, and renders.

## Paths

- `notes.md`
- `logs/graphical-s6.log`
- `screenshots/s6-phone-390x844.png`
- `probe/zz_accept546_probe.gd` — the harness; copied into `game/` only to run, deleted afterwards

## Defects

None. S6 passed on the render; no game or interface failure was found on this build.
