# Experience and Feel

Authoring rules: [`.agents/specs/rules/design/experience.md`](../../.agents/specs/rules/design/experience.md).

## Experience goals

| Vision quality | Moment the player feels it | How the design produces it |
|----------------|----------------------------|----------------------------|
| Instant play | Piece settles and move sound finish with no wait after a place | Shared-game and puzzle loops; [Advice](glossary.md) never blocks a move ([move-advice.md](features/move-advice.md)) |
| Clear board | Each piece type is named from its shape at a glance | Clarity rules below; piece readability intent for entities |
| Cafe calm | Opening and play feel unhurried, like a quiet table | Untimed default ([configuration.md](configuration.md)); cafe mood and sound intent below; simple [mode pick](flows/mode-pick.md) |

## Pacing

- **Session arc**: Open → [mode pick](flows/mode-pick.md) → one [Shared game](glossary.md) or a stretch of [Puzzle stream](glossary.md) → leave when choosing, or start another Shared game after an end.
- **Rhythm**: Think → move → short settle (snap and sound) → next turn or next puzzle. After each puzzle result, [Player Elo](glossary.md) nudges the next deal; not a career ladder.
- **Durations**: One Shared game or several puzzles in a sitting of about 15–40 minutes ([design.md](design.md)). Each puzzle is one short position attempt.

## Feedback principles

| Event | Player must understand | Priority |
|-------|------------------------|----------|
| Piece selected or touched | Which piece is active | high |
| Move completed | Where it went; turn changed | high |
| Check | The side to move's king is in check | high |
| Checkmate, resign, or clock loss | The game is over and who won or drew | high |
| Wrong puzzle move | That move failed the puzzle | high |
| Puzzle solved or abandoned | The result, and that the next puzzle will deal | medium |
| Advice ready (On and online) | Best move and eval are available without delaying the move | medium |
| Draw end (stalemate, agreement, and other draws) | The game ended in a draw | medium |

## Sensory intent

- **Mood and style**: Quiet cafe table; classic warm board; distinct vector pieces; calm, not tournament-site chrome.
- **Sound intent**: Short cues for touch, move, check, and checkmate or resign; soft cafe ambient under play. Sound alone is never required to know a rules outcome.
- **Clarity rules**: Piece types always distinguishable by shape; side to move and check always obvious; Advice marks never obscure piece identity.

## Accessibility

- **Channels**: Piece type stays clear with color removed (shape). Critical move, check, and end outcomes stay clear with sound off (visual).
- **Timing and assists**: Untimed Shared game eases clock pressure. Advice On/Off is optional help ([configuration.md](configuration.md)). None beyond those existing options.
- **Scale**: Body text and labels readable at the smallest shipped size on Web touch. None for a separate audio-scale option.

## Localization

Player-facing content that varies by locale (`en` default, `zh-Hant`, `ja` — [quality.md](../definition/quality.md)):

- Mode pick and mode labels (Shared game, Puzzle stream)
- Shared-game options and their choices (White seat, Clock, Increment, Advice)
- In-play and end-of-game status copy (check, checkmate, resign, draw reasons, clock expiry, whose turn)
- Puzzle stream result copy (solved, wrong move, abandon, leave stream)
- Player Elo labels and short helper text
- Exception and system copy the interface shows (loading, error, save-failure, confirm)

Not translated: piece identity by shape; board geometry; cafe ambient music (no lyrics).

## Learning and mastery

Play assumes basic chess knowledge; Clear board and orthodox rules carry the rest. [Puzzle stream](glossary.md) teaches by adaptive difficulty. A beginner finishes a calm Untimed Shared game or a few puzzles. An expert reads positions quickly and uses timed clocks and Advice deliberately.

## Experiences to avoid

- Waiting on the network before a local move settles — breaks Instant play.
- Feeling like a loud competitive chess site — breaks Cafe calm.
- Ambiguous piece silhouettes — breaks Clear board.
