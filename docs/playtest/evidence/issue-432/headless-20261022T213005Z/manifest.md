# Manifest

- **Issue**: 432
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`95386d5` — merge of PR #489, "Record a no-cue rule for draw endings and silence the accept-draw path"). Probe `TEL.3`: `sess-1792706600555-10297-playtest`. Smoke `TEL.3`: `sess-1792706714356-11117-playtest`.
- **Coverage mode**: full (in-scope protocols for the playable deliverables `SND.X4` / `END.D1`–`D5`: `PTD-end-conditions`, `PTU-shared-result`; cue-level check under `PTD-shared-game`'s sound scope).
- **Screenshots**: waiting on a graphical re-run of the same build (`../graphical-<run-id>/screenshots/`). `PTD-end-conditions` is design-level and requires none; `PTU-shared-result` requires one result-screen screenshot from the graphical twin.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTD-end-conditions — `END.D1` stalemate (move-commit path) reaches `shared-result` as `END.D1`, no `X4` | pass |
| PTD-end-conditions — `END.D2` accept-draw (play-control path) reaches `shared-result` as `END.D2`, no `X4` | pass |
| PTD-end-conditions — `END.D5` clock-expiry draw (K vs K, no possible mate) reaches `shared-result` as `END.D5`, no `X4` | pass |
| PTD-end-conditions — `END.L2` resign keeps exactly one `SND.X4` end cue | pass |
| PTD-end-conditions — `END.L3` clock loss with mating material keeps `SND.X4` | pass |
| PTD-end-conditions — `END.D3` / `END.D4` classification: not loss ends, so no `X4` (unit classification + repo suite) | pass |
| PTD-end-conditions protocol verdict | pass (headless) |
| PTU-shared-result (headless) — every draw reaches the result screen | pass (headless) |
| PTU-shared-result protocol verdict | not-judged — graphical twin still required (`P2`) |
| Cue plumbing sanity — select `X1` / move `X2` still play on the probed build | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/headless-smoke.log`
- `logs/accept-432-probe.log`
- `logs/accept-432-probe.gd` (probe script; run from `game/` as `res://zz_accept432_probe.gd`)
- `screenshots/` — waiting on graphical re-run of the same build
