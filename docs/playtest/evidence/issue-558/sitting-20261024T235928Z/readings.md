# Readings — #558 sitting soak

Build `c4202bb` (`Web Release` local export), `ENV.2`. Sources: `logs/sitting.log`,
`logs/probe-release-state.log`.

## Sitting

| Reading | Value |
|---|---|
| Start (wall clock) | 2026-10-25T00:09:57.886Z |
| End (wall clock) | 2026-10-25T00:25:19.411Z |
| Duration | 921.5 s = 15 min 22 s |
| Window required | 15–40 min (`quality.md` Reliability) |
| Heartbeats | 26 |
| Heartbeats with `alive:false` | 0 |
| Idle bands saved | 5 (`08-game-over`, `11-puzzle`, `20-reopen`, `34-offline`, `38-sitting`) |
| Renderer crash / forced exit | 0 |
| Deliberate relaunches | 1 (the quit-and-reopen leg) |
| Rows in `logs/sitting.log` with a failure kind | 0 |

## Advice-Off leg

| Reading | Value |
|---|---|
| `GS.advice` | `false` |
| `GS.online` | `true` |
| `GS.adviceBestMove` at start / after `f3` | `null` / `null` |
| `GS.adviceEval` at start / after `f3` | `null` / `null` |
| `GS.adviceError` | `false` |
| `GS.sideToMove` after the move | `black` |
| Advice marks on the board | none (`sitting-06-g4-after.png`) |

## Offline leg (Advice On, build offline)

| Reading | Value |
|---|---|
| `GS.advice` | `true` |
| `GS.online` | `false` |
| Advice endpoint (`T9`/`T10`) | empty on the release |
| `GS.adviceBestMove` after `e4 e5` | `null` |
| `GS.adviceEval` after `e4 e5` | `null` |
| `GS.adviceError` / S3 error surface | `false` / none (`sitting-reopen-33-offline-after-wait.png`) |

## Reopen leg

| Reading | Value |
|---|---|
| Quit at | 2026-10-25T00:14:15.648Z |
| Reopened at | 2026-10-25T00:14:35.420Z |
| Time closed | 19.8 s |
| First screen after reopen | mode pick |
| Stored document before / after | identical |
| Stored value | `{"simplechessv2.persist.v1":"{\"last_mode\":\"puzzle\",\"player_elo\":1000.0,\"recent_solved\":[],\"version\":1}"}` |

## Release-graph probe (`DBG.2` substitute)

| Reading | Value |
|---|---|
| Checks | 26 |
| Failures | 0 |
| `PlaytestSeams` on `main_release.tscn` | absent (ADR-0004 `G2`) |
| Advice client shipped | yes |
| Advice endpoint | empty |
| Probe exit warning | 8 leaked `ObjectDB` instances (harness teardown, outside the sitting) |
