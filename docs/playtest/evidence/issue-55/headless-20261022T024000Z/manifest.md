# Manifest

- **Issue**: 55
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`39ada2b` on this worktree; clocks from merged PR #306 `774d9a9`, O4 fix from PR #308 `cff234d`). No `TEL.3` session id: domain L2 clock tick / expiry does not emit playtest telemetry.
- **Coverage mode**: full (in-scope for #55: `PTD-shared-game` P1 and S3/P3; `PTD-end-conditions` S4 L3-versus-D5 half. Resign-at-zero half of S4 stays on #54. Clock rendering stays on #58.)
- **Screenshots**: none. `PTD-shared-game` and `PTD-end-conditions` are headless Design protocols and judge no rendered state.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTD-shared-game P1 (untimed clocks none) | pass |
| PTD-shared-game S3 / P3 (side-to-move clock + increment) | pass |
| GS.V2 (at most one running clock; side to move) | pass |
| CFG.K1 / K2 / T1 / T2 init, lock, re-init (K3) | pass |
| Increment applied / denied at zero; illegal keeps clock | pass |
| PTD-end-conditions S4 L3 (other side can checkmate) | pass |
| PTD-end-conditions S4 D5 (other side cannot) | pass |
| O4 defender-material cases (K+B vs K+N, K+N vs K+B, opposite/same bishops, KNN) | pass |
| Tick does not block presentation (O(1) clamp) | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/ptd-shared-game-clocks.log`
