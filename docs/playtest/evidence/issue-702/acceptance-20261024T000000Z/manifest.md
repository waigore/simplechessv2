# Acceptance evidence — #702

Spec-only acceptance check for "Three puzzle-catalog and stream-visit design stories are covered by no playtest protocol".

- **Issue**: #702 (`type:defect`)
- **Environment**: none — spec-only deliverable, so no playtest protocol is in scope ([`specs/playtest/playtest.md`](../../../../../specs/playtest/playtest.md) gate: not required for spec-only issues)
- **Build read from**: `origin/main` at `400e288` (`Judge piece identity and lifecycle in PTD-pieces-common (#703) (#741)`), fetched 2026-10-24
- **Deliverable PR**: #740 (squash merge `d71178b`)
- **Outcome**: **Accept**

## Results — the issue's four reproduction steps

| Step | Command | Expected after fix | Observed on `400e288` |
|------|---------|--------------------|------------------------|
| 1 | `grep -rn '^- \*\*Cites\*\*' specs/playtest/design/*.md` | a line naming each key | 13 lines (twelve protocols + `_template.md`); `specs/playtest/design/puzzle-stream.md:8` names `` `F-puzzle-catalog` (R1–R5, I1–I3, X1–X2, D1) `` and `` `SC-puzzle-stream-visit` (W1.1–W1.4, W2.1–W2.4) `` — **pass** |
| 2 | `grep -rn -E '^- \*\*Spec key\*\*' specs/design/stories/features/puzzle-catalog.md specs/design/stories/features/puzzle-catalog-select.md specs/design/stories/scenarios/puzzle-stream-visit.md` | three rows, keys as stated | `F-puzzle-catalog` ×2 (lines 6 of both catalog files), `SC-puzzle-stream-visit` ×1 (line 6) — **pass** |
| 3 | `grep -ohE '`(F\|SC)-[a-z-]+`' <design Cite lines> \| sort -u` | both keys present, not judged indirectly only | `F-move-advice`, `F-puzzle-catalog`, `SC-puzzle-stream-visit` — **pass** |
| 4 | re-read `specs/playtest/traceability/story-protocol/design/index.md` | these rows no longer `none` | Row-level `none` table holds **1** row (`entities/pieces.md#PS1`, #703). Tally reads `41 rows = 40 judged + 1 none`. The shared paragraph states the two `F-puzzle-catalog` rows and the `SC-puzzle-stream-visit` row are judged by `PTD-puzzle-stream` — **pass** |

## Expected section, criterion by criterion

| Expected | Evidence |
|----------|----------|
| Each of the two rows is judged by at least one design protocol under the design judge rule | `PTD-puzzle-stream` Cites both keys with each row's full `Proves` set, under the row's own `Spec key` (`puzzle-stream.md:8`). No cross-key cite is claimed: `F-move-advice`'s `R1`–`R9` and `END.W1` stay distinct. |
| Extend `design/puzzle-stream.md` Cites and Steps/Pass where a judging step is missing | Steps S1–S10 drive the mode-pick entry and the dealt record's fields (`R`/`I`/`X`, `W1.1`/`W1.2`), recent-id skip, numeric widen, empty-solution and unreadable-catalog no-deal, wrong-move reset, reveal/abandon, leave; Pass rows P1–P3 cover all three rows' elements. |
| Actual: no Cites line names either key | On `400e288` `puzzle-stream.md:8` names both. |

## Scope check

Spec-only change: no `game/` file, asset, or catalog entry is in the merge diff, so no Design or UX protocol is in scope and no screenshot gate applies. No defect filed. No log or screenshot artifacts are expected beyond this record.
