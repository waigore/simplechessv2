# Acceptance checks — #703

Detail for the [acceptance manifest](manifest.md) of #703. Read from `origin/main` at `586bd7f`.

## Expected, criterion by criterion

| Expected | Evidence |
|----------|----------|
| A design protocol's **Cites** covers the identity and lifecycle elements | `specs/playtest/design/pieces-common.md:8` names `P1`–`P4`, `S1`–`S3`, and `Placement`. Element IDs verified to exist in `specs/design/entities/pieces.md`: `P1` color l.17, `P2` type l.18, `P3` origin l.19, `P4` has moved l.20, `S1` on board l.26, `S2` captured l.27, `S3` promoting l.28, `§Placement and availability` l.41 — no phantom IDs. |
| The covered elements are actually judged, not only listed | Every cited element is reached by a step in the same file (mentions: `P1` 4, `P2` 2, `P3` 2, `P4` 5, `S1` 5, `S2` 2, `S3` 4, `Placement` 3). S6 reads color/type/origin/on-board/moved-false on the orthodox opening; S7 the moved flag denying castling; S8 the moved flag denying the double step; S9 capture → `S2`, out of play; S10 promotion `S3` → `S1` as the chosen type; S11 orthodox `Placement`. |
| Outcomes recorded so a failing build is caught | Pass `P3`, and fail `F2` (blocks acceptance), state the identity/lifecycle outcomes: wrong color/type/origin/moved flag, a captured unit staying on the board, promotion resolving without a chosen type. |
| The issue's own steer — "most naturally `design/pieces-common.md`" | Delivered there; no new protocol created, matching the defect's premise that the row "is owned by an existing protocol's cite and needs no new protocol". |

## Map consistency across the six touched files

All paths are under `specs/playtest/traceability/`.

| File | Check | Result |
|------|-------|--------|
| `story-protocol/design/pieces-common.md` | `entities/pieces.md#PS1` present with element token `P1–P4, S1–S3, Placement`, judged by `pieces-common` | pass |
| `story-protocol/design/index.md` | 41 rows, `none` 0, tally `41 judged + 0 none` | pass |
| `story-protocol/protocols-design.md` | `pieces-common` cite quote and judged-row list updated; "one row no design protocol judges" note replaced by "no row-level `none` remains" | pass |
| `story-protocol/protocols.md` | protocol view `41 of 41 story rows`, `none` note dropped | pass |
| `story-protocol.md` | tally `Design 41 / 41 / 0`, total `75 / 60 / 15` | pass |

## Gates run in this session

| Check | Command | Result |
|-------|---------|--------|
| Spec lint | `python3 .github/scripts/spec_lint.py` | **pass** — 0 errors, 1 pre-existing warning (`specs/view/glossary.md:14`, 'Diagram' also defined in `specs/technical/glossary.md`), unrelated to this change |
| Cite correctness | new **Cites** IDs located in the owning spec | **pass** — all eight tokens exist in `specs/design/entities/pieces.md` |
| File budget | word count of the edited protocol | **pass** — 401 words (< 500) |
