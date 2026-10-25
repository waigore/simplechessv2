# Manifest — #655 branch re-run on `ddaca90` (2026-10-24 implement pass, parallel id 2)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: T9/T10 are unset (`type:defect`)
- **Disposition**: none claimed here; the proposal stands in [`../review-20261025T000000Z/disposition.md`](../review-20261025T000000Z/disposition.md), updated by [`finding-479.md`](finding-479.md). This folder is a re-measurement, not a new decision.
- **Environment**: `ENV.1` headless — Godot `4.7.2.stable.official.ed1daf0bf`. Published leg: HTTP identity read only.
- **Build / session id**: probe leg on a clean detached worktree of `origin/main` **`ddaca90`** ("Cover the wave-3 Advice copy in the +40% growth sweep (#804)"). `TEL.3` `sess-1792860958076-14788-playtest-192056`. Published artefact identity in [`logs/build-identity.txt`](logs/build-identity.txt).
- **Repeat count**: 1 probe leg, 1 unit-suite run.
- **Coverage mode**: `critical-only`.

## Results

| Row / protocol | Outcome | Evidence |
|---|---|---|
| Criterion 1 — a quoted `specs/` sentence stating the catalog route's release status | **unmet** | `git grep -n -i "ships enabled\|release status\|published release" origin/main -- specs/` → no match on `ddaca90`; `configuration.md` `T9`/`T10` still "Set per deployment", `B5` still only "every deal fails" |
| Criterion 2 — deal path reaches the resolver (no `B5` empty-value refusal) | **fail** | `X655 B5 endpoint=<> key_set=false is_available=false`; `game/session_router.gd:33-34` still `""` on `ddaca90` |
| Criterion 3 — one named outcome (`K1` dealt **or** `F-puzzle-catalog.X2` absence) | **fail** | `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>` |
| Criterion 4 — absence recorded as `FAIL.T14` | **holds as an observable** | `last_failure=<status>` plus the `puzzle stream: deal read failed (status)` line in the probe stdout; Elo 1000.00 before and after; no puzzle id |
| Criterion 5 — `C5` → `EX.confirm` → Cancel on the entered `S1` | **pass** | `X655 C5_ACTIVATED … confirm_kind=<leave_confirm> confirm_shown=true`, `X655 CANCEL state=S1 has_puzzle=false`, `X655 ROUTER … after_confirm=mode-pick flow_left=true`, plus `puzzle.confirm` / `puzzle.leave` on the same `TEL.3` |
| Criterion 6 — published rows, or held under the sequencing note | **held, under the sequencing note** | `index.pck` unchanged (`last-modified` 2026-10-24 13:00:58 GMT, 9561236 bytes) so the published rows cannot have moved; #648's sentence and #479's delivery are still unlanded on `main` |
| Criterion 7 — `#550` manifest rows | **unchanged** — the sweep has not re-run; its `Defects` line still names #655 | `docs/playtest/evidence/issue-550/headless-20261024T000000Z/manifest.md:8` |
| Criterion 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** — this pass adds only this folder | — |
| Criterion 9 — #332 / #333 / #335 relationship | **holds** — no native edge added or implied | — |
| Unit suite (`gdscript_tests.py test`) | **pass** — 29 headless tests | — |

Protocol verdicts on this build: `PTD-puzzle-stream` **fail** (K1), `PTU-puzzle-play` **fail** (US1), `PTU-puzzle-session` **pass** (S2–S3).

## Paths

- [`logs/x655-probe.log`](logs/x655-probe.log) — the probe's `X655` verdict lines
- [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log) — the same run's stdout, with the refusal warning and `TEL.1`–`TEL.5`
- [`logs/build-identity.txt`](logs/build-identity.txt) — published `index.pck` `last-modified` / length / `etag`
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the unchanged probe, for re-running
- [`notes.md`](notes.md) — what this run settles
- [`finding-479.md`](finding-479.md) — the new #479 finding and why it changes the disposition
