# Evidence manifest — issue #335, demo run (headless)

| Field | Value |
|-------|-------|
| Issue | #335 (epic #35, wave 1 demo follow-on) |
| Environment | headless (`godot --headless`) |
| Build / session id | branch `task/335-demo-puzzle-stream` off `origin/main` `ab5b144`; `demos/puzzle-stream/`; Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | demo (`docs/demos.md`: unit tests and playtesting are optional) |

## Results

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Deal from mode pick at the player's Elo | `L-puzzle-stream.K1`, `DIF.Y1`, `NAV.T2`, `GS.Q1` | pass — puzzle `0003` at 1000 for Elo 1000, band 100 |
| Solving-side play, required reply | `UI-puzzle-play.C1`, `C2`, `K2` | pass |
| Wrong move resets, stream continues | `UI-puzzle-play.K2`, `END.L4` | pass — board back to deal, no new puzzle, Elo 1000 → 989 |
| Solve, reveal, abandon endings | `END.L5`, `END.L6` | pass — Elo 988 → 979, 978 → 972 |
| Mate-in-one accepts any checkmate | `F-puzzle-catalog.R5`, `END.W1` | pass — solved by an unrecorded mate (`Qb8#`); Elo 972 → 980, recentSolved 1 |
| Illegal place refused, not a Wrong move | `EX.rejected`, `UI-puzzle-play.S5` | pass — puzzle untouched |
| Calm leave, Elo kept, no ending | `L-puzzle-stream.K4`, `E1`, `END.L5` | pass — back at mode pick at Elo 980 |
| Promotion type asked before judging | `EX.promote.S4`, `UI-puzzle-play.C6` | pass |
| Fixture slice is recorded-format and legal | `F-puzzle-catalog.R1`, `R3`, `X1` | pass — 6 records, every mate-in-one mark a real mate |
| Style: piece bodies inside extent, labels clear the board | `SPC.E1`, `FRM.P2`, `PER.R7`, `UIS.T2` | pass |
| Persistence + save-failure keeps prior Elo | `PRG.M1`, `EX.save-failure`, `S3` | pass — prior Elo kept at 1043 |

No failures. `[demo] PASS` at exit 0.

## Paths

| Artifact | Path |
|----------|------|
| Autodrive log | `logs/autodrive.log` |
