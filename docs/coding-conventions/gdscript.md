# GDScript lint, tests, and coverage

Linked from [coding conventions](../coding-conventions.md). Godot 4.7.2 and GDScript ([ADR-0001](../../specs/adr/decisions/0001-godot-engine.md)); domain headless tests on every build ([ADR-0006](../../specs/adr/decisions/0006-layered-client-architecture.md)); client root `game/` ([M1](../../specs/technical/modules.md)).

## Code lint

`gdformat` and `gdlint` (gdtoolkit 4.5.0) read `.gd` sources. They do not need `project.godot`. `gdlint` enforces CC-1 and its default design checks (line length 100 among them). `gdformat` enforces CC-2.

## Unit tests

Command: `python3 .github/scripts/gdscript_tests.py test`.

A unit test is `game/**/*_test.gd` (not under `addons/` or `.godot/`). It extends `SceneTree` and calls `quit(0)` on success and `quit` with a non-zero code on failure. The runner imports the project (`--import`) so `class_name` resolves, then runs `godot --headless --path game -s res://…` (Godot 4.7.2). Set `GODOT_BIN` to that binary; on linux x86_64 the script downloads 4.7.2 when the variable is unset.

While `game/` has no `*_test.gd` scripts, the command exits 0 and does not invoke Godot. When those scripts exist, a failing test fails the job. Missing `game/project.godot` fails the job. This is not the playtest `ENV.1` smoke.

## Coverage

Command: `python3 .github/scripts/gdscript_tests.py coverage`. Threshold 80.

The same skip applies: no `*_test.gd` means exit 0 and Godot is not invoked. Otherwise the command runs the headless tests against a temporary instrumented copy and fails when coverage is under 80. A failing test fails this command too.

Statement-line coverage is the share of executable statement lines in main `game/**/*.gd` (every `*_test.gd`, `addons/`, and `.godot/` excluded) that ran. A statement line is the first line of a function-body statement: `if`, `elif`, `while`, `for`, `match`, `return`, call, assignment, local `var` or `const`, `break`, `continue`, or `pass`. Declarations, blanks, and comments do not count. A body statement on the same line as the declaration that opens that body does not count, so a class-level inline lambda is not probed at class scope. A statement on a later line inside the body still counts. Exactly 80 passes.

gdtoolkit 4.5.0 parses those lines once test scripts exist. The Coverage workflow installs it. The measurement copy is not committed under `game/`.
