# Criteria — source behind each row

Companion to [`notes.md`](notes.md), which carries the measurement and the verdicts. Every row here is a quote or a path on `161b4a9`, reproduced from the logs in `logs/`.

## 1 — the `specs/` sentence (`specs/technical/configuration.md:43`, `e19401f`)

> `B5` … | Ships enabled in the release: a missing T9 or T10 there is a deployment fault, not accepted (every deal fails, `FAIL.T14`; Elo kept; log). Arrival: #479 (delivery) |

`T9` (`:31`) and `T10` (`:32`) each read *"…ships set (`B5`)"*. `catalog-service.md:56` cites the same. Both files last changed at `e19401f`.
## 2 — `is_available()` / the refusal path

- `game/session_router.gd:33-34` — `var advice_endpoint := ""` / `var advice_api_key := ""`.
- `:552` — `return not advice_endpoint.is_empty() and not advice_api_key.is_empty()`.
- `:756` — `puzzle_flow.enter(_persist, advice_endpoint, advice_api_key, _puzzle_sim_factory())`.
- `game/advice_ui_test.gd:40-41` — the only assignments in `game/`.
- `.github/workflows/web-release.yml`, `.github/scripts/web_export.py` — no step that could set either value.

Probe: `X655 B5 endpoint=<> key_set=false is_available=false`.

## 3 — the two named outcomes

`dealt` is not reached (`S1`, `has_puzzle=false`, `pid=<>`). The absence branch `F-puzzle-catalog.X2` is not committed as a delivered outcome: `specs/design/features/puzzle-catalog.md` X2 describes the behaviour, but nothing in `game/` or `specs/` presents it, and this body's criterion 3 requires the branch be *committed* rather than left as the silent no-op the defect filed.

## 4 — the `FAIL.T14` observable

`X655 ENTERED … pid=<> elo=1000.00 last_failure=<status>` — Elo unchanged, no id, reason held. The run's log window carries `puzzle stream: deal read failed (status)` twice (`logs/x655-probe-stdout.log`). No player-facing copy required, none invented.

## 5 — `C5` on `S1` (conforming for the tenth time)

`S1 → S2 (leave_confirm) → S1` by activating `C5`, and `ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true`. `game/puzzle_session.gd:518-521` carries the `needs_puzzle = false` exemption.

## 6 — published rows

Not held, and not pass: see [`posture-conflict.md`](posture-conflict.md) and [`gap-delivery-owner.md`](gap-delivery-owner.md).

## 7–9

#550 has not re-run; its manifest `Defects` line still names #655. Only this folder is added. No native edge to #332/#333/#335 is added or implied.
