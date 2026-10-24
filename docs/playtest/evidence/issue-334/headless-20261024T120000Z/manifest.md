# Manifest

- **Issue**: 334 — Localize the wave-2 puzzle copy in en, zh-Hant, and ja
- **Environment**: headless (`ENV.1`) for the gate and value checks; the graphical half is not this leaf's (see `notes.md` §AC8)
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf` (macOS, `/opt/homebrew/bin/godot`), `origin/main` `d0e827d04b414acde913b193fbc7d82190ea43b5`
- **Coverage mode**: not applicable — #334's deliverables are string-table values and a copy-gate test, so it adds no playable behavior, no design protocol is in scope, and no screenshot is required.
- **Method**: clean detached worktree at `origin/main` created for this run. Nothing was judged from the shared checkout, which carries another task's branch and uncommitted changes.
- **Defects**: none filed by this run.

## Results

| Acceptance criterion | Result |
|---|---|
| AC1 — 21 `puzzle-play` Copy-table keys + `mode-pick.puzzle` resolve in `en`/`zh-Hant`/`ja`, non-empty, not key-equal | **pass** |
| AC2 — `UI-mode-pick.C4` locale switch, all copy updates | **pass** |
| AC3 — 17 varying keys not verbatim `en`; four L3 piece rows `en`-equal by marking | **pass** |
| AC4 — `puzzle-play` owns its shared bare names, no cross-owner resolution | **pass** |
| AC5 — owner recorded as shipped; dropped key fails, `en`-copied varying key fails, `en`-copied marked row passes, unmutated passes, no schema text | **pass** |
| AC6 — `mode-pick` additions-only; `locale` stays the own-name row | **pass** |
| AC7 — `GS.locale` init/persistence unchanged | **pass** |
| AC8 — `PTU-localization` headless and graphical, S2/S3 `puzzle-play` readings | **pass within this leaf's scope** — see `notes.md` |

## Paths

- `notes.md` — judgement text and the AC8 scope ruling
- `criteria.md` — per-criterion derivations
- `logs/unit-tests.txt` — import, 28 headless unit tests, gdlint, gdformat, spec lint
- `logs/negative-cases.txt` — the four AC5 states reproduced by mutation, plus AC1/AC4/AC6/AC7 derivations
- `logs/copy-table-keys.txt` — the 21 keys parsed from `specs/ux/screens/puzzle-play.md`
- `screenshots/` — omitted: this headless run judges no protocol that requires one

## Related PRs

- #584 (`cbff807`, merged 2026-10-23T12:35Z, `Refs #334`) — the merged implementation. CI on its head: Code lint, Unit tests, Coverage, Spec lint, Web playtest, Advice backend all SUCCESS.
- #515 — the earlier PR that shipped the `puzzle-play` owner and its 21 keys in three locales.
