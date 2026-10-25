# Manifest

- **Issue**: 655
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf`, `main` `80c27cc` plus this branch's three `game/` files (no `specs/` change), Web Playtest tree (`game/main.tscn`, seams live, `playtest_build=true`). `TEL.3` leg A `sess-1792889319637-48929-playtest-350148`, leg B `sess-1792889319868-48929-playtest-*` (`logs/accept655-probe.log`). No export ran — see *Published leg*.
- **Coverage mode**: `full` (critical IDs: none), intersected with #655's acceptance criteria. This run does not re-run #550's protocol set.
- **Judged under**: the #648 answer *catalog enabled in the release*, stated in `specs/technical/configuration.md` (`T9`/`T10` "ships set"; `B5` "Ships enabled in the release … every deal fails, `FAIL.T14`; Elo kept; log"), landed at `a9192a0` / `e19401f`.

## Results

Leg A is the shipped configuration (`T9`/`T10` unset, since #479 owns delivery); leg B sets only the pair, so the deal path reaches the resolver. The dealer is identical in both.

| Criterion | Result |
|-----------|--------|
| AC2 — `C2` enters `puzzle-play` (reproduction step 2) | pass |
| AC2 — `is_available()` true whenever the values are present | pass — leg B true; leg A false with the pair unset |
| AC2 — no refusal is the empty-value guard once present | pass — leg B reason `error`, not `unconfigured` |
| AC3 — one named outcome, neither inert | pass — leg A `X2`, reason `unconfigured`; leg B `X2`, reason `error` |
| AC3 — `GS.playerElo` unchanged | pass — 1000.00 → 1000.00 (session and document) |
| AC4 — `FAIL.T14` recorded | pass — Elo kept, no puzzle id, `last_failure` and log line `deal read failed (unconfigured)` |
| AC4 — no player-facing absence copy invented | held — `FAIL.T14`'s Effect column names none |
| AC5 — `C5` on `S1` raises `leave_confirm` | pass — `S1 → S2`, copy "Leave the puzzle stream?" |
| AC5 — Cancel returns to `S1` unchanged | pass — `stage=puzzle-play`, no deal, no pending confirm |
| AC5 — Confirm leaves | pass — `mode-pick`, nothing scored (`J-puzzle-session` B1) |
| AC6 — published-release rows | **held** — #479's delivery and a deployed route are unlanded |
| TEL.3 — build / session identity | pass — captured per leg |

`A655_PROBE pass` — 17 pass, 0 fail, 2 held.

Row changes for #550: [`rows.md`](rows.md).

## Published leg

Held, not failed: `game/session_router.gd` still starts `T9`/`T10` as `""` and the shipped path assigns neither, so a published build reaches only the absence outcome. #648's `specs/` sentence has landed; #479's client delivery has not. Under the issue's sequencing note the published rows wait for it.

## Paths

- [`notes.md`](notes.md)
- `probe/accept655_probe.gd` — both legs and every judgement
- `logs/accept655-probe.log`, `logs/import.log`, `logs/headless-smoke.log`
- `logs/unit-tests.log` — 32 passed; `logs/coverage.log` — 87.4% (4876/5580), threshold 80
- `logs/gdformat-check.log`, `logs/gdlint.log`, `logs/env.log`, `logs/spec-lint.log`

## Defects

- #655 — this run's subject: the absence leg is a recorded `FAIL.T14` outcome; the `C5`/`S1` conformance leg passes on `main`'s landed repair (`2e389b5`).
