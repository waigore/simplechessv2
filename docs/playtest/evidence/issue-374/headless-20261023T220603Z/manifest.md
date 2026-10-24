# Manifest

- **Issue**: 374 — client advice streaming: request, apply, cancel, never delay
- **Environment**: headless (`ENV.1`), Godot 4.7.2.stable.official.ed1daf0bf, macOS (Apple Silicon), no browser
- **Build / session id**: `origin/main` `ba6a59a`, exported as the shipped **`Web Release`** graph (`main_release.tscn`, `custom_features="release"`, PCK not embedded) and driven through the release scene by `logs/drive.gd`. `TEL.3` session id: none — the release graph carries no `PlaytestSeams`.
- **Timing (`SIT.4` measurements in this run)**: macOS Apple Silicon, headless (no browser), **3 repeats** per phase; readings below are the worst of three.
- **Coverage mode**: full, intersected with issue scope: `PTD-move-advice` (Design, headless only). The protocol asks for no screenshots, so this headless folder is the whole requirement.
- **Backend**: reachable advice peer `logs/peer.py`, a scripted `CTR-advice-stream` stand-in on a real loopback socket (ADR-0002 Testability). No Stockfish, no UCI. With no seam node, `_advice_sim_factory()` is `null` and the client uses the shipped `AdviceStreamTransport` — the graph [Gate — #534](https://github.com/waigore/simplechessv2/issues/374#gate--534) asks for.
- **Reproduce**: `python3 logs/run_checks.py <this-dir> 3`; prep in [`setup.md`](setup.md).

## Results

| Protocol / criterion | Result | Evidence |
|----------------------|--------|----------|
| S1 — arrival with no ask action (AC 1, 9) | **pass** | first E1 at 102–111 ms; 8/8 authorised peer rows, `time_ms=2000` (B3) |
| AC 11 — E1 progressive, deepening | **pass** | `19 → 28 → 41` at 0.00 / 0.10 / 0.30 s, E2 `cap` at 0.70 s |
| AC 2 — side to move, no principal line | **pass** | White `e2→e4 / +41`, Black `e7→e5 / −14` |
| AC 3 — local move never waits | **pass** | HUD click 28–30 ms, drag 14–15 ms, stream in flight |
| AC 4–6 — clear, re-evaluate, stale dropped | **pass** | cleared on move complete; fresh stream per position; `I3` holds |
| AC 7 / 10 / 12 — Puzzle, loss, one error | **pass** | no puzzle advice; `online=false` + move applies; 1 `advice.error` per run |
| AC 13 / 14 / 15 | mixed | PCK has no Stockfish endpoint; `move-advice` headless passes; telemetry **not captured** (no seam on the release graph) |
| Unit tests / Coverage / Code lint / Spec lint | **pass** | 25 suites; 86.3% (80); lint clean; 0 errors, 1 pre-existing warning |

Full table with 16 criteria: [`results.md`](results.md). Per-story outcomes: [`verdicts.md`](verdicts.md).

## Paths

- [`notes.md`](notes.md), [`setup.md`](setup.md), [`results.md`](results.md), [`verdicts.md`](verdicts.md)
- `logs/drive.gd`, `logs/peer.py`, `logs/run_checks.py`, `logs/repeats.json`, `logs/repeats.log`
- `logs/drive-{advice,lifecycle,failure}-{1,2,3}.log`; `logs/peer-{advice,lifecycle,failure}-{1,2,3}.{jsonl,log}`
- `logs/import.log`, `logs/export-release.log`, `logs/unit-tests.log`, `logs/coverage.log`, `logs/gdlint.log`, `logs/gdformat-check.log`, `logs/spec-lint.log`
- Screenshots: none — `PTD-move-advice` is headless-only.
