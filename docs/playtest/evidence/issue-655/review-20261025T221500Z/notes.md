# Notes — `review-20261025T221500Z`

Implement dispatch, parallel id 1, unattended, 2026-10-25. `status:pending-implementation` on `type:defect` (#655) asserted before any measurement.

## Where

A clean **detached worktree** of `origin/main` **`5d80029`** (`git worktree add --detach`). The primary checkout was not used — it carries another agent's in-flight edits. One import (`--import --quit`, exit 0), then every command below on that tree. `TEL.3` `sess-1792877959388-40808-playtest-309342`; the probe file is `probe/x655_confirm_probe.gd`, carried unchanged from `impl10` (`md5 326b60bad50803a46896151661b815da`) so the comparison is the same instrument on a new commit.

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

Telemetry: `puzzle.enter` (`J-puzzle-session.S1`) → `puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`J-puzzle-session.S2`). The log carries `puzzle stream: deal read failed (status)` twice — from the bare `PuzzlePlayFlow` and from the router's `C2` entry at `session_router.gd:756`.

## Criterion by criterion

**1 — pass.** Under the #648 answer *catalog enabled in the release*: `configuration.md:43` (`B5`, **`a9192a0`**) and `catalog-service.md:56` (**`a94210d`**), both ancestors of `5d80029`.

**2 — fail.** `is_available=false`; `session_router.gd:33-34` still `""`; the only assignments in `game/` are the test seam `advice_ui_test.gd:40-41`; `:552` reads availability, `:756` hands the empty pair to `puzzle_flow.enter`.

**3 — fail.** `S1`, `has_puzzle=false`, no puzzle id, no committed absence branch — which the body calls a `fail` verbatim.

**4 — holds as an observable.** `elo=1000.00` unchanged, `pid=<>`, `last_failure=<status>` plus the log line. No player-facing absence copy is required by `specs/`, and none was invented.

**5 — pass.** `S1 → S2 (leave_confirm) → S1`, and the router journey `mode-pick → puzzle-play → confirm → mode-pick`. `game/puzzle_session.gd:518-521` documents the exemption; `git log -S'needs_puzzle = false'` places it on #694 (`2e389b5`). The repair clause does not fire.

**6 — fail, not held.** Both halves landed (`a9192a0`, `a94210d`, `f07eed6`). The published artefact is unchanged — `etag "6adcf171-91ff1c"`, 9,568,028 bytes, deployment `7302318984` at `c5b8189b` — and the release pipeline has no step that could set the values. See [`gap-delivery-owner.md`](gap-delivery-owner.md).

**7 — holds, unchanged.** #550's sweep has not re-run; its manifest `Defects` line still names #655.

**8 — holds.** Only this folder is added. **9 — holds.** No edge to #332/#333/#335.

Suite **32/32**; coverage **86.7% (4797/5531)** ≥ 80 with `gdtoolkit==4.5.0`.

## What is not claimed

- The published build was **not driven** this run; its identity is a live read, and the drive on this same unchanged artefact is cited by folder name.
- No `game/` repair is owed (item 4 conforms for the ninth time). No `specs/`, asset, or native-edge change. No `priority:*` label touched.
