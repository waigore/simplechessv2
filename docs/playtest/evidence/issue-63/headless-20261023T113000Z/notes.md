# Rework run — issue #63 (headless), piece extent fix

Environment: **Headless**, Godot 4.7.2 (`4.7.2.stable.official.ed1daf0bf`).
Build: `demos/shared-game/` with the piece-fit rework of the acceptance fail on #63
(`SPC.E1` / `FRM.P1` / `FRM.P2` / `PER.R1` / `AES.P2`, item 1 of defect #427), on `main`
`50d098e` (includes the `FRM.P2` per-type heights from #571).
Scope: the issue's acceptance criteria; playtesting is optional for demos (`docs/demos.md`).

## What was run

- `godot --headless --path demos/shared-game --import --quit` — completes.
- `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` — `[demo] PASS`.
  Log: `logs/autodrive.log`.

## Result

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game (both scenarios) | `L-two-player-game.K1`/`K2`, `END.L1` | pass — refused bad drop, 16 moves with capture break, check and capture-promotion, mate `Checkmate — White wins` |
| Drawn body inside the extent and at its `FRM.P2` height | `SPC.E1`, `FRM.P1`, `FRM.P2`, `PER.R1` | pass — K 0.40 × 0.85, Q 0.40 × 0.79, B 0.39 × 0.76, N 0.48 × 0.75, R 0.40 × 0.68, P 0.38 × 0.62 |
| `AES.P1` snap settle | `PHY.M1`, `MOT.T1` | pass — 0–18 ms vs the 150 ms budget |
| End panel inside the frame above the board (#456 regression) | `END.L1` | pass — `P (41, 582.5) S (638, 185)`, margins 230/160, z 10 |

## Harness fix found by this run

The scripted promotion (I33/I34) left the in-board chooser open, so the next scripted
command (`h8g8`) was swallowed by the input gate: the exercise ran 15 of its 16 moves and
`[demo] PASS` still printed. The autodrive now dismisses the chooser like a player pick does,
and a scripted move that leaves the board unchanged fails the run.
