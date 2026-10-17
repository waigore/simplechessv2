# Experience and Feel

Authoring rules: [`.agents/specs/rules/design/experience.md`](../../.agents/specs/rules/design/experience.md).

## Experience goals

| Vision quality | Moment the player feels it | How the design produces it |
|----------------|----------------------------|----------------------------|
| Instant play | Piece and move sound finish with no wait after a place | Shared-game and puzzle loops; [Advice](glossary.md) never blocks a move |
| Clear board | Each piece type named from its shape at a glance | Clarity rules below; piece readability for entities |
| Cafe calm | Play feels unhurried, like a quiet table | Untimed default; cafe mood and sound intent; simple [mode pick](flows/mode-pick.md) |

## Pacing

- **Session arc**: Open → [mode pick](flows/mode-pick.md) → one [Shared game](glossary.md) or a stretch of [Puzzle stream](glossary.md) → leave when choosing, or start another Shared game after an end.
- **Rhythm**: Think → move → short settle → next turn or puzzle. [Player Elo](glossary.md) nudges the next deal after each puzzle result; not a career ladder.
- **Durations**: One Shared game or several puzzles in a ~15–40 min sitting ([design.md](design.md)). Each puzzle is one short position attempt.

## Feedback principles

| Event | Player must understand | Priority |
|-------|------------------------|----------|
| Piece selected or touched | Which piece is active | high |
| Move completed | Where it went; turn changed | high |
| Check | Side to move's king is in check | high |
| Checkmate, resign, or clock loss | Game over and who won or drew | high |
| Wrong puzzle move | That move failed the puzzle | high |
| Puzzle solved or abandoned | Result; next puzzle will deal | medium |
| Advice ready (On and online) | Best move and eval available; move not delayed | medium |
| Draw end | Game ended in a draw | medium |

## Sensory intent

- **Mood and style**: Quiet cafe table; classic warm board; distinct vector pieces; calm, not tournament-site chrome.
- **Sound intent**: Short cues for touch, move, check, checkmate or resign; soft cafe ambient under play. Sound alone never required for a rules outcome.
- **Clarity rules**: Piece types always by shape; side to move and check always obvious; Advice marks never obscure piece identity.

## Accessibility

- **Channels**: Piece type clear with color removed (shape). Critical move, check, and end outcomes clear with sound off (visual).
- **Timing and assists**: Untimed Shared game eases clock pressure. Advice On/Off is optional help ([configuration.md](configuration.md)). None beyond those options.
- **Scale**: Body text and labels readable at the smallest shipped size on Web touch. None for a separate audio-scale option.

## Localization

Varies by locale (`en` default, `zh-Hant`, `ja` — [quality.md](../definition/quality.md)): mode pick and mode labels; Shared-game options and choices; in-play and end status copy (check, checkmate, resign, draws, clock expiry, whose turn); puzzle result copy (solved, wrong move, abandon, leave stream); Player Elo labels and short helpers; exception and system copy (loading, error, save-failure, confirm).

Not translated: piece identity by shape; board geometry; cafe ambient music (no lyrics).

## Learning and mastery

Assumes basic chess knowledge; Clear board and orthodox rules carry the rest. Puzzle stream teaches by adaptive difficulty. Beginner: finishes a calm Untimed Shared game or a few puzzles. Expert: reads positions quickly; uses timed clocks and Advice deliberately.

## Experiences to avoid

- Waiting on the network before a local move settles — breaks Instant play.
- Feeling like a loud competitive chess site — breaks Cafe calm.
- Ambiguous piece silhouettes — breaks Clear board.
