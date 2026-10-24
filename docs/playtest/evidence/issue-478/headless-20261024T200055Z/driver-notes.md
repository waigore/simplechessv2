# Driver and capture notes — #478 headless run

Corrections made in the sweep driver before the recorded run. All were in the
driver, not the product; they are recorded so a reader does not re-derive the
same false findings from scratch runs. Verified against the source named in each
item.

## The reveal is wall-clock, not frame-count

`UiChrome.transition_in` fades over `M1_S` (`game/ui_chrome.gd`). Under
`--script` the frame loop runs far faster than 60 fps, so a 24-frame wait
captured mid-fade (measured `modulate.a` ≈ 0.49–0.77). That reads as blank or
stale text and as an empty offer panel. The driver now waits in real time
(0.45 s) plus three drawn frames before reading a panel.

## Headless has no draw callback

The settle also waits for `RenderingServer.frame_post_draw`, which never fires
headless; waiting on it there hangs the run. The drawn-frame part is skipped when
the run is headless, and no headless row asserts a pixel.

## Positions a gesture sweep cannot reach

Castling, promotion, under-promotion, en passant and its expiry, long officer
rays, attacked squares, threefold repetition, clock expiry and the lapsed draw
offer were reached by forging positions through `ChessRules.load_position` and
then driving the real controls, so each is judged on session state rather than by
replaying hundreds of moves.

## Controls are driven through the router

Every play action goes through `router.handle_control("shared-play", id)` rather
than by calling session methods directly, so the same path a tap takes runs, the
panel repaints, and a row cannot pass on state the UI never showed.

## Position setup uses the real placement API

`shared_game_session.gd` `place()` takes a `Dictionary` and the play token carries
the piece `kind`; the mint → C5 → S2 → confirm → S6 sequence, and the ordering
that starts the clock only after the first move, were taken from the source. The
earlier scratch driver asserted against an outdated shape of each and reported
false failures.

## Story rows come from the protocol view

Row labels are copied from
`specs/playtest/traceability/story-protocol/protocols.md`, not re-derived from a
protocol `Cites` line; the earlier draft carried rows the view does not list and
missing story numbers.

## Scope

Nothing outside `docs/playtest/evidence/issue-478/` changed. The driver lives in
`logs/` so the reading is reproducible; it is not product code and is not loaded
by the game.
