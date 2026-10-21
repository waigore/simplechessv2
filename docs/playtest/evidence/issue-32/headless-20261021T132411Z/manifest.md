# Playtest evidence manifest

| Field | Content |
|-------|---------|
| Issue | 32 |
| Environment | headless |
| Build / session id | `sess-1792588948067-1151631-playtest` (`TEL.3`) |
| Coverage mode | `full` (intersected with this epic: scaffold session only; chess design and UX protocols are out of scope) |
| Godot | 4.7.2.stable.official.ed1daf0bf |
| Commit | `11309eb5c6cd70d6d488b11049b17cd3265a0e32` |

## Results

| Story or protocol | Result |
|-------------------|--------|
| `SEQ-playtest-headless-smoke` | pass |
| `EX.loading` (`TEL.4` on `smoke_inspect`) | pass |
| `ENV.1` | pass |

## Paths

- Screenshots: none (headless smoke judges telemetry, not a rendered frame). See `screenshots/README.md`.
- Notes: `notes.md`
- Logs: `logs/headless-smoke.log`
