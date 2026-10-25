# Manifest — #626 mobile-browser sitting (phone-class viewport)

- **Issue**: #626 — Run #558's sitting soak and #557's durability legs on a phone browser, where
  the sitting actually happens.
- **Environment**: `graphical` (`ENV.2`) — headless Chrome **156.0.8078.47**, viewport
  **390×844 CSS px**, DPR 2, touch emulation, macOS 27.0.1 arm64. **No phone hardware attached**;
  see [seat.md](seat.md).
- **Build / session id**: **published** release `https://waigore.github.io/simplechessv2/`, commit
  **`c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96`**, `Web release` run **`40118381611`** (success,
  2026-10-24T17:56:09Z). Source: **published URL** — the issue's preferred build source, used
  because it serves a commit carrying #647's repair (`bccdb1c`) and it leaves `EX.loading` with
  the boot group resolved. **No `Web Release` export fallback was needed.** Details:
  [builds.md](builds.md).
  `TEL.3` session id: **none** — the release strips `CMP-playtest-seams` (ADR-0004 `G2`), so no
  session id is emitted and none is invented. Correlation key: commit sha + this folder.
- **Timing (`SIT.4` runs)**: not a `SIT.4` timing run — this is a soak/durability reading. One
  continuous sitting of **15.40 minutes** (first mark 2026-10-25T00:02:22.817Z, last
  2026-10-25T00:17:46.656Z), one page, one browser profile, **56 marks**, no repeat count
  required by the rows read.
- **Coverage mode**: `critical-only` — the three rows this issue names, plus the Advice-Off
  observation it cites.

## Build gate — the build under test is readable

| Reading | Value | Source |
|---|---|---|
| Build leaves `EX.loading` and reaches mode pick | **yes** | `screenshots/sit-01-01-mode-pick-cold.png` |
| `Error opening file 'game_assets/…'` lines | **0** | [logs/probes/sit-probe1.json](logs/probes/sit-probe1.json) `reading.openFailedCount`, [boot console](logs/) |
| `Preload boot left N approved IDs unresolved` | **absent** (0 unresolved) | same |

This is the `not-judged` gate the issue sets; it **passed**, so the run is graded rather than
recorded `not-judged` for #630's reason.

## Results

The rows, their outcomes, and their bases are in [results.md](results.md).

## Paths

The folder's files are listed in [paths.md](paths.md).

## Defects and reproduce

- **No `type:defect` filed.** Every row that was reached passed; the rows that were not reached
  are `not-judged` by a limit of the seat (handset hardware) or of this build (#655 deals no
  puzzle, no advice backend), and `evidence.md` files no defect for a `not-judged` row.
- **Cited, not re-filed:** **#655** (release deals no puzzle — why Elo cannot change and leg 1
  is unavailable); **#845** (board taps land about one rank above the finger — read again here,
  see [notes.md](notes.md)); **#785** (this commit predates the audio-route repair, so the board's
  cues and ambience are silent — merged as `d21bbf6`, after `c5b8189`).

```sh
cd docs/playtest/evidence/issue-626/graphical-20261024T225654Z
node scripts/sitting.mjs https://waigore.github.io/simplechessv2/ . 16
```

Requires Node ≥ 20 and a Chrome at `/Applications/Google Chrome.app` (or `CHROME_BIN`). Node's
built-in `WebSocket` is used, so no `npm install` is needed.
