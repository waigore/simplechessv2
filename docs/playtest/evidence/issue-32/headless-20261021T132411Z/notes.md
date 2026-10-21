# Headless notes

Judged `main` at `11309eb` after `godot --headless --path game --import --quit` (exit 0), then `godot --headless --path game` (exit 0).

The smoke harness jumped to `mode-pick-ready`, inspected that stage, emitted `TEL.4` `EX.loading`, then paused and resumed. Each event carried `TEL.1`, `TEL.2`, `TEL.3`, and `TEL.5` pass. Display server was headless, so this is `ENV.1`.

A boot warning said the manifest is missing. That load is owned by a later asset-pipeline task, not this epic.

Design protocols for pieces, shared game, end conditions, and game state, and UX protocols for screens and controls, are outside this epic's scope. They were not run. The situational tools those protocols cite are present on the playtest build; this run only proves the headless smoke those tools sit on.
