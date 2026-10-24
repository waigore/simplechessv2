# Driver and capture notes — #478 graphical run

Corrections made in the sweep driver before the recorded run. All were in the
driver, not the product; they are recorded so a reader does not re-derive the
same false findings from scratch runs. Verified against the source named in each
item.

## The reveal is wall-clock, not frame-count

`UiChrome.transition_in` fades over `M1_S` (`game/ui_chrome.gd`). Under
`--script` the frame loop runs far faster than 60 fps, so a frame-count wait
captured mid-fade (measured `modulate.a` ≈ 0.49–0.77): blank or stale text and an
empty offer panel. Each capture now waits 0.45 s in real time, then three drawn
frames, before it is taken. That is what fixed
`05-shared-play-S2-confirm.png` and `08-shared-play-S6-offer.png`.

## The refusal flash is shorter than that wait

`REJECT_FLASH_S` is 0.3 s (`game/shared_game_session.gd`), so US3.11's assertion
must be read before any wait, and its screenshot needs its own ~0.12 s window.
Reading the state after the settle reported a false `fail` (`S1` instead of `S5`)
in an earlier graphical run; the product was correct. `06-shared-play-S5-reject.png`
shows what `shared-play-states.md` asks for: danger flash on `e5`, selection still
on `e2`, legal marks still drawn.

## Repaint must not push another screen's chrome

The repaint helper originally forced `STAGE_SHARED_PLAY` whenever a session
existed, so capturing `mode-pick` painted play chrome over the panel and produced
a mislabelled, partly empty frame. It now returns unless the stage is already
shared-play. `10-mode-pick-zh-Hant.png` and `11-mode-pick-ja.png` are mode-pick
in those locales.

## Keyboard rows go through the presentation

US1.6 (mode-pick keyboard focus) is judged by sending `InputEventKey` through
`presentation.handle_gui_input`, with no platform gate, rather than reported
`not-judged`; the platform-neutral path is what the screen owns.

## Positions a gesture sweep cannot reach

Castling, promotion, under-promotion, en passant and its expiry, long officer
rays, attacked squares, threefold repetition, clock expiry and the lapsed draw
offer were reached by forging positions through `ChessRules.load_position` and
then driving the real controls, so each is judged on session state rather than by
replaying hundreds of moves.

## Browser surface

The shipped export was served from `build/web` and driven over CDP to confirm the
browser booted, rendered mode-pick and shared-play, and to re-check the
focused-label reading outside the desktop app. That probe is not part of the row
judgements — rows are judged in `ENV.1`/`ENV.2` by `logs/w478_sweep.gd` — so no
browser-only verdict is claimed.

## Scope

Nothing outside `docs/playtest/evidence/issue-478/` changed. The driver lives in
`logs/` so the reading is reproducible; it is not product code and is not loaded
by the game.
