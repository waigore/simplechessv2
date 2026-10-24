# Playtest coverage

Authoring rules: [`.agents/specs/rules/playtest/coverage.md`](../../.agents/specs/rules/playtest/coverage.md).

## Mode

Declared on [`playtest.md`](playtest.md): **`full`**.

| Mode | Playtest set |
|------|----------------|
| `full` | Every design story and every UX journey (then intersected with issue scope in [`procedures.md`](procedures.md)) |
| `critical-only` | Only the Critical IDs table below (then intersected with issue scope) |

View stories are never in the set. Environment rules (Design → Headless; UX → Headless and Graphical) are on the hub, not here.

The mode-`full` reading against the story rows is owned by [#660](https://github.com/waigore/simplechessv2/issues/660) and applied, not restated, here. Which rows exist and which protocol judges each is recorded in the [story-to-protocol map](traceability/story-protocol.md), which changes the set's membership but not this table.

## Critical IDs

| ID | Upstream story / journey ID | Why critical |
|----|-----------------------------|--------------|
| — | — | None — mode is full |

## Issue mapping

A required acceptance playtest runs protocols for the intersection of this coverage set and the design/UX IDs the issue's playable deliverables can affect. See [`procedures.md`](procedures.md).
