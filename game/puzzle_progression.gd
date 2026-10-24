class_name PuzzleProgression
extends RefCounted
## CMP-puzzle-progression (L3). R1–R2 the scored Elo update and recent-solved list,
## R4 the deal pick, R5 the required sequence. Domain owns the arithmetic and the
## pick policy; CMP-puzzle-session commits what these return and never computes
## them itself (LAY.D2 / CON.O6). Design: DIF.Y1 C1, PRG.M1 P3, F-puzzle-catalog I1 I3.


## DIF.Y1 / PRG.M1 — the values one scored ending produces. END.W1 is a win (S = 1);
## END.L4, END.L5 and END.L6 are losses (S = 0). Puzzle Elo never changes. The window
## trim belongs to the caller's `CFG.ELO_RECENT_WINDOW`.
static func score(
	player_elo: float,
	puzzle_elo: float,
	ending: String,
	puzzle_id: String,
	recent_solved: Array,
	elo_k: float
) -> Dictionary:
	var points := 1.0 if ending == PuzzleSession.END_W1 else 0.0
	# PRG.M1 / F-puzzle-catalog I3 — only a clean solve appends the PuzzleId.
	var recent: Array = recent_solved.duplicate()
	if ending == PuzzleSession.END_W1 and not puzzle_id.is_empty():
		recent.append(puzzle_id)
	return {
		"player_elo": player_elo + elo_step(player_elo, puzzle_elo, points, elo_k),
		"recent_solved": recent,
		"score": points,
	}


## DIF.Y1 — one result's Elo delta: `CFG.ELO_K × (S − E)` with
## `E = 1 / (1 + 10^((puzzleElo − playerElo) / 400))`; no cap.
static func elo_step(player_elo: float, puzzle_elo: float, points: float, elo_k: float) -> float:
	var expected := 1.0 / (1.0 + pow(10.0, (puzzle_elo - player_elo) / 400.0))
	return elo_k * (points - expected)


## DIF.Y1 / F-puzzle-catalog I1 / GS.Q1 — the candidate set's first non-empty rung.
## Widen the ± `match_range` by `band_widen` with the recent rule still on, then allow
## recently solved ids and widen again. Returns the rung's members, or `[]` when no
## puzzle fits at any rung. Order inside a rung is the input order, so any member may
## be dealt and two deals need not agree.
static func candidate_set(
	records: Array,
	player_elo: float,
	recent_solved: Array,
	match_range: int,
	band_widen: int,
	id_field: String,
	rating_field: String
) -> Array:
	var widen := maxi(band_widen, 1)
	var span := 0
	for record in records:
		if record is Dictionary:
			span = maxi(span, absi(int(record.get(rating_field, 0)) - int(round(player_elo))))
	var steps := int(ceil(float(span) / float(widen))) + 1
	for allow_recent in [false, true]:
		for widen_steps in range(steps + 1):
			var found := rung(
				records,
				player_elo,
				recent_solved,
				int(match_range) + widen * widen_steps,
				allow_recent,
				id_field,
				rating_field
			)
			if not found.is_empty():
				return found
	return []


## One rung: records within ±`reach` of Player Elo, optionally holding solved ids back.
static func rung(
	records: Array,
	player_elo: float,
	recent_solved: Array,
	reach: int,
	allow_recent: bool,
	id_field: String,
	rating_field: String
) -> Array:
	var out: Array = []
	for record in records:
		if not (record is Dictionary):
			continue
		var rating: int = int(record.get(rating_field, 0))
		if absi(rating - int(round(player_elo))) > reach:
			continue
		if not allow_recent and recent_solved.has(str(record.get(id_field, ""))):
			continue
		out.append(record)
	return out


## R5 — a puzzle's required sequence: the record's moves after the opening opponent
## move, each as {from, to, promotion}. Returns `[]` for a record with no move after
## the first (F-puzzle-catalog X1) so the session refuses the deal.
static func required_sequence(moves: Array) -> Array:
	if moves.size() < 2:
		return []
	var sequence: Array = []
	for index in range(1, moves.size()):
		var uci := str(moves[index])
		sequence.append(
			{"from": uci.substr(0, 2), "to": uci.substr(2, 2), "promotion": uci.substr(4, 1)}
		)
	return sequence
