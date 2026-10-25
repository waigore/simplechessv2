# Manifest

- **Issue**: 334 — Localize the wave-2 puzzle copy in en, zh-Hant, and ja
- **Environment**: graphical (`ENV.2`) — the twin the headless run `../headless-20261024T180000Z` left waiting
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf` (macOS window, OpenGL 4.1 Metal), `origin/main` `0fd4640` (this worktree branched from it). Capture session `TEL.3`: `sess-1792882280138-80759-playtest-439809` (`logs/graphical-probe.log`).
- **Coverage mode**: `full`, intersected with this leaf's scope: UX `PTU-localization` only (`specs/playtest/ux/localization.md`). `PTU-puzzle-play`, the growth layout, and the C4-on-the-puzzle-screen reading are #333's evidence per the issue body's `## Preconditions`; design protocols are untouched by a copy change.
- **Story-row source**: the protocol file's own `Cites` rows (`UI-mode-pick.US1`, `LOC.US1`).
- **Frame**: the project's default 1280×720 window.
- **Defects**: none filed by this run — see `notes.md` Finding B4 and Outcome.
- **Screenshots**: `screenshots/` (seven PNGs at 1280×720), covering mode-pick in all three locales, Shared play, and the promotion-chooser read.

## Results

| Protocol / row | Result |
|----------------|--------|
| `ENV.2` rendered display | pass — `macOS`, 1280×720 |
| `S1` / P1 — first `C4` keeps S1, `R3` reads `繁體中文`, copy is `zh-Hant` | pass — `02-mode-pick-zh-Hant.png`: 選擇遊玩方式 / 共用對局 · 上次 / 謎題串流 / 結束 / 繁體中文 |
| `S1` / P3 — `locale` reads its own name while `zh-Hant` / `ja` is live | pass — `繁體中文`, then `日本語` |
| `S1` / P2 — `title`, `shared`, `puzzle` differ across the three locales | pass — `01`/`02`/`03` |
| `S1` / F1 — no `FAIL.T13` miss logged after the switches | pass — no miss marker in `logs/graphical-probe.log` |
| `S2` / P4 — `shared-play` copy per locale | **fail** — the rendered panel shows only the status, Advice, Resign and Offer draw rows; the `queen` row the protocol asks for is not on that screen (see `notes.md` Finding B1) |
| `S3` / P5 — `C4` closed at `en`, then the `queen` row in Shared play | **fail** — the promotion chooser does not open on a last-rank pawn place, so `queen` is never rendered (see `notes.md` Finding B2) |
| Table rows re-read on this build — 21 `puzzle-play` keys + `mode-pick.puzzle` resolve in three locales; 17 varying keys differ from `en` | pass |
| **Protocol verdict `PTU-localization`** | **fail** — P4 and P5 not met |

## Paths

- `notes.md`
- `probe/accept334_graphical.gd`
- `logs/graphical-probe.log`
- `screenshots/01-mode-pick-en.png` — mode-pick at `en`
- `screenshots/02-mode-pick-zh-Hant.png` — mode-pick after the first `C4` activation (`S1` evidence)
- `screenshots/03-mode-pick-ja.png` — mode-pick after the second `C4` activation
- `screenshots/04-shared-play-en.png` — Shared play at `en` (`S2` reading)
- `screenshots/06-shared-play-promote-{en,zh-Hant,ja}.png` — the `S3` last-rank pawn place: no chooser opened
