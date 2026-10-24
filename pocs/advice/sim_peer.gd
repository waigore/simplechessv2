extends RefCounted
## Demo #376 — simulated advice peer (ADR-0002 Testability; epic #36 Notes). It
## stands in for CMP-advice-backend: it is handed an O1 `fen` and answers in the
## CTR-advice-stream wire shape (E1 `best_move_uci` / `eval_cp` updates, then one
## E2 end). The move is what a real engine would play in this common line, not a
## position search, and it deliberately deepens from a coarse tick to the final
## tick so the demo can show advice settling calmly. No network, no UCI, no
## Stockfish (CTR-advice-stream.G3; ADR-0002 validation "No client Stockfish
## endpoint").

## Wire `time_ms` cap the demo hands the peer (CFG.ADVICE_TIME_MS, default).
const DEFAULT_TIME_MS := 2000
## The scripted opener in demo main.gd ADVICE_MOVES. Keys are
## "<side>|<ply>": the side that is to move and its half-move index in that
## line, recognised from the placement (see `answer_for`).
const LINE := {
	"w|1": {"move": "e2e4", "eval": 30},   # ply 1
	"b|1": {"move": "e7e5", "eval": 20},   # ply 2
	"w|2": {"move": "g1f3", "eval": 25},   # ply 3
	"b|2": {"move": "b8c6", "eval": 15},   # ply 4
	"w|3": {"move": "f1b5", "eval": 35},   # ply 5
}
const FALLBACK := {"move": "e2e4", "eval": 30}
## The stream's three ticks, as a share of the cap: a coarse first tick (depth
## 6), a deepening tick (depth 12), and the final tick near the cap (depth 18).
## Each tick's eval starts away from the final value and closes on it, which is
## what a deepening search looks like to the player.
const TICKS := [
	{"depth": 6, "at": 0.05, "eval_offset": 20},
	{"depth": 12, "at": 0.35, "eval_offset": 5},
	{"depth": 18, "at": 0.85, "eval_offset": 0},
]


## The peer's answer for a FEN: `{"move": uci, "eval": cp}` (White's view).
## The scripted line's position is recognised by its own moves rather than by a
## parsed move number: each entry's move must have left `from` empty and put the
## mover's piece on `to`, with the other side to move.
static func answer_for(fen: String) -> Dictionary:
	var fields := fen.split(" ")
	if fields.size() < 2:
		return FALLBACK
	var placement := str(fields[0]).split("/", true)
	if placement.size() != 8:
		return FALLBACK
	var side := "w" if str(fields[1]) == "w" else "b"
	for key in LINE:
		var parts := str(key).split("|")
		if str(parts[0]) != side:
			continue
		var uci := str((LINE[key] as Dictionary)["move"])
		var from_file := "abcdefgh".find(uci.substr(0, 1))
		var from_rank := uci.substr(1, 1).to_int()
		var to_file := "abcdefgh".find(uci.substr(2, 1))
		var to_rank := uci.substr(3, 1).to_int()
		# FEN rows run rank 8 first; a square on rank r is row 8 - r.
		if _piece_at(placement, from_file, from_rank) != ".":
			continue
		if _piece_at(placement, to_file, to_rank) == ".":
			continue
		return LINE[key]
	return FALLBACK


static func _piece_at(placement: PackedStringArray, file: int, rank: int) -> String:
	if file < 0 or rank < 1 or rank > 8:
		return "."
	var squares: Array = []
	for row in placement:
		for symbol in str(row):
			if symbol.is_valid_int():
				for pad in range(int(symbol)):
					squares.append(".")
			else:
				squares.append(symbol)
	var index := (8 - rank) * 8 + file
	if index < 0 or index >= squares.size():
		return "."
	return str(squares[index])


## Update schedule for a cap: `[{"at_ms": int, "update": Dictionary}]`, each
## update already in wire shape (best_move_uci, eval_cp, depth, time_ms).
static func schedule(fen: String, cap_ms: int) -> Array:
	var answer := answer_for(fen)
	var cap := cap_ms if cap_ms > 0 else DEFAULT_TIME_MS
	var out: Array = []
	for tick in TICKS:
		var at := int(round(float(cap) * float(tick["at"])))
		out.append({
			"at_ms": at,
			"update": {
				"best_move_uci": str(answer["move"]),
				"eval_cp": int(answer["eval"]) + int(tick["eval_offset"]),
				"depth": int(tick["depth"]),
				"time_ms": at,
			},
		})
	return out
