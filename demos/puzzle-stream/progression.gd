class_name DemoProgression
extends RefCounted
## CMP-puzzle-progression R1-R2 / CTR-puzzle-progress O1: compute the next
## GS.playerElo and GS.recentSolved for one scored puzzle outcome. DIF.Y1:
## END.W1 is a win (S = 1); END.L4, END.L5, and END.L6 are losses (S = 0);
## E = 1 / (1 + 10^((puzzleElo - playerElo) / 400)); playerElo += K * (S - E).
## The session commits the returned values and never computes them itself
## (CON.O6). Puzzle Elo never changes (DIF.Y1).


## The next Player Elo and recent-solved list after a scored outcome.
## recentSolved appends the PuzzleId on END.W1 only, trimmed to the window
## (PRG.M1, PRG.P3, F-puzzle-catalog I3).
static func score(
	player_elo: float,
	puzzle_elo: float,
	outcome: String,
	puzzle_id: String,
	recent_solved: Array,
	cfg: Dictionary
) -> Dictionary:
	var win := outcome == "W1"
	var s := 1.0 if win else 0.0
	var expected := 1.0 / (1.0 + pow(10.0, (puzzle_elo - player_elo) / 400.0))
	var next_elo := player_elo + float(cfg["elo_k"]) * (s - expected)
	var recent: Array = recent_solved.duplicate()
	if win and puzzle_id != "":
		recent.append(puzzle_id)
		while recent.size() > int(cfg["elo_recent_window"]):
			recent.pop_front()
	return {
		"playerElo": next_elo,
		"recentSolved": recent,
		"expected": expected,
		"score": s,
	}
