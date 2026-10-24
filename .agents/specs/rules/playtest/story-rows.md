# Authoring rules: playtest story rows

Read this before editing `specs/playtest/story-rows.md`. Do not copy these rules into the spec.

Also read [playtest.md](playtest.md), [coverage.md](coverage.md), [procedures.md](procedures.md), [evidence.md](evidence.md), and [ids.md](ids.md).

This file is the single owner of the playtest row source: the unit a run judges, the rule that binds a protocol to a row, the multi-protocol rule, and the `none` rules. Procedures select and judge rows through it; evidence names its outcomes. No protocol, sweep, map, or evidence folder states a rule of its own.

## Row unit

- One row per story heading, never per file, and one row per journey. Name the identifying form (`<path>#<heading>`) and the citing form (`<spec key>.<heading>`) so a row can be named from a protocol and found in the story files.
- A split story file is part of its base spec and contributes its own heading. Say how a story ID reaches base and split files, and that a scenario ID reaches only the file carrying it.
- A journey is a row; its story file holds the scenarios. Do not count a journey twice.

## Judge rule

- **UX**: state which **Cites** forms judge a row (story ID, bare spec key, scenario ID) and what each covers.
- **Design**: state the element-plus-spec-key test, that a bare **Proves** entry belongs to the row's key, that a cross-key element never covers a row, and that a bare key-level cite (`GS`, `CFG`) covers every row of that key. A qualifier after the key narrows coverage.
- State that a row names every protocol that judges it.
- Do not restate a story's content or a protocol's steps.

## Mode full

State which rows mode `full` selects, in one sentence, so the set has one reading. [`coverage.md`](coverage.md) applies it and does not restate it.

## Rows no protocol judges

- Row-level `none` is `none — <reason>` with a linked `type:defect` number; scenario-cell `none` sits in the row's scenario cell and needs no defect.
- `none` is not `out` and not `not-judged`; the outcome vocabulary stays in [`evidence.md`](evidence.md).
- The only fail of this rule is a row-level `none` with no defect number.

## Splitting

Keep the file under 500 words. If it passes, move the worked examples or the mode row set to a focused file under `specs/playtest/` and update the hub index.
