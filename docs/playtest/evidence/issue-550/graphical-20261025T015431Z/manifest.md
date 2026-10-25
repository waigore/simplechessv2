# Manifest — #550 wave-2 sweep, graphical run

- **Issue**: #550 (Wave 2 — Adaptive Puzzle stream)
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: `26b07af` (`origin/main`, 2026-10-25), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session `sess-1792893281479-94581-playtest-643849`
- **Build source**: the `26b07af` tree run in-process from a detached worktree (`godot --path --path game`) — the [`procedures.md`](../../../specs/playtest/procedures.md) fallback, not a published reading: ADR-0009 publishes the seam-free `Web Release` only, and this sweep needs `DBG.*` / `TEL.*`. Both folders name the same commit.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run — no timing row is judged here; the one `SIT.6` step (`PTU-mode-pick` S6) reads text size, not frame time.
- **Coverage mode**: `full`, intersected with #550's scope: the 7 UX protocols. Design protocols are headless only; the 7 UX protocols run in both environments. No view story is in the set.
- **Story-row source**: [`protocols-design.md`](../../../specs/playtest/traceability/story-protocol/protocols-design.md) and [`protocols-ux.md`](../../../specs/playtest/traceability/story-protocol/protocols-ux.md) at `26b07af`; no row re-derived from a protocol's `Cites` line. **18 rows**: 18 UX.
- **`PTU-localization` `Cites` line**, verbatim from `specs/playtest/ux/localization.md` at `26b07af`: **Cites**: `UI-mode-pick.US1`, `LOC.US1`.
- **Screenshots**: `screenshots/` — 36 images, listed in `notes.md`.
- **Driver**: [`logs/w550_sweep.gd`](logs/w550_sweep.gd) — kept with the run so the readings can be reproduced. It is the #400 sweep driver (`logs/w400_sweep.gd`), with the wave-2 changes `notes.md` §Driver lists.
- **Defects**: none filed — no story row failed. The shipped-path deal is #655 / #892's, not this run's finding.

## Results

**18 rows** — 14 pass, 0 fail, 4 not-judged. **7 protocols** — 4 pass, 0 fail, 3 not-judged. A protocol is `pass` only when every cited story passes, `fail` if any fails, `not-judged` if any is ([`evidence.md`](../../../specs/playtest/evidence.md)).

## Protocol verdicts

- **Design** (headless only): not judged in this run — design protocols are headless (`playtest.md` §Levels); the headless folder records their eight verdicts.
- **UX**: 4 pass, 3 not-judged, 0 fail — pass: `PTU-puzzle-session`, `PTU-mode-pick`, `PTU-navigation`, `PTU-controls`. Not-judged: `PTU-puzzle-play`, `PTU-exceptions`, `PTU-localization`.

## Results by protocol

| Protocol | Verdict | Rows | pass | fail | not-judged |
|---|---|---|---|---|---|
| `PTU-puzzle-session` | **pass** | 1 | 1 | 0 | 0 |
| `PTU-puzzle-play` | **not-judged** | 5 | 4 | 0 | 1 |
| `PTU-mode-pick` | **pass** | 2 | 2 | 0 | 0 |
| `PTU-navigation` | **pass** | 2 | 2 | 0 | 0 |
| `PTU-controls` | **pass** | 3 | 3 | 0 | 0 |
| `PTU-exceptions` | **not-judged** | 2 | 0 | 0 | 2 |
| `PTU-localization` | **not-judged** | 3 | 2 | 0 | 1 |

## Story rows

One file per protocol, one row per story row the map lists:

- **`PTU-puzzle-session`** — [rows-puzzle-session.md](rows-puzzle-session.md)
- **`PTU-puzzle-play`** — [rows-puzzle-play.md](rows-puzzle-play.md)
- **`PTU-mode-pick`** — [rows-mode-pick.md](rows-mode-pick.md)
- **`PTU-navigation`** — [rows-navigation.md](rows-navigation.md)
- **`PTU-controls`** — [rows-controls.md](rows-controls.md)
- **`PTU-exceptions`** — [rows-exceptions.md](rows-exceptions.md)
- **`PTU-localization`** — [rows-localization.md](rows-localization.md)

## `not-judged` rows and their reasons

| Story row | Protocol | Why it is `not-judged` |
|---|---|---|
| `screens/puzzle-play-place.md#US3` | `puzzle-play` | `US3.13` promotion and `US3.14` the lapsed confirm need a last-rank pawn; no reachable deal offers one and the build offers no position seam. |
| `exceptions.md#US1` | `exceptions` | `US1.6` needs a non-touch Web device (unsupported input), which neither environment is; the other cells of the row are judged. |
| `exceptions-play.md#US1` | `exceptions` | `US1.8`/`US1.9` promotion needs a crafted position; the other cells of the row are judged. |
| `localization.md#US1` | `localization` | `LOC.US1.1` (key names) is a spec review, not a run state, per `specs/playtest/ux/localization.md` §Evidence; the protocol reads `LOC.US1` as its three scenarios, so the row stays `not-judged` while `LOC.US1.2`/`LOC.US1.3` pass. |

## Row-level `none`

| Story row | Recorded | Linked defect |
|---|---|---|
| `localization.md#US2` | none — `LOC.US2` is out of playtest scope; judged by spec read | [#788](https://github.com/waigore/simplechessv2/issues/788) |

Every design row is judged on the map, so the design run records no row-level `none`.

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson), [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json), [`logs/w550_sweep.gd`](logs/w550_sweep.gd)
- Notes: [`notes.md`](notes.md)
- Screenshots: [`screenshots/`](screenshots/) — 36 images.
