# Acceptance run — issue #63 (headless)

Environment: **Headless**, Godot 4.7.2 (`4.7.2.stable.official.ed1daf0bf`).
Build: `demos/shared-game/` as on `main`; identical to this worktree's demo tree.
Scope: the issue's acceptance criteria, cited to the spec elements each carries. Playtesting
is optional for demos (`docs/demos.md`), so the ACs are the judged units.

## What was run

- `godot --headless --path demos/shared-game --import --quit` — completes.
- `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` — `[demo] PASS`: bad drop
  refused (`PHY.M5` + `PER.R8`), 15 moves with capture breaks, check, and capture-promotion;
  mate scenario ends `Checkmate — White wins`. Motions 0–6 ms against 150 ms (`AES.P1`).
  Log: `logs/autodrive.log`.

## Judgement

| AC | Verdict | Basis |
|----|---------|-------|
| Runs from the repo, one shared game | pass | Commands above; mate ending. |
| Realizes the demo-ready ID set; IDs exist | **fail** | All cited IDs resolve in `specs/` (56 qualified, plus bullet IDs `GS.V1`, `END.L1`, `PRG.M1`, `AST.O3`, `CFG.K1`, `E-pieces.I1`–`I35`). The build misses `FRM.P1` / `SPC.E1` / `PER.R1`. |
| Cataloged, approved, review-Pass assets | pass | 20/20 `assets.json` IDs: `approved` + `review.verdict: Pass`. |
| `AES.P1`–`P3` | **fail** | `P1` passes; `P2` fails (silhouette outside `SPC.E1`); `P3` passes. |
| Under `demos/`; main code does not import it | pass | No `demos/` reference in `game/`. |
| Assumptions in `specs/` | pass (demo scope) | A1–A4 are demo-only details naming their owning specs. |
| README records citations, type, question | pass, with correction | Present; the `D11` / `PER.R1` piece claims are wrong. |

## Failure — piece bodies ~2× over the `SPC.E1` extent

`board_view.gd:_apply_piece_texture` maps the sprite's opaque **width** to `PIECE_EXTENT`
0.85. Bodies are ~0.40 × 0.85 of the 512 px canvas, so height becomes `0.85 × body_h / body_w`.

| Type | Drawn height | `SPC.E1` / `FRM.P1` |
|------|--------------|---------------------|
| King | 1.81 | 0.85 max |
| Queen | 1.67 | |
| Bishop | 1.64 | |
| Rook | 1.44 | |
| Pawn | 1.39 | |
| Knight | 1.32 | |

- `logs/piece-body-measure.log` — from the catalog sprites with the demo's own fit.
- `logs/pixel-measure.log` — silhouette runs from the frame, on vertically isolated squares
  so no two pieces merge into one run.

`FRM.P1` requires bodies drawn *within* 0.85 × 0.85 and "never wider, taller, or spilling
into neighbors". Silhouettes span ~1.8 units on a 1-unit square, and the queen at d8 paints
over the empty a8 square. This is **#427 item 1**: that defect asked to bring bodies *up* to
the extent; the current fit overshoots it. Not re-filed here.

## Non-blocking notes

- `PER.R7` coordinates: cream `PAL.C10` on `#6E4430` lips, 7.38:1, correct lips.
- #456 end panel: x 41–678 inside the 720 px frame, above pieces.
- Headless exit logs `ObjectDB instances leaked at exit` — engine shutdown noise.
