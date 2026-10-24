# Manifest — #478 wave-1 sweep, headless run

- **Issue**: #478
- **Environment**: `headless` (`ENV.1`)
- **Build / session id**: `d34050f` (`origin/main`), `Web Playtest` scene `res://main.tscn`,
  Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session
  `sess-1792875151541-18199-playtest-504265`
- **Build source**: the `d34050f` tree run in-process with `godot --headless --path game`.
  The `procedures.md` fallback, not a published reading: ADR-0009 publishes the seam-free
  `Web Release` only, and AC 7 needs `DBG.*` / `TEL.*`.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run — no timing row is judged here.
- **Coverage mode**: `full` — eight design and nine UX wave-1 protocols.
- **Story-row source**: `specs/playtest/traceability/story-protocol/protocols.md` and its
  `protocols-design.md` / `protocols-ux.md` halves at `d34050f`; no row re-derived from a
  `Cites` line. **50 distinct rows** (52 cells), all judged.
- **`PTU-localization` `Cites` line**, verbatim from `specs/playtest/ux/localization.md:8`
  at `d34050f` — **Cites**: `UI-mode-pick.US1`, `LOC.US1`.
- **Screenshots**: none — headless run; see the
  [graphical run](../graphical-20261025T205830Z/manifest.md).
- **Defects**: **#846** — `PTU-mode-pick` and `PTU-localization` fail on
  `screens/mode-pick-unavailable.md#US1`. Row-level `none`: **#788** for
  `localization.md#US2`.

## Results

**5 pass, 2 fail, 10 not-judged** over the seventeen protocols; **36 pass, 2 fail,
14 not-judged** over their row cells. A protocol is `pass` only when every cited story
passes, `fail` if any fails, `not-judged` if any is (`evidence.md`).

## Protocol verdicts

**Design**: `PTD-game-state` pass; `PTD-shared-game`, `PTD-mode-and-config`,
`PTD-end-conditions`, `PTD-pieces-common`, `PTD-pieces-king`, `PTD-pieces-officers`,
`PTD-pieces-pawn` not-judged.

**UX**: `PTU-shared-session`, `PTU-shared-setup`, `PTU-shared-result`,
`PTU-navigation` pass; `PTU-mode-pick` **fail** (#846), `PTU-localization` **fail**
(#846); `PTU-shared-play`, `PTU-controls`, `PTU-exceptions` not-judged. `PTU-controls`
is `not-judged` here because pointing needs a display; the graphical run judges it.

Per-protocol failed and not-judged rows: [rows-design.md](rows-design.md) and
[rows-ux.md](rows-ux.md).

## Story rows

One row per cited story row, with its outcome and every `not-judged` reason:

- **[rows-design.md](rows-design.md)** — the eight design protocols
- **[rows-ux.md](rows-ux.md)** — the nine UX protocols

## Row-level `none`

| Story row | Outcome | Reason |
|---|---|---|
| `localization.md#US2` | none — out of playtest scope | [#788](https://github.com/waigore/simplechessv2/issues/788) |

## AC 8 — art opened at run time

From `logs/static.json` (`TEL.*` `report.assets`), read before protocol step 1, not from
the source tree: `boot` **11 of 11 opened**, `play` **19 of 19 opened**, unresolved
**0** in both; `boot_outcome` `0`, `session_playable` `true`, `log_counts` `{}`. Every
asset the piece and board rows depend on opened, so those rows are judged on what
rendered. Resolved IDs: `logs/static.json` → `resolved_ids`.

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson),
  [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json)
- Driver: [`logs/w400_sweep.gd`](logs/w400_sweep.gd)
- Notes: [`notes.md`](notes.md)
- Screenshots: none — waiting on the [graphical run](../graphical-20261025T205830Z/manifest.md)
