# Driver and capture notes — #478 graphical run

The same driver produced both runs (`logs/w478_sweep.gd` in each folder). All
corrections below were in the driver, not the product, and are recorded so a
reader does not re-derive the same false findings from scratch runs.

## The reveal is wall-clock, not frame-count

`UiChrome.transition_in` fades over `M1_S` (`game/ui_chrome.gd`). Under
`--script` the frame loop runs far faster than 60 fps, so a 24-frame wait
captured mid-fade (`modulate.a` ≈ 0.49–0.77) — blank or stale text and an empty
offer panel. Screenshots now wait 0.45 s real time, then take three drawn frames.

## The refusal flash is shorter than that wait

`REJECT_FLASH_S` is 0.3 s (`game/shared_game_session.gd`), so US3.11 is read
before any wait and its shot uses a ~0.12 s window. Reading after the settle
reported a false `fail` (`S1` instead of `S5`) in an earlier graphical run; the
product was correct. `06-shared-play-S5-reject.png` here shows the specified
state: danger flash on `e5`, selection on `e2`, legal marks drawn.

## Repaint must not push another screen's chrome

`_repaint()` originally forced `STAGE_SHARED_PLAY` whenever a session existed,
so capturing `mode-pick` painted play chrome over the panel. It now returns
unless the stage is already shared-play, which is why `10`/`11` are mode-pick in
`zh-Hant`/`ja` rather than shared-play frames.

## Legacy positions need forging

Castling, promotion, en passant and its expiry, officer rays, attacked squares,
threefold repetition and clock expiry were reached through
`ChessRules.load_position` and then driven with the real controls, so each is
judged on session state instead of a long move script.

## What the screenshots show

`01`–`02` mode-pick S1 and S3; `03` shared-setup; `04`–`08` shared-play S1, S2
confirm, S5 refusal, S4 promotion, S6 draw offer; `09` shared-result; `10`–`11`
mode-pick copy in `zh-Hant` and `ja`.

`06` is the one to read alongside AC 6: it is the corrected capture of a refused
place, and it is why no story failed on the refusal path. `01` and `10` are the
captures that surface #833 (focused label invisible).

## Browser surface

The export was served from `build/web` and driven over CDP to confirm the browser
booted and rendered mode-pick and shared-play, and to re-check #833 outside the
desktop app (10 s and 14 s after load). That probe is not part of the row
judgements, so no browser-only verdict is claimed.

## Scope

Nothing outside `docs/playtest/evidence/issue-478/` changed. The driver lives in
`logs/` for reproducibility; it is not product code.
