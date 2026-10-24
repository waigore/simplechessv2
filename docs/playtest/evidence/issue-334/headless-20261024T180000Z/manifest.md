# Manifest

- **Issue**: 334 — Localize the wave-2 puzzle copy in en, zh-Hant, and ja
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf`, `origin/main` `8cdfd45` (worktree at the verified commit; PR #584 merge commit `a384c4c` is an ancestor of this build). Probe `TEL.3` `sess-1792858564177-96736-playtest-201666` (`logs/playtest-headless.log`). Graphical twin: **not run in this pass** — see `notes.md`, Outcome B.
- **Coverage mode**: `full`, intersected with this leaf's scope: UX `PTU-localization` only (`specs/playtest/ux/localization.md`). The issue body defers `PTU-puzzle-play` and the growth layout to #333; design protocols are untouched by a copy change. View stories excluded.
- **Story-row source**: the protocol file's own `Cites` rows (`UI-mode-pick.US1`, `LOC.US1`).
- **Defects**: #788 (`LOC.US2` growth row, linked from #481) is pre-existing; **no new defect filed** — the `zh-Hant` `shared` "FR " regional-indicator glyphs are absent (`notes.md`, Finding B4).
- **Screenshots**: waiting on `../graphical-<run-id>/screenshots/`, same build. A headless run omits them without a fail.

## Results

| Protocol / row | Result |
|----------------|--------|
| `ENV.1` headless display | pass |
| `TEL.3` session id marks a playtest build | pass |
| AC1 — 21 `puzzle-play` keys (`cue_failed` included) + `mode-pick.puzzle` resolve in `en`/`zh-Hant`/`ja`, non-empty, not key-equal | pass |
| AC3 — 17 varying keys differ from `en`; the four `L3` piece rows equal `en` | pass |
| AC5 — `locale` row reads its own name (`English` / `繁體中文` / `日本語`); `puzzle-play` marked set is exactly the four piece names | pass |
| AC4 — the shipped owner passes; a dropped `zh-Hant` key reports `puzzle-play.cue_failed missing in zh-Hant`; an `en` copy reports `puzzle-play.reveal still English in ja`; an `en`-copied marked piece row passes | pass (4/4) |
| AC4b — `puzzle-play` owns its 10 shared bare names | pass |
| `PTU-localization` P1/P2 (AC2, `LOC.US1.3`) — `C4` cycles `en` → `zh-Hant` → `ja` → `en` and every copy row differs per locale, `puzzle` among them | **fail** — the cycle is `zh-Hant`, `zh-Hant`, `ja` and the mode-pick `puzzle` label never renders in that store |
| `PTU-localization` P4 (AC2) — copy is its Copy-table value, no raw key | partial — no raw key rendered; the `puzzle` row cannot be read on the live screen |
| `PTU-localization` P5 (S3, `queen` in Shared play, Graphical only) | not-judged — headless |
| `PTU-localization` P3 (`locale` row only) | pass (owner read; see `notes.md` Finding B2 for the screen reading) |
| **Protocol verdict `PTU-localization`** | **not-judged** in this environment |
| Successor defect | held — `notes.md` Outcome B names the shape and why it is not filed here |

## Paths

- `notes.md`
- `probe/accept334_probe.gd` — the driver and every judgement
- `logs/playtest-headless.log` — the probe run cited above
- `logs/import.log`, `logs/headless-smoke.log`
- `logs/unit-tests.log` — 28 passed
- `logs/coverage.log` — 86.5% (4655/5383), threshold 80
- `logs/gdlint.log`, `logs/gdformat-check.log` — clean, 62 files unchanged
- `logs/spec-lint.log` — 0 errors, 1 pre-existing view-glossary warning
- `screenshots/` — waiting on a graphical run of the same build
