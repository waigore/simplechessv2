# Configuration (technical)

Authoring rules: [`.agents/specs/rules/technical/configuration.md`](../../.agents/specs/rules/technical/configuration.md).

- **Serves**: Design tunables bound into client code
- **Informed by**: [`specs/design/configuration.md`](../design/configuration.md); [`CTR-localization`](contracts/localization.md)
- **ADRs**: [ADR-0001](../adr/decisions/0001-godot-engine.md), [ADR-0010](../adr/decisions/0010-advice-backend-stack.md), [ADR-0013](../adr/decisions/0013-puzzle-catalog-api.md)
- **Design config**: [`specs/design/configuration.md`](../design/configuration.md)

## Sources

| ID | Source | Format / shape | Loaded when | Owner |
|----|--------|----------------|-------------|-------|
| S1 | Design tunables table | Compile-time / data constants mirroring `CFG.*` | Client boot | Session / Domain consumers |
| S2 | Persist document | JSON via [`CTR-persist-document`](contracts/persist-document.md) | Cold open | [`CMP-persist-store`](components/persist-store.md) |
| S3 | Runtime options | In-memory `GS.*` configuration fields | Mode setup / play | Shared / puzzle sessions |
| S4 | String tables | Compile-time copy keyed by `GS.locale` (`en`, `zh-Hant`, `ja`). Shape, key naming, completeness, and the `en` source per [`SCH-string-table`](schemata/string-table.md) and [`CTR-localization`](contracts/localization.md). Not a persist field ([`fields-persist`](../design/game-state/fields-persist.md)). Initial value is the browser locale when shipped, else `en` ([`experience.md`](../design/experience.md)). | Boot, and again when locale changes | [`CMP-session-router`](components/session-router.md) owns `GS.locale` |

## Tables and tunables

| ID | Name | Maps to design param | Type | Default / range |
|----|------|----------------------|------|-----------------|
| T1 | blitz_start | `CFG.BLITZ_START` | int seconds | 60 |
| T2 | rapid_start | `CFG.RAPID_START` | int seconds | 600 |
| T3 | elo_k | `CFG.ELO_K` | int | 20 |
| T4 | elo_match_range | `CFG.ELO_MATCH_RANGE` | int Elo | 100 |
| T5 | elo_start | `CFG.ELO_START` | int Elo | 1000 |
| T6 | advice_time_ms | `CFG.ADVICE_TIME_MS` | int ms | 2000 |
| T7 | elo_recent_window | `CFG.ELO_RECENT_WINDOW` | int puzzles | 20 |
| T8 | elo_band_widen | `CFG.ELO_BAND_WIDEN` | int Elo | 50 |
| T9 | advice_endpoint | — (integration value, not a design param; [`ADR-0010`](../adr/decisions/0010-advice-backend-stack.md)) | string URL | Set per deployment; no fixed default |
| T10 | advice_api_key | — (integration value; [`ADR-0010`](../adr/decisions/0010-advice-backend-stack.md), [`ADR-0013`](../adr/decisions/0013-puzzle-catalog-api.md)) | string secret | Set per deployment; never committed; T9 and T10 serve the catalog route too |
| T11 | catalog_rate_limit | — (integration value; [`ADR-0013`](../adr/decisions/0013-puzzle-catalog-api.md)) | int requests per key per minute | 30 |

## Binding

| ID | Consumer | Reads | Fail if missing |
|----|----------|-------|-----------------|
| B1 | [`CMP-shared-game-session`](components/shared-game-session.md) | T1 T2; S3 clock options | Use design defaults; log |
| B2 | [`CMP-puzzle-session`](components/puzzle-session.md) | T3 T4 T5 T7 T8; S2 Elo | [`FAIL.T3`](failures.md) persist read fail: use T5 |
| B3 | [`CMP-advice-client`](components/advice-client.md) | T6 T9 T10 | T6 missing: send 2000 as the O1 `time_ms` (the design default; the search stop stays [`CMP-advice-backend`](components/advice-backend.md) R3). T9 or T10 missing: Advice unavailable ([`FAIL.T1`](failures.md)) when requested; log |
| B4 | [`CMP-presentation`](components/presentation.md) | S4 table for the current `GS.locale`, through [`CTR-localization`](contracts/localization.md) O1 | Unshipped locale reads `en`; a key missing in a locale reads `en` and logs ([`FAIL.T13`](failures.md)); a switch applies immediately ([`experience.md`](../design/experience.md)) |
| B5 | [`CMP-puzzle-session`](components/puzzle-session.md) catalog read; [`CMP-catalog-service`](components/catalog-service.md) | T9 T10 T11 | T9 or T10 missing: every deal fails ([`FAIL.T14`](failures.md)); Elo kept; log |

## Diagram

None — flat constant bind.
