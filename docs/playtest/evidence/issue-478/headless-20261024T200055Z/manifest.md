# Manifest

- **Issue**: 478
- **Environment**: headless (`ENV.1`)
- **Build / session id**: `34ac59e3dfd7f300219ede627a4d27ce4b01e5fc`, `Web Playtest` export, `Godot 4.7.2.stable.official.ed1daf0bf`, pck sha256 `6e8f99c344004c23c8703ff8e1c77a01f2e2512273b0ef17c4ee301e31cdaa90`; `TEL.3` session `sess-20261025-478-wave1-playtest`
- **Build source**: local `Web Playtest` export into `build/web/`
  (`web_export.py --preset "Web Playtest"`). A `procedures.md` fallback, not a
  published reading: ADR-0009 publishes only the seam-free `Web Release` build,
  and AC 7 needs the `DBG.*`/`TEL.*` surface, so no published URL serves this
  preset at this commit.
- **Coverage mode**: `full`
- **Protocols**: the eight wave-1 design protocols (headless only) and the nine wave-1 UX protocols
- **Story-row source**: `specs/playtest/traceability/story-protocol/protocols.md`
  and its `protocols-design.md` / `protocols-ux.md` halves. No row was
  re-derived from a protocol `Cites` line.
- **Screenshots**: omitted — headless run; see the [graphical run](../graphical-20261024T200132Z/manifest.md)
- **Defects**: none new. The one visual finding was already tracked as #793
  (accepted) and is fixed on this build ([notes.md](notes.md)).

## Results

**45 pass, 0 fail, 5
not-judged** over 50 story rows (171 passing and
5 not-judged scenario checks). A protocol is `pass` only
when every cited story passes, `fail` if any fails, `not-judged` if any is
`not-judged` (`evidence.md`).

| Protocol | Verdict | Failed rows | Not-judged rows |
|---|---|---|---|
| `PTD-shared-game` | pass | — | — |
| `PTD-mode-and-config` | not-judged | — | `difficulty-tunables.md#PS1` |
| `PTD-end-conditions` | pass | — | — |
| `PTD-game-state` | pass | — | — |
| `PTD-pieces-common` | pass | — | — |
| `PTD-pieces-king` | pass | — | — |
| `PTD-pieces-officers` | pass | — | — |
| `PTD-pieces-pawn` | pass | — | — |
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

One row per story row this run judges, with outcome and the screenshot waiting on the graphical run: **[rows-design.md](rows-design.md)** (eight design protocols), **[rows-ux.md](rows-ux.md)** (nine UX protocols).

## Row-level `none`

| Story row | Outcome | Reason |
|---|---|---|
| `localization.md#US2` | none — out of playtest scope | [#788](https://github.com/waigore/simplechessv2/issues/788) |

## AC 8 — art resolved at run time

Read from `static.json` (`TEL.*` `report.assets`) before protocol step 1, not from
`game_assets/`:

- boot group: **11 of 11 opened**, unresolved `0`, `boot_outcome` `0`
- wave-1 `play` group: **19 of 19 opened**, unresolved `0`

File-side checks (`logs/`, they prove presence, not opening): `35/35 cataloged
game_assets/ file(s), 15 audio_runtime/ copy(ies)`; `14 of 14 boot asset file(s)
resolved`. Every piece and board row is judged on what rendered.

## Paths

- [notes.md](notes.md) · [driver-notes.md](driver-notes.md)
- `results.json`, `static.json`
- `logs/telemetry.ndjson` — `TEL.1`–`TEL.5` for the judged window (136 lines)
- `logs/w478_sweep.gd` — the driver
- `logs/check-assets.log`, `logs/check-boot.log`
