# Notes — #558 sitting soak, Advice-Off and offline observation

Build, window, and outcomes: [manifest.md](manifest.md). Numbers: [readings.md](readings.md).

## What was judged

One continuous sitting on the local `Web Release` export of `c4202bb`, driven through the
shipped screens at `ENV.2`: mode pick, a full Shared game, a Puzzle stream attempt, a
quit-and-reopen, an offline Advice-On game, and an idle band on mode pick. The sitting ran
**15 min 22 s** with **no crash and no forced exit**. It is inside the 15–40 minute window
`quality.md` Reliability names.

The two advice legs were read from the same sitting, on the same build, as the task asks.

## Advice Off (`F-move-advice.R2`, `R9`)

- Setup showed the **`advice_off`** copy (`Advice Off` on the play screen,
  `sitting-02-advice-off-setup.png`). This is the state #793 repaired; the published `c5b8189`
  renders it unreadable, which is why this run used the local export.
- `1. f3` was played with Advice Off. After the move the board carried **no advice marks** and
  no evaluation text (`sitting-06-g4-after.png`: Black to move, no highlight beyond the pieces).
- `GS.adviceBestMove` and `GS.adviceEval` stayed **null** before and after the move, with
  `GS.advice` false and no error field set.

## Offline and On (`F-move-advice.R2`, `R9`)

- The build shipped with an **empty advice endpoint** (`T9`/`T10` unset on this export), so
  there is no backend to reach. That is the state #558 asks about: an offline-and-On session
  that never had a backend.
- Network was cut with CDP `Network.emulateNetworkConditions { offline: true }` before the game.
  `1. e4 e5` were played with `Advice On`.
- No evaluation appeared, no marks rendered (`sitting-reopen-33-offline-after-wait.png`), and
  **no S3 error** was shown. `GS.adviceBestMove` / `GS.adviceEval` stayed null and
  `GS.online` read false.

## Reopen inside the sitting

The browser was quit and relaunched on the same profile at 00:14:15Z and reopened at 00:14:35Z
onto mode pick. The stored document was **byte-identical** before and after
(`last_mode` `puzzle`, `player_elo` `1000.0`), so the reopen leg neither lost nor corrupted a
commit.

## How the state was read — `DBG.2` limitation

The release export carries **no `PlaytestSeams`** (ADR-0004 `G2`), so `DBG.2` cannot be called
on the shipped build at all. The task names `DBG.2`; that seam only exists on the
playtest-certified build, and running the soak there would not read the shipped build in the
form #558 describes.

To read the fields anyway, this run added a headless **release-graph probe**
(`logs/probe_release_state.gd`) that loads the same `res://main_release.tscn` the preset
exports, drives it through `Presentation`'s control path, and reads
`SharedGameSession.play_state()` — the data `DBG.2` returns. It changes nothing: the session is
built by the shipped router from the shipped configuration, with the empty advice endpoint the
release ships. Result: **26 checks, 0 failures** (`logs/probe-release-state.log`), covering the
Advice-Off start and after-move reads, the online-On unavailable case, and the offline-and-On
after-move read.

This is the method limit to carry into acceptance: the field values are read from the release
scene graph, not from a `DBG.2` call on a playtest build. The screen evidence (marks absent,
no S3 error, `advice_off` copy) comes from the same build in the same sitting, so the two agree.

The probe emits one `ObjectDB instances were leaked at exit` warning when the headless harness
shuts down. That is the probe's own `SceneTree` teardown, not a game crash, and it appears
outside the sitting window.

## Driving method

Screens were driven over CDP with coordinates derived from each screenshot (the UI reflows and
shrinks as the board rebuilds), never from hardcoded rows. The board was located from the dark
square colour only: the light square colour also paints the band above the board, which is the
trap #845 exposed in the published build.

The Advice-Off game is a complete Shared game through fool's mate (`f3`, `e5`, `g4`, `Qh4#`),
which reaches the real "Game over / Black wins" screen. The Puzzle leg dealt a position and
played one move, then left the stream through its confirm dialog. Resign went through its own
confirm dialog.

## Not judged here

- **Audio** — `SND.L1`–`L2` ambient beds are #567's row; the second bed is not on this build.
  Recorded as not-judged for that row, not as a pass.
- **Load time, Performance, Observability, Save durability, Accessibility, Localization** — other
  `quality.md` rows with their own owners and runs. The reopen leg here is not a substitute for
  #402's `Page.crash` reopen row.
- **`TEL.*`** — the release build emits no telemetry by specification, so no `TEL.*` row is
  claimed from this run.

## Marks

None blocking. Two non-blocking observations, both harmless and neither a spec breach:

1. The headless probe's `ObjectDB` leak warning at exit, described above.
2. During the offline idle band the game sat still for ~60 s with no visible change; the
   heartbeats confirm the page stayed alive.
