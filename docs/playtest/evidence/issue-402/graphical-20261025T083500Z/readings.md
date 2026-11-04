# Readings

Raw data: [logs/served-build.json](logs/served-build.json),
[logs/browser-probe.json](logs/browser-probe.json). Build identity and the served pack
walk: [builds.md](builds.md).

## Colour readings — cited from #640 / #641, not re-measured

| Check | Source | Build | Result |
|---|---|---|---|
| `PER.R1` shape, `PAL.K1` squares, `PAL.K2` piece side | `docs/accessibility/issue-640/review-20261025/` (PR #887) | published `69a03d4`, run `40146630737` | shape **pass**, `K1` **pass**, `K2` **fail** (#883) |
| Eight shared-play signals without colour, last move | `docs/playtest/evidence/issue-641/review-20261025T0037Z/` (PR #889) | published `69a03d4` | seven **pass**, last move **fail** (#888) |

Both were read one deployment back. Citing them as that build's readings is what makes
row 8 the record's `fail`; re-reading the two failing carriers on `ad9c04d` belongs to
#625 / #640 / #641, and this run does not assert it from pixels.

## Localization copy, per locale, from the served build

Read from `game/string_table.gd`, which the served pack carries. Lengths are graphemes —
what a CJK glyph count means on screen.

| Key | `en` | `zh-Hant` | `ja` | Growth `en` → CJK |
|---|---|---|---|---|
| `title` | `Choose how to play` (18) | `選擇遊玩方式` (6) | `遊び方を選ぶ` (6) | **−67%** |
| `shared` | `Shared game` (11) | `共用對局` (4) | `シェア対局` (5) | −64% / −55% |
| `puzzle` | `Puzzle stream` (13) | `謎題串流` (4) | `パズルストリーム` (8) | −69% / −38% |
| `quit` | `Quit` (4) | `結束` (2) | `終了` (2) | −50% |
| `quit_confirm` | `End this session?` (17) | `結束本次遊玩？` (7) | `このセッションを終了しますか？` (15) | −59% / −12% |
| `save_failed` | `Save failed. Prior values kept.` (31) | `儲存失敗。已保留先前數值。` (13) | `保存に失敗しました。以前の値を保持します。` (21) | −58% / −32% |

Every locale table carries the same 11 mode-pick keys, so copy **completeness** on mode
pick holds in the artifact. The "~40% growth" clause is **not exercised** by these
screens: CJK is shorter than `en` for every key, so mode pick is the wrong witness for
it. Screens where `en` is the short side (Shared game and Puzzle stream chrome, end
screens) were not read.

## Smallest text at phone width — tree fact, not a reading

`UiChrome.add_font_size` sizes body text as `16 × frame_height / 640`; at 390×844 that
asks **21 px**. #546 measured 21 px for the five mode-pick strings `SIT.6` judges — but
only in English (`English`, `Shared game · Last`, `Puzzle stream`, `Quit`, title), and
on the playtest scene, never on a release build. So the size leg has a number; the
**width** leg (does translated copy fit a 390 px card) has none.

## What this run could not take

No frame-time window, no cold-open timer, no screenshot, no locale switch, no crash
reload. The browser dies before `--version` on this host
([logs/browser-probe.md](logs/browser-probe.md)). Those readings belong to #625 on this
build.
