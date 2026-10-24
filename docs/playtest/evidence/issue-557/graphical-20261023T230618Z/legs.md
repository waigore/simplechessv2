# Legs — #557 graphical run `20261023T230618Z`

Judgement text per leg. Verdicts and basis summaries are in `manifest.md`; the raw document and screen reads are in `readings.md`.

### Leg 1 — quit/reload

The leg needs a `SEQ-puzzle-result-commit` S1–S4 commit before the close so the committed values have something to survive. That commit needs `puzzle-play`, which needs mode pick. The build stays on `EX.loading` for the full 30 s settle, so the leg stops before it has a value, and the document reads `null` both before the close and after the reopen — the comparison the leg is for has no committed side. `not-judged`. **Not a fail:** no durability behavior ran and misbehaved.

### Leg 2 — crash

The leg needs a mid-session Last-mode selection that was never committed, then a kill with no quit path. Mode pick carries that selection (`game/mode_pick_panel.gd`) and never rendered, so no uncommitted value existed. The renderer was killed through CDP `Page.crash` (not the in-game quit) and the reopen read the document as `null`. The crash half ran; the comparison half had nothing to compare. `not-judged`.

### Leg 3 — faulted session

The `localStorage.setItem` wrapper the issue names was installed for `simplechessv2.persist.v1` to throw on write, the prior document was read, then the leg tried to produce a commit to trip it. No commit path is reachable on this build: the wrapper received no call, `PersistStore._web_set` ran no round-trip check, `EX.save-failure` (`puzzle-play` S3) never appeared, and the `G2`/`I2` prior-document-intact comparison had no write to reject. The wrapper was restored before the reopen. `not-judged`.
