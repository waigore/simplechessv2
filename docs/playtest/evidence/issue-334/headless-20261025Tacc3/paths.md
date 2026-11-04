# Paths — #334 acceptance, headless

- `manifest.md` — session facts, environment, coverage scope.
- `notes.md` — method, the 21-vs-23 key-count finding, independence pointer.
- `results.md` — the per-AC reading.
- `findings.md` — recorded, filed nowhere.
- `independence.md` — why this is an acceptance pass, not an independent cycle.
- `probe/accept334_probe.gd` — independent reader of the shipped getters (re-run from this copy produces `logs/probe-values.log`)
- `probe/runner.gd` — the wrapper that runs the shipped gate document
- `logs/probe-values.log`, `logs/copy-gate.log`
- `logs/unit-tests.log` — 33 passed
- `logs/mutation-missing.log`, `logs/mutation-i5-disarmed.log` — the two mutation runs
- `../graphical-20261025Tpar1/` — the cited graphical `PTU-localization` run and its screenshots
