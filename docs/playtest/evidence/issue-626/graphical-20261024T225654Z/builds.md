# Builds — #626 mobile-browser sitting

What was read, where it came from, and what the seat can and cannot show. Judgement text in
[notes.md](notes.md); results table in [manifest.md](manifest.md); the seat in full in
[seat.md](seat.md).

## The build under test (the reading)

| Field | Value |
|---|---|
| Source | **published URL** — `https://waigore.github.io/simplechessv2/` (the issue's preferred source) |
| Commit | `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96` |
| Published by | `Web release` workflow run **`40118381611`** (success, 2026-10-24T17:56:09Z) |
| Playtest seams | **absent** — the release build strips `CMP-playtest-seams` (ADR-0004 `G2`), so `TEL.3` has no session id and none is invented |
| Correlation key | commit sha + this folder |
| Environment | `graphical` (`ENV.2`) |

The published source was chosen because it serves a commit that **descends from #647's repair
(`bccdb1c`)** and leaves `EX.loading` with the boot group resolved. The network route to it was
read directly from the page (`logs/sit-network.log`): one navigation to `/`, then `index.js`,
`index.wasm`, `index.pck`, `index.icon.png` — every response `200`.

## The gate that made the run gradable

The issue sets a `not-judged` gate on the build being readable. It passed:

| Reading | Value | Source |
|---|---|---|
| Leaves `EX.loading`, reaches mode pick | **yes** | `screenshots/sit-01-01-mode-pick-cold.png` |
| `Error opening file 'game_assets/…'` lines | **0** | `logs/probes/sit-probe1.json` → `reading.openFailedCount` |
| `Preload boot left N approved IDs unresolved` | absent (0) | same |

## The control build (not a published reading)

A local `Web Release` export of `9ed334aca44385ee530f57129cec38fb55a18dc5` exists in `build/web/`
and was used only as a **network-route control** — never as a source of a graded row. The four
release gates over it all came back clean:

| Gate | Reading | Log |
|---|---|---|
| Engine / project | `build/web` | `logs/g626-engine.log` |
| Cataloged assets | 35/35 `game_assets/` files, 15 audio-runtime copies | `logs/g626-assets.log` |
| Boot group | 14 of 14 resolved | `logs/g626-boot.log` |
| Play / ambient groups | 19 of 19 play, 2 of 2 ambient | `logs/g626-groups.log` |

No `Web Release` export fallback was needed for the graded run: the published URL was live and
readable, so nothing here stands in for it.

## Audio on this commit

This commit predates the audio-route repair (`d21bbf6`, **#785**), which merged after `c5b8189`.
The board's cues and the café ambience are silent here:

```
ERROR: Cannot open file 'res://game_assets/sound-effects/touch-select.ogg'.   (×5 cues)
ERROR: Preload play left 5 approved IDs unresolved
ERROR: Preload ambient left 2 approved IDs unresolved
```

That is #785's already-merged repair not yet published on this commit — not a new defect, and not
re-filed. Audibility is #627's row, not this one.
