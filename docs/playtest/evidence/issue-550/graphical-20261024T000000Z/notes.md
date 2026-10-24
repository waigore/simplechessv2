# Graphical notes — #550

Same build as the headless twin: `origin/main` `614746c`, Godot `4.7.2.stable.official.ed1daf0bf`, `ENV.2`, macOS window at the project's default 1280×720. Run:

```
godot --path game -s res://../docs/playtest/evidence/issue-550/graphical-20261024T000000Z/probe/accept550_graphical.gd
```

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-mode-pick-en.png` | Mode pick: "Choose how to play", Shared game, Puzzle stream, Quit, English. |
| `02-mode-pick-zh-Hant.png` | After `C4`: 選擇遊玩方式 / 謎題串流 / 結束 / 繁體中文. |
| `03-mode-pick-ja.png` | After another `C4`: 遊び方を選ぶ. |
| `04-puzzle-play-entry.png` | `C2` → puzzle play. Board, Reveal, Abandon and Leave stream render, but **no puzzle is open** and no cue shows. |
| `06-puzzle-leave-confirm.png` | `C5` with no open puzzle: no confirm is raised, so cancel is unreachable. |
| `07-shared-play-move.png` | Shared play after `e2`→`e4`: the move lands. |
| `08-shared-play-reject.png` | After an illegal `d7`→`d3`: refused, still in shared play. |

## What this adds to the headless verdict

The headless run proved no deal arrives. These captures show what the player sees: a complete puzzle-play layout whose controls are inert because the stream has nothing open. That is the same #655 failure, rendered.

`PTU-controls` and `PTU-exceptions` are judged here rather than headless because they need a rendered board to hit-test; both pass.

## Frame

Captures use the project's default 1280×720, as #483's graphical evidence did. `PTU-mode-pick` S6 (`SIT.6`, phone width 390×844) is **not-judged**: the post-boot frame reflow that legibility check needs is #546's open finding, and this run does not claim a result it cannot render honestly.

## Checks recorded in the log

- `A550G_PROBE fail` — the two puzzle protocols fail, matching the headless twin.
- `A550G display=macOS session=sess-1792789467220-40296-playtest`.
- Every capture reports `err=0` at 1280×720.

## Prep

Unit tests, coverage, lint, and spec lint are recorded once in the headless twin; this run re-runs only the driver, on the same build.
