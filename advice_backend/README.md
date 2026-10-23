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

Serve it over TLS behind whatever proxy the operator deploys; the process
must not be reachable without that TLS terminator. The client opens advice
traffic only to its configured endpoint, carrying the API key (ADR-0010).
There are no accounts and no player state.

## Wire

`POST /advice` with `{"api_key", "fen", "time_ms"}` (`CTR-advice-stream` O1).
The response is `application/x-ndjson`, chunked: one `advice_update` per line
(`best_move_uci`, `eval_cp` in White centipawns, optional `mate_in`, `depth`,
`time_ms`), then one `{"reason": "cap" | "cancel" | "error"}`. A missing or
wrong key answers `401` with `{"reason": "error"}` without starting a search.

The search stops at the earlier of the client's `time_ms` and
`ADVICE_TIME_MS` (`CFG.ADVICE_TIME_MS`, default 2000) — F-move-advice R7 and
`CMP-advice-backend` R3 make the configured value the maximum think time, so
the client may shorten a search but never extend it. The end message is
delivered by the cap, not after it: a small reserve is held back from the
search, and a child that will not exit is killed after E2 is written. A client
that drops the response is a cancel; no update follows it.

Timing and errors are logged on `advice_backend` (`advice_start` with
`cap_ms`, `advice_end` with `reason` / `elapsed_ms` / `disconnected`,
`advice_error` with `reason`) for Observability playtests.

## Test

```bash
python3 -m unittest discover -s advice_backend/tests -t .
```

The tests use a stand-in engine script, so no Stockfish binary is needed.
