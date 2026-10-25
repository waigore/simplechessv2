# Notes — issue #375 acceptance run

Back to [`manifest.md`](manifest.md) and the [`ledger.md`](ledger.md). Issue #375, epic #36.

## What this run exists for

Acceptance after the 2026-10-24 verification. Two earlier artifacts disagreed about the S3 `EX.error` leg: the implementor's graphical run on `abc6469` recorded pointer play in S3 as `fail` (#753), the verifier's run on `ea37581` recorded it as `pass`. Both builds predate the S3 gate fix (#798, `4e50418`). This run re-derived the shipped-path half from scratch on today's `main` rather than adopting either verdict.

## The graphical leg

`git merge-base --is-ancestor 4e50418 abc6469` and `… ea37581` both fail, so neither #375 graphical artifact probes the code `main` ships. The accepted [#753 graphical run](../../issue-753/graphical-20261025T100000Z/manifest.md) ran on `4e50418`, an ancestor of `161b4a9`, and shows the panel naming the failure over a live board (`screenshots/02-s3-exerror-panel.png`). Between those two commits the gesture path and the advice error state are unchanged: the `session_router.gd` + `shared_game_session.gd` diff is empty, `presentation.gd` gains only the #793 prompt band and an `in_check` field, and the panel diff is the #767 / #810 check chip. The advice **marks** were restyled (`0019e75`, PAL.K9 edge brackets), so AC4 is re-measured here instead of cited.

The #375 graphical folder's own `s3-error.png` was captured before the frame that paints the panel, so the image named for the error state shows none. That is a stale artifact from the superseded build, not a fail on `main`.

## What was re-derived

- **AC11, the shipped path.** `main_release.tscn`, no seams, shipped transport over HTTP to a reachable `peer.py`; marks and eval arrive (`e2→e4`, `+0.18`), clear on the move, Black re-evaluates (`e7→e5`).
- **AC4, the ink.** [`logs/ink_probe.gd`](logs/ink_probe.gd) renders twelve piece types with and without advice in a real Metal session. **Its summary line is not usable this run:** the title fades in between the plain and inked captures, so ~2,656 non-board pixels count as ink and the first-measured piece (white pawn) reports 69–90% across repeats. Measured on the board region, the pawn is `ink=1100, body=258, overlap=0` → **0.00%**, identical to the earlier graphical log. Worst real coverage is 0.13% (black King). The flake is probe timing, not rendering, and no game code is implicated. See the appended note in [`logs/ink-run.log`](logs/ink-run.log).
- **AC4 contrast.** From `palette/swatches.md`: C7 `#53A2BE` on C1 `#E8D5B5` and on C2 `#8B5A3C` → **2.01:1** each. Eval text goes through `UiChrome.style_label` → `BODY_PX` (`UIS.T2`).

## Blockers

None.

## Non-blocking marks

- `ink_probe.gd` should crop to the board or wait out the chrome fade before its number is quoted. It is evidence tooling, not product code.
- `graphical-20261024T033000Z/screenshots/s3-error.png` is a stale pre-#798 frame; the #753 run supersedes it.
