# Acceptance evidence — #703

Spec-only acceptance check for "Piece identity and lifecycle story is covered by no playtest protocol".

- **Issue**: #703 (`type:defect`) — https://github.com/waigore/simplechessv2/issues/703
- **Environment**: none — spec-only deliverable, so no playtest protocol is in scope ([`specs/playtest/playtest.md`](../../../../../specs/playtest/playtest.md) gate: not required when the deliverables change no playable behavior)
- **Build read from**: `origin/main` at `586bd7f` (`Record the #702 acceptance run (spec-only re-derivation) (#744)`), fetched 2026-10-24; fix commit `400e288` (`Judge piece identity and lifecycle in PTD-pieces-common (#703) (#741)`) is an ancestor
- **Deliverable PR**: #741 (squash merge `400e288`)
- **Outcome**: **Accept**

## Results — the issue's three reproduction steps

| Step | Command | Expected after fix | Observed on `586bd7f` |
|------|---------|--------------------|------------------------|
| 1 | `grep -rn '^- \*\*Cites\*\*' specs/playtest/design/pieces-*.md` | a Cites line names the identity/lifecycle elements | `specs/playtest/design/pieces-common.md:8` now reads `` `E-pieces` common (I1–I11 board, capture, check, legality) and identity/lifecycle (P1–P4, S1–S3, Placement) ``. The other three piece protocols correctly keep their `I` ranges (`king` I12–I22, `officers`, `pawn`). **pass** |
| 2 | `grep -n 'Proves' specs/design/stories/entities/pieces.md` | row proves only `P`/`S`/`Placement` | 7 `Proves` lines: `P1, P2, P3, S1`; `P4` ×3; `S2`; `S3`; `Placement` — the cited set is exactly the proven set, no element cited that the row does not prove. **pass** |
| 3 | re-read `specs/playtest/traceability/story-protocol/design/index.md` | row no longer `none` | Row-level `none` is **0**, tally reads `41 rows = 41 judged + 0 none`, `pieces-common.md` row count 3→4, and the paragraph states `entities/pieces.md#PS1` is judged by `PTD-pieces-common`. **pass** |

## Details

Criterion-by-criterion evidence, the map-consistency table, the gates run in this session, and the scope check: [`checks.md`](checks.md).

## Scope check

Spec-only change: no `game/` file, asset, or catalog entry is in the merge diff, so no Design or UX protocol is in scope and no screenshot gate applies. No defect filed. No log or screenshot artifacts are expected beyond this record.
