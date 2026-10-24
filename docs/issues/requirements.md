# Issue documentation requirements

Applies to every issue, whether filed from the GitHub form or by a skill. Index: [README.md](README.md). Body templates: [body-shapes.md](body-shapes.md).

- Use the exact `##` headings for that type. Do not rename, reorder, or omit required sections.
- Required sections need real content. Optional sections that do not apply use `None` / `none` — do not leave them blank or drop the heading when the skill/form includes them.
- Be specific enough that an agent or human can act without guessing (paths, behaviors, environments).
- Titles are concise and descriptive; no mandatory title prefix.
- Every issue carries exactly one of `type:epic`, `type:task`, or `type:defect` (unless the user explicitly adds more labels).
- Priority is optional on create: unlabeled means normal. Apply `priority:high` or `priority:critical` only when a human requests it; do not apply `priority:normal`. Only humans set or change priority.

## Epic

- **Goal / outcome**: What “done” looks like for the whole epic — observable outcome, not a task list.
- **Scope**: Explicit **in scope** and **out of scope**. Out-of-scope items may belong in other epics; name them when known.
- **Notes**: Design notes, constraints, and links to relevant specs under `specs/` when they exist.

## Task

- **Description**: Concrete unit of work.
- **Deliverables**: Files and areas to change — as specific as possible (paths, modules, specs).
- **Acceptance criteria**: Clear, testable conditions (prefer checkbox list). The task is done only when all pass.
- **Parent**: `#N` of parent epic or task, or `None`.

## Defect

- **Description**: Problem statement — as specific as possible.
- **Expected** / **Actual**: Contrasting behaviors so the failure is unambiguous.
- **Reproduction steps**: Numbered steps when known; otherwise `None`.
- **Additional context**: Platform, build, screenshots, logs, config when relevant; otherwise `None`.
- **Related tasks or defects**: `#N` links for related (not necessarily blocking) work, or `None`.
