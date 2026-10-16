# ADR requirement notes

- if the player is connected to the network, a chess engine (stockfish) running on the server would evaluate the board and (if the player wants it) provide suggestions on the best move. stockfish is allowed limited time to come up with its evaluation. it should use stockfish's real time streams to provide a good evaluation experience. for easy integration, use stockfish. local moves never wait on the engine stream — target: `specs/adr/`
