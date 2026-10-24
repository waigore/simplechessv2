# Notes — #557 graphical run `20261024T012000Z`

## What this run judged

The three legs #557 names, on the published release build at `46cec71`. All three are **`not-judged`**, and so are both quality claims they support. No leg reached its comparison state, so nothing was compared and nothing passed.

## Why the legs cannot be judged on this build

Measured this run on the deployed commit; full detail in `build-observations.md`.

1. **Boot never completes** — 15 `game_assets/…` file failures, then `Preload boot left 9 approved IDs unresolved`.
2. **The resolver returns instead of continuing** — `_preload` pushes the error and returns, so `boot_ready` never fires.
3. **The router stays in loading** — `_on_boot_ready` is the only exit from `STAGE_LOADING`, so mode pick never renders.
4. **Nothing is written** — `localStorage` holds no key at all after a 25 s settle, and leg 3's wrapper saw **0** persist writes.

That chain is #630. Its repair is #647, which needs ADR-0014 from #636 (`status:pending-review`). #557 has no reachable build to measure today.

## What I deliberately did not do

- **No seeded `localStorage` "survival" reading.** A synthetic document read back after a reload returns a value whether or not mode pick rendered. Calling that durability would be a `pass` for a user-invisible result.
- **No local `Web Release` export.** The issue forbids it here, and `46cec71` is published, so the `procedures.md` fallback would not apply anyway; the local export has the same stall.
- **No `game/` or `specs/` edit**, no new fault seam. The leg-3 wrapper is browser-side only.
- **No defect invented.** #630 and #648/#479 own every cause.

## Per-leg judgement

- **Leg 1 (quit/reload)** — `not-judged`. Mode pick never rendered, so no puzzle was dealt, no commit ran, and there was no R2 Elo to read before the close. The close and reopen were performed; both document reads are empty, which shows the build wrote nothing rather than that a commit survived.
- **Leg 2 (crash)** — `not-judged`. No uncommitted selection could be made or abandoned. The renderer was killed with CDP `Page.crash`, not the in-game quit, and the reopen re-read the document: still empty.
- **Leg 3 (faulted session)** — `not-judged`. The wrapper was installed before the commit window and restored before the reopen, exactly as specified, but no commit path exists, so it received no write. `G2` / `I2` were never reached and `EX.save-failure` never had an occasion to show. Only the install/restore half holds.

## Screen-read caveat

`visible_text` in `run.json` is empty for every read: the game renders into a WebGL canvas, so DOM text does not carry the screen. Screen observation rests on the screenshots (viewed directly) and the console.

## What would make this judgeable

1. #630 clear — a build whose `boot` group resolves and which reaches mode pick (#647, behind #636).
2. A dealt puzzle and a real commit result (#648/#479), so a committed document exists to survive.
