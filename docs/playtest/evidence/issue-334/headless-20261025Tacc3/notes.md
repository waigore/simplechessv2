# Notes — #334 acceptance, headless

Build: `origin/main` `ad9c04d`, Godot 4.7.2, `ENV.1` (headless worktree). Everything below was re-derived this run; nothing is copied from the implementation or verification comments.

## Method

Runs one live and two mutations:

1. `probe/accept334_probe.gd` reads `StringTable.puzzle_play` / `StringTable.mode_pick` directly (it preloads `game/string_table.gd`, so it does not use the test's helpers) and parses the `## Copy` table of `specs/ux/screens/puzzle-play.md` with its own reader. It prints every value per locale, the empty / key-equal / `en`-copy verdicts, and the marked set. Log: `logs/probe-values.log`.
2. `probe/runner.gd` drives the shipped `game/string_table_test.gd` document (the gate itself: parity, completeness, I5, marked-set, and the `_copy_gate_negative_cases` proof) and prints its verdict — `ERROR:` lines are the gate's `push_error(problem)`, `GATE RUN COMPLETE` is the settle point. Log: `logs/copy-gate.log`. The project's own entry point, `python3 .github/scripts/gdscript_tests.py test`, also ran green: 33 passed (`logs/unit-tests.log`).
3. Mutation A empties one `zh-Hant` value in `game/string_table.gd` (`puzzle-play.cue_failed`); mutation B disarms the I5 varying-key branch in `game/string_table_test.gd`. Each is run, then reverted with `git checkout`. Logs: `logs/mutation-*.log`.

Reading the mutations: the gate reports through `push_error` and the harness wrapper still exits 0, so the verdict is the `ERROR: <problem>` line, not the process code. Mutation B surfaces as `an en-copied varying key passed the gate` — the first check that trips is the parity/spec leg of `_after_boot`, ahead of `_copy_gate_negative_cases`, which is the guard working, not a second mechanism. After both reverts the gate is green again (`logs/copy-gate.log`; its only `ERROR:` lines are the harness's unresolved catalog fonts, not a copy problem).

## Key set — 23, not 21

The live `## Copy` table carries **23** keys. The issue body names 21, omitting `pawn` and `king`. The gap is in the body's arithmetic, not in the owner: the shipped table and the spec agree key-for-key in both directions, and the six `L7` marked rows on `puzzle-play` are `pawn king queen rook bishop knight`.

Consequences for the ACs as written: "all 21 keys" is met as a subset and the real set of 23 resolves; "the 17 varying keys" is correct (23 − 6 marked = 17); "`queen`, `rook`, `bishop`, `knight` stay equal to `en`" is correct but incomplete — `pawn` and `king` are marked too. The same two-name gap appears in the graphical run's `screen-findings.md` B1 reasoning (`L7` marked = four). Treat this as a body-wording defect repaired here, not as an implementation gap.

## Findings — recorded, filed nowhere

1. **Screen-side `C4` symptoms** (carried from `../headless-20261024T180000Z/live-screen-findings.md`): first `C4` activation reading `zh-Hant` twice, the puzzle panel not re-reading `GS.locale`, and a stale-locale render on back-navigation. The graphical run `../graphical-20261025Tpar1/` does **not** reproduce them on `0fd4640` — its `S1` reads `zh-Hant` then `ja` correctly (`01`/`02`/`03-mode-pick-*.png`). They remain for the #550 wave sweep to re-run on current `main`.
2. **Regional-indicator glyphs**: the headless twin saw `…` for the flag pair in `zh-Hant` `shared`; the graphical run also does not reproduce it. Not filed. Note that the current `## Copy` table for `mode-pick` on this build carries no flag pair at all, so whichever result the sweep gets, it is a panel question, not a copy question.
3. **`PTU-localization` `S2`/`S3` ambiguity**: `S2` asks for every visible string on `shared-play` and `S3` asks to read the `queen` row there. `queen` renders only in the S4 promotion chooser (graphical `B1`), and S4 was unreachable on `0fd4640` (`B2`, now fixed by `589ed41`/`#868`). This is a protocol-wording question owned by #494/#550, not by this leaf; nothing in this leaf depends on it.

## Independence

The implementation summary on the issue was posted by `k-junior-claw`, the same identity this unattended session runs as. This run therefore is not an independent implement→verify cycle. It is an acceptance pass: its checks are re-derived from the spec and the shipped table (`probe-values.log`.), all reads and mutation runs are new, and no prior verdict was reused. The operator decision recorded on this issue on 2026-10-23/24 — whether a fresh dispatch session counts as independent — is unchanged and not decided here.

## Outcome

**Accept.** The deliverable (the `puzzle-play` owner values plus the gate that keeps them from passing vacuously) holds on `main`; the two mutations show the gate is not vacuous. The only body-level repair is the 21→23 key count. Nothing in this run contradicts the graphical run's verdict on this leaf's own copy.
