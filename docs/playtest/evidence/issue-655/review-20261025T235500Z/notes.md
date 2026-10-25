# Notes — `review-20261025T235500Z`

Implement dispatch, parallel id 1, unattended, 2026-10-25. `status:pending-implementation` on `type:defect` (#655) asserted before any measurement.

## Where

A clean **detached worktree** of `origin/main` **`161b4a9`** (`git worktree add --detach`). The primary checkout was not used — it carries another agent's in-flight edits. One import (`--import --quit`, exit 0), then every command below on that tree. `TEL.3` `sess-1792880244915-63772-playtest-242939`; the probe is `probe/x655_confirm_probe.gd`, `md5 326b60bad50803a46896151661b815da`, unchanged.

## The measurement

```
X655 B5 endpoint=<> key_set=false is_available=false
X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>
X655 PANEL_C5_GATE=true
X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true
X655 CANCEL state=S1 has_puzzle=false
X655_PROBE pass
X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true
X655 ROUTER_JOURNEY pass
```

Telemetry: `puzzle.enter` (`J-puzzle-session.S1`) → `puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`J-puzzle-session.S2`). The log carries `puzzle stream: deal read failed (status)` twice — from the bare `PuzzlePlayFlow` and from the router's `C2` entry at `session_router.gd:756`. Source for each criterion is quoted in [`criteria.md`](criteria.md).

## Criterion by criterion

**1 — pass.** Under #648's answer *catalog enabled in the release*: `configuration.md:43` (`B5`) and `catalog-service.md:56`, both at **`e19401f`**. Quoted in the issue comment. The posture contradiction this pass found is in [`posture-conflict.md`](posture-conflict.md).

**2 — fail.** `is_available=false`; `session_router.gd:33-34` still `""`; only `advice_ui_test.gd:40-41` assigns either; `:552` guards on emptiness and `:756` hands the empty pair on. No release-pipeline step can set them (`logs/release-workflow-check.log`).

**3 — fail.** `S1`, `has_puzzle=false`, no puzzle id, and no machinery commits the `F-puzzle-catalog.X2` absence as a delivered outcome.

**4 — holds as an observable.** `elo=1000.00` unchanged, `pid=<>`, `last_failure=<status>`, and the log line is in the run's window. No player-facing copy required, none invented.

**5 — pass.** `S1 → S2 (leave_confirm) → S1` and the router journey `mode-pick → puzzle-play → confirm → mode-pick`. The probe activated `C5`; the repair clause does not fire.

**6 — fail, not held.** Both spec halves persist at `e19401f`; the published artefact is unchanged since 2026-10-24T17:57:05Z (`etag "6adcf171-91ff1c"`, deployment `7302318984` at `c5b8189b`). See [`gap-delivery-owner.md`](gap-delivery-owner.md).

**7 — holds, unchanged.** #550's sweep has not re-run; its manifest `Defects` line still names #655. **8 — holds.** Only this folder is added. **9 — holds.** No edge to #332/#333/#335.

Suite **32/32**; coverage **86.7% (4797/5531)** ≥ 80; `spec_lint` 0 errors, 1 pre-existing warning.

## What is not claimed

- The published build was **not driven** this run; its identity is a live read, and the drive on this same unchanged artefact is cited by folder name.
- No `game/` repair is owed (item 4 conforms for the tenth time). No `specs/`, asset, or native-edge change. No `priority:*` label touched.
- `held` is **not** claimed for criterion 6. The posture conflict is named, not adjudicated.
