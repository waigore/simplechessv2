# Acceptance criteria — issue #528

| AC | Result | Evidence |
|----|--------|----------|
| 1 — one O1 with Elo, recent ids and key; one F1–F13 record validated; only then `deal()`; no hand-supplied catalog | pass | `request_payload={ "api_key": "sim-key", "player_elo": 1000.0, "recent_solved": [] }`, `the O1 body validates as one F1-F13 record`, `the dealt puzzle is the returned record` |
| 2 — the dealt puzzle is the single record; no widened candidate list | pass | `required=[e7e5, g1f3, b8c6]` from a 4-move record: `the dealt sequence is the record's own moves; nothing was widened` |
| 3 — every failed read deals nothing, keeps `puzzleId` none and Elo, is observable | pass | the five `failed_read …` rows in [`results.md`](results.md), each with `puzzle.deal_failed` telemetry carrying the O2 reason; reader rejections `bulk`/`file`/`missing`/`wrong_type`/`snapshot`/`mark`/`one_move` all `malformed`/`bulk` |
| 4 — no bundled catalog bytes, no snapshot fetched as a static file | pass | `game/` grep in `logs/no-catalog-bytes.log`; the only catalog call is the O1 POST to `/catalog/deal` |
| 5 — catalog IO off the move and render path, never blocks a frame | pass | `unresponsive tick_ms=0.0 gesture_ms=0.0`, `leave ms=1.22` against a 3000 ms cap; `judged_move ms=0.52`; `real-socket-retire.log`: `leave_ms=1.26 … dealt=false`, `retiring_held=0` after the cap, no resource at exit |
| 6 — `CMP-puzzle-session` and traceability cite the catalog peer and the contract | pass | `specs/technical/components/puzzle-session.md` C5, `specs/technical/concurrency.md` U4/O5/S3/S4, `specs/technical/traceability/alignment.md` |
| 7 — tests cover the success path, every failure shape incl. a bulk body, and the off-path rule; suite green | pass | `logs/unit-tests.log` 25 suites (4 consecutive runs), `logs/coverage.log` 85.8% (threshold 80) |