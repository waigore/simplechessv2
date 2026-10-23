# Advice backend

The separate Python server that is the sole UCI peer of Stockfish
(`specs/technical/components/advice-backend.md`, M2). The Godot client never
talks to Stockfish (ADR-0002, ADR-0010, ADR-0011).

## Run

Stockfish is not shipped (ADR-0012). An operator installs it and points the
server at it:

```bash
export ADVICE_API_KEY=<the key the client is configured with>
export STOCKFISH_PATH=/path/to/stockfish        # default: stockfish on PATH
export ADVICE_HOST=127.0.0.1 ADVICE_PORT=8080   # listen address this process is given
export ADVICE_TIME_MS=2000                      # CFG.ADVICE_TIME_MS
python3 -m advice_backend
```

Serve it over TLS behind whatever proxy the operator deploys; the client opens
advice traffic only to its configured endpoint, carrying the API key
(ADR-0010). There are no accounts and no player state.

## Wire

`POST /advice` with `{"api_key", "fen", "time_ms"}` (`CTR-advice-stream` O1).
The response is `application/x-ndjson`, chunked: one `advice_update` per line
(`best_move_uci`, `eval_cp` in White centipawns, optional `mate_in`, `depth`,
`time_ms`), then one `{"reason": "cap" | "cancel" | "error"}`. A missing or
wrong key answers `401` with `{"reason": "error"}` without starting a search.
The search stops by `min(time_ms, CFG.ADVICE_TIME_MS)`; a client that drops
the response is a cancel and no update follows it.

Timing and errors are logged on `advice_backend` (`advice_start`,
`advice_end`, `advice_error`) for Observability playtests.

## Test

```bash
python3 -m unittest discover -s advice_backend/tests -t .
```

The tests use a stand-in engine script, so no Stockfish binary is needed.
