# Findings — #334 acceptance, headless

Recorded here, filed nowhere. Context: `manifest.md`.

1. **Screen-side `C4` symptoms** (carried from `../headless-20261024T180000Z/live-screen-findings.md`): first `C4` activation reading `zh-Hant` twice, the puzzle panel not re-reading `GS.locale`, and a stale-locale render on back-navigation. The graphical run `../graphical-20261025Tpar1/` does **not** reproduce them on `0fd4640` — its `S1` reads `zh-Hant` then `ja` correctly (`01`/`02`/`03-mode-pick-*.png`). They remain for the #550 wave sweep to re-run on current `main`.
2. **Regional-indicator glyphs**: the headless twin saw `…` for the flag pair in `zh-Hant` `shared`; the graphical run also does not reproduce it. Not filed. Note that the current `## Copy` table for `mode-pick` on this build carries no flag pair at all, so whichever result the sweep gets, it is a panel question, not a copy question.
3. **`PTU-localization` `S2`/`S3` ambiguity**: `S2` asks for every visible string on `shared-play` and `S3` asks to read the `queen` row there. `queen` renders only in the S4 promotion chooser (graphical `B1`), and S4 was unreachable on `0fd4640` (`B2`, now fixed by `589ed41`/`#868`). This is a protocol-wording question owned by #494/#550, not by this leaf; nothing in this leaf depends on it.
