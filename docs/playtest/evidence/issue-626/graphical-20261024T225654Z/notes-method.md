# Notes — method — #626 mobile-browser sitting

Method findings kept for the next run. Readings in [manifest.md](manifest.md); the seat in
[seat.md](seat.md).

## Why `Page.setWebLifecycleState` is not the background leg

The first two attempts froze the page with `Page.setWebLifecycleState: frozen` and resumed with
`active`. That path **does not resume in this headless build**: after resume the page keeps
`document.hidden: true`, `requestAnimationFrame` never fires, and every later input dispatch
hangs (`logs/probes/resume-path.json`). Once that was measured, the driver switched to a real
second-tab backgrounding (`logs/probes/background-tab.json`), which is what a phone's app switch
looks like from the page's side. Neither attempt is used as a row: they are recorded as method
findings in `logs/`.

## What to carry into the next sitting

- `Page.setWebLifecycleState` frozen→active does not resume (above).
- Repeated `Page.reload` alone leaves touch working (243–379 ms taps); the wedge came from the
  freeze, not from reloading.
- The board's control row has no puzzle-stream entry; the puzzle stream is reached from mode
  pick only, and #655 keeps it from dealing.

## The build's asset state, measured on this commit

The boot group resolves (`Preload boot left 0`), but this commit predates the audio-route repair
(`d21bbf6`, #785's fix, merged after `c5b8189`), so the board's cues and the café ambience are
silent. That is **#785's repair already merged and not yet published on this commit**, not a new
defect, and it is not re-filed. It does affect what Advice-Off can show by ear: audibility is
#627's row, not this one. The exact lines are in [builds.md](builds.md).
