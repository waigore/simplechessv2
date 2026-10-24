class_name PuzzleProgressionTest
extends SceneTree
## CMP-puzzle-progression (#768): R1–R2 the Elo update and recent list, R4 the DIF.Y1
## deal pick, R5 the required sequence. Domain only — no session, store, or network.


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		printerr("FAIL: %s" % problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array[Callable] = [
		_check_win_step,
		_check_loss_step,
		_check_even_elo,
		_check_score_appends_on_win_only,
		_check_required_sequence,
		_check_candidate_prefers_fresh_in_band,
		_check_candidate_widens,
		_check_candidate_widens_before_allowing_recent,
		_check_candidate_allows_recent_after_widen,
		_check_candidate_any_member,
		_check_candidate_empty,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return "%s: %s" % [check.get_method(), problem]
	return ""


func _record(id: String, rating: int) -> Dictionary:
	return {"puzzle_id": id, "rating": rating}


func _check_win_step() -> String:
	var got := PuzzleProgression.elo_step(1000.0, 900.0, 1.0, 20.0)
	if absf(got - 7.2) > 0.01:
		return "DIF.Y1: W1 vs 900 must add 7.2 (got %s)" % got
	return ""


func _check_loss_step() -> String:
	var got := PuzzleProgression.elo_step(1000.0, 900.0, 0.0, 20.0)
	if absf(got + 12.8) > 0.01:
		return "DIF.Y1: L6 vs 900 must lose 12.8 (got %s)" % got
	return ""


func _check_even_elo() -> String:
	if absf(PuzzleProgression.elo_step(1000.0, 1000.0, 1.0, 20.0) - 10.0) > 0.001:
		return "DIF.Y1: even-Elo win must add K/2"
	if absf(PuzzleProgression.elo_step(1000.0, 1000.0, 0.0, 20.0) + 10.0) > 0.001:
		return "DIF.Y1: even-Elo loss must subtract K/2"
	return ""


func _check_score_appends_on_win_only() -> String:
	var scored := PuzzleProgression.score(1000.0, 1000.0, "END.W1", "p1", ["old"], 20.0)
	if absf(float(scored["player_elo"]) - 1010.0) > 0.001:
		return "R1: a win at even Elo must yield 1010 (got %s)" % scored["player_elo"]
	if not (scored["recent_solved"] as Array) == ["old", "p1"]:
		return "R2: a win must append the PuzzleId"
	var failed := PuzzleProgression.score(1000.0, 1000.0, "END.L4", "p1", ["old"], 20.0)
	if not (failed["recent_solved"] as Array) == ["old"]:
		return "R2: a fail must leave recentSolved unchanged"
	if absf(float(failed["player_elo"]) - 990.0) > 0.001:
		return "R1: an even-Elo loss must yield 990 (got %s)" % failed["player_elo"]
	return ""


func _check_required_sequence() -> String:
	var sequence := PuzzleProgression.required_sequence(["e2e4", "e7e5", "g1f3"])
	if sequence.size() != 2:
		return "R5: the opening move is not part of the required sequence"
	if str(sequence[0]["from"]) != "e7" or str(sequence[0]["to"]) != "e5":
		return "R5: sequence steps must be {from, to, promotion}"
	if not PuzzleProgression.required_sequence(["e2e4"]).is_empty():
		return "F-puzzle-catalog X1: a record with no move after the first has no sequence"
	return ""


func _check_candidate_prefers_fresh_in_band() -> String:
	var records := [_record("seen", 1000), _record("fresh", 1050)]
	var found := PuzzleProgression.candidate_set(
		records, 1000.0, ["seen"], 100, 50, "puzzle_id", "rating"
	)
	if found.size() != 1 or str(found[0]["puzzle_id"]) != "fresh":
		return "DIF.Y1: an in-band unsolved puzzle must be the first rung"
	return ""


func _check_candidate_widens() -> String:
	var records := [_record("wide", 1150)]
	var found := PuzzleProgression.candidate_set(
		records, 1000.0, [], 100, 50, "puzzle_id", "rating"
	)
	if found.size() != 1:
		return "DIF.Y1 D1: the band must widen by CFG.ELO_BAND_WIDEN until a puzzle fits"
	return ""


func _check_candidate_widens_before_allowing_recent() -> String:
	# A fresh puzzle needs one widen step; a solved one sits in band. Widen wins first.
	var records := [_record("seen", 1000), _record("fresh", 1130)]
	var found := PuzzleProgression.candidate_set(
		records, 1000.0, ["seen"], 100, 50, "puzzle_id", "rating"
	)
	if found.size() != 1 or str(found[0]["puzzle_id"]) != "fresh":
		return "DIF.Y1: widening the band must come before allowing a recently solved id"
	return ""


func _check_candidate_allows_recent_after_widen() -> String:
	var records := [_record("seen", 1000), _record("seen2", 1120)]
	var found := PuzzleProgression.candidate_set(
		records, 1000.0, ["seen", "seen2"], 100, 50, "puzzle_id", "rating"
	)
	if found.size() != 1 or str(found[0]["puzzle_id"]) != "seen":
		return "DIF.Y1: after widening finds nothing unsolved, a recent id in band is dealt"
	return ""


func _check_candidate_any_member() -> String:
	var records := [_record("a", 1010), _record("b", 1040)]
	var found := PuzzleProgression.candidate_set(
		records, 1000.0, [], 100, 50, "puzzle_id", "rating"
	)
	if found.size() != 2:
		return "GS.Q1: every in-band unsolved puzzle must be a candidate-set member"
	return ""


func _check_candidate_empty() -> String:
	if not (
		PuzzleProgression.candidate_set([], 1000.0, [], 100, 50, "puzzle_id", "rating").is_empty()
	):
		return "an empty catalog must have no candidate"
	return ""
