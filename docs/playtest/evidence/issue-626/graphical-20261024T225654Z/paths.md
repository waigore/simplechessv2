# Paths — #626 mobile-browser sitting

What is in this folder and what each part is for. Readings: [results.md](results.md).

- [manifest.md](manifest.md) — the run header: issue, environment, build, timing, coverage mode,
  and the build gate
- [results.md](results.md) — one row per claim, outcome and basis
- [builds.md](builds.md) — the build read, the export control, the audio state on this commit
- [seat.md](seat.md) — the environment, what it reaches, what stays `not-judged`
- [notes.md](notes.md) — judgement index: what the run is, the board-read caveat, Advice-Off
- [notes-method.md](notes-method.md) — method findings kept for the next run
- [notes-durability.md](notes-durability.md) — the Elo caveat and what a phone run still owes
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
