# Results — #626 mobile-browser sitting

One row per claim, each naming the build it was read on. Folder index:
[manifest.md](manifest.md).

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
these cycles*; read it beside #557 and #558, never in place of them. Full text:
[notes-durability.md](notes-durability.md).
