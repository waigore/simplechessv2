# #655 implement pass, parallel id 1 — re-measured on `1cb3a5e`

Dispatched `issue-workflow-implement-agent` per `docs/issues/workflow-dispatch.md`. Status asserted `status:pending-implementation` on `type:defect`. Measured on a clean detached worktree of `origin/main` **`1cb3a5e`** with Godot `4.7.2.stable.official.ed1daf0bf`.

## What this pass adds that the previous ten did not

1. **Coverage measured for the first time.** Every earlier pass recorded "coverage not measured — `gdtoolkit==4.5.0` absent in this container". This pass installed it into a throwaway venv: **86.7% (4775/5508), threshold 80 — pass**.
2. **The blocker is verified to be a graph gap.** See [`gap-deploy-owner.md`](gap-deploy-owner.md).
3. **The published leg is re-read, not re-inherited.** `index.pck` is still `etag "6adcf171-91ff1c"`, 9568028 bytes, `last-modified` 2026-10-24 17:57:05 GMT — the artefact `review-20261025T022500Z` drove into a cold open that made zero catalog requests. Held is unavailable, so criterion 6 is a fail on a measured artefact.

## What did not move, and why

Every commit on this surface since `ce8a156` is docs-only. The probe output is byte-identical to `review-20261025-impl10/logs/x655-probe.log` and to both verification passes; see `logs/x655-probe.log`.

`game/session_router.gd:34-35` still initialises `advice_endpoint` and `advice_api_key` to `""`, and **no non-test assignment exists anywhere in `game/`** (`logs/criterion2-3-grep.log`). The refusal is `B5`'s empty-value guard, before any transport.

## Item 4 — the `C5`/`S1` leg, conforming for the eighth time

`game/puzzle_session.gd:534-535` sets `needs_puzzle = false` for `C5`, so the `has_open_puzzle()` guard at `:538` exempts it. The probe activates `C5` on the entered `S1`, sees `S2` with `confirm_kind=leave_confirm`, cancels back to `S1`, and walks the router to `mode-pick`. The repair clause does not fire, so **no `game/` change is owed and none is made**.

## Identity — stated rather than over-claimed

The probe boots `PuzzlePlayFlow` and a bare `SessionRouter`. It does construct a `PlaytestSeams` node with `playtest_override = 1`; this run captured only `x655_probe3.log`, which carries no `TEL.3` window id, so **none is claimed**. Build identity is `origin/main` `1cb3a5e` plus Godot `4.7.2.stable.official.ed1daf0bf`.

## Why this pass still writes no code

Criteria 2, 3 and 6 need a published client carrying a real `T9`/`T10` pair, and no owner exists for that step ([`gap-deploy-owner.md`](gap-deploy-owner.md)). A fourth implement dispatch before one happens measures the same legs a ninth time; this folder is the record that says so, with the measurement behind it rather than a re-reading of the previous one.
