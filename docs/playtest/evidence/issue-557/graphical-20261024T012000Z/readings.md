# Readings — committed vs. observed, per leg

Source of truth for every number here is `run.json` (machine-written by `driver.mjs`, same run) and the per-leg console logs. Document reads use key `simplechessv2.persist.v1` (`PersistStore.STORAGE_KEY`), fields `player_elo`, `last_mode`, `recent_solved` (`SCH-persist-doc`).

"Committed baseline" is the document read immediately before the leg's punitive action. In every leg the baseline is **absent**, so there is no committed value to preserve and the leg has nothing to compare against.

| Leg | Action | Document before | Document after | Mode pick on screen | R2 Elo read | Outcome |
|---|---|---|---|---|---|---|
| 1 quit/reload | cold open 25 s → close tab → cold open 25 s | absent (no keys) | absent (no keys) | no — `Loading…` | not available (`puzzle-play` never opened) | `not-judged` |
| 2 crash | cold open 25 s → CDP `Page.crash` → cold open 25 s | absent (no keys) | absent (no keys) | no — `Loading…` | not available | `not-judged` |
| 3 faulted session | cold open 25 s → install `setItem` wrapper → 25 s commit window → restore → cold open 25 s | absent (no keys) | absent (no keys) | no — `Loading…` | not available | `not-judged` |

## Leg 3 fault mechanics

| Quantity | Value |
|---|---|
| Wrapper installed | yes, `Storage.prototype.setItem`, persist key only |
| Persist writes observed | **0** |
| Prior document at install | absent |
| Document after wrapper + window | absent |
| Wrapper restored before reopen | yes |
| `EX.save-failure` surface shown | no |

`PersistStore._web_set` compares the stored value with the payload and returns `false` on mismatch — the documented `G2` / `I2` failed-write path. With zero writes attempted, that branch was never reached, so this leg demonstrates the install/restore mechanism only. It does **not** demonstrate `G2`.

## Screenshots

Seven captures, all `md5 7ba3b2c7a110a2219608ad9ab65c5165`, all showing `Loading…`:

- `leg1-before-close.png`, `leg1-after-reopen.png`
- `leg2-before-crash.png`, `leg2-after-reopen.png`
- `leg3-before-fault.png`, `leg3-after-fault.png`, `leg3-after-reopen.png`

The identity is the measured consequence of the stall: the frame does not change, so no distinct judged moment exists. `run.json` records the whole md5 set under `screenshot_md5_all` and the distinct count under `screenshot_distinct_md5_count` so this claim is checkable rather than asserted.
