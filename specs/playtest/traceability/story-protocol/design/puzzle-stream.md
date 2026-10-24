# Design story view: puzzle-stream

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [design story view](index.md); rule: [map index](../../story-protocol.md). Rows whose scenarios prove `L-puzzle-stream` K steps and E1, `F-puzzle-catalog` `R`/`I`/`X`/`D` elements, or `SC-puzzle-stream-visit` walkthrough steps.

**Element** is the cite token from the judging protocol that covers the row. **Judged by** lists every protocol that covers it.

| Story row | `Spec key` | Element | Judged by |
|-----------|-----------|---------|-----------|
| [`loops/puzzle-stream.md#PS1`](../../../../design/stories/loops/puzzle-stream.md#PS1) | `L-puzzle-stream` | `L-puzzle-stream` K1, K2, K3, K4, E1 | `puzzle-stream` |
| [`loops/puzzle-stream-advance.md#PS1`](../../../../design/stories/loops/puzzle-stream-advance.md#PS1) | `L-puzzle-stream` | `L-puzzle-stream` K2 | `puzzle-stream` |
| [`features/puzzle-catalog.md#PS1`](../../../../design/stories/features/puzzle-catalog.md#PS1) | `F-puzzle-catalog` | `F-puzzle-catalog` R1–R5 | `puzzle-stream` |
| [`features/puzzle-catalog-select.md#PS2`](../../../../design/stories/features/puzzle-catalog-select.md#PS2) | `F-puzzle-catalog` | `F-puzzle-catalog` I1, I2, I3, X1, X2, D1 | `puzzle-stream` |
| [`scenarios/puzzle-stream-visit.md#PS1`](../../../../design/stories/scenarios/puzzle-stream-visit.md#PS1) | `SC-puzzle-stream-visit` | `SC-puzzle-stream-visit` W1.1–W1.4, W2.1–W2.4 | `puzzle-stream` |
