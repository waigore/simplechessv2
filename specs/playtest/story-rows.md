# Playtest story rows

Authoring rules: [`.agents/specs/rules/playtest/story-rows.md`](../../.agents/specs/rules/playtest/story-rows.md).

This file owns the rows a required run judges: where a row comes from, which protocol judges it, and how an unjudged row is recorded. [`coverage.md`](coverage.md) owns which rows are in the playtest set; [`procedures.md`](procedures.md) selects and judges them; [`evidence.md`](evidence.md) owns the outcome vocabulary.

## Row unit

A row is identified `<path>#<heading>` and cited `<spec key>.<heading>`.

- **Design row**: one `## PS<n>` heading in one file under `specs/design/stories/`, excluding `_template.md`. A split file contributes its own row. Example: `DIF.PS1`.
- **UX story row**: one `## US<n>` heading in one file under `specs/ux/stories/`, excluding `_template.md`. A split file is part of its base spec: it carries the base `Spec key` and its own heading is a row of its own.
- **UX journey row**: a journey is a heading and is therefore a row. `specs/ux/stories/journeys/<name>.md` is that row, with spec key `J-<name>` and `specs/ux/journeys/<name>.md` as its journey spec.

A row carries the scenarios its judging protocols' steps reach and names those they do not.

## Judge rule

- **UX**: a protocol judges a UX row when its **Cites** names that row's story ID (`UI-mode-pick.US1`), its bare spec key (`J-shared-session`), or one of the row's scenario IDs (`UI-mode-pick.US1.1`). A story ID or bare key judges every row carrying that heading or key across base and split files; a scenario ID judges only the row of the file that carries it.
- **Design**: a protocol judges a design row when its **Cites** names an element the row's scenarios **Proves** and that element belongs to the row's `Spec key`. A bare `Proves` entry is the row's key; a key-qualified entry carries its own. Element IDs repeat across design keys, so an element cited from another key never covers a row. A key-level cite (`GS`, `CFG`) covers every row whose `Spec key` it names; a qualifier after the key narrows coverage to the elements or stories it names.
- **Multi-protocol**: a row names every protocol that judges it.

## Mode full

Mode `full` selects every design row and every UX row, journey rows included. It does not stop at journeys. This settles the reading [#661](https://github.com/waigore/simplechessv2/issues/661) recorded; [`coverage.md`](coverage.md) applies it.

## Rows no protocol judges

- A row no protocol judges is recorded `none — <reason>` with a durable reason. When material uncovered work needs an owner, the row names an open epic or task. It does not require a linked `type:defect`, and a defect is not a planning owner. It is never `out` and never `not-judged`.
- A scenario inside a judged row that no step reaches is a scenario-cell `none`, listed in that row's scenario cell. It needs no owner and is not a row-level `none`.
- A row-level `none` without a durable reason is the only fail of this rule.

Runs record outcomes per [`evidence.md`](evidence.md). The applied row list is the story-to-protocol map under `specs/playtest/traceability/`, recorded by [#481](https://github.com/waigore/simplechessv2/issues/481); this file is the rule it applies.
