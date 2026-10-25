# Verdicts — #655 re-run #11, criteria that hold

Detail for [`manifest.md`](manifest.md). Measured on a clean detached worktree of
`origin/main` `6a969ee`, probe carried over unchanged from `review-20261025-impl10`.

## Criterion 1 — the quoted release-status sentence

The catalog is judged under the **release** branch. Two sentences say so, both ancestors of
`origin/main` ([`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log)):

- `specs/technical/configuration.md:43` (`B5`), landed `a9192a0` (PR #822).
- `specs/technical/components/catalog-service.md:56`, landed `a94210d` (PR #815).

`B5` calls a missing `T9`/`T10` on the published release *"a deployment fault, not
accepted"*. The release is in exactly that state (criterion 6, [`held.md`](held.md)).

## Criterion 4 — absence is observable

Elo `1000.00` before and after, no puzzle id, `PuzzleStream.last_failure` holds `<status>`,
and the run log carries `WARNING: puzzle stream: deal read failed (status)` twice
([`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log)). No player-facing absence copy is
required by `specs/`, and none is invented here.

## Criterion 5 — leave-confirm journey, and item-4 attribution

`C5` → `EX.confirm` (`leave_confirm`) → Cancel returns to `S1`; the router journey
`mode-pick` → `puzzle-play` → confirm → `mode-pick` both report pass. `TEL.3`
`sess-1792873135319-1941-playtest-242597` carries `puzzle.enter` (`J-puzzle-session.S1`) →
`puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`J-puzzle-session.S2`).

Item 4 is the only `game/` change this defect may own, and it measures conforming:
`game/puzzle_session.gd:554` sets `needs_puzzle = false` for `C5`, so the
`has_open_puzzle()` guard (line 557) does not apply. `git blame` on `origin/main` attributes
both lines to **#694**, merge `2e389b5` ([`logs/c5-attribution.log`](logs/c5-attribution.log)).
The repair clause does not fire; no `game/` change is owed.

## Criteria 7, 8 and 9

- **7** — the `#550` sweep has not re-run; its `Defects` line still names #655
  ([`logs/published-and-550.log`](logs/published-and-550.log)).
- **8** — this folder adds no `specs/`, `asset_catalog/`, `game_assets/`, or `game/` change.
- **9** — no native edge to #332 / #333 / #335 is added or implied.

## Harness limit

Coverage was not measured: `gdtoolkit==4.5.0` is absent in this container, so
`gdscript_tests.py coverage` exits before running. The unit suite itself is green (32/32).
