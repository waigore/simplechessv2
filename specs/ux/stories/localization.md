# Stories: Localization Copy

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`localization.md`](../localization.md)
- **Spec key**: `LOC`
- **Glossary terms**: [Screen](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| L1 | Key names are lower-case letters, digits, and underscores | US1.1 |
| L2 | The Copy table is the only copy source | US1.2 |
| L3 | Every key varies by locale except the same-in-every-locale row | US1.3 |
| L4 | A state carries the copy that state names, tolerating 40% growth | US2.1 |
| L5 | A value changes only against a cited element | US2.2 |

## US1: Copy keys and owners

As a bottom player, I read every label and message in my locale so that the interface is never half-translated.

### US1.1: A key name follows the naming rule

- **Proves**: `LOC.L1`

```gherkin
Given the Copy tables of the five screens and exceptions, in en, zh-Hant, and ja
When a reviewer reads every Key cell in those tables
Then each key matches lower-case letters, digits, and underscores only
And each qualified name is its owner plus the key, such as `puzzle-play.cue_solved`
```

### US1.2: Every player-facing string is a Copy-table row

- **Proves**: `LOC.L2`

```gherkin
Given the shipped build in en, zh-Hant, and ja
When a reviewer lists every visible string on mode-pick, shared-setup, shared-play, shared-result, and puzzle-play
Then each string appears as a Copy-table row in the screen that shows it
And no visible string is absent from those tables
```

### US1.3: Each key varies by locale except the own-name row

- **Proves**: `LOC.L3`

```gherkin
Given the three shipped locales en, zh-Hant, and ja
When mode-pick is shown and C4 Switch locale is activated twice from en
Then title, shared, and puzzle differ in value between en, zh-Hant, and ja
And the `locale` row reads English, then 繁體中文, then 日本語, and no other row is marked same in every locale
```

## US2: Locale completeness and change control

As a top player, I switch locale and read a complete interface so that no label shows a raw key.

### US2.1: Every state carries its copy at 40% growth

- **Proves**: `LOC.L4`

```gherkin
Given puzzle-play on S3 EX.save-failure in ja
When the `save_failed` and `dismiss` strings are each lengthened by 40%
Then both strings stay inside the 720×1280 frame with no clipped label
And Dismiss remains a 44 px or more touch target
```

### US2.2: A value changes only against a cited element

- **Proves**: `LOC.L5`

```gherkin
Given shared-play Copy row `refused_place` reads "Refused place"
When an edit proposes a rewording with no contradicting design or view element
Then the edit is rejected and the row keeps "Refused place"
And a proposal citing `EX.rejected` names that element and still satisfies it
```
