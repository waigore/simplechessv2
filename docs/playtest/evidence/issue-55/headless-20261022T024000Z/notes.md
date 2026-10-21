# Notes

Headless acceptance playtest for #55 against merged `main` (Godot 4.7.2). Position and clock setups use `start_shared` / `load_position` / `set_clock_ms` / `tick` on `CMP-shared-game-session` and `CMP-chess-rules` (`SIT.1` / DBG.3 equivalents). Shared-play clock rendering (`UI-shared-play.R2`) is out of scope (#58). Resign-at-zero (`END.L2`) stays on #54.

## PTD-shared-game (clock cases)

- **P1**: Untimed `start_shared` stores both clocks as none, runs no active clock, has no expiry path, and keeps increment at zero (`CFG.K1`).
- **S3 / P3**: Blitz start uses `CFG.BLITZ_START` (60 s → F3 ms) with 3 s increment; Rapid uses `CFG.RAPID_START` (600 s) with 5 s. Only the side-to-move clock ticks (`GS.V2` / I3). After a completed White move, White stops with increment applied and Black’s clock starts. Options lock at start; a new session re-inits from newly chosen options (`K3`).

## Move / increment / illegal

- Completed move with clock > 0 adds increment then starts the opponent.
- Completed move with clock already at zero adds no increment.
- Illegal attempt leaves remaining time and the same active clock unchanged.
- Stored values never go below zero (`tick` clamps; `set_clock_ms` clamps).

## PTD-end-conditions S4 (L3 / D5 half)

- Running clock to zero when the other side can checkmate → `END.L3`, both clocks stop, no seconds added (`END.P1`).
- Bare-king dead position → `END.D5` draw, clocks stop.
- Session calls `CTR-local-move` O4 (`possible_checkmate` on `CMP-chess-rules`); no material table in `shared_game_session.gd`.
- Prior verification fail resolved: no `lone_minors` shortcut. K+B vs K+N, K+N vs K+B, opposite-colored bishops, and K+N+N vs K return possible mate (L3). Same-colored bishops stay dead (D5).

## Tick / performance

- `tick(delta_ms)` returns immediately when untimed, stopped, ended, or delta ≤ 0. Otherwise one subtraction and optional O4 call — does not block a frame or delay move presentation.

## Suite

`python3 .github/scripts/gdscript_tests.py test` — 11 headless unit tests passed. Coverage 88.8% (1800/2026). Focused `godot --headless --path game -s res://shared_game_session_test.gd` exit 0. Import exit 0.
