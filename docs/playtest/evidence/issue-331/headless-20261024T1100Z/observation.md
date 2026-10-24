# Observation — #331 headless run

Not this issue, and not a fail. Recorded from [notes.md](notes.md).

 (not this issue, not a fail)

While probing `CMP-chess-rules` on a throwaway script, `legal_targets` returned no targets for a king in check whose escape square is attacked only by an enemy king: with `k7/1R6/1N6/8/8/7N/8/1R4K1 b`, the black king's only move is to capture the rook on `b7`, which the knight on `b6` guards, yet `attacks("white", "b7")` is false while `attacks("black", "b7")` is true — the attack test looks like it answers "does an enemy piece attack this square" rather than "does the given side attack this square" for king-adjacent squares. En passant generation is also absent. Neither affects any #331 criterion — the deal applies only the record's opening move — but they are `CMP-chess-rules` correctness questions that already have a verify note; worth a defect if untracked.
