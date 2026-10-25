# Stories: Localization Copy

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`localization.md`](../localization.md)
- **Spec key**: `LOC`
- **Glossary terms**: [Screen](../glossary.md)

## Coverage

[`story-coverage/specs.md`](../story-coverage/specs.md) holds the level; one scenario per element here.

## US1: Copy keys and owners

As a bottom player, I read every label and message in my locale so that the interface is never half-translated.

### US1.1: A key name follows the naming rule

- **Proves**: `LOC.L1`

```gherkin
Given the Copy tables of the five screens and exceptions
When a reviewer reads every Key cell
Then each key uses lower-case letters, digits, and underscores only
And each qualified name is its owner plus the key, such as `puzzle-play.cue_solved`
```

### US1.2: Every player-facing string is a Copy-table row

- **Proves**: `LOC.L2`

```gherkin
Given the shipped build in en, zh-Hant, and ja
When a reviewer lists every visible string on the five screens
Then each appears as a Copy-table row in the screen that shows it
And none is absent from those tables
```

### US1.3: Each key varies by locale except the marked rows

- **Proves**: `LOC.L3`

```gherkin
Given mode-pick in en
When C4 Switch locale is activated twice
Then title, shared, and puzzle differ in each locale
And `locale` reads English, then 繁體中文, then 日本語
And only the rows L7 marks stay in `en`
```

### US1.4: A piece names itself from copy

- **Proves**: `LOC.L7`, `LOC.L8`, `CMP-presentation.R8`

```gherkin
Given shared-play and puzzle-play in en, zh-Hant, and ja
When the board presentation names each of the twelve pieces
Then each name is the `en` value of the row L9 maps for its kind
And no name carries a side, a colour, or a raw key
```

## US2: Locale completeness and change control

As a top player, I switch locale and read a complete interface so that no label shows a raw key.

### US2.1: Every state carries its copy at 40% growth

- **Proves**: `LOC.L4`

```gherkin
Given puzzle-play S3 in ja
When `save_failed` and `dismiss` each grow 40%
Then both stay inside the frame unclipped
And Dismiss stays a 44 px target
```

### US2.2: A value changes only against a cited element

- **Proves**: `LOC.L5`

```gherkin
Given `shared-play.refused_place` reads "Refused place"
When an edit rewords it citing no element
Then the row keeps "Refused place"
And a proposal citing `EX.rejected` still satisfies it
```

### US2.3: A journey cites its screen's key

- **Proves**: `LOC.L6`

```gherkin
Given a journey that shows a string
When its spec names that string
Then it cites the owning `owner.key` and defines no row
```

### US2.4: A piece name meets 40% growth at the assistive layer

- **Proves**: `LOC.L10`

```gherkin
Given the longest piece name per locale
When it is measured at the assistive layer at L4's tolerance
Then no measurement exceeds it
And the TBD names the first measured locale until then
```
