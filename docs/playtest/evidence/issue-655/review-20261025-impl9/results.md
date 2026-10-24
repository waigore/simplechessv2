# Results — #655 re-run on `ce8a156`

Detail split out of [`manifest.md`](manifest.md); the row verdicts stay there.

**Judged under: catalog enabled in the published release.** Product-owner comment on
[#648, 2026-10-24T07:16:25Z](https://github.com/waigore/simplechessv2/issues/648#issuecomment-6381343549):
*"The puzzle catalog route ships enabled in the published release…"*

## Criterion 1 — the answer is in, the sentence is not

`git grep -n -i "ships enabled\|release status\|published release" origin/main -- specs/`
→ **no match** on `ce8a156` ([`logs/criterion1-grep.log`](logs/criterion1-grep.log)).
`specs/technical/configuration.md` `T9`/`T10` still read *"Set per deployment"* and `B5`
still only *"T9 or T10 missing: every deal fails (`FAIL.T14`); Elo kept; log"*.

The sentence this criterion asks for is [#648](https://github.com/waigore/simplechessv2/issues/648)'s
AC2 deliverable, and this defect's criterion 8 forbids writing it here. **Criterion 1
stays unmet.**

## Criteria 2–4 — measured, not inherited

- **C2 — fail.** `X655 B5 endpoint=<> key_set=false is_available=false`.
  `game/session_router.gd:33-34` still `""`; the only assignments in `game/` remain the
  test seam `advice_ui_test.gd`. The refusal never leaves the client, so no transport
  case of `FAIL.T14` is exercised.
- **C3 — fail.** `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>`
  — neither `K1` dealt nor `F-puzzle-catalog.X2` committed. The body calls this state a
  `fail` verbatim.
- **C4 — holds as an observable.** `GS.playerElo` 1000.00 before and after, no puzzle id
  set, `last_failure=<status>` on `PuzzleStream`, and
  `puzzle stream: deal read failed (status)` in the probe stdout. There is no `specs/`
  requirement for player-facing absence copy, and none is invented here.

## Criterion 5 — `C5` → `EX.confirm` → Cancel on the entered `S1` (pass)

```
X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true
X655 CANCEL state=S1 has_puzzle=false
X655 PROBE pass
X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true
X655 ROUTER_JOURNEY pass
```

Telemetry on the fresh `TEL.3` `sess-1792862240351-24968-playtest-190316`:
`puzzle.enter` (`J-puzzle-session.S1`) → `puzzle.confirm` (`leave_confirm`) →
`puzzle.leave` (`J-puzzle-session.S2`). The verdict lines are **byte-identical** to
[`../review-20261025-impl7/logs/x655-probe.log`](../review-20261025-impl7/logs/x655-probe.log),
so the `#694` repair (`2e389b5`) still holds and item 4's repair clause does not fire.

## Criterion 6 — published rows: **held**, and the condition is verified

The sequencing note holds when *"#648's sentence and #479's delivery decision are
unlanded"*. Both were checked live: **#648** is `pending-implementation` with no PR
anywhere and its sentence absent from `main`; **#479** is `pending-acceptance` with its
landing PR [#806](https://github.com/waigore/simplechessv2/pull/806) **open**, so its
ADR-0010 text is not on `main`.

So criterion 6 is **held** under the note, with the session id above. The published
artefact is byte-identical to `review-20261025-impl7`'s (see
[`logs/build-identity.txt`](logs/build-identity.txt)), and the following release runs
failed, so its published rows cannot differ. Detail: [`logs/published-leg.md`](logs/published-leg.md).

## Criteria 7–9

- **C7 — unchanged.** `docs/playtest/evidence/issue-550/headless-20261024T000000Z/manifest.md:8`
  still names #655 and the sweep has not re-run — see
  [`logs/finding-550.md`](logs/finding-550.md).
- **C8 — holds.** This pass adds only this folder.
- **C9 — holds.** No native edge to #332 / #333 / #335 added or implied.

## Build checks

- **Unit suite** — `GODOT_BIN=/opt/homebrew/bin/godot python3 .github/scripts/gdscript_tests.py test`
  → **30** headless tests pass (one more than `review-20261025-impl7`'s 29, from `#809`).
- **Import** — `godot --headless --path game --import --quit` → exit 0.
