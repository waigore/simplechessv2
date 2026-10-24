# Criteria — measured on `6e9cb7e`

The instrument is `probe/x655_confirm_probe.gd` (`md5 326b60bad50803a46896151661b815da`), carried unchanged from `review-20261025T235500Z`, so any difference between this table and the last one is a difference in the build.

## Criterion 1 — pass

`specs/technical/configuration.md:43` (`B5`), `a9192a0`:

> Ships enabled in the release: a missing T9 or T10 there is a deployment fault, not accepted (every deal fails, `FAIL.T14`; Elo kept; log). Arrival: #479 (delivery)

`specs/technical/components/catalog-service.md:56`, `a94210d`:

> Because the route ships enabled, a missing T9/T10 or an unreachable route on the published release is a deployment fault, never an accepted state.

The posture conflict escalated on #648 (`pending-clarification`) does not change this row: the sentence exists, and criterion 1 asks for the sentence.

## Criterion 2 — fail

`X655 B5 endpoint=<> key_set=false is_available=false`. `game/session_router.gd:33-34` still `""`; the only assignments in `game/` are the test seam `game/advice_ui_test.gd:40-41`; `CatalogDealClient.is_available()` (`game/catalog_deal_client.gd:39-40`) refuses on emptiness; the empty pair is handed to the deal at `game/session_router.gd:756`.

## Criterion 3 — fail

`X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>`. Neither `K1` dealt nor a committed `F-puzzle-catalog.X2`. The body names this shape: *"A screen still in `S1` with no dealt puzzle and no failed-read record is a `fail`."*

## Criterion 4 — holds as an observable

Elo `1000.00` unchanged, no puzzle id, `last_failure=<status>`, `puzzle stream: deal read failed (status)` twice in `logs/x655-probe.log`. No player-facing copy is required by `specs/`; none invented.

## Criterion 5 — pass

`S1` → `C5` → `S2` (`leave_confirm`) → `cancel` → `S1`; router journey `mode-pick → puzzle-play → confirm → mode-pick` with the flow freed (`TEL.3` `sess-1792883679081-94520-playtest-273473`). Eleventh conforming measurement; item 4's repair clause does not fire.

## Criterion 6 — fail (`held` is spent)

Published artefact unchanged (`etag "6adcf171-91ff1c"`, 9,568,028 bytes, `last-modified` 2026-10-24 17:57:05 GMT), `GET /catalog/deal` → `404`. See `gap-delivery-owner.md`.

## Criterion 7 — holds

`docs/playtest/evidence/issue-550/headless-20261024T000000Z/manifest.md:8` still names #655; the sweep has not re-run (#550 is open, `logs/owner-state.log`).

## Criterion 8 — holds

This folder only. No `game/`, `specs/`, `asset_catalog/`, `game_assets/` change.

## Criterion 9 — holds

No native edge to #332 / #333 / #335 added or implied; the body's relationship statement is unchanged.
