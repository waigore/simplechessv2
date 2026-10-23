# Readings — #557 graphical run `20261023T230618Z`

Per-leg document and screen reads behind the `manifest.md` results table. Every leg read the document with `localStorage.getItem("simplechessv2.persist.v1")` (`PersistStore.STORAGE_KEY`) and the screen by screenshot. Values are verbatim.

| Leg | Document before | Document after reopen | Mode pick reached | Screenshots |
|---|---|---|---|---|
| 1 — quit/reload | `null (absent)` | `null (absent)` | no | `leg-1-before-close.png`, `leg-1-after-reopen.png` |
| 2 — crash (CDP `Page.crash`) | `null (absent)` | `null (absent)` | no | `leg-2-after-reopen.png` |
| 3 — faulted session | `null (absent)` prior, `null (absent)` after the wrapped fault | `null (absent)` | no | `leg-3-forced-failure.png`, `leg-3-after-reopen.png` |

- **No R2 Elo on screen** in any leg: `playerElo` renders only inside the `puzzle-play` R2 region (`game/puzzle_play_panel.gd:179`), which this build never opens.
- **No Last-mode affordance** in any leg: `FL-mode-pick.N1` is drawn by `game/mode_pick_panel.gd` (`_is_last_shared()` / `_is_last_puzzle()`), which this build never renders.
- **Leg 3's wrapper was exercised as far as the build allows**: `Storage.prototype.setItem` was replaced for `simplechessv2.persist.v1` to throw, the prior document was read, no write reached it, and the wrapper was restored before the reopen. The `G2` / `I2` comparison could not be made because no commit was attempted.
- **No persistence document was ever created**: `localStorage` held no key at all after a 30 s cold open (`logs/leg-0-mechanism.log`: `localStorage keys: []`, `setItem calls after 30 s open: []`), so every leg starts and ends with an absent document rather than a default one.
