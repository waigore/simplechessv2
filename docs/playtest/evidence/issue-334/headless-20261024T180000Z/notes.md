# Notes — #334 acceptance, headless `PTU-localization`

Build: `origin/main` `8cdfd45`, Godot 4.7.2, `ENV.1`. Probe and judgements: `probe/accept334_probe.gd`, run log `logs/playtest-headless.log`.

## What was judged

The issue's remaining work is the non-vacuity proof on the `puzzle-play` copy owner, so the playable-behaviour change is in the string table and its gate. `PTU-localization` is the only UX protocol this leaf can move; `PTU-puzzle-play` and the ~40% growth layout are #333's evidence per the body's `## Preconditions`, and no design protocol reads a copy table.

Left over from PR #515 in the same owner, the values were also read fresh rather than copied from the implementation comment: all 21 Copy-table keys were parsed from `specs/ux/screens/puzzle-play.md` (21 rows) and compared with `StringTable.puzzle_play_keys()` — set difference empty both ways.

## Findings

**B1 — the gate's negative cases are real (AC4).** The probe reproduces the shipped rule itself instead of calling the test under review, then mutates one row: a dropped `zh-Hant` `cue_failed` returns `puzzle-play.cue_failed missing in zh-Hant`; `reveal` set to `Reveal` in `ja` returns `puzzle-play.reveal still English in ja`; an `en`-copied `queen` returns nothing, which is the `L3`/`I5` marking doing its job. The unmutated owner returns nothing. A green gate run therefore cannot mean the owner stopped being checked.

**B2 — `mode-pick`'s `locale` row.** Read through `StringTable.mode_pick("locale", …)` the row is `English` / `繁體中文` / `日本語`, its own name in each locale, and `EVERY_LOCALE_ROWS` carries no `mode-pick` entry — no implicit fifth marked row. The live panel is a separate matter (B4).

**B3 — the owner's marked set.** `puzzle-play`'s same-in-every-locale rows are exactly `queen`, `rook`, `bishop`, `knight` and nothing else, matching `localization.md` L3.

**B4 — a `mode-pick` copy finding, outside this leaf's owner.** Driving the live build rather than the table:

Three interface findings — the C4 locale cycle stranding `router.stage`, the missing `zh-Hant` regional-indicator glyphs, and `ja` puzzle-play showing the previous locale's copy — are recorded in `live-screen-findings.md`.

## Outcome

**Waiting on screenshots, plus one interface observation recorded and not filed.** `PTU-localization` requires Headless **and** Graphical. The headless half is recorded here; `P5` (`queen` in Shared play) is Graphical-only and is `not-judged` by design in `ENV.1`. Acceptance therefore waits on a graphical re-run of this same build under `../graphical-<run-id>/`. No defect is filed and the status stays `pending-acceptance`.

Per the issue body, AC2 and AC8 also have table-level evidence only: `PTU-puzzle-play` and the C4-reads-puzzle-copy check are #333's, and B4 above is the first evidence that they will not pass as shipped.
