# Localization Copy

Authoring rules: [`.agents/specs/rules/ux/ux.md`](../../.agents/specs/rules/ux/ux.md).

- **Serves**: [quality.md](../definition/quality.md) Localization (`en`, `zh-Hant`, `ja`); Cafe calm; Instant play
- **Informed by**: screen Copy tables; [`ux.md`](ux.md)

Every player-facing string a screen shows is a key in that screen's Copy table. This file fixes how those keys are named and what each locale must carry; it adds no wording of its own.

A key's owner is the screen whose Copy table holds it, named by that screen's file (`puzzle-play`), or `exceptions` for wording from the Key column of [exceptions.md](exceptions.md). A key belongs to exactly one owner, and its qualified name is the owner plus the key, such as `puzzle-play.cue_solved`. A table row that reuses another owner's key cites it as `owner.key` and adds no key of its own.

## Rules

| ID | Rule |
|----|------|
| L1 | Key names use lower-case letters, digits, and underscores only, and stay stable within their screen. Renaming a key is an edit to that screen's Copy table, not a locale edit. |
| L2 | **The Copy table is the only copy source.** A string a player can read is a Copy-table row with its `en` value. No other spec or mockup defines player-facing wording, and a mode adds keys only by adding rows to its own Copy table. |
| L3 | Every key varies by locale except a row its Copy table marks same in every locale. Only two such rows exist: the `mode-pick` `locale` own name (C4), and the four piece-type names `queen`, `rook`, `bishop`, and `knight` on `shared-play` and `puzzle-play` (C6). Piece names stay as the `en` value in every locale because they double as the accessibility names for a piece's shape, so a piece is called the same at every locale and by every reader. |
| L4 | A screen shown in a state carries the copy that state names, and the 40% growth tolerance ([quality.md](../definition/quality.md) Localization) applies to every string in every state the screen can show. |
| L5 | A value changes only when a cited element contradicts it, and the change names that element. A wording preference is not a reason. |
| L6 | A journey or a state carries no Copy table of its own: where it shows a string, it cites the owning screen's key, so each key has one value and one place to edit. |

## Modes and keys

Wave 1 is `mode-pick`, `shared-setup`, `shared-play`, and `shared-result`. Wave 2 adds `puzzle-play`, whose Copy table names all 21 of its keys, each with a value in every shipped locale. Wave 3 Advice copy reaches the player only through `shared-play` rows (`advice_on`, `advice_off`, `advice_error`) and the `shared-setup` row `advice`.

## Experience intent

Switching locale updates every string at once, so the table reads as one calm interface in each language, never a half-translated one.
