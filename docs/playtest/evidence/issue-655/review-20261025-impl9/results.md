# Results — #655 re-run on `ce8a156`

Detail split out of [`manifest.md`](manifest.md); the row verdicts stay there.

Judged under **catalog enabled in the published release** — product-owner comment on
[#648, 2026-10-24T07:16:25Z](https://github.com/waigore/simplechessv2/issues/648#issuecomment-6381343549):
*"The puzzle catalog route ships enabled in the published release…"*

## Criterion 1 — unmet at measurement, satisfied mid-pass by `a94210d`

`git grep -n -i "ships enabled\|release status\|published release" origin/main -- specs/`
→ **no match** on the measured `ce8a156` ([`logs/criterion1-grep.log`](logs/criterion1-grep.log)).
`specs/technical/configuration.md` `T9`/`T10` still read *"Set per deployment"*, `B5`
only *"every deal fails (`FAIL.T14`); Elo kept; log"*.

**Then PR #815 merged as `a94210d` while this pass was open**, adding the sentence to
`specs/technical/components/catalog-service.md` (`R9`, line 23; line 56):

> Because the route ships enabled, a missing T9/T10 or an unreachable route on the
> published release is a deployment fault, never an accepted state.

So criterion 1 is **unmet on the measured commit and satisfiable from `a94210d`**; that
quote with its commit is what the issue asks a pass to record. Detail:
[`logs/landed-648.md`](logs/landed-648.md).

## Criteria 2–4 — measured, not inherited

- **C2 — fail.** `X655 B5 endpoint=<> key_set=false is_available=false`;
  `game/session_router.gd:33-34` still `""`. The refusal never leaves the client, so no
  transport case of `FAIL.T14` is exercised.
- **C3 — fail.** `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>`
  — neither `K1` dealt nor `F-puzzle-catalog.X2` committed. The body calls this state a
  `fail` verbatim.
- **C4 — holds as an observable.** `GS.playerElo` 1000.00 before and after, no puzzle id,
  `last_failure=<status>` on `PuzzleStream`, and the `deal read failed (status)` line in
  the probe stdout. No player-facing absence copy is required by `specs/`, and none is
  invented here.

## Criterion 5 — `C5` → `EX.confirm` → Cancel on the entered `S1` (pass)

```
X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true
X655 CANCEL state=S1 has_puzzle=false
X655 PROBE pass
X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true
X655 ROUTER_JOURNEY pass
```

Telemetry on `TEL.3` `sess-1792862240351-24968-playtest-190316`: `puzzle.enter`
(`S1`) → `puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`S2`). The verdict lines
are **byte-identical** to [`../review-20261025-impl7/logs/x655-probe.log`](../review-20261025-impl7/logs/x655-probe.log),
so the `#694` repair (`2e389b5`) still holds and item 4's repair clause does not fire.

## Criterion 6 — published rows: **held**, and the condition is verified

The sequencing note holds when *"#648's sentence and #479's delivery decision are
unlanded"*. At measurement neither was; **#648's sentence has since landed**
(`a94210d`), and **#479's has not** — PR
[#806](https://github.com/waigore/simplechessv2/pull/806) is still open, so its
ADR-0010 text is not on `main` and no published client carries the pair.

So criterion 6 is **held**, with only the #479 half of the condition remaining. The
published artefact is byte-identical to `review-20261025-impl7`'s and predates `a94210d`
(see [`logs/build-identity.txt`](logs/build-identity.txt) and
[`logs/published-leg.md`](logs/published-leg.md)).

## Criteria 7–9

- **C7 — unchanged.** `docs/playtest/evidence/issue-550/headless-20261024T000000Z/manifest.md:8`
  still names #655 and the sweep has not re-run — see
  [`logs/finding-550.md`](logs/finding-550.md).
- **C8 — holds.** This pass adds only this folder.
- **C9 — holds.** No native edge to #332 / #333 / #335 added or implied.

## Build checks

- **Unit suite** — `gdscript_tests.py test` → **30** headless tests pass (`impl7` had 29).
- **Import** — `godot --headless --path game --import --quit` → exit 0.
