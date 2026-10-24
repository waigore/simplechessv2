# Manifest

- **Issue**: 483
- **Environment**: graphical (`ENV.2`)
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf` (OpenGL 4.1 Metal, Apple M5). Deliverable PR [#631](https://github.com/waigore/simplechessv2/pull/631) at head `fa23a7d`, merged for the run with `main` `63f744c`. Session `TEL.3` `sess-1792778211038-87730-playtest` (see `logs/graphical-capture.log`).
- **Coverage mode**: full, intersected with issue scope: `PTU-localization` (UX). This run supplies the graphical half of the protocol and the screenshots for the mode-pick copy and the promotion-chooser `queen` row.
- **Screenshots**: present under `screenshots/` (four PNGs, 1280×720).

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-localization` S1/P1 — first `C4` activation reads 繁體中文, copy is `zh-Hant` | pass |
| `PTU-localization` S1/P2 — `title`, `shared` differ across `en`, `zh-Hant`, `ja` | pass |
| `PTU-localization` S1/P4 — `locale` row reads the live locale's own name | pass |
| `PTU-localization` S3/P5 — promotion-chooser `queen` row reads `Queen` in all three locales | pass |
| `PTU-localization` F6 — graphical `queen` row not `Queen` in all three locales | pass (not observed) |
| `PTU-localization` S2/S3 five-screen listing | not judged beyond the mode-pick copy and the queen row — outside the change's blast radius; the completeness gate covers key sets for every owner |

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `screenshots/01-mode-pick-en.png`
- `screenshots/02-mode-pick-zh-Hant.png`
- `screenshots/03-mode-pick-ja.png`
- `screenshots/04-shared-play-promote.png`

## Defects

None filed.
