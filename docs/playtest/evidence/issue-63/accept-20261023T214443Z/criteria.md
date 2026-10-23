# Acceptance criteria — issue #63

Part of the [issue #63 acceptance run](notes.md). Commands and logs are listed there.

| Criterion | Outcome | Evidence |
|-----------|---------|----------|
| Runs from the repo and shows one shared game by the stated means | pass | `--import --quit` exit 0; headless and graphical autodrive `[demo] PASS` (refused bad drop, 16 exercise moves, capture break, check, capture-promotion, `Checkmate — White wins`); [exercise](screenshots/demo-shared-game-exercise.png) and [mate](screenshots/demo-shared-game-mate.png) frames |
| Realizes the epic's demo-ready ID set; every cited ID exists in `specs/` | pass | 89 ID-shaped tokens in the README resolve in `specs/` ([logs/spec-ids.log](logs/spec-ids.log)); `PER.R7` measured from rendered pixels in [coordinate-labels.md](coordinate-labels.md) |
| Only cataloged assets with a `review-asset` Pass or a person exemption | pass | 20/20 IDs `state: approved`, `review.verdict: Pass`, files present ([logs/assets.json](logs/assets.json)); no exemption used; no catalog file changed |
| Expresses `AES.P1`–`P3` | pass | every scripted move 0–3 ms against the 150 ms budget with `TRAVEL_S`/`RETURN_S` = 0.15 s; rendered bodies K 0.85, Q 0.79, B 0.76, N 0.75, R 0.68, P 0.62 per `FRM.P2`; mahogany `PAL.C2`/`C5` board, rose only for check/refusal, visible in the screenshots |
| Lives entirely under `demos/`; main code does not import it | pass | standalone `project.godot`; no `demos/` reference under `game/` |
| Any new assumption recorded in `specs/` scope, not only in the demo | pass | README A1–A4, each naming its owning spec (demo scope per `docs/demos.md`) |
| README records citations, type, and question | pass | question "Does a shared game at a cafe table feel instant, readable, and calm?", type `Engine demo`, issue #63, Included/Excluded sets, D1–D14, A1–A4, run steps present |

Judged elements and their spec sources:

| Unit | Cited spec elements |
|------|---------------------|
| Runnable shared game, both scenarios | `L-two-player-game.K1`/`K2`, `END.L1` |
| Coordinates outside the 8x8, ≥ 4.5:1, ≥ `UIS.T2` | `PER.R7`, `PAL.C1`, `PAL.C9`, `UIS.T2` |
| Cataloged assets with a review Pass | `specs/assets/` kinds, `AST.O3` |
| `AES.P1`–`P3` | `MOT.T1`, `FRM.P2`, `PAL.C2`/`C5` |
