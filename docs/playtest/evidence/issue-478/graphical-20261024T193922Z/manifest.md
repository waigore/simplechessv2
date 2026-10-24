# Manifest

- **Issue**: 478
- **Environment**: graphical (`ENV.2`)
- **Build / session id**: `8cdfd45a1f1d7c1726244437a0d4277c6edd9e6c`, `Web Playtest` export, `Godot 4.7.2.stable.official.ed1daf0bf`, pck sha256 `17a820b6b42ca261780110b01b1eb804b6f03a51415705317d5b44565eb75550`; `TEL.3` session `sess-20261025-478-wave1-playtest`
- **Build source**: local `Web Playtest` export into `build/web/`
  (`web_export.py --preset "Web Playtest"`). A `procedures.md` fallback, not a
  published reading: ADR-0009 publishes only the seam-free `Web Release` build,
  and AC 7 needs the `DBG.*`/`TEL.*` surface, so no published URL serves this
  preset at this commit.
- **Coverage mode**: `full`
- **Protocols**: the nine wave-1 UX protocols, re-run graphically on the same build
- **Story-row source**: `specs/playtest/traceability/story-protocol/protocols.md`
  and its `protocols-design.md` / `protocols-ux.md` halves. No row was
  re-derived from a protocol `Cites` line.
- **Screenshots**: present under `screenshots/` (11 images)
- **Defects**: #833 — filed from this sweep; no story verdict changed
  ([notes.md](notes.md)).

## Results

**18 pass, 0 fail, 2
not-judged** over 20 story rows (95 passing and
2 not-judged scenario checks). A protocol is `pass` only
when every cited story passes, `fail` if any fails, `not-judged` if any is
`not-judged` (`evidence.md`).

| Protocol | Verdict | Failed rows | Not-judged rows |
|---|---|---|---|
| `PTU-shared-session` | pass | — | — |
| `PTU-mode-pick` | pass | — | — |
| `PTU-shared-setup` | pass | — | — |
| `PTU-shared-play` | pass | — | — |
| `PTU-shared-result` | pass | — | — |
| `PTU-controls` | not-judged | — | `controls-point.md#US3` |
| `PTU-navigation` | pass | — | — |
| `PTU-exceptions` | pass | — | — |
| `PTU-localization` | not-judged | — | `localization.md#US1` |

## Story rows

One row per story row this run judges, with outcome and screenshot: **[rows.md](rows.md)**.

## Row-level `none`

| Story row | Outcome | Reason |
|---|---|---|
| `localization.md#US2` | none — out of playtest scope | [#788](https://github.com/waigore/simplechessv2/issues/788) |

## AC 8 — art resolved at run time

Read from `static.json` (`TEL.*` `report.assets`) before protocol step 1, not from
`game_assets/`:

- boot group: **11 of 11 opened**, unresolved `0`, `boot_outcome` `0`
- wave-1 `play` group: **19 of 19 opened**, unresolved `0`

File-side checks on the same build, in the headless folder, prove presence but
not opening: `35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)`;
`14 of 14 boot asset file(s) resolved`. Every piece and board row is judged on
what rendered.

## Paths

- [notes.md](notes.md) · [driver-notes.md](driver-notes.md)
- `results.json`, `static.json`
- `logs/telemetry.ndjson` — `TEL.1`–`TEL.5` for the judged window (87 lines)
- `logs/w478_sweep.gd` — the driver
- file-side export checks: [`../headless-20261024T193902Z/logs/`](../headless-20261024T193902Z/logs/)
