# Readings — #557 run `graphical-20261023T233200Z`

Every leg reads the document with `localStorage.getItem("simplechessv2.persist.v1")` (`PersistStore.STORAGE_KEY`) and the screen by screenshot. Values are verbatim.

| Leg | Document before | Document after reopen | Mode pick reached | Screenshots |
|---|---|---|---|---|
| 1 — quit/reload | `null (absent)` — never seeded | `null (absent)` | no | `leg-0-cold-open-390x844.png` |
| 2 — crash | `null (absent)` | `null (absent)` | no | `leg-0-cold-open-390x844.png` |
| 3 — faulted session | `null (absent)` | `null (absent)` | no | `leg-0-cold-open-390x844.png` |

- **No R2 Elo on screen** in any leg: `playerElo` renders only inside the `puzzle-play` R2 region, which this build never opens.
- **No Last-mode affordance** in any leg: `FL-mode-pick.N1` is drawn by `game/mode_pick_panel.gd`, which this build never renders.
- **Leg 3's wrapper was never exercised**: with no commit reachable, no write reached `PersistStore._web_set`. A storage-layer wrapper — the only path a seeded check could drive — is not the build's commit path, so it is not reported as a leg.
