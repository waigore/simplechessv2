# Notes — #558 sitting soak, Advice-Off and offline observation

Build, window, and outcomes: [manifest.md](manifest.md). Numbers: [readings.md](readings.md).
How state was read: [dbf2.md](dbf2.md).

## What was judged

One continuous sitting on the local `Web Release` export of `c4202bb`, driven through the
shipped screens at `ENV.2`: mode pick, a full Shared game, a Puzzle stream attempt, a
quit-and-reopen, an offline Advice-On game, and an idle band on mode pick. It ran **15 min 22 s**
with **no crash and no forced exit** — inside the 15–40 minute window `quality.md` Reliability
names. Both advice legs were read inside that sitting, on that build.

## Advice Off (`F-move-advice.R2`, `R9`)

- Setup showed the **`advice_off`** copy (`sitting-02-advice-off-setup.png`). This is the state
  #793 repaired; the published `c5b8189` renders it unreadable, which is why this run used the
  local export.
- `1. f3` was played with Advice Off. After the move the board carried **no advice marks** and no
  evaluation text (`sitting-06-g4-after.png`).
- `GS.adviceBestMove` and `GS.adviceEval` stayed **null** before and after the move, with
  `GS.advice` false and no error field set.

## Offline and On (`F-move-advice.R2`, `R9`)

- The build shipped with an **empty advice endpoint** (`T9`/`T10` unset on this export), so there
  is no backend to reach — the state #558 asks about: offline and On in a session that never had
  a backend.
- Network was cut with CDP `Network.emulateNetworkConditions { offline: true }` before the game.
  `1. e4 e5` were played with `Advice On`.
- No evaluation appeared, no marks rendered (`sitting-reopen-33-offline-after-wait.png`), and
  **no S3 error** was shown. Both advice fields stayed null and `GS.online` read false.

## Reopen inside the sitting

The browser was quit and relaunched on the same profile at 00:14:15Z, reopening at 00:14:35Z onto
mode pick. The stored document was **byte-identical** before and after, so the reopen neither lost
nor corrupted a commit.

## Driving method

Screens were driven over CDP with coordinates derived from each screenshot (the UI reflows and
shrinks as the board rebuilds). The board was located from the dark square colour only: the light
square colour also paints the band above the board, the trap #845 exposed.

The Advice-Off game is a complete Shared game through fool's mate, reaching the real "Game over /
Black wins" screen. The Puzzle leg dealt a position, played one move, and left the stream through
its confirm dialog. Resign went through its own confirm dialog.

## Not judged here

- **Audio** — `SND.L1`–`L2` ambient beds are #567's row; the second bed is not on this build.
- **Load time, Performance, Observability, Save durability, Accessibility, Localization** — other
  `quality.md` rows with their own owners and runs. The reopen here is not a substitute for #402's
  `Page.crash` reopen row.
- **`TEL.*`** — the release emits no telemetry by specification; no `TEL.*` row is claimed.

## Marks

None blocking. Two harmless observations, neither a spec breach: the probe's `ObjectDB` leak
warning at harness exit ([dbf2.md](dbf2.md)), and a ~60 s offline idle band with no visible
change, where heartbeats confirm the page stayed alive.
