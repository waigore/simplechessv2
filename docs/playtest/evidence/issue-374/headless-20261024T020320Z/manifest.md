# Manifest

Build `b171a3f` (`main`, contains PR #518 / #541 / #555 and PR #711), environment `ENV.1`, **released** scene graph.
Back to [`notes.md`](notes.md).

| File | What it is |
|------|------------|
| [`setup.md`](setup.md) | commands and probe design |
| [`notes.md`](notes.md) | what was run, limits |
| [`results.md`](results.md) | per-criterion readings |
| [`verdicts.md`](verdicts.md) | `PTD-move-advice` P1–P3 / F1–F2 |
| `logs/import.log` | fresh-checkout import |
| `logs/export-release.log` | `Web Release` export (`main_release.tscn`, no `PlaytestSeams`) |
| `logs/repeats.{json,log}` | three repeats per phase, peer request rows |
| `logs/drive-{advice,lifecycle,failure}-N.log` | per-phase probe output (`R374 {...}` lines) |
| `logs/peer-{advice,lifecycle,failure}-N.{jsonl,log}` | loopback peer: one row per O1 request |
| `logs/unit-tests.log` | 26 headless suites |
| `logs/coverage.log` | statement-line coverage |
| `logs/advice-suite-peer.log`, `logs/peer-unit.jsonl` | advice suite with `ADVICE_STREAM_PEER` armed |
| `logs/gdlint.log`, `logs/gdformat-check.log`, `logs/spec-lint.log` | lint gates |
| `logs/drive.gd`, `logs/peer.py`, `logs/run_checks.py` | the probes themselves |
