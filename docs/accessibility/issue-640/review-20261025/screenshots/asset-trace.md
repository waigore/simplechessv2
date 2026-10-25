# Asset trace — the twelve shipped sprites (#640)

Parent: [`silhouette-naming.md`](silhouette-naming.md)

Both sides are identical in solid black, so the sheet renders **six** types (one per type,
from the white-side sprite) and names all twelve shipped assets here. Twelve IDs, six
figures — never twelve judged rows.

| `asset_catalog` entry ID | Sprite asset ID | File | Sheet row |
|---|---|---|---|
| `01a15dab-051c-75dc-8624-91f1c45f98f7` | `piece-sprites/k-white` | `game_assets/piece-sprites/k-white.png` | A (King) |
| `01a15dab-051c-7392-9318-e8b69bf7abf2` | `piece-sprites/k-black` | `game_assets/piece-sprites/k-black.png` | A (King) |
| `01a15dab-051c-7023-973b-0b37ef3aa1b3` | `piece-sprites/q-white` | `game_assets/piece-sprites/q-white.png` | B (Queen) |
| `01a15dab-051c-784b-859a-1d347edf39f0` | `piece-sprites/q-black` | `game_assets/piece-sprites/q-black.png` | B (Queen) |
| `01a15dab-051c-73ff-96fa-a75c6719313a` | `piece-sprites/b-white` | `game_assets/piece-sprites/b-white.png` | C (Bishop) |
| `01a15dab-051c-7061-9aaf-f2ba5a069413` | `piece-sprites/b-black` | `game_assets/piece-sprites/b-black.png` | C (Bishop) |
| `01a15dab-051c-7155-b8ec-6de860bae114` | `piece-sprites/n-white` | `game_assets/piece-sprites/n-white.png` | D (Knight) |
| `01a15dab-051c-72b6-8859-f3edab33c514` | `piece-sprites/n-black` | `game_assets/piece-sprites/n-black.png` | D (Knight) |
| `01a15dab-051c-7c3f-94fc-ce51926b3549` | `piece-sprites/r-white` | `game_assets/piece-sprites/r-white.png` | E (Rook) |
| `01a15dab-051c-73b7-bad0-e6df05f4d2b6` | `piece-sprites/r-black` | `game_assets/piece-sprites/r-black.png` | E (Rook) |
| `01a15dab-051c-7db1-8f3e-9cb5e68058d8` | `piece-sprites/p-white` | `game_assets/piece-sprites/p-white.png` | F (Pawn) |
| `01a15dab-051c-73c8-9edc-c4e82957f267` | `piece-sprites/p-black` | `game_assets/piece-sprites/p-black.png` | F (Pawn) |

All twelve entries are `state: approved`, `version: 1`, one file each, under ADR-0005's
catalog root `asset_catalog/` and asset root `game_assets/`. Nothing comes from `demos/`.
