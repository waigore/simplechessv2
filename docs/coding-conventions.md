# Coding conventions

Project-owned conventions: naming, formatting, file layout, errors, logging, and tests. Engine: [ADR-0001](../specs/adr/decisions/0001-godot-engine.md) (Godot 4.7.2, GDScript). Domain headless tests: [ADR-0006](../specs/adr/decisions/0006-layered-client-architecture.md). Client root `game/` is [M1](../specs/technical/modules.md).

The template allows `None — <reason>`. This repo does not: Tooling, Unit tests, and Coverage are commands. Job behavior: [gdscript.md](coding-conventions/gdscript.md).

Review a diff with [`review-code`](../.agents/skills/review-code/SKILL.md) against this file and [`solid.md`](solid.md).

## Precedence

1. [`solid.md`](solid.md): SOLID principles, owned by the template and applied to every project.
2. This file: project conventions.
3. Structure continuity: patterns inferred from existing code.

Higher wins. Extend `solid.md`; never contradict it (e.g. no central type switch, no core→vendor SDK). Do not restate SOLID. Reviewers ignore contradicting rules and file a must-fix here.

ADRs ([`specs/adr/`](../specs/adr/adr.md)) and technical design ([`specs/technical/`](../specs/technical/technical.md)) decide tech; cite them, do not choose them here.

Conventions do not apply under `pocs/` ([pocs](pocs.md#what-is-relaxed)).

## Rules

Each rule has a permanent ID `CC-<n>` (never reused) and a level:

- **must**: a violation is a `must-fix` and fails verification.
- **should**: a violation is a `suggestion`.

| ID | Level | Rule |
|----|-------|------|
| CC-1 | must | Naming. snake_case functions, signals, and locals; optional leading `_` on arguments and class variables; PascalCase classes and enums; UPPER_SNAKE_CASE constants and enum members. |
| CC-2 | must | Formatting. GDScript matches gdtoolkit 4.5 `gdformat --check`. |
| CC-3 | must | File layout. Shippable GDScript is under `game/` (M1). No upward or skip-layer references (ADR-0006). |
| CC-4 | should | File layout. One `class_name` per file; the stem is that name in snake_case. |
| CC-5 | must | Errors. Check Godot `Error` returns. Signal failure with `push_error` or a handled value, not `print` alone. |
| CC-6 | should | Logging. `push_warning` for recoverable problems, `push_error` for failures, `print` only for non-failure traces. |
| CC-7 | must | Tests. `game/**/*_test.gd` extends `SceneTree` and `quit`s non-zero on failure. Not under `pocs/` or `.github/scripts`. |
| CC-8 | must | Tests. Coverage fails when main-code statement-line coverage is under 80. |

Past 500 words, split under `docs/coding-conventions/` and link.

## Tooling

Each command is one step in [`code-lint.yml`](../.github/workflows/code-lint.yml) (`Code lint`). Both read `.gd` files and do not need `project.godot`.

| Tool | Command | Enforces |
|------|---------|----------|
| gdformat 4.5.0 | `gdformat --check game` | CC-2 |
| gdlint 4.5.0 | `gdlint game` | CC-1 |

## Unit tests

One step in the `Unit tests` job of [`unit-tests.yml`](../.github/workflows/unit-tests.yml). Main code under `game/` (M1), not `pocs/` or `.github/scripts`. Not `None`. While `game/` has no `*_test.gd`, the command exits 0 and does not invoke Godot.

| Tool | Command | Scope |
|------|---------|-------|
| Godot 4.7.2 headless | `python3 .github/scripts/gdscript_tests.py test` | `game/**/*_test.gd` |

## Coverage

Runs after `Unit tests` (`needs`). Threshold **80**. Not `None`. The same skip applies (exit 0, Godot not invoked). Once `*_test.gd` exists, the command fails under 80. Not the playtest `ENV.1` smoke. Details: [gdscript.md](coding-conventions/gdscript.md).

| | |
|--|--|
| Threshold | 80 |
| Godot 4.7.2 statement lines | `python3 .github/scripts/gdscript_tests.py coverage` |
