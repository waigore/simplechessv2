# Technical Glossary

Authoring rules: [`.agents/specs/rules/technical/glossary.md`](../../.agents/specs/rules/technical/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Advice backend | Server process that is the sole UCI peer to Stockfish and streams advice to the client. | [`modules.md`](modules.md) M2; [`CMP-advice-backend`](components/advice-backend.md); [ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md) |
| Component | A named unit of runtime responsibility with defined peers and communication. | [`components/`](components/) |
| Contract | A behavioral interface between components: operations, events, and guarantees. | [`contracts/`](contracts/) |
| Diagram | A Mermaid or HTML drawing of one technical spec's structure or flow; the [view sense](../view/glossary.md) differs. | [`diagrams/README.md`](diagrams/README.md) |
| Edge | L4 band: persist, advice client, asset resolver, playtest seams. | [`layers.md`](layers.md) L4 |
| Layer | A dependency band: what may call or depend on what. | [`layers.md`](layers.md) |
| Module | A packaging or source boundary that groups components or code. | [`modules.md`](modules.md) |
| Persist document | Whole JSON blob in `localStorage` for Elo, Last mode, and recent solved IDs. | [`schemata/persist-doc.md`](schemata/persist-doc.md) |
| Playtest build | Client export that includes DBG/TEL seams; not the public release Web export. | [`verification.md`](verification.md); [ADR-0004](../adr/decisions/0004-dual-playtest-environments.md) |
| Playtest seams | Playtest-build-only DBG/TEL drive and observe surface. | [`CMP-playtest-seams`](components/playtest-seams.md); [`CTR-playtest-drive`](contracts/playtest-drive.md) |
| Puzzle attempt | Current puzzle deal, played prefix, and outcome before Elo commit. | [`SCH-puzzle-attempt`](schemata/puzzle-attempt.md) |
| Resolver | The one component that reads the asset manifest and turns an asset ID into a loaded engine resource. | [`asset-access.md`](asset-access.md); [`components/asset-resolver.md`](components/asset-resolver.md) |
| Schema | The shape and lifecycle of a data object or entity in code. | [`schemata/`](schemata/) |
| Sequence | An ordered interaction across components and contracts. | [`sequences/`](sequences/) |
| Telemetry sink | Playtest build stdout: one JSON object per line (NDJSON) for `TEL.*` events. | [`verification.md`](verification.md) H3 |
