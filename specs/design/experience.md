# Experience and Feel

Authoring rules: [`.agents/specs/rules/design/experience.md`](../../.agents/specs/rules/design/experience.md).

- **Serves**: Instant play, Clear board, and Cafe calm (vision); a commute session of about 15–40 minutes (definition scope).

## Experience goals

| Vision quality | Moment the player feels it | How the design produces it |
|----------------|----------------------------|----------------------------|
| Instant play | Piece and move sound finish with no wait after a place | Shared-game and puzzle loops; [Advice](glossary.md) never blocks a move |
| Clear board | Each piece type named from its shape at a glance | Clarity rules below |
| Cafe calm | Play feels unhurried, like a quiet table | Untimed default; cafe mood and sound; simple [mode pick](flows/mode-pick.md) |

## Pacing

- **Session arc**: Open → [mode pick](flows/mode-pick.md) → one [Shared game](glossary.md) or [Puzzle stream](glossary.md) stretch → leave when choosing, or start another Shared game after an end.
- **Rhythm**: Think → move → short settle → next turn or puzzle. [Player Elo](glossary.md) nudges the next deal after each puzzle result.
- **Durations**: One Shared game or several puzzles in a ~15–40 min session ([design.md](design.md)). Each puzzle is one short attempt.

## Feedback principles

[`experience/feedback.md`](experience/feedback.md).

## Sensory intent

- **Mood and style**: Quiet cafe table; classic warm board; distinct vector pieces; calm, not tournament chrome.
- **Sound intent**: Short cues for touch, move, check, checkmate or resign; soft cafe ambient beds [SND.M1](../aesthetics/sound.md) then [SND.M2](../aesthetics/sound.md) (~3 min each). While music is on: play M1 → M2 → M1…; when one bed ends, the next starts (no crossfade). Sound alone never required for a rules outcome.
- **Clarity rules**: Piece types by shape; side to move and check obvious; Advice marks never obscure piece identity.

## Accessibility

- **Channels**: Piece type clear with color removed (shape). Critical move, check, and ends clear with sound off (visual).
- **Timing and assists**: Untimed eases clock pressure; Advice On/Off optional ([configuration.md](configuration.md)). None beyond those.
- **Scale**: Body text and labels readable at smallest shipped size on Web touch. None for separate audio scale.

## Localization

Varies by locale (`en`, `zh-Hant`, `ja` — [quality.md](../definition/quality.md)): mode pick and mode labels; Shared-game options and choices; in-play and end status copy; puzzle result copy; Player Elo labels and helpers; exception and system copy (loading, error, save-failure, confirm). Not translated: piece identity by shape; board geometry; cafe ambient (no lyrics). The locale defaults to the browser's locale when shipped, else `en`; the player may switch locale, and a switch applies immediately to all player-facing copy.

## Learning and mastery

Assumes basic chess knowledge. Puzzle stream teaches by adaptive difficulty. Beginner: calm Untimed Shared game or a few puzzles. Expert: reads positions quickly; uses timed clocks and Advice deliberately.

## Experiences to avoid

- Waiting on the network before a local move settles — breaks Instant play.
- Feeling like a loud competitive chess site — breaks Cafe calm.
- Ambiguous piece silhouettes — breaks Clear board.
