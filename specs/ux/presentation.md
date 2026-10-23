# Presentation

Authoring rules: [`.agents/specs/rules/ux/presentation.md`](../../.agents/specs/rules/ux/presentation.md).

- **Serves**: Instant play, Clear board, Cafe calm; Accessibility, Localization (quality); [ui-style.md](../aesthetics/ui-style.md); screens and journeys.

## Design-system binding

- **Design system**: `linear-app` / `design-systems/linear-app` (Open Design slug for Linear)
- **Content root**: `OPEN_DESIGN_ROOT`, or `~/.open-design-skill/repo` when unset
- **Aesthetics fit**: Realize [`ui-style.md`](../aesthetics/ui-style.md). `linear-app` meets as is: `UIS.I1` iconography (flat 24-unit grid, soft corners) and `UIS.M1`–`M3` interface motion (short ease-out transitions, no bounce). Overridden tokens: colors to `PAL` cream and ink per `UIS.C1`–`C5` roles (not Linear dark/indigo); type to humanist sans per `UIS.T1`–`T3` (not Inter-on-black); panel border and radius per `UIS.F1`–`F2`. Where `linear-app` disagrees, aesthetics win.
- **Accessibility**: Actor-facing labels use `UIS.T2` at 16 px or more; text uses `PAL.K4` ink on cream; cues carry text or shape as well as color; touch targets are 44 px or more.

## Surfaces

| Surface | Screens | Template | Craft |
|---------|---------|----------|-------|
| Meta UI: menus, setup, results | `mode-pick`, `shared-setup`, `shared-result` | `web-prototype` | `state-coverage`, accessibility |
| Play UI: board and in-play overlays | `shared-play`, `puzzle-play` | [`mockups/screens/_template.html`](mockups/screens/_template.html) | `state-coverage`, accessibility |
