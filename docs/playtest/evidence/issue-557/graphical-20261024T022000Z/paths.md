# Paths — #557 graphical run `20261024T022315Z`

| Artifact | What it holds |
|---|---|
| `manifest.md` | the `evidence-manifest.md` fields, the five results rows, and the `Defects` line |
| `notes.md` | what was judged, why `not-judged`, and what the run deliberately did not do |
| `readings.md` | per-leg document and screen reads, and the console every open produced |
| `build-observations.md` | the build checked before the legs ran, and how to reproduce |
| `setup.md` | driver commands and flags |
| `run.json` | machine-readable record: build, environment, per-leg before/after/during reads, screenshot md5s, verdicts |
| `driver.mjs` | the driver that wrote every file above except this one |
| `screenshots/leg-1-before-close.png`, `screenshots/leg-1-after-reopen.png` | leg 1 screen before the quit and after the reopen |
| `screenshots/leg-2-before-crash.png`, `screenshots/leg-2-after-reopen.png` | leg 2 screen before the crash and after the reopen |
| `screenshots/leg-3-before-fault.png`, `screenshots/leg-3-after-fault.png`, `screenshots/leg-3-after-reopen.png` | leg 3 screen before the forced failure, in the faulted window, and after the reopen |
| `logs/leg-1.console.log`, `logs/leg-2.console.log`, `logs/leg-3.console.log` | the console for both opens of each leg (102 lines each) |

All seven captures are byte-identical (`md5 7ba3b2c7…`) — the measured consequence of the `EX.loading` stall, recorded in `run.json` `screenshot_distinct_md5_count`. There is no `EX.save-failure` screenshot because the surface was never reached.
