# Acceptance run — issue #63 (headless)

Environment: **Headless**, Godot 4.7.2 (`4.7.2.stable.official.ed1daf0bf`).
Build: `origin/main` at `7299459`, worktree checkout; `demos/shared-game/` as shipped
(PR #418 initial demo, #513/#521 #427 rework, #523 coordinate contrast, #572 piece extent,
#569 coordinate anchoring).
Scope: the issue's acceptance criteria. Playtesting is optional for demos
(`docs/demos.md`), so no playtest protocol is cited; this run supplies the reproducible
logs and the graphical run supplies the screenshots.

## What was run

- `godot --headless --path demos/shared-game --import --quit` — exits 0, no errors
  (`logs/import.log`).
- `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` — `[demo] PASS`
  (`logs/autodrive.log`).

## Result

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game, both scenarios | `L-two-player-game.K1`/`K2`, `END.L1` | pass — refused bad drop, 16 exercise moves, capture break, check, capture-promotion, mate `Checkmate — White wins` |
| Drawn piece bodies inside the extent at their `FRM.P2` heights | `SPC.E1`, `FRM.P1`, `FRM.P2`, `PER.R1` | pass — K 0.40 × 0.85, Q 0.40 × 0.79, B 0.39 × 0.76, N 0.48 × 0.75, R 0.40 × 0.68, P 0.38 × 0.62 |
| `AES.P1` motion budget | `PHY.M1`, `MOT.T1` | pass — `TRAVEL_S = RETURN_S = 0.15`; scripted commands 0–18 ms (this number times tween start, not travel — non-blocking note) |
| End panel inside the frame above the board | `END.L1`, #456 | pass — `P (41, 582.5) S (638, 185)`, margins 230/160, z 10 |

The graphical run in the sibling folder supplies the rendered judgement, the screenshots,
and the coordinate-label measurement that fails acceptance (defect #592).
