# Manifest

- **Issue**: 54
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`6394047` on this worktree; code from merged PR #298 `77ddf31`, stories from PR #301 `a679725`). No `TEL.3` session id: domain L2/L3 does not emit playtest telemetry.
- **Coverage mode**: full (in-scope for #54: `PTD-end-conditions` S1–S3 and non-clock `END.P1`; S4/S5 and full `PTD-shared-game` stay on #55 / screen tasks)
- **Screenshots**: none. `PTD-end-conditions` is a headless Design protocol and judges no rendered state.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTD-end-conditions S1 (END.L1 checkmate) | pass |
| PTD-end-conditions S2 (END.L2 resign) | pass |
| PTD-end-conditions S3 (END.D1–D4 draws) | pass |
| END.P1 L1 before D1 / L1 before D4 | pass |
| END.L2 when clock already zero | pass |
| END.D2 only on legal accept; blocked by position ending | pass |
| Decline / withdraw / lapse continue play | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/ptd-end-conditions.log`
- `logs/spec-lint.log`
