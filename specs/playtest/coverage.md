# Playtest coverage

Authoring rules: [`.agents/specs/rules/playtest/coverage.md`](../../.agents/specs/rules/playtest/coverage.md).

## Mode

Declared on [`playtest.md`](playtest.md): **`full`**.

| Mode | Playtest set |
|------|----------------|
| `full` | Every design story and every UX journey (then intersected with issue scope in [`procedures.md`](procedures.md)) |
| `critical-only` | Only the Critical IDs table below (then intersected with issue scope) |

View stories are never in the set. Environment rules (Design → Headless; UX → Headless and Graphical) are on the hub, not here.

## Critical IDs

| ID | Upstream story / journey ID | Why critical |
|----|-----------------------------|--------------|
| — | — | None — mode is full |

## Issue mapping

A required acceptance playtest runs protocols for the intersection of this coverage set and the design/UX IDs the issue's playable deliverables can affect. See [`procedures.md`](procedures.md).
