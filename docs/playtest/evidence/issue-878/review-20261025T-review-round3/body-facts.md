# #878 round 3 — facts the body cites, re-read

| Body claim | Read-back | Holds |
|---|---|---|
| `B5` says the release ships enabled and a missing pair is a deployment fault | `specs/technical/configuration.md:43` | yes |
| `R9` restates the criterion and cites `B5` | `specs/technical/components/catalog-service.md:23` | yes |
| ADR-0015 is `Status: Proposed`, decides no project backend, catalog route on the operator's host | `specs/adr/decisions/0015-*.md:5`; `R8` names the operator as host owner | yes |
| `#648` is `status:pending-clarification` and holds the posture question, unanswered | live label read; latest comment 2026-10-25T00:34Z is a planner pass, not a PO answer | yes, for the posture question |
| `#329` delivered the serve route | `advice_backend/catalog.py` exists; `#329` `status:accepted` | yes |
| `#479` records client delivery as a deploy-time decision, advice-scoped | `#479` `status:accepted`, no live edge | yes |
| `#655` records the empty stream | `#655` `status:pending-implementation`, cites `session_router.gd:33-34` | yes |
| `game/` does not change: `session_router.gd` initialises both | `session_router.gd:33-34` initialise; `:502`, `:571`, `:793` only read | yes, as far as it goes |
| `puzzle_play_flow.gd` already receives them | `puzzle_play_flow.gd:40` forwards both into `CatalogDealClient.configure` | yes |
| `CatalogDealClient.is_available()` guards on empty values | `catalog_deal_client.gd:34` `configure`, `:39` `is_available` | yes |
| Technical element IDs exist | `B5`, `T9`, `T10`, `R6`–`R9`, `SCH-puzzle-catalog`, ADR-0008/0010/0015 present at the cited paths | yes |

Technical-elements check passes: every layer, module, component, contract, schema and ADR the
title and body name exists on `main`.

What the table does **not** support is the inference the body draws from the `session_router.gd`
row — that both values are already available, so `game/` needs no change. Initialising a value to
`""` and reading it three times says nothing about what writes it. See
[`delivery-gap.md`](delivery-gap.md).
