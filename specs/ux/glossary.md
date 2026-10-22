# UX Glossary

Authoring rules: [`.agents/specs/rules/ux/glossary.md`](../../.agents/specs/rules/ux/glossary.md).

- **Serves**: Instant play, Clear board, Cafe calm; Shared game and Puzzle stream (definition); the UX specs, deferring to [design/glossary.md](../design/glossary.md) and [view/glossary.md](../view/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Actor | A person at the device who may touch the screen. The interface does not identify which person touched, and it does not allow or refuse a control by game seat. | [`actors/`](actors/) |
| Binding | A mapping from one platform input to one UI action. | [`controls.md`](controls.md) |
| Board coordinates | File letters a–h and rank numbers 1–8 shown only along the outer board edges. | [`screens/shared-play.md`](screens/shared-play.md), [`screens/puzzle-play.md`](screens/puzzle-play.md) |
| Control | A named thing an actor operates on a screen. | [`screens/`](screens/) |
| Copy key | A named player-facing string: its owner plus a snake_case key, as in `puzzle-play.cue_solved`. | [`localization.md`](localization.md) |
| Copy owner | The screen whose Copy table holds a string, or `exceptions` for a shared exception string. | [`localization.md`](localization.md); [`exceptions.md`](exceptions.md) |
| Design-system binding | The Open Design system the mockups are bound to; not an input Binding. | [`presentation.md`](presentation.md) |
| Exception | A shared interface state, such as loading, empty, or error. | [`exceptions.md`](exceptions.md) |
| Focus | The control that keyboard or gamepad input currently targets. | [`controls.md`](controls.md) |
| Journey | An ordered path an actor takes through existing screens to reach a goal. | [`journeys/`](journeys/) |
| Mockup | A self-contained HTML view of one screen, or a click-through of one journey. | [`mockups/`](mockups/) |
| Region | A named part of a screen that shows specific content. | [`screens/`](screens/) |
| Screen | One interface surface with one job. | [`screens/`](screens/) |
| UI action | A named interface command, such as confirm or back. | [`controls.md`](controls.md) |
