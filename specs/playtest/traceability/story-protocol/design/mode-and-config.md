# Design story view: mode-and-config

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [design story view](index.md); rule: [map index](../../story-protocol.md). Rows whose `Spec key` is `CFG` or `FL-mode-pick` (key-level cites), plus rows proving only `CFG.*` tunables that the bare `CFG` cite covers.

**Element** is the cite token from the judging protocol that covers the row. **Judged by** lists every protocol that covers it.

| Story row | `Spec key` | Element | Judged by |
|-----------|-----------|---------|-----------|
| [`configuration.md#PS1`](../../../../design/stories/configuration.md#PS1) | `CFG` | `CFG` | `mode-and-config` |
| [`flows/mode-pick.md#PS1`](../../../../design/stories/flows/mode-pick.md#PS1) | `FL-mode-pick` | `FL-mode-pick` P1, N1… | `mode-and-config` |
| [`flows/mode-pick-unavailable.md#PS1`](../../../../design/stories/flows/mode-pick-unavailable.md#PS1) | `FL-mode-pick` | `FL-mode-pick` P1, P2… | `mode-and-config` |
