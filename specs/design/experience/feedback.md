# Feedback principles

Authoring rules: [`.agents/specs/rules/design/experience.md`](../../../.agents/specs/rules/design/experience.md).

Part of [`experience.md`](../experience.md).

| Event | Player must understand | Priority |
|-------|------------------------|----------|
| Piece selected | Which piece is active | high |
| Move completed | Where it went; turn changed | high |
| Check | Side to move's king is in check | high |
| Checkmate, resign, or clock loss | Game over and who won or lost | high — `X4` end cue ([sound.md](../../aesthetics/sound.md)) |
| Wrong puzzle move | That move failed the puzzle | high |
| Illegal place refused | The attempt did not move; the same piece stays selected | high |
| Puzzle solved or abandoned | Result; next puzzle will deal | medium |
| Advice ready (On and online) | Best move and eval up; move not delayed | medium |
| Draw end | Game ended in a draw | medium — the `result_draw` copy on the result screen ([shared-result](../../ux/screens/shared-result.md)); no end cue ([sound.md](../../aesthetics/sound.md)) |
