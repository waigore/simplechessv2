# Manifest

- **Issue**: 544 — implement `SIT.4` frame-time / load-time capture (seam `S11`, op `O10`)
- **Environment**: headless (`ENV.1`) — the real `main.tscn` playtest wiring driven through the public `PlaytestSeams` API by a throwaway probe (not committed); no game or seam code ran otherwise
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf` on branch `task/544-sit4-frame-load-capture` (based on `origin/main` `fded56b`; the `S11` seam code is unchanged from `58edbf6`, PR #950). Run sessions (`TEL.3`): repeat 1 `sess-1793899355680-95364-playtest-198860`, repeat 2 `sess-1793899356024-95365-playtest-193003`.
- **Coverage mode**: partial — the 2026-11-01 verification reopened AC 7 only (repeat count from two actual runs of the same window). All three code findings of that round are closed and were not re-litigated; nothing in `game/` is in this run's diff.
- **Screenshots**: not applicable — headless `ENV.1`; the window the criterion repeats is the cold `EX.loading` span of the real boot.
- **SIT.4 timing record**: device `Mac17,2 (Apple M5)`, OS `macOS 27.2 (26B123)`, engine `Godot 4.7.2`, browser `n/a — headless rendering, no browser`, **repeat count `2`** (one run per repeat below, read from each run's own `TEL.3`).

## Results

| Check | Result |
|-------|--------|
| AC 7 — two actual runs of the same window recorded, with their `session_id` pair and the repeat count | pass — repeat 1 and repeat 2 below: both a cold `loading_ready` window armed inside the natural `EX.loading` span, closed at `mode-pick`, read late through `measure()` |
| AC 7 — every report returns `sample_count` | pass — both reports carry `sample_count: 1` with a real `max_ms` (148.06 / 149.41); two repeats of one window is the evidence, not one |
| Late read and once-only handover unaffected | pass — the report was read four frames after its close and a second ask returned `refused` / `no window` (`notes.md`) |
| Scope | pass — docs-only change; `spec_lint.py` 0 errors with the one pre-existing `specs/view/glossary.md` warning |

## Paths

- `../headless-20261024T203114Z/` — the earlier headless passes (unit, lint, coverage, the pre-repair live reads)
- Log excerpts for this run are recorded verbatim in [`notes.md`](notes.md); under `docs/playtest/evidence/**/logs/` is gitignored, so no log file is committed

## Defects

None filed. The shipped-build blocker stays with #630 / #647 as previously recorded.
