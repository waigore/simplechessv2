# Manifest

- **Issue**: 550
- **Environment**: graphical (`ENV.2`)
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf` (macOS window, OpenGL), `origin/main` `614746c` — the same build id as the headless twin `../headless-20261024T000000Z`. Capture session `TEL.3`: `sess-1792789467220-40296-playtest` (see `logs/graphical-probe.log`).
- **Coverage mode**: `full`, intersected with #550's scope: the UX protocols' graphical half — `PTU-mode-pick`, `PTU-puzzle-session`, `PTU-puzzle-play`, `PTU-controls`, `PTU-exceptions`, `PTU-localization`. Design protocols are headless only ([`evidence.md`](../../../../../specs/playtest/evidence.md): Design folder is headless only).
- **Frame**: the project's default 1280×720 window, as #483's graphical evidence used. `PTU-mode-pick` S6 (`SIT.6` phone-width legibility) is **not-judged**: the post-boot frame reflow it needs is #546's open finding, so this run does not claim it.
- **Defects**: #655 — the same shipped-path deal failure the headless twin found; it is visible here as a puzzle-play screen with no puzzle, no result cue, and inert Reveal / Abandon / Leave controls.
- **Screenshots**: present under `screenshots/` (seven PNGs, 1280×720), covering every judged state.

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-mode-pick` US1 / P1 — both mode entries render interpretable | pass — `01-mode-pick-en.png`: "Choose how to play", Shared game, Puzzle stream, Quit, English |
| `PTU-localization` P1/P2 — `C4` switches copy on the rendered screen | pass — `02` reads 選擇遊玩方式 / 謎題串流 / 結束 / 繁體中文; `03` reads 遊び方を選ぶ |
| `PTU-puzzle-session` S1 / P1 — `C2` opens the stream on the rendered build | pass — `04-puzzle-play-entry.png`: the puzzle-play screen renders |
| `PTU-puzzle-play` US1 / P1 — a dealt puzzle renders playable controls | **fail** — `04`: the board, Reveal, Abandon and Leave stream render, but no puzzle is open and no result cue appears (#655) |
| `PTU-puzzle-session` S3 / P1 — Leave raises `EX.confirm`; Cancel stays | **fail** — `06-puzzle-leave-confirm.png`: `C5` raises no confirm while no puzzle is open, so the cancel path is unreachable |
| `PTU-controls` S1 / P1 — select then place completes a legal move | pass — `07-shared-play-move.png`: `e2`→`e4` played |
| `PTU-controls` S2 / P1 — deselect path | pass — exercised by the same place |
| `PTU-exceptions` S2 / P1 — an illegal place is refused, no crash, stage unchanged | pass — `08-shared-play-reject.png` after `d7`→`d3` |
| `PTU-mode-pick` S6 (`SIT.6`, phone width) | not-judged — frame reflow is #546 |
| **Protocol verdict `PTU-mode-pick`** | **pass** (S6 not-judged in this frame; the legibility leg belongs to #546) |
| **Protocol verdict `PTU-localization`** | **pass** |
| **Protocol verdict `PTU-puzzle-session`** | **fail** — the leave-confirm leg is unreachable with no open puzzle |
| **Protocol verdict `PTU-puzzle-play`** | **fail** — US1 not met on this build |
| **Protocol verdict `PTU-controls`** | **pass** |
| **Protocol verdict `PTU-exceptions`** | **pass** |

## Paths

- `notes.md`
- `probe/accept550_graphical.gd`
- `logs/graphical-probe.log`
- `screenshots/01-mode-pick-en.png`
- `screenshots/02-mode-pick-zh-Hant.png`
- `screenshots/03-mode-pick-ja.png`
- `screenshots/04-puzzle-play-entry.png`
- `screenshots/06-puzzle-leave-confirm.png`
- `screenshots/07-shared-play-move.png`
- `screenshots/08-shared-play-reject.png`

## Defects

- #655 — Puzzle stream deals nothing on the shipped-path build (`T9`/`T10` unset). Visible here as an openable but inert puzzle-play screen.
