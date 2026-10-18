# Presentation

Authoring rules: [`.agents/specs/rules/ux/presentation.md`](../../.agents/specs/rules/ux/presentation.md).

## Binding

- **Design system**: `linear` / `design-systems/linear`
- **Content root**: `OPEN_DESIGN_ROOT`, or `~/.open-design-skill/repo` when unset
- **Aesthetics fit**: Realize [`ui-style.md`](../aesthetics/ui-style.md). `linear` meets as is: `UIS.I1` iconography (flat 24-unit grid, soft corners) and `UIS.M1`–`M3` interface motion (short ease-out transitions, no bounce). Overridden tokens: colors to `PAL` cream and ink per `UIS.C1`–`C5` roles; type to humanist sans per `UIS.T1`–`T3`; panel border and radius per `UIS.F1`–`F2`. Where linear disagrees, aesthetics win.

## Surfaces

| Surface | Screens | Template | Craft |
|---------|---------|----------|-------|
| Meta UI: menus, setup, results | `mode-pick`, `shared-setup`, `shared-result` | `web-prototype` | `state-coverage`, accessibility |
| Play UI: board and in-play overlays | `shared-play`, `puzzle-play` | [`mockups/screens/_template.html`](mockups/screens/_template.html) | `state-coverage`, accessibility |
