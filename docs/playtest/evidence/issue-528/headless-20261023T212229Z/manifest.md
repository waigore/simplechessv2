# Evidence manifest — issue #528 (headless run)

| Field | Value |
|-------|-------|
| Issue | #528 (defect, epic #35 / Wave 2 — Adaptive Puzzle stream) |
| Environment | headless `ENV.1` — Godot `4.7.2.stable.official.ed1daf0bf`, macOS arm64 |
| Build | `origin/main` `614746c` (worktree `1`, branch `main`, no local code changes) |
| Coverage mode | `full`, intersected with this defect's playable deliverables: `PTD-puzzle-stream` (Design, headless). `PTD-difficulty` is `n/a` — `DIF.Y1` runs on the service (#329), and neither the client nor the session selects from a downloaded set. UX protocols `PTU-puzzle-session` / `PTU-puzzle-play` were scheduled because the read sits on the puzzle-play journey and its leave path; their headless half is here and their graphical half is the twin run. |
| Peer | `FakeCatalogTransport` — the ADR-0013 Testability stand-in the seam build installs; no network, no Stockfish, no key on the wire. The shipped seam peer never answers, which is this run's "unresponsive catalog" case. |
| Screenshots | None — Design protocol requires none; the UX halves' screenshots are in `../graphical-20261023T212229Z/screenshots/`. |
| Defects | None — no cited story failed. Two observations recorded for other owners (see `notes.md`). |

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTD-puzzle-stream` S1 / K1 (`L-puzzle-stream.K1`) — a production deal asks for one record, validates it, and deals that record | pass — `logs/drive-headless.log`: `deal started=true requests=1 puzzle_id=pz-1 puzzle_elo=1000 solving_side=black`, `the production deal opened a puzzle` |
| `PTD-puzzle-stream` S1 / `F-puzzle-catalog` X2 — a failed read deals nothing, keeps `GS.puzzleId` none and `GS.playerElo`, and stays visible to the caller | pass — `failed_read reason=status|timeout|error|malformed|bulk … puzzle_id=none elo=1000.0 failure=<same reason> tel=true` for all five shapes; missing `T9`/`T10` at entry: `failure=status` |
| `PTD-puzzle-stream` S2 / K3, E1 — a solved attempt scores per `DIF.Y1` direction and owes exactly one next deal | pass — `after_solve cue_seen=true elo=1000.28774368332`, `next_deal puzzle_id=pz-2 new_requests=1` |
| `PTD-puzzle-stream` S3 / K2, F1 — a Wrong move resets the open puzzle, deals nothing, and can never end as a solve | pass — `wrong_move placed=true puzzle_id=pz-1 … deals nothing (no new O1)`, then `after_wrong_complete cue_failed=true elo=990.0 next=pz-1b` (L4, not W1) |
| `PTD-puzzle-stream` S4 / K3 — reveal fails the attempt and deals the next puzzle | pass — `after_reveal cue_seen=true … next=pz-3` |
| `PTD-puzzle-stream` S5 / K4, E1 — leave returns to mode-pick with no Elo penalty | pass — `unresponsive_leave ms=1.22 stage=mode-pick`, `leave applies no Elo penalty (K4)` |
| `PTU-puzzle-session` S1 — mode-pick `C2` opens `puzzle-play` | pass (headless) — `missing_key stage=puzzle-play state=S1` |
| `PTU-puzzle-session` S2 — leave confirm returns to mode-pick **on an open puzzle**; S3 leave cancel stays | pass (headless) — `leave_confirm stage=mode-pick`, `leave_cancel stage=puzzle-play … keeps the open puzzle` |
| `PTU-puzzle-play` S1 — the Solving side plays the record's required steps | pass (headless) — `timed move ['e7','e5'] is a required step` ×4 on `pz-4` |
| `PTU-puzzle-play` S3 — reveal confirm; leave confirm / cancel | pass (headless) — `reveal_confirm=reveal_confirm`, `leave_cancel`, `leave_confirm` |
| `PTU-puzzle-play` S4 / P3 — a move holds a frame | pass (headless, handler cost) — `judged_move ms=0.52`, `no O1 request is made on the move path`; the frame-sample half is judged in the graphical twin |
| **Protocol verdict `PTD-puzzle-stream`** | **pass** (headless) |
| **Protocol verdict `PTU-puzzle-session`** | **headless half pass**; graphical half in `../graphical-20261023T212229Z/` |
| **Protocol verdict `PTU-puzzle-play`** | **headless half pass**; graphical half in `../graphical-20261023T212229Z/` |

## Issue acceptance criteria, judged in this run

| AC | Result | Evidence |
|----|--------|----------|
| 1 — one O1 with Elo, recent ids and key; one F1–F13 record validated; only then `deal()`; no hand-supplied catalog | pass | `request_payload={ "api_key": "sim-key", "player_elo": 1000.0, "recent_solved": [] }`, `the O1 body validates as one F1-F13 record`, `the dealt puzzle is the returned record` |
| 2 — the dealt puzzle is the single record; no widened candidate list | pass | `required=[e7e5, g1f3, b8c6]` from a 4-move record: `the dealt sequence is the record's own moves; nothing was widened` |
| 3 — every failed read deals nothing, keeps `puzzleId` none and Elo, is observable | pass | the five `failed_read …` rows above, each with `puzzle.deal_failed` telemetry carrying the O2 reason; reader rejections `bulk`/`file`/`missing`/`wrong_type`/`snapshot`/`mark`/`one_move` all `malformed`/`bulk` |
| 4 — no bundled catalog bytes, no snapshot fetched as a static file | pass | `game/` grep in `logs/no-catalog-bytes.log`; the only catalog call is the O1 POST to `/catalog/deal` |
| 5 — catalog IO off the move and render path, never blocks a frame | pass | `unresponsive tick_ms=0.0 gesture_ms=0.0`, `leave ms=1.22` against a 3000 ms cap; `judged_move ms=0.52`; `real-socket-retire.log`: `leave_ms=1.26 … dealt=false`, `retiring_held=0` after the cap, no resource at exit |
| 6 — `CMP-puzzle-session` and traceability cite the catalog peer and the contract | pass | `specs/technical/components/puzzle-session.md` C5, `specs/technical/concurrency.md` U4/O5/S3/S4, `specs/technical/traceability/alignment.md` |
| 7 — tests cover the success path, every failure shape incl. a bulk body, and the off-path rule; suite green | pass | `logs/unit-tests.log` 25 suites (4 consecutive runs), `logs/coverage.log` 85.8% (threshold 80) |

