# Stockfish licensing notices

The advice backend conveys no Stockfish binary and ships no project source of
it (ADR-0012). Stockfish stays a separate program an operator installs and
runs over local UCI (ADR-0011). This directory keeps the licence text,
credits, exact version, and source URL of the Stockfish the backend talks to,
beside the server, so the record stays current.

| Item | Value |
|------|-------|
| Program | Stockfish (chess engine) |
| Version in use | The operator's installed build, Stockfish 17 or newer. The backend speaks only the stable UCI subset (`uci`, `position fen`, `go movetime`, `stop`, `quit`, `info depth/score/pv`, `bestmove`), which these releases share; it bundles none of it |
| Version recorded here | Repository-wide pin: **Stockfish 17**, published 2025-01-01, source tag [`sf_17`](https://github.com/official-stockfish/Stockfish/tree/sf_17) |
| Licence | GNU General Public License, version 3 |
| Licence text | [`GPLv3.txt`](GPLv3.txt) (canonical copy published at <https://www.gnu.org/licenses/gpl-3.0.txt>) |
| Credits | Stockfish is a community project; contributors at <https://github.com/official-stockfish/Stockfish> |
| Source URL | <https://github.com/official-stockfish/Stockfish> |

The tests run against a stand-in engine script, so no Stockfish build is
required or shipped to verify the backend. When the project pins a different
release for a deployment, change the version row and this table together
(`CMP-advice-backend` R8, ADR-0012 Maintainability).

An operator that serves a deployed backend to players, or distributes it with
Stockfish, offers the source for the exact binary it conveys and keeps these
notices intact (ADR-0012).
