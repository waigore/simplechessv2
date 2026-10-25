# Attempt log — #868, graphical

Ordered by attempt, so a reader can see which failure was which. No frame from this session judged `US3.3` or
`US3.4`.

| # | Attempt | Returned |
|---|---|---|
| 1 | Run from the first harness, after a pass that captured 12 frames | `Chrome exposed no page target` — the shell exited under load before serving its target |
| 2 | Repeated after clearing my own stale browsers | Same; a probe at load ~10 started and painted the board |
| 3 | Full pass, `drive.mjs` over a local `Web Playtest` export of `ad9c04d` | 12 frames; White leg painted (`white-s4` destination centre `247,241,232`, four slots `242/240/242/240`, same at `white-ready`), then `white-deselect`, `black`, `no-promotion` returned flat white (8,072 bytes each) |
| 4 | Re-open the last two fixtures in fresh browsers | The first browser painted the first board; the retry script lost the shell at start (`Not attached to an active page`) |
| 5 | Probe: does a released browser paint after `Page.reload`? | Yes — board painted at 12 s, 18 s, and 24 s after reload |
| 6 | Final drive on a clean harness, one browser, reload trusted | Interrupted before the first fixture; nothing captured |

## Console from attempt 3

`logs/drive-console.log` of that pass (deleted with the frames) read, in order: Godot 4.7.2 WebGL 2 startup, two
`shared.start` events on the same session id, `shared.resign` `confirm` and `end`, `shared.end` with
`TEL.4: NAV.T6`, then three `404` resource errors. The 404s are the missing static files this harness does not
serve; the run does not depend on them.

## Running the reproducer

```bash
# 1. serve the export and this folder on one origin
node serve.mjs <exportRoot> /home/waigore/simplechessv2/1/docs/playtest/evidence
# prints http://127.0.0.1:<port>/build/web/index.html

# 2. drive it (the headless shell needs its ALSA library on LD_LIBRARY_PATH)
LD_LIBRARY_PATH=<dir with libasound.so.2> CHROME_BIN=<chrome-headless-shell> \
  node drive.mjs http://127.0.0.1:<port> .

# 3. read the frames offline
node read.mjs .
```

`drive.mjs` writes `readings.json`, `screenshots/`, and `logs/drive-console.log` into this folder. `read.mjs` prints
one block per fixture: `origin`, `dest`, the centre between the sprites, and the four slots Queen/rook/bishop/knight.
`ink:1/<brightness>` is painted, `---` is plain tile.
