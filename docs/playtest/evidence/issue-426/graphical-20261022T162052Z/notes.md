# Graphical notes

Acceptance playtest for #426 (Ambient load point at mode-pick ready) on build `1949553` (merged PR #461).

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 15 headless unit tests passed
- `godot --headless --path game -s res://presentation_audio_test.gd` — exit 0
- `godot --headless --path game -s res://asset_resolver_test.gd` — exit 0 (the `Preload play left 1 approved IDs unresolved` / `Unresolved asset ID: missing-runtime` lines are the test's intentional negative-path assertions, and the run exits 0)
- `godot --path game --resolution 1280x720 -s <issue426 capture>` — graphical session on macOS / Metal

## Scope

#426 reconciles a single Ambient load point across `CTR-asset-resolve.O4` (row + Diagram), `CMP-asset-resolver.R5`, `CMP-session-router.C5`, and `CTR-presentation.E3`; the client preloads Ambient when mode pick becomes ready and starts `BED_M1` on `ambient_ready`. This affects the mode-pick screen (`PTU-mode-pick`) and the bed continuing through Shared setup/play (`PTU-shared-play`).

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-cold-open-loading-silent.png` | `stage=loading`; `ambient_loaded=false` — cold open stays silent |
| `02-mode-pick-ready-ambient-started.png` | `stage=mode-pick`; `ambient_loaded=true`, `music_started=true`, `bed_index=0` (M1) — `SND.M1` "mode pick" delivered |
| `03-shared-setup-bed-continues.png` | Shared setup; `music_started=true` — bed does not restart or drop |
| `04-shared-play-bed-continues.png` | Shared play; `play_loaded=true`, `music_started=true` |
| `05-mode-pick-return-bed-continues.png` | After resign → result → Stop; `stage=mode-pick`, `ambient_loaded=true`, `music_started=true` — bed stays for the sitting |

No protocol failure. Mode-pick activates the Shared control and the board renders in Shared play, so the interface still operates; the only defect the issue addresses (missing bed at mode pick) is fixed.

## Spec reconciliation

- `grep -rn "after the board is playable\|board is playable\|board playable" specs/technical/` → only `specs/technical/failures.md:18` `T6` (load gate), which the issue marks out of scope.
- `grep -rn "board_playable\|note_board_playable" game/ specs/ docs/` → no hits; no board-playable load trigger remains in code or specs.
- The four technical sheets now name mode-pick ready (`O4`, `R5`, `C5`, `E3`), and `ACC.G3` / `AST.G3` already did, so the set agrees.

Capture log ends with `ISSUE426_GRAPHICAL pass`.
