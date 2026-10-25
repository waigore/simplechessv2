# Readings — #557 graphical run `20261024T204223Z`

Build: published release at `c5b8189`. Key: `simplechessv2.persist.v1`. Every value is a live `localStorage` read recorded in `run.json`; the screen half is the named screenshot. The game draws to one canvas, so the DOM carries no game text.

Cold open: the build leaves loading in about 21 s and renders mode pick.

## Leg 1 — quit/reload (`not-judged`)

| Moment | `player_elo` | `last_mode` | `recent_solved` | Screen |
|---|---|---|---|---|
| Cold open | key absent | — | — | mode pick, no Last mark (`leg-1-cold-open-mode-pick.png`) |
| In `puzzle-play` | `1000` | `puzzle` | `[]` | `Elo 1000`; Reveal/Abandon disabled; no puzzle (`leg-1-puzzle-play-before-close.png`) |
| Quit path, mode pick | `1000` | `puzzle` | `[]` | `Puzzle stream · Last` (`leg-1-mode-pick-before-quit.png`) |
| After reopen | `1000` | `puzzle` | `[]` | `Puzzle stream · Last` (`leg-1-mode-pick-after-reopen.png`) |

Entering the stream committed `last_mode: puzzle`, then logged `deal read failed (status)`. No deal means no result and no puzzle-result commit (`dealt: false`). The quit path is the build's own (`Leave stream` → confirm → mode pick); `run.json` records `screen_before_quit: mode-pick`.

## Leg 2 — crash (`pass`)

| Moment | `player_elo` | `last_mode` | Screen |
|---|---|---|---|
| After reaching mode pick | `1000` | `puzzle` | mode pick |
| Mid-session, before the kill | `1000` | `shared` | Shared setup, `White seat · Top` pressed after the commit (`leg-2-before-crash.png`) |
| After reopen | `1000` | `shared` | mode pick |

The kill was `chrome://crash` with no quit path; the renderer died (`crashed: true`). The reopened document matches the state committed before the uncommitted toggles, which left no trace because they were never written.

**Caveat**: the reopen capture is byte-identical to a fresh cold open — correct for this state, since mode pick with `last_mode: shared` renders exactly like the cold open. The pass rests on the document read.

## Leg 3 — faulted session (`pass`)

| Moment | `player_elo` | `last_mode` | Screen |
|---|---|---|---|
| Before the fault, committed | `1000` | `shared` | mode pick, `Shared game · Last` (`leg-3-before-fault.png`) |
| Fault installed, commit attempted | `1000` | `shared` | `Save failed. Prior values kept.` (`leg-3-after-fault.png`) |
| Restored, reopen | `1000` | `shared` | mode pick (`leg-3-mode-pick-after-reopen.png`) |

The fault was a browser-side `Storage.prototype.setItem` wrapper silently dropping writes to the persist key. It received exactly **1** write (`attempts: 1, dropped: 1`) committing `puzzle` over `shared`. `PersistStore._web_set` read back the old payload and `commit()` returned false:

```
ERROR: PersistStore: write failed; prior commit kept
```

That is `CTR-persist-document` `G2` / `I2` holding on a build. The step commits a *changed* value deliberately: an unchanged payload would round-trip even with the write dropped.

## Screenshot distinctness

Four captures share `md5 777969b0…` (cold open, leg 2 reopen, leg 3 before-fault and reopen) because they show the same state. See `paths.md` for every hash.
