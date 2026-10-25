# Review notes — #655

The puzzle stream's first deal, re-run on `main` `80c27cc` + this branch, headless `ENV.1`, Godot `4.7.2.stable.official.ed1daf0bf`. Manifest: [`manifest.md`](manifest.md).

## What the run shows

**Leg A, shipped configuration.** `T9`/`T10` are `""` before anything assigns them (`game/session_router.gd:33-34`) and the shipped path assigns neither. `C2` enters `puzzle-play`, the first read refuses, and the outcome is the spec's designed one: nothing dealt, no puzzle id, `GS.playerElo` unchanged, reason on `PuzzleStream.last_failure` and in the log — `F-puzzle-catalog.X2` and `FAIL.T14`'s own items.

**Leg B, only the pair set.** `is_available()` is then true and the deal path reaches the resolver; the read fails in transport (`error`), a read the client actually sent, not the empty-value guard.

**Item 4, `C5` on `S1`.** Already conforming on `main`: `2e389b5` repaired `request_confirm` so `C5` no longer needs an open puzzle. Confirmed by driving the router's `puzzle-play` control path. **No repair was owed.**

## The one `game/` change

`request()` refused an unset pair with `REASON_STATUS` — the same reason a sent read answered non-200 reports (#550's log: `deal read failed (status)` at `request`). Criterion 2 forbids exactly that conflation, so the run could not judge it.

`CatalogWireReader.REASON_UNCONFIGURED = "unconfigured"` is added; `PuzzleStream.request()` returns it for the guard. Nothing else changes. `CTR-puzzle-catalog-read` O2 names no reason vocabulary and `FAIL.T14`'s Effect column names no reason, so this is a client-internal label, not a contract value: no spec text changes. `puzzle_stream_test` gains `_check_unset_values_are_not_a_sent_read`.

## Limits, stated plainly

- **No real deal was observed.** This proves the absence outcome and the resolver reach, never `K1` with a live record; that needs a deployed route and #479's delivery. This defect allows either named outcome; the one taken is the absence one.
- **The published leg is held**, not failed, under the issue's sequencing note.
- **The seam peer never answers.** `_puzzle_sim_factory` supplies `FakeCatalogTransport`, whose `poll()` is `[]` until a record is pushed, so a playtest read stays in flight. Leg B retires that read and re-requests against a peer answering with a transport failure — the #528 drive's and #550's own crosscheck's pattern. A testability observation, not a shipped-path failure; no defect filed.
- **`ENV.TEL.3` in #550's probe now fails on `main`**: ids end `-playtest-<usec>` (`game/playtest_seams.gd:436-442`), so its `endswith("-playtest")` check is stale. #550's probe, outside #655; named here, not fixed.

## Checks

Import, smoke, 32 unit tests, 87.4% coverage (threshold 80), `gdformat --check` and `gdlint` clean — in `logs/`.

`spec_lint` errors all sit outside this change: `docs/accessibility/issue-640` and `docs/playtest/evidence/issue-878` are untracked, and `issue-627` is tracked here but absent from `origin/main` — all three from other work in this working tree (see the `627-agent-strand: prior run leftovers` stash). No `issue-655` file is flagged.

`specs/`, `asset_catalog/`, `game_assets/`: unchanged. No native edge to #332/#333/#335 is added or implied.
