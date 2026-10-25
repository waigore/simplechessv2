# Notes — #402 re-record, 2026-10-25T08:35Z

## Seat

`issue-workflow-implement-agent`, agent-orc parallel id 2, worktree
`.orc/worktrees/issue-workflow-implement-agent-2-20261025T083005159810Z`, on a Linux
container (4 vCPU, 7.9 GiB, no GPU device). The published bytes are reachable; the
**browser is not**: Chrome `156.0.8078.47` dies with `SIGSEGV` at `execve` before
`--version`, under every flag set tried (bare, `--no-sandbox`,
`--headless=new --no-sandbox --disable-gpu`, `xvfb-run`), and `strace` shows the fault in
the kernel's read of the executable. No other browser or automation package is
installed; `godot` is not installed either.

So this folder has no screenshot and no timing. A fabricated or borrowed frame would be
a proxy pass, which `specs/playtest/evidence.md` forbids.

## What each `not-judged` means

`not-judged` here means one of two things, never a soft `fail`:

1. **No display on this seat** — rows 1, 2, 5, 7, 9, 10. The build is not accused; the
   reading was not taken. #625 owns 1 and 2 (and the device legs); #557 owns 5 and 7.
2. **The row's own seat is another build or a precondition the release cannot meet** —
   rows 3, 4, 6. Row 3 needs Advice On *and* online, impossible with empty `T9`/`T10`;
   row 4's only `pass` is on `c4202bb`; row 6 is read on the playtest-certified build by
   the body's own rule (#729).

None of the nine is a `pass`.

## What the fail's six points asked, and the answer here

| Point | Answer |
|---|---|
| 1. Re-read on the served build; name the run and the pack | **Done** for identity: `ad9c04d`, run `40176551606`, pack 9 364 800 B ([builds.md](builds.md)). Rendered halves not possible here |
| 2. Performance on a GPU host, or a named seat | **Named seat**: #625 |
| 3. Drive the locale switch | **Not possible** (no browser). Copy tables read from the pack; growth clause shown not exercised by mode pick ([readings.md](readings.md)) |
| 4. Fold #640 / #641 in; cite #888 and #883 | **Done** — row 8 is the one `fail`; both defects listed with states |
| 5. Pick the build that owns Reliability | **Done** — `not-judged` on `ad9c04d`; #558's `pass` cited as another build's |
| 6. Keep what still holds | Kept: #647 asset root, copy tables, transports. #845's `fail` dropped with reasons ([superseded.md](superseded.md)) |

## Next reader

On a host with a working browser: `probe-browser.mjs` (confirm the seat), then
`read-pck.mjs` (pin the build), then `drive.mjs` + `locator.mjs` for cold open, move,
locale switch, crash/reload. #625 is the funded version of exactly that work on a real
device — prefer closing these rows from #625's record over a third browser run.
