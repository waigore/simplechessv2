# Technical requirement notes

- stockfish running on the server, limited time to evaluate, real time streams, and local moves never wait on the engine stream — target: `specs/technical/`
- dual playtest environments: Godot `--headless` and Graphical Web sessions with Must DBG/TEL seams in playtest builds only (ADR-0004) — target: `specs/technical/verification.md`
