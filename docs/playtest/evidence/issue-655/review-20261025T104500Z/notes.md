# Notes — #655 implementation re-run #11 on `6a969ee`

Detail for [`manifest.md`](manifest.md). Every line below is measured on a clean detached
worktree of `origin/main` `6a969ee`; the probe is carried over unchanged from
`review-20261025-impl10`. This pass wrote no `game/`, `specs/`, `asset_catalog/`, or
`game_assets/` file.

## What moved since the verify fail on `8af7f8f`

| Item | On `8af7f8f` | On `6a969ee` |
|---|---|---|
| Criterion 1 sentences | present (`a9192a0`, `a94210d`) | present |
| `game/session_router.gd:33-34` | `""` | `""` — unchanged |
| Probe output | identical | **byte-identical** |
| #479 delivery decision (PR #806) | **open** | **merged `f07eed6`** |
| Published `index.pck` | `"6adcf171-91ff1c"` | `"6adcf171-91ff1c"` — no release since |

`origin/main` moved by docs-only commits (`ffb2b39` #768 wiring, `1894f31` #546 record,
`f07eed6` #479 record, `6a969ee` #478 record). None touches the deal path.

## Criteria 2, 3 and 6 stay the defect's live symptom

- **2** `is_available()` is false because both values are empty. The only assignment
  anywhere in `game/` is the test seam `game/advice_ui_test.gd:40-41`.
- **3** The stream enters `S1` with nothing dealt, no puzzle id, `last_failure=<status>` —
  neither `K1` nor a committed `F-puzzle-catalog.X2`.
- **6** The published `index.pck` is unchanged since `review-20261025T022500Z` measured a
  zero-catalog-request cold open; it still refuses inside `B5`'s empty-value guard before any
  transport, the state `configuration.md` `B5` calls *"a deployment fault, not accepted"*.

Criterion 6's held clause is spent and the fix belongs to a deploy-path decision; see
[`held.md`](held.md). Criteria 1, 4, 5, 7, 8 and 9 hold; see [`verdicts.md`](verdicts.md).
