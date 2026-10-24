# Notes — #557 graphical run `20261024T022315Z`

## Verdict

All three legs and both `quality.md` claims are **`not-judged`**. No mode pick rendered, no puzzle dealt, no result commit ran, no persistence write attempted. Raw output: `run.json`, `logs/`, `screenshots/`; readings in `readings.md`.

## Why this run is not the previous two

The runs of 2026-10-23T23:06Z and 2026-10-24T01:20Z recorded the same stall. This one adds:

- **A real console on every open.** The driver attaches listeners before the first navigation; a listener attached after `goto` misses the boot log, which is why the earlier folder's logs were near-empty. All three legs now carry the 102-line log.
- **A counted fault.** Leg 3 reports `attempts: 0`, which is the finding: `_web_set` was never called, so `EX.save-failure` could not be provoked without first producing a commit.
- **Blockers re-read at run time.** #630's repair (#647, PR #712 → `bccdb1c`) is on `main`, but `Web release` fails at its own `--check-assets` step, so no repaired build publishes (#677).
- **No sibling run cited as the same build** — #402's record measures `98d3473`; this run measures `fb1e57e`.

## Defects

- **#630** — sole cause of every row. Already open; **not re-filed** (a `not-judged` row files no per-row defect).
- **#655 / #648 / #479** — no deal, so no commit. Already open; **not re-filed**.
- **#677** — read path open, export gate red. Already open; **not re-filed**.
- No `type:defect` against **#35**: that rule covers a *failing* leg, and none failed.

## Not done deliberately

- **No local `Web Release` export substituted** — the issue forbids it, and it would not tell the gate what a player sees.
- **No bypass of the stall** — no input synthesised past `EX.loading`, no asset bytes injected into the running engine. The task measures the build a player gets.
- **No change to `specs/`, `game/`, `asset_catalog/` or `game_assets/`** (AC7); leg 3's fault is a browser-side wrapper, installed and restored in-page.
- **No seeded-`localStorage` "survival" reading** — writing the document by hand and reading it back would pass every leg while proving nothing.
- **No guessed pass, no fabricated session id.**
