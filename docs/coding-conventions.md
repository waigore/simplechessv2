# Coding conventions

Project-owned conventions for code in this repo: language idioms, naming, formatting, file layout, errors, logging, and tests. Once the Engine ADR is Accepted, replace every `<!-- fill in -->`. Template sync keeps this file's project content.

Project conventions are optional. To use only [`solid.md`](solid.md), write `None — SOLID only (<reason>)` as the single Rules row and `None — <reason>` as the single Tooling row. Leftover placeholders mean the choice is still open, not SOLID only.

Review code with [`review-code`](../.agents/skills/review-code/SKILL.md), which checks this file together with [`solid.md`](solid.md).

## Precedence

1. [`solid.md`](solid.md): SOLID principles, owned by the template and applied to every project.
2. This file: project conventions.
3. Structure continuity: patterns inferred from existing code.

A higher level wins. Conventions extend `solid.md` and never contradict it: no rule may require what a principle forbids, such as a central switch over every type (OCP) or core rules importing a vendor SDK (DIP). Do not restate SOLID here; add only what it leaves open. A reviewer ignores a contradicting rule and files a must-fix against this file.

Technology choices are ADRs in [`specs/adr/`](../specs/adr/adr.md); layers, modules, and contracts are in [`specs/technical/`](../specs/technical/technical.md). Conventions may cite them but never decide them.

Conventions do not apply under `demos/` ([demos](demos.md#what-is-relaxed)).

## Rules

Each rule has a permanent ID `CC-<n>` (never reused) and a level:

- **must**: a violation is a `must-fix` and fails verification.
- **should**: a violation is a `suggestion`.

| ID | Level | Rule |
|----|-------|------|
| <!-- fill in: CC-1 --> | <!-- fill in: must or should --> | <!-- fill in: e.g. functions and variables use snake_case; types use PascalCase --> |

Group rows by topic as the table grows. Past 500 words, split into linked files under `docs/coding-conventions/`.

## Tooling

Every lint or format command listed here runs as a step in [`code-lint.yml`](../.github/workflows/code-lint.yml), the `Code lint` check. Reviewers read that check's result instead of running the commands. A rule a tool enforces lists the tool here.

| Tool | Command | Enforces |
|------|---------|----------|
| <!-- fill in: e.g. formatter --> | <!-- fill in: e.g. `fmt --check .` --> | <!-- fill in: CC IDs --> |
