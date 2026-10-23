# Graphical notes

Acceptance check for #456 on `main` @ `eec7d4a` (fix merged as `a6dbfd9`, PR #464).

## Prep

- `godot --version` → `4.7.2.stable.official.ed1daf0bf`
- `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` → `[demo] PASS`, exit 0
- `DEMO_SHOT_DIR=<tmp> DEMO_AUTODRIVE=1 godot --path demos/shared-game` → `[demo] PASS`, exit 0, two screenshots written

## Judgement

Panel geometry from the run: `Rect2(pos (41.0, 582.5), size (638.0, 185.0))`, so it spans x 41–679 and y 582.5–767.5 in the 720×1280 frame.

| Criterion | Judged |
|-----------|--------|
| Inside the frame, 4 px+ margins all sides | x 41 / 679 (41 px each side) and y 582.5 / 767.5 — well inside. The defect's negative-x / edge-to-edge band is gone. |
| Text inside the panel with clear margins | One line, `Checkmate — White wins`, centred by `HORIZONTAL_ALIGNMENT_CENTER` with 28 px side padding, 24 px block padding; nothing clips. |
| Above the board and pieces | `z_index` 10 vs pieces 3 (6 mid-animation) and overlays 5. In the screenshot no piece or square shows through the cream band; the piece art that was previously "cream on cream" no longer interacts with the panel. |
| Does not cover the final position | Board rows are 72 px on `BOARD_ORIGIN.y = 352`: rank 8 = 352–424, rank 7 = 424–496, rank 6 = 496–568. The panel starts at y 582.5, so ranks 8 and 7 (with `Qf7#` and the checked king) are fully visible; it covers empty rank 5 squares b–g. |
| Calm result treatment | Rounded cream band, ink text, no chrome — matches `AES.P3` as cited in `_show_end()`. |

No fail on any acceptance criterion.

## Duplicated result (non-blocking, pre-existing)

The mate frame shows the result twice: the turn chip above the board and the end panel. This was flagged in the verify comment as the one part of the defect body not addressed by #464. The defect body frames it in a list of symptoms ("duplicates the result already shown in the turn chip") rather than as a standalone requirement, and the observable bug — overflow, occlusion, illegibility — is fixed. The chip is the side-to-move indicator (`PER.R6`) and the duplication predates the fix, so it is not a regression from this change.

Recommendation: leave it as a cosmetic residue and, if wanted, handle it as a small follow-up (blank or repurpose the chip when `ended`) rather than reopening this defect. It does not block acceptance.

## Spec parity

The review asked whether the calm end overlay is the sanctioned look. PR #464 records it as demo-only: the main game presents the outcome on the dedicated `shared-result` screen with no board behind it, and `END.L1` is a rules element. `specs/` needs no change; nothing here authorises the overlay in main code.
