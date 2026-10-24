# Paths — #557 graphical run `20261024T204223Z`

| Artifact | Path |
|---|---|
| Manifest | `manifest.md` |
| Readings (per-leg document and screen table) | `readings.md` |
| Notes (blockers, method, non-blocking marks) | `notes.md` |
| Setup / reproduce | `setup.md` |
| Machine-readable run record | `run.json` |
| Driver | `driver.mjs` |

## Screenshots

| File | Moment | md5 |
|---|---|---|
| `screenshots/leg-1-cold-open-mode-pick.png` | Leg 1 cold open at mode pick, before entering the stream | `777969b01c1ffde6e1644940fe047742` |
| `screenshots/leg-1-puzzle-play-before-close.png` | Leg 1 in `puzzle-play` with `Elo 1000`, before the close | `a5590188e46d0579846fd1506bba0646` |
| `screenshots/leg-1-mode-pick-before-quit.png` | Leg 1 quit path, back at mode pick (`Puzzle stream · Last`) | `74ac8b73bcf91efc868013514da8fbcc` |
| `screenshots/leg-1-mode-pick-after-reopen.png` | Leg 1 after close and reopen, same state | `74ac8b73bcf91efc868013514da8fbcc` |
| `screenshots/leg-2-before-crash.png` | Leg 2 Shared setup with the uncommitted `White seat · Top` toggle | `38b1267fa36fafd547eb0107aaea2d98` |
| `screenshots/leg-2-mode-pick-after-reopen.png` | Leg 2 after the crash, mode pick holding the last committed state | `777969b01c1ffde6e1644940fe047742` |
| `screenshots/leg-3-before-fault.png` | Leg 3 mode pick with `Shared game · Last` before the fault | `777969b01c1ffde6e1644940fe047742` |
| `screenshots/leg-3-after-fault.png` | Leg 3 save-failure surface (`Save failed. Prior values kept.`) | `0abd57d70791780451497357e94c94fe` |
| `screenshots/leg-3-mode-pick-after-reopen.png` | Leg 3 after the fault and a clean reopen | `777969b01c1ffde6e1644940fe047742` |

Repeated hashes are the same rendered state, not separate observations; see `readings.md` *Screenshot distinctness*.

## Logs

| File | Window |
|---|---|
| `logs/leg-1.console.log` | Leg 1: cold open, stream entry, leave-and-quit, reopen |
| `logs/leg-2.console.log` | Leg 2: open, Shared setup, renderer kill, reopen |
| `logs/leg-3.console.log` | Leg 3: open, commit, forced failed write, reopen |

The `PersistStore: write failed; prior commit kept` line is in `logs/leg-3.console.log`; the `puzzle stream: deal read failed (status)` line is in `logs/leg-1.console.log`.
