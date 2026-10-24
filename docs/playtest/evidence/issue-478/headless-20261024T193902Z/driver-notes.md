# Driver and capture notes — #478 headless run

Corrections made in the sweep driver before the recorded run. All were in the
driver, not the product; they are recorded so a reader does not re-derive the
same false findings from scratch runs. Verified against the source named in
each item.

## The reveal is wall-clock, not frame-count

`UiChrome.transition_in` fades over `M1_S` (`game/ui_chrome.gd`). Under
`--script` the frame loop runs far faster than 60 fps, so a 24-frame wait
captured mid-fade (measured `modulate.a` ≈ 0.49–0.77). That reads as blank or
stale text and as an empty offer panel. Screenshots now wait in real time
(0.45 s) and then take three drawn frames.

## The refusal flash is shorter than that wait

`REJECT_FLASH_S` is 0.3 s (`game/shared_game_session.gd`), so US3.11's assertion
must be read before any wait, and its screenshot needs its own ~0.12 s window.
Reading the state after the settle reported a false `fail` (`S1` instead of
`S5`) in an earlier graphical run; the product was correct. The corrected
`06-shared-play-S5-reject.png` in the graphical folder shows what
`shared-play-states.md` asks for: danger flash on `e5`, selection still on `e2`,
legal marks still drawn.

## Repaint must not push another screen's chrome

`_repaint()` originally forced `STAGE_SHARED_PLAY` whenever a session existed,
so capturing `mode-pick` painted play chrome over the panel and produced a
mislabelled, partly empty frame. It now returns unless the stage is already
shared-play. The graphical `10`/`11` images are mode-pick in `zh-Hant`/`ja`.

## Headless has no draw callback

`_settled` waits for `RenderingServer.frame_post_draw`, which never fires
headless; waiting on it there hangs the run. The wait now skips drawn frames when
the run is headless.

## Positions a gesture sweep cannot reach

Castling, promotion, under-promotion, en passant and its expiry, long officer
rays, attacked squares, threefold repetition, clock expiry and the lapsed draw
offer were reached by forging positions through `ChessRules.load_position` and
then driving the real controls, so each is judged on session state rather than by
replaying hundreds of moves.

## Browser surface

The shipped export was served from `build/web` and driven over CDP to confirm the
browser booted, rendered mode-pick and shared-play, and to re-check #833 outside
the desktop app. That probe is not part of the row judgements — rows are judged
in `ENV.1`/`ENV.2` by `logs/w478_sweep.gd` — so no browser-only verdict is
claimed.

## Scope

Nothing outside `docs/playtest/evidence/issue-478/` changed. The driver lives in
`logs/` so the reading is reproducible; it is not product code and is not loaded
by the game.
