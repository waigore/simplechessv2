# Results — issue #528 headless run

| Protocol / story | Result |
|------------------|--------|
| `PTD-puzzle-stream` S1 / K1 (`L-puzzle-stream.K1`) — a production deal asks for one record, validates it, and deals that record | pass — `logs/drive-headless.log`: `deal started=true requests=1 puzzle_id=pz-1 puzzle_elo=1000 solving_side=black`, `the production deal opened a puzzle` |
| `PTD-puzzle-stream` S1 / `F-puzzle-catalog` X2 — a failed read deals nothing, keeps `GS.puzzleId` none and `GS.playerElo`, and stays visible to the caller | pass — `failed_read reason=status|timeout|error|malformed|bulk … puzzle_id=none elo=1000.0 failure=<same reason> tel=true` for all five shapes; missing `T9`/`T10` at entry: `failure=status` |
| `PTD-puzzle-stream` S2 / K3, E1 — a solved attempt scores per `DIF.Y1` direction and owes exactly one next deal | pass — `after_solve cue_seen=true elo=1000.28774368332`, `next_deal puzzle_id=pz-2 new_requests=1` |
| `PTD-puzzle-stream` S3 / K2, F1 — a Wrong move resets the open puzzle, deals nothing, and can never end as a solve | pass — `wrong_move placed=true puzzle_id=pz-1 … deals nothing (no new O1)`, then `after_wrong_complete cue_failed=true elo=990.0 next=pz-1b` (L4, not W1) |
| `PTD-puzzle-stream` S4 / K3 — reveal fails the attempt and deals the next puzzle | pass — `after_reveal cue_seen=true … next=pz-3` |
| `PTD-puzzle-stream` S5 / K4, E1 — leave returns to mode-pick with no Elo penalty | pass — `unresponsive_leave ms=1.22 stage=mode-pick`, `leave applies no Elo penalty (K4)` |
| `PTU-puzzle-session` S1 — mode-pick `C2` opens `puzzle-play` | pass (headless) — `missing_key stage=puzzle-play state=S1` |
| `PTU-puzzle-session` S2 — leave confirm returns to mode-pick on an open puzzle; S3 leave cancel stays | pass (headless) — `leave_confirm stage=mode-pick`, `leave_cancel stage=puzzle-play … keeps the open puzzle` |
| `PTU-puzzle-play` S1 — the Solving side plays the record's required steps | pass (headless) — `timed move ['e7','e5'] is a required step` ×4 on `pz-4` |
| `PTU-puzzle-play` S3 — reveal confirm; leave confirm / cancel | pass (headless) — `reveal_confirm=reveal_confirm`, `leave_cancel`, `leave_confirm` |
| `PTU-puzzle-play` S4 / P3 — a move holds a frame | pass (headless, handler cost) — `judged_move ms=0.52`, `no O1 request is made on the move path`; the frame-sample half is judged in the graphical twin |

No story failed, so no defect is filed. S2/S3 of `PTU-puzzle-session` were judged with an
open puzzle; the empty failed-read state has no Leave path, which is the screen's (#333) and
is recorded in [`notes.md`](notes.md).