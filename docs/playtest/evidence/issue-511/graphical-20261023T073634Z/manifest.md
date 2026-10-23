# Manifest

- **Issue**: 511
- **Environment**: graphical (`ENV.2`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`e022f83` on `main`; deliverable merged as `f44b535`, PR #519). Display: X11 on Xvfb, Mesa 25.2.8 / llvmpipe, OpenGL Compatibility. Capture session `TEL.3` `sess-1792740695…-playtest` (see `logs/graphical-capture.log`).
- **Coverage mode**: full, intersected with issue scope: `PTU-localization` (UX). S1/P1, P2, P4, P5 and S2/P3 are judged here; the graphical run of the same build supplies the screenshots.
- **Screenshots**: present under `screenshots/` (six PNGs, 720×1280).

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-localization` S1/P1 — first `C4` activation reads 繁體中文, copy is `zh-Hant`, screen stays S1 | pass |
| `PTU-localization` S1/P2 — `title`, `shared`, `puzzle` differ across `en`, `zh-Hant`, `ja` | pass |
| `PTU-localization` S1/P4 — `locale` row reads the live locale's own name | pass |
| `PTU-localization` S2/P3 — `shared-play` `queen` (and the other three marked piece rows) render their `en` value | pass — `Queen` `Rook` `Bishop` `Knight` in `ja` |
| `PTU-localization` P5 for the listed strings — Copy-table row values, no clipped label | pass — `COPY … unmatched=[]`, no `CLIPPED` line |
| `PTU-localization` P6 — both environments pass and the graphical run adds the screenshots | pass |
| `PTU-localization` S3 five-screen full listing | not-judged beyond the marked rows (outside the change's blast radius; see the headless twin) |

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `screenshots/01-mode-pick-en.png`
- `screenshots/02-mode-pick-zh-Hant.png`
- `screenshots/03-mode-pick-ja.png`
- `screenshots/04-shared-setup-ja.png`
- `screenshots/05-shared-play-promote.png`
- `screenshots/06-shared-play-s1.png`
