# Presentation

Authoring rules: [`.agents/specs/rules/ux/presentation.md`](../../.agents/specs/rules/ux/presentation.md).

## Binding

- **Design system**: `linear` / `design-systems/linear`
- **Content root**: `OPEN_DESIGN_ROOT`, or `~/.open-design-skill/repo` when unset
- **Aesthetics fit**: Realize [`ui-style.md`](../aesthetics/ui-style.md): override surface/text/accent to `UIS.C` / `PAL` cream and ink; type to humanist sans `UIS.T`; panels to soft warm borders `UIS.F1`. Where linear disagrees, aesthetics win.

## Surfaces

| Surface | Screens | Template | Craft |
|---------|---------|----------|-------|
| Meta UI: menus, setup, results | `mode-pick`, `shared-setup`, `shared-result` | `web-prototype` | `state-coverage`, accessibility |
| Play UI: board and in-play overlays | `shared-play`, `puzzle-play` | [`mockups/screens/_template.html`](mockups/screens/_template.html) | `state-coverage`, accessibility |
