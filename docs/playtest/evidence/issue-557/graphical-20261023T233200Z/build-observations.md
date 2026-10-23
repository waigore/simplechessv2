# Build observations — #557 run `graphical-20261023T233200Z`

- **Cold open, 20 s settle** (`logs/leg-0-cold-open.log`): WebGL context and Godot banner present; the boot group's asset files fail to open; `Preload boot left 9 approved IDs unresolved`; the canvas still renders "Loading…" (`screenshots/leg-0-cold-open-390x844.png`).
- **`localStorage` holds no key at all** after the clean cold open (`logs/driver.log`: `localStorage keys after clean cold open: []`). The release export never writes a persistence document on this build, so no leg can begin from a value the build committed.
- **The published `index.pck` is `251 904` bytes.** It carries the catalog's asset *paths* in manifest text but not the bytes: `GET /game_assets/icons/quit.svg` answers `404`. That is the #630 / #647 route gap, restated only as why this run is blocked.
- **Same on the current build as on its predecessor**: this run measured `3f81b59`; #630's own rerun recorded the identical stall, so the boot gap is not a build-to-build artifact.
