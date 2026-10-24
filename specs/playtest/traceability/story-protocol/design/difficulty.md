# Design story view: difficulty

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [design story view](index.md); rule: [map index](../../story-protocol.md). Rows whose scenarios prove `DIF` `Y1` or `C1`. `Y1` is a contract-level entry in the row header, since `difficulty.md` has no numbered table.

**Element** is the cite token from the judging protocol that covers the row. **Judged by** lists every protocol that covers it.

| Story row | `Spec key` | Element | Judged by |
|-----------|-----------|---------|-----------|
| [`difficulty.md#PS1`](../../../../design/stories/difficulty.md#PS1) | `DIF` | `DIF` Y1,C1; `CFG` (CFG.ELO_K, CFG.ELO_MATCH_RANGE…) | `difficulty`, `mode-and-config` |
| [`difficulty-tunables.md#PS1`](../../../../design/stories/difficulty-tunables.md#PS1) | `DIF` | `CFG` (CFG.ELO_K, CFG.ELO_MATCH_RANGE…) | `mode-and-config` |
| [`difficulty-repeat.md#PS1`](../../../../design/stories/difficulty-repeat.md#PS1) | `DIF` | `DIF` Y1 | `difficulty` |
