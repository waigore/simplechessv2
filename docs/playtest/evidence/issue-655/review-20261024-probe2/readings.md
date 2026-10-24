# Probe readings — #655 `C5` / `S1` leg

Detail for [`notes.md`](notes.md). Raw output: [`logs/x655_probe.log`](logs/x655_probe.log).

## Method

`probe/x655_confirm_probe.gd` builds the same `PuzzlePlayFlow` that `session_router._enter_puzzle_play` builds and enters it exactly as the shipped path does — `T9`/`T10` at `session_router.gd:33-34`'s `""` defaults, no catalog peer — then activates `C5` through `PuzzlePlayFlow.control`, the entry `session_router` forwards a control tap to.

## Output

```
X655 B5 endpoint=<> key_set=false is_available=false
X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>
X655 PANEL_C5_GATE=true
X655 C5_ACTIVATED state=S1 confirm_kind=<> confirm_shown=false
X655_PROBE fail
```

## Read against the criteria

- **Criterion 2 (deal path reaches the resolver): fail, and it is `B5`'s guard.** `is_available()` is `false` with the shipped-path values, so the read never leaves the client and `last_failure` is the client-side `status` refusal — not a transport, status-code, or body failure from a server.
- **Entered state is `S1`**, matching the refinement's claim: `play_ui_state` is `S1` after `enter()`.
- **Criterion 5 (`C5` on `S1` raises `EX.confirm`): fail.** The panel does advertise `C5` on this state (`puzzle_play_panel.gd:83-92` enables it on everything except `S2`/`S4`), so `PANEL_C5_GATE=true`, but activating it leaves the screen in `S1` with an empty `confirm_kind` and no `EX.confirm`. The reject is `PuzzleSession.request_confirm`'s `has_open_puzzle()` guard (`game/puzzle_session.gd:532`), exactly as the issue's *Actual behavior* states. `US5.1` / `US5.3` and `J-puzzle-session` B1 are non-conforming on `main` today.
- `GS.playerElo` read `1000.00` and no puzzle id was set, which is `FAIL.T14`'s Effect column holding — but that is the *pre-*#648 build, so it is not the absence-path record criterion 4 asks for, and is not written up as one here.
