# Manifest — #655 independent verification (2026-10-25T20:58Z, parallel id 1)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Role**: verification pass. Nothing here is an implementation claim; every row was measured on the build named below, not read off an implement comment.
- **Environment**: `headless` (`ENV.1`).
- **Build / session id**: clean detached worktree of `origin/main` **`906b8b3`** ("Record the #655 re-run on 6a969ee (#655 impl11, held spent) (#841)"), Godot `4.7.2.stable.official.ed1daf0bf`; **`TEL.3` `sess-1792874090554-8369-playtest-239729`**.
- **Deliverable under verification**: PR [#841](https://github.com/waigore/simplechessv2/pull/841) — **merged as `906b8b3`**, folder `docs/playtest/evidence/issue-655/review-20261025T104500Z/`. The deliverable exists on the verified tree (§ *Deliverable present* below).
- **Published artefact** (read, not driven this pass): `index.pck` `last-modified: Sat, 24 Oct 2026 17:57:05 GMT`, `content-length: 9568028`, `etag: "6adcf171-91ff1c"` — unchanged since `review-20261025T022500Z` drove it.
- **Coverage mode**: `critical-only`.
- **Repeat count**: 1 probe run, 1 import, 1 unit-suite run, 1 coverage attempt.

## Deliverable present

`git log --oneline -1 906b8b3` → the impl11 folder is on the verified commit; `ls docs/playtest/evidence/issue-655/` on `906b8b3` contains `review-20261025T104500Z`. Both earlier verification fails on this issue were about a record living only in a comment or only on an unmerged branch; that ground is gone and is **not** a reason for this verdict.

## Results

One row per criterion, with the deliverable and scope checks, in [`criteria.md`](criteria.md).

## Probe output (my run on `906b8b3`)

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

Byte-identical (`md5 399c0d171b70bf43a3ca98505ae91335`) to `review-20261025-impl10/logs/x655-probe.log` and to the verify pass on `8af7f8f`. The issue's own probe was run **unchanged**.

## Paths

- [`logs/x655-probe.log`](logs/x655-probe.log) — probe verdict lines
- [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log) — same run's stdout (`TEL.1`–`TEL.5`, both refusal backtraces)
- [`logs/criterion1-grep.log`](logs/criterion1-grep.log) — build identity, the two criterion-1 sentences, their landing commits and ancestry
- [`logs/criterion2-5-code.log`](logs/criterion2-5-code.log) — the empty `T9`/`T10` defaults and the only assignments in `game/`; the `C5` gate in `puzzle_session.gd:522-542`
- [`logs/published-and-550.log`](logs/published-and-550.log) — published artefact identity and the `#550` manifest rows
- [`logs/c5-attribution.log`](logs/c5-attribution.log) — `puzzle_session.gd` provenance
- [`logs/unit-tests.log`](logs/unit-tests.log), [`logs/coverage.log`](logs/coverage.log)
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the unchanged probe carried from `review-20261025-impl10`
- [`notes.md`](notes.md) — what moved, what did not, and what this pass cannot close
- Screenshots: **none** — headless-only run; published-build captures live in [`../review-20261025T022500Z/screenshots/`](../review-20261025T022500Z/screenshots/)

Protocols on this build: `PTD-puzzle-stream` **fail** (K1), `PTU-puzzle-play` **fail** (US1), `PTU-puzzle-session` **pass** (S2–S3).
