# Live-screen findings — outside this leaf's owner

Judged by driving the live build (`ENV.1`, `8cdfd45`) rather than reading the table. See `notes.md` for the table readings.

- `C4` on `mode-pick` while the puzzle screen is open flips `GS.locale` and repaints mode-pick, but `router.stage` stays `puzzle-play`; the puzzle screen then ignores the new locale (`Elo 值 1000 | 顯示解答` → `ja` still reads `Elo 值`). `DBG.3` jump to `mode-pick` afterwards restores the stage but renders an empty panel. The table reads this leaf ships are correct in all three locales, so this is a *screen/state* problem and it lives on the puzzle screen's side (#333 shipped that panel).
- In the rendered `zh-Hant` mode-pick, `shared` reads `共用對局` — the leading `FR ` of the two-letter flag pairs is replaced by `…` (the two regional-indicator glyphs are missing from the font chain), so the visible string is not its Copy-table value either.
- In the same sweep, `ja` *puzzle-play* renders `Reveal`, `Abandon`, `Leave stream` while its `en` model values are the CJK strings: the puzzle-play panel is not re-applied after its `en` write, so the panel shows the previous locale's copy.

All three are interface findings against the panels, not against the string table this issue delivers; they are also visible on the #550 wave sweep evidence (`docs/playtest/evidence/issue-550/graphical-20261024T000000Z/`), which is where the graphical half of these protocols belongs. None is filed here: per `procedures.md` a defect is filed against the protocol that fails, and this leaf's protocol is `not-judged` for the graphical half, so the successor filing is left to the run that judges it.
