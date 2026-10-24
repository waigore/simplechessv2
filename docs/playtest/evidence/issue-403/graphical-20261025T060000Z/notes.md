# Notes — how these readings were taken, and what almost made them wrong

This is the run's working record for #403: the published release build, read for the
Every-release ADR rows. It exists so a verifier can tell a *measurement* from an *instrument
artefact* without re-running everything.

## Build under test

The published release `c5b8189` (run `40118381611`), which **is** at or after #647's merge —
unlike #402's `dd15479`. See [builds.md](builds.md). No row in this folder passes on a build
that predates the repair, and no local export is labelled published.

## The instrument changed because the first one could not resolve the budget

`capture_open_route.mjs` polls the canvas readback every 250 ms while walking a route. That is
fine for *which screen was reached* and useless for a 3 s budget: it can only bracket the
first painted frame. A bracket that straddles 3000 ms decides the row by accident.

`cold_open_exact.mjs` therefore reads the same `gl.readPixels` probe **once per
`requestAnimationFrame`, inside the page**, and stamps each frame from the build's own
`timeOrigin`. The probe is reinstalled on the build's document after navigation (it cannot
survive the navigation), and `probeInstalled: true` is recorded per run.

One consequence worth stating: the first *sampled* frame (1.4–2.2 s) is when the browser
started running the page's rAF loop, **not** when pixels appeared. Between those two moments
there was no `canvas` at all, so the readback could not answer. The painted instant is the
first frame whose readback is non-zero.

## Traps that were hit, and what each cost

- **Board square mapping.** For most of the session every move failed on the published build.
  Cause: square centres were computed in **DPR-2 device pixels** and used as **CSS px** on a
  page whose `--force-device-scale-factor=2` makes the screenshots 780×1688. Correct map at
  390×844 CSS: `fileA = 59.5`, `row8 = 399.5`, `step = 38.75` (`e2` = 214,632; `e4` =
  214,554). With the wrong map, `e2` resolved onto a square that was not `e2`, so every
  "input ignored / no move reachable" conclusion was a coordinate error, not a build
  behaviour. Those conclusions are **withdrawn**.
- **Screencast vs frame budget.** A JPEG screencast every frame competes with the frames it
  is measuring. `mv1`/`mv2` were therefore taken with `--no-cast`; the screencast runs exist
  only as visual proof and are not the source of the frame numbers.
- **Leaked Chromes from parallel agents.** This machine runs other agents' work. Leaked
  `cap402` profiles pinned GPU helpers at ~420 % CPU each (load average 33) and inflated cold
  opens to ~9.2–9.4 s — a machine reading, not a build reading. Before every timing run the
  machine was checked (`ps aux | grep "[h]eadless=new"`), and the four counted runs are from
  an idle machine (load ~3–5).
- **A test failure that was not this worktree's.** One `gdscript_tests.py test` run reported
  `Fail: res://entry_spine_test.gd` at `entry_spine_test.gd:318`, a line that does not exist
  (`entry_spine_test.gd` is 251 lines). Parallel agents were running Godot in the shared main
  checkout at that moment (`zz_verify846.gd`, `t2.gd`). Re-run in the isolated `/tmp/orc403`
  worktree: **30 passed**, four times in a row (one of them shown in
  `logs/unit-tests-c5b8189.log`).
- **`--check-engine` takes a tree.** `web_export.py --check-engine` with no argument exits
  with a usage error, and `exit=0` after a shell pipeline is the *pipeline's* status, not the
  tool's. The recorded run uses `--check-engine build/web` and reads `EXIT=0` explicitly.

## What is cited, not measured here

- **#402's outcome rule** is used; #402's *numbers* are not, because its build predates
  #647 and never left `Loading…`. Where a row's Method is the same `quality.md` reading
  #402 took, the record says so and gives the #403 reading on the shipped build.
- **#400** has not run (`status:pending-implementation`), so the playtest-protocol rows are
  `not-judged` with that reason.
- **#640 / #641 / #643** have not returned verdicts, so the shape/colour-blind and locale
  rows are `not-judged` naming those leaves.
- **#566** has landed (`status:pending-acceptance`) and owns the Localization hand-off; no
  row recorded by #403 is Localization-derived.
- **#560**'s `scan_release_bundle` is still **absent** from `.github/scripts/web_export.py`
  (0 occurrences at `c5b8189`), so *No client Stockfish endpoint* is `not-judged`. The other
  half of that idea — that the *released bundle* carries no Stockfish binary, engine WASM, or
  endpoint — was checked directly with `web_export.py --check-engine build/web` (exit 0) and
  is recorded as supporting evidence, not as a substitute for the missing check.

## File map

| File | What it holds |
|---|---|
| `manifest.md` | The row table: result per ADR check, with the Method quoted and the evidence named |
| `readings.md` | Timelines, cold-open instants, move-window frame numbers, and the FAIL.T1 run |
| `builds.md` | Published build identity, fallback comparator, and why #402 supplies no pass |
| `logs/x*-*` | Cold-open probe sessions, per-frame stamps, console |
| `logs/mv*-*` | Move runs: timeline windows, frame stamps, console |
| `logs/*-c5b8189.log` | Unit tests, advice test, `--check-engine`, manifest check, roots audit |
| `screenshots/` | Mode pick, shared setup, board, `e2` selected, `e4` played, and the control route |
| `scripts/` | The harness as run: `cdp.mjs`, `cold_open_exact.mjs`, `capture_open_route.mjs`, `play_move.mjs`, `probe_input.mjs`, `analyse.py` |

To re-run the cold open:

```
node scripts/cold_open_exact.mjs https://waigore.github.io/simplechessv2/ <outDir> <label>
```

To re-run the move reading:

```
node scripts/play_move.mjs https://waigore.github.io/simplechessv2/ <outDir> <label> --no-cast
```
