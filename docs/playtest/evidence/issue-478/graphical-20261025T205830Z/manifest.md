# Manifest — #478 wave-1 sweep, graphical run

- **Issue**: #478
- **Environment**: `graphical` (`ENV.2`) — macOS desktop window, Godot `4.7.2`
- **Build / session id**: `d34050f` (`origin/main`), `Web Playtest` scene `res://main.tscn`,
  Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session
  `sess-1792875416162-20580-playtest-580200`
- **Build source**: the same tree and commit as the
  [headless run](../headless-20261025T205500Z/manifest.md), run in-process with
  `godot --path game`. Same `Web Playtest` fallback, for the same AC 7 reason.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run — no timing row is judged here.
- **Coverage mode**: `full` — the nine UX wave-1 protocols, re-run graphically.
- **Story-row source**: `specs/playtest/traceability/story-protocol/protocols-ux.md`,
  read at `d34050f`. **20 distinct rows** (22 cells), all judged. The eight design
  protocols are headless-only.
- **`PTU-localization` `Cites` line**, verbatim from `specs/playtest/ux/localization.md:8`
  at `d34050f` — **Cites**: `UI-mode-pick.US1`, `LOC.US1`.
- **Screenshots**: **28** under [`screenshots/`](screenshots), numbered in run order.
- **Defects**: **#846** — `PTU-mode-pick` and `PTU-localization` fail on
  `screens/mode-pick-unavailable.md#US1`. Row-level `none`: **#788** for
  `localization.md#US2`.

## Results

**5 pass, 2 fail, 2 not-judged** over the nine UX protocols; **15 pass, 2 fail,
5 not-judged** over their 22 row cells. This leg judges `controls-point.md#US3`, which
headless cannot (pointing needs a display), so `PTU-controls` is `pass` here.

## Protocol verdicts

| Protocol | Verdict | Failed rows | Not-judged rows | Defects |
|---|---|---|---|---|
| `PTU-shared-session` | pass | — | — | — |
| `PTU-mode-pick` | **fail** | `mode-pick-unavailable.md#US1` | — | #846 |
| `PTU-shared-setup` | pass | — | — | — |
| `PTU-shared-play` | not-judged | — | `shared-play-place.md#US3`, `shared-play-unavailable.md#US4` | — |
| `PTU-shared-result` | pass | — | — | — |
| `PTU-controls` | pass | — | — | — |
| `PTU-navigation` | pass | — | — | — |
| `PTU-exceptions` | not-judged | — | `exceptions.md#US1`, `exceptions-play.md#US1` | — |
| `PTU-localization` | **fail** | `mode-pick-unavailable.md#US1` | `localization.md#US1` | #846 |

Both `not-judged` protocols carry the same crafted-position gaps as the headless leg.

## Story rows

One row per cited story row, with its outcome, reason, and screenshot numbers:
**[rows-ux.md](rows-ux.md)**.

## Row-level `none`

| Story row | Outcome | Reason |
|---|---|---|
| `localization.md#US2` | none — out of playtest scope | [#788](https://github.com/waigore/simplechessv2/issues/788) |

## AC 8 — art opened at run time

From `logs/static.json` (`TEL.*` `report.assets`), read before protocol step 1: `boot`
**11 of 11 opened**, `play` **19 of 19 opened**, unresolved **0** in both;
`boot_outcome` `0`, `session_playable` `true`, `log_counts` `{}`. Identical to the
headless run, so both legs judged the same rendered surface.

## Screenshots

**28** images in [`screenshots/`](screenshots), numbered in run order; what each shows
is in [shots.md](shots.md).

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson),
  [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json)
- Driver: [`logs/w400_sweep.gd`](logs/w400_sweep.gd)
- Notes: [`notes.md`](notes.md)
- Screenshots: [`screenshots/`](screenshots)