## Checks run

| Check | Result | Log |
|-------|--------|-----|
| `godot --headless --path game --import --quit` | exit 0 | `logs/import.log`, `logs/import.status` |
| `python3 .github/scripts/gdscript_tests.py test` | 25 headless unit tests passed (run 4×) | `logs/unit-tests.log`, `logs/unit-tests.status` |
| `python3 .github/scripts/gdscript_tests.py coverage` | 85.8% (4466/5206), threshold 80 | `logs/coverage.log`, `logs/coverage.status` |
| `gdformat --check game` | 58 files unchanged | `logs/gdformat.log` |
| `gdlint game` | no problems | `logs/gdlint.log` |
| `python3 .github/scripts/spec_lint.py` | 0 errors, 1 pre-existing glossary warning | `logs/spec-lint.log` |
| Playtest smoke `godot --headless --path game` | exit 0, `TEL.5` pass rows | `logs/headless-smoke.log`, `logs/headless-smoke.status` |
| Acceptance drive (`logs/drive.gd`) | 93 checks pass, `ACCEPT DRIVE PASS`, exit 0 | `logs/drive-headless.log` |

## Paths

- [`notes.md`](notes.md)
- `logs/drive.gd` — the drive (same file as the graphical twin's `logs/drive.gd`)
- `logs/drive-headless.log`
- `logs/real-socket-retire.gd`, `logs/real-socket-retire.log`
- `logs/retire-without-reaper.gd`, `logs/retire-without-reaper.log`
- `logs/baseline-30-frames.gd`, `logs/baseline-30-frames*.log`
- `logs/no-catalog-bytes.log`
- `logs/import.*`, `logs/unit-tests.*`, `logs/coverage.*`, `logs/gdformat.*`, `logs/gdlint.*`, `logs/spec-lint.*`, `logs/headless-smoke.*`