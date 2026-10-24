# Notes — #655 implementation re-run #10 on `5c15e80`

Detail for [`manifest.md`](manifest.md). Every line below is measured on a clean detached
worktree of `origin/main` `5c15e80`; nothing is inherited from an earlier folder except the
probe script, which is copied unchanged from `review-20261025-impl9`.

## What moved since the verify fail on `4f133e8`

| Item | On `4f133e8` | On `5c15e80` |
|---|---|---|
| Criterion 1 sentence | present (`a94210d`) | present |
| `game/session_router.gd:33-34` | `""` | `""` — unchanged |
| Probe output | identical | **byte-identical** |
| Published artefact | `"6adcf171-91ff1c"` | `"6adcf171-91ff1c"` — no release since |
| Probe harness for this defect | none new | none new |

`origin/main` moved by docs-only commits (`e20854f` verify record, `5c15e80` #753 record).
None touches the deal path.

## Criteria 2, 3 and 6 stay the defect's live symptom

- **2** `CatalogDealClient.is_available()` is false because both values are empty:
  `X655 B5 endpoint=<> key_set=false is_available=false`. The only assignment anywhere in
  `game/` is the test seam `game/advice_ui_test.gd:40-41`.
- **3** The stream enters `S1` with nothing dealt, no puzzle id, and `last_failure=<status>`
  — neither `K1` nor a committed `F-puzzle-catalog.X2` verdict. The body calls this a `fail`
  verbatim.
- **6** `R9` states a missing `T9`/`T10` on the published release is *"a deployment fault,
  never an accepted state"*. The published `index.pck` is unchanged since
  `review-20261025T022500Z` measured a zero-catalog-request cold open, so it cannot have
  moved. No release has happened since.

## Criteria that hold

- **1** — `R9` and the failure paragraph are on `main` at `a94210d`; quoted in
  [`logs/landed-648.md`](logs/landed-648.md) with its commit.
- **4** — the absence is observable exactly as the body defines it: Elo `1000.00` unchanged,
  no puzzle id, `PuzzleStream.last_failure` holds `<status>`, and the run log carries
  `WARNING: puzzle stream: deal read failed (status)` twice. No player-facing absence copy
  is required by `specs/`, and none is invented here.
- **5** — `C5` → `EX.confirm` (`leave_confirm`) → Cancel back to `S1`, and the router journey
  `mode-pick` → `puzzle-play` → confirm → `mode-pick`, both `pass`. `TEL.3`
  `sess-1792868748148-67330-playtest-215430` carries `puzzle.enter` → `puzzle.confirm`
  (`J-puzzle-session.S1`) → `puzzle.leave` (`J-puzzle-session.S2`). The item-4 repair clause
  does not fire, so no `game/` change is owed.
- **7** — the `#550` sweep has not re-run; its `Defects` line still names #655.
- **8**, **9** — this folder adds no `specs/`, asset, or `game/` change and implies no edge.

## Why this pass writes no code

Item 4 is the only `game/` change this defect may own, and it measures conforming for the
sixth time (repaired in #694, merge `2e389b5`). Criteria 2, 3 and 6 need a published client
carrying a real `T9`/`T10` pair, which is the deploy path:

- #479 (`status:pending-acceptance`) records client delivery as the **deploy path** and
  names no mechanism in `specs/`; its PR #806 is **open**.
- The deploy-path task that would put a real pair into the published client still does not
  exist in the graph.

## Harness limit

Coverage was not measured: `gdtoolkit==4.5.0` is absent in this container, so
`gdscript_tests.py coverage` exits before running. The unit suite itself is green (31/31).
