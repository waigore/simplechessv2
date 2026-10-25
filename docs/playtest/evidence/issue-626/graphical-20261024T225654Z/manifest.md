# Manifest — #626 mobile-browser sitting (phone-class viewport)

- **Issue**: #626 — Run #558's sitting soak and #557's durability legs on a phone browser, where
  the sitting actually happens.
- **Environment**: `graphical` (`ENV.2`) — headless Chrome **156.0.8078.47**, viewport
  **390×844 CSS px**, DPR 2, touch emulation, macOS 27.0.1 arm64. **No phone hardware attached**;
  see [builds.md *What the phone-class viewport does and does not reach*](builds.md) and
  [notes.md *The seat*](notes.md).
- **Build / session id**: **published** release `https://waigore.github.io/simplechessv2/`, commit
  **`c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96`**, `Web release` run **`40118381611`** (success,
  2026-10-24T17:56:09Z). Source: **published URL** — the issue's preferred build source, used
  because it serves a commit carrying #647's repair (`bccdb1c`) and it leaves `EX.loading` with
  the boot group resolved. **No `Web Release` export fallback was needed.**
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

Each row names the build it was read on.

| Row | Claim | Outcome | Basis |
|---|---|---|---|
| Reliability — sitting soak (mobile browser) | One continuous 15–40 minute sitting does not crash, discard the tab, or lose the run | **pass**, with the phone-hardware limit named | 15.40 min continuous, 56 marks, **0** crash/abort/memory lines in [logs/sit-console.log](logs/sit-console.log); page still visible, producing frames, and accepting a tap (**814 ms**) at the window's end (`sit-14-window-closed`) |
| Reliability — background/foreground interruption inside the sitting | The sitting survives a background/foreground cycle and the run is not lost | **pass** | 45.0 s backgrounded via a second tab; on return `document.hidden: false`, **10/10** rAF frames, tap accepted in **658 ms**; the board was still drawn (`sit-10-foreground-return`) |
| Save durability — background/return | Committed document is held across background/return | **pass** (Elo unchanged — see limit) | `localStorage['simplechessv2.persist.v1']` byte-identical before/after: `{player_elo: 1000, last_mode: 'shared', recent_solved: [], version: 1}` |
| Save durability — quit/reopen | Committed document survives a quit and reopen in the same profile | **pass** (Elo unchanged — see limit) | Same document after reopen; mode pick rendered (`sit-11-mode-pick-after-reopen`) |
| Save durability — reload | Committed document survives a reload | **pass** (Elo unchanged — see limit) | Same document after `Page.reload {ignoreCache}`; mode pick rendered (`sit-12-mode-pick-after-reload`) |
| Advice-Off (`F-move-advice` R2, `PTD-move-advice` S4/F2) | With Advice Off there is no evaluation and no advice display | **pass for the Advice-Off arm** | Control settles to `Advice Off` (`sit-05-advice-off-settled`); a tile tap with Advice Off shows the selection ring and legal-move diamonds and **no** best-move arrow or eval text (`sit-06-advice-off-after-tap`, `sit-07-advice-off-still-1..3`) |
| Advice-Off — offline arm (`PTD-move-advice` S4/F2, R2 *offline*) | Going offline also clears advice and stops evaluation | **not-judged** | The build publishes no advice backend, so there is no online advice stream to clear; nothing could be observed |
| `PTD-move-advice` protocol verdict | Every cited row (R1–R9) passes in this environment | **not-judged** | Only the Advice-Off arm was in scope; R1, R3–R9 were not read here |
| Tab discard / `localStorage` eviction / OS suspension on a handset | The phone-specific failure modes are covered | **not-judged** | No phone hardware attached; a phone-class viewport cannot evict storage under device pressure or suspend an OS process |

**Why the durability rows say "Elo unchanged — see limit", not a weaker `pass`:** the three
cycles are real and the document is byte-identical across all of them. What they cannot show is a
*changed* Elo surviving, because nothing on this build can change it: Elo moves only at
`SEQ-puzzle-result-commit` and the release deals no puzzle (**#655**, open). #557's leg 1 records
the identical limit from the desktop side. The reading is a `pass` for *committed values survive
these cycles*; read it beside #557 and #558, never in place of them.

## Paths

- [builds.md](builds.md) — the build read, the export control, the environment, what the seat reaches
- [notes.md](notes.md) — judgement text, the seat, method findings, the board-read caveat
- `sit.json` — every mark with its wall-clock time, store read, and control read
- `screenshots/` — 56 sitting frames plus 8 probe frames (`resume-active`, `freeze-03-after-resume`,
  `background-03-foreground-return`, `layout-01-board`, `layout-02-advice-tapped`,
  `control-04-tap-board-menu`, `touch-04-after-touch-e2`, `responsive-03-after-touch`)
- `logs/sit-console.log`, `logs/sit-network.log` — the judged window
- `logs/gate-{engine,assets,boot,groups}.log` — the release gates over the local `Web Release`
  export of `9ed334a` (the control build; **not** a published reading)
- `logs/probes/` — the method probes this run needed: `resume-path.json`,
  `background-tab.json`, `after-freeze.json`, `after-reload.json`, `layout.json`,
  `controls.json`, `touch-map.json`, `move-probe.json`, `board-map.json`, `responsive.json`,
  `freeze.json`, `sit-probe1.json` (an aborted earlier sitting)
- `scripts/` — the drivers: `sitting.mjs` (the graded run), `cdp.mjs`, `pixels.mjs`, and the probes

## Defects

- **No `type:defect` filed.** Every row that was reached passed; the rows that were not reached
  are `not-judged` by a limit of the seat (handset hardware) or of this build (#655 deals no
  puzzle, no advice backend), and `evidence.md` files no defect for a `not-judged` row.
- **Cited, not re-filed:** **#655** (release deals no puzzle — why Elo cannot change and leg 1
  is unavailable); **#845** (board taps land about one rank above the finger — read again here,
  see [notes.md](notes.md)); **#785** (this commit predates the audio-route repair, so the board's
  cues and ambience are silent — merged as `d21bbf6`, after `c5b8189`).

## Reproduce

```sh
cd docs/playtest/evidence/issue-626/graphical-20261024T225654Z
node scripts/sitting.mjs https://waigore.github.io/simplechessv2/ . 16
```

Requires Node ≥ 20 and a Chrome at `/Applications/Google Chrome.app` (or `CHROME_BIN`). Node's
built-in `WebSocket` is used, so no `npm install` is needed.
