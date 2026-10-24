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

## Expected, criterion by criterion

| Expected | Evidence |
|----------|----------|
| A design protocol's **Cites** covers the identity and lifecycle elements | `specs/playtest/design/pieces-common.md:8` names `P1`–`P4`, `S1`–`S3`, and `Placement`. Element IDs verified to exist in `specs/design/entities/pieces.md` (`P1` color l.17, `P2` type l.18, `P3` origin l.19, `P4` has moved l.20, `S1` on board l.26, `S2` captured l.27, `S3` promoting l.28, `§Placement and availability` l.41) — no phantom IDs. |
| The covered elements are actually judged, not only listed | Every cited element is reached by a step in the same file: `P1` 4, `P2` 2, `P3` 2, `P4` 5, `S1` 5, `S2` 2, `S3` 4, `Placement` 3 mentions. Steps S6 (color/type/origin/on-board/moved-false on the orthodox opening), S7 (moved flag denying castling), S8 (moved flag denying the double step), S9 (capture → `S2`, stays out of play), S10 (promotion `S3` → `S1` as the chosen type), S11 (orthodox `Placement`: ranks, back-rank order, pawns). |
| Outcomes recorded so a failing build is caught | Pass `P3` and fail `F2` (blocks acceptance) state the identity/lifecycle outcomes: wrong color/type/origin/moved flag, a captured unit staying on the board, promotion resolving without a chosen type. |
| "Most naturally `design/pieces-common.md`" (the issue's own steer) | Delivered in that file; no new protocol was created, matching the defect's framing that this row "is owned by an existing protocol's cite and needs no new protocol". |

## Map consistency across the six touched files

| File | Check | Result |
|------|-------|--------|
| `specs/playtest/traceability/story-protocol/design/pieces-common.md` | `entities/pieces.md#PS1` present with element token `P1–P4, S1–S3, Placement`, judged by `pieces-common` | pass |
| `specs/playtest/traceability/story-protocol/design/index.md` | 41 rows, `none` 0, tally `41 judged + 0 none` | pass |
| `specs/playtest/traceability/story-protocol/protocols-design.md` | `pieces-common` cite quote and judged-row list updated; trailing "one row no design protocol judges" note replaced by "no row-level `none` remains" | pass |
| `specs/playtest/traceability/story-protocol/protocols.md` | protocol view `41 of 41 story rows`, `none` note dropped | pass |
| `specs/playtest/traceability/story-protocol.md` | tally `Design 41 / 41 / 0`, total `75 / 60 / 15` | pass |

## Gates run in this session

| Check | Command | Result |
|-------|---------|--------|
| Spec lint | `python3 .github/scripts/spec_lint.py` | **pass** — 0 errors, 1 pre-existing warning (`specs/view/glossary.md:14` 'Diagram' also defined in `specs/technical/glossary.md`), unrelated to this change |
| Cite correctness | new **Cites** IDs located in the owning spec | **pass** — all eight tokens exist in `specs/design/entities/pieces.md` |
| File budget | word count of the edited protocol | **pass** — 401 words (< 500) |

## Scope check

Spec-only change: no `game/` file, asset, or catalog entry is in the merge diff, so no Design or UX protocol is in scope and no screenshot gate applies. No defect filed. No log or screenshot artifacts are expected beyond this record.
