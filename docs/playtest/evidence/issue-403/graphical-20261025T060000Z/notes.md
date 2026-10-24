# Notes — method, and what almost made these readings wrong

Working record for #403 on the published release `c5b8189`, so a verifier can separate a
*measurement* from an *instrument artefact* without re-running everything.

## The instrument changed because the first could not resolve the budget

`capture_open_route.mjs` polls the readback every 250 ms while walking a route — fine for *which
screen was reached*, useless for a 3 s budget: it only brackets the first painted frame, and a
bracket straddling 3000 ms decides the row by accident.

`cold_open_exact.mjs` therefore reads the same `gl.readPixels` probe **once per
`requestAnimationFrame` inside the page**, stamped from the build's own `timeOrigin`. The probe
is reinstalled after navigation and `probeInstalled: true` is recorded per run.

## Traps hit, and what each cost

- **Board square mapping.** For most of the session every move failed on the published build.
  Cause: square centres computed in **DPR-2 device pixels** and used as **CSS px** on a page whose
  `--force-device-scale-factor=2` makes screenshots 780×1688. Correct map at 390×844 CSS:
  `fileA = 59.5`, `row8 = 399.5`, `step = 38.75`. With the wrong map `e2` resolved off-square, so
  every "input ignored / no move reachable" conclusion was a coordinate error. Those conclusions
  are **withdrawn**. The same class of error is why this record disputes **#845** (see
  [readings-cold-open.md](readings-cold-open.md)).
- **Screencast vs frame budget.** A per-frame JPEG stream competes with the frames it measures;
  `mv1`/`mv2` used `--no-cast`, and screencast runs are visual proof only.
- **Leaked Chromes from parallel agents.** `cap402` profiles pinned GPU helpers at ~420 % CPU
  each (load 33) and inflated cold opens to ~9.2–9.4 s — a machine reading. `ps aux | grep
  "[h]eadless=new"` was checked before every timing run; the four counted runs are from an idle
  machine (load ~3–5).
- **A test failure that was not this worktree's.** One `gdscript_tests.py test` run reported
  `Fail: res://entry_spine_test.gd` at `:318` — a line that does not exist (the file is 251
  lines). Parallel agents were running Godot in the shared checkout then (`zz_verify846.gd`,
  `t2.gd`). Re-run in the isolated `/tmp/orc403` worktree: **30 passed**, four times running.
- **`--check-engine` takes a tree.** Called bare it exits with a usage error, and `exit=0` after a
  pipeline is the *pipeline's* status. The recorded run uses `--check-engine build/web` and reads
  `EXIT=0` explicitly.

## What is cited, not measured here

- **#402's verdicts** are inherited where it judged a row on this same build; its numbers are not
  re-taken. Its first record (`dd15479`) could not supply a `pass` — it never left `Loading…`.
- **#400** has not run, so playtest-protocol rows are `not-judged`.
- **#640 / #641 / #643** have returned no verdict; **#566** is `pending-acceptance` and owns the
  Localization hand-off (no row here is Localization-derived).
- **#560**'s `scan_release_bundle` is still **absent** from `.github/scripts/web_export.py`. The
  related fact that the *bundle* carries no Stockfish was checked directly
  (`--check-engine build/web`, exit 0) and is supporting evidence, never a substitute.

## Re-running

```
node scripts/cold_open_exact.mjs https://waigore.github.io/simplechessv2/ <outDir> <label>
node scripts/play_move.mjs https://waigore.github.io/simplechessv2/ <outDir> <label> --no-cast
node scripts/forced_write.mjs https://waigore.github.io/simplechessv2/ <outDir> <label>
```
