# Asset Catalog Integrity

Authoring rules: [`.agents/specs/rules/assets/catalog.md`](../../../.agents/specs/rules/assets/catalog.md).

Part of [`catalog.md`](../catalog.md).

## Integrity

| ID | Rule | How checked |
|----|------|-------------|
| `I1` | Every file under the asset root, except engine import sidecars, belongs to one entry, and every entry's files exist | CI: `asset_catalog.py` |
| `I2` | Asset IDs are valid UUIDs version 7, unique, and never reused | CI: `asset_catalog.py` |
| `I3` | Every approved entry has a Pass review for its current version, or a review exemption | CI: `asset_catalog.py` |
| `I4` | Every cited ID exists; a planned kind spec named in the hub counts | CI for kind specs and successors; `review-asset` for the rest |
| `I5` | Main code uses no draft or deprecated asset | Code review + CI: main code cites only approved asset IDs from the generated manifest; no path/handle literals |
| `I6` | Every review exemption names the person who granted it | CI: `asset_catalog.py` |
| `I7` | Handles are unique, deprecated entries included, and prefixed by a kind spec the hub names | CI: `asset_catalog.py` |
| `I8` | No entry was generated or touched up with a tool that [`docs/asset-tools.md`](../../../docs/asset-tools.md) bans | CI: `asset_catalog.py` |
| `I9` | Empty or omitted `coverage` on a non–person-supplied entry is allowed only when the asset ID is listed under Style anchors in its kind's `SS1` | CI: `asset_catalog.py` |
| `I10` | In-scope `coverage` matches that kind's Coverage, Naming, and recipe Outputs | CI: `asset_catalog.py` |

### CAT.I10

Check a `draft` or `approved` entry whose `coverage` list is non-empty, including a person-supplied entry. `draft` matches `approved`. Empty `coverage`, omitted `coverage`, and a `deprecated` entry stay out. A deprecated entry adds no claim. `CAT.I9` still covers the three sheet anchors with empty `coverage`.

Each cited ID is a Coverage row of that entry's kind, written `AK-<kind>.V<n>`. Another kind, an unknown row, or an unqualified `V<n>` fails. The handle matches that kind's Naming for the claimed subject. `fonts/noto-sans` and `fonts/noto-sans-cjk` may both list `AK-fonts.V1`; their multi-file `files` lists stay valid without a fonts Naming edit.

When recipe Outputs say one file per coverage row, one file per `V` row, or one `V1` file, `files` has one path and the entry lists only the rows that file carries. Outputs that name `V1 and V2 files` describe the kind, not one handle claiming both rows. Under-claim is a listed `V` ID whose handle or files fail this rule. A Coverage row no entry lists stays valid.

One claim is one in-scope entry that lists that qualified ID. Claims for a row are at most that row's Count maximum. Fewer claims stay valid, including zero and a count below a range minimum, so `1–2` allows 0 or 1. The cap counts entries, not one entry's `files` length. Read Count, Naming, and Outputs from the kind spec. Piece-sprite Outputs are in [`kinds/piece-sprites/recipes.md`](../kinds/piece-sprites/recipes.md).
