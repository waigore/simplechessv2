class_name ChessRulesEndTest
extends SceneTree
## END.L1, END.D1, END.D3, END.D4 and END.P1 pairs on CMP-chess-rules O3.


func _initialize() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array = [
		_check_end_l1,
		_check_end_d1,
		_check_end_d3,
		_check_end_d4,
		_check_p1_l1_before_d1,
		_check_p1_l1_before_d4,
		_check_schema_fields,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return problem
	return ""


func _check_end_l1() -> String:
	var rules := ChessRules.new()
	(
		rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("c6", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	if not rules.try_move("c7", "b7"):
		return "END.L1 mating move rejected"
	var signals: Dictionary = rules.end_signals()
	if str(signals.get("ending", "")) != ChessRules.END_L1:
		return "END.L1 expected, got %s" % signals.get("ending", "")
	if str(signals.get("side_to_move", "")) != ChessRules.SIDE_BLACK:
		return "END.L1 side to move should be checkmated Black"
	if not bool(signals.get("in_check", false)):
		return "END.L1 must be in check"
	return ""


func _check_end_d1() -> String:
	var rules := ChessRules.new()
	(
		rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("b6", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("c6", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	if not rules.try_move("b6", "c7"):
		return "END.D1 stalemating move rejected"
	var signals: Dictionary = rules.end_signals()
	if str(signals.get("ending", "")) != ChessRules.END_D1:
		return "END.D1 expected, got %s" % signals.get("ending", "")
	if bool(signals.get("in_check", false)):
		return "END.D1 must not be in check"
	return ""


func _check_end_d3() -> String:
	var rules := ChessRules.new()
	(
		rules
		. load_position(
			[
				_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("g1", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
				_man("b8", ChessRules.SIDE_BLACK, ChessRules.KIND_KNIGHT),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	# Full returns to the start key need both knights home (8 plies for third occurrence).
	var cycle: Array = [
		["g1", "f3"],
		["b8", "c6"],
		["f3", "g1"],
		["c6", "b8"],
		["g1", "f3"],
		["b8", "c6"],
		["f3", "g1"],
		["c6", "b8"],
	]
	for step in cycle:
		if not rules.try_move(str(step[0]), str(step[1])):
			return "END.D3 cycle move failed %s-%s" % [step[0], step[1]]
	var signals: Dictionary = rules.end_signals()
	if str(signals.get("ending", "")) != ChessRules.END_D3:
		return (
			"END.D3 expected after threefold, got %s count=%s"
			% [
				signals.get("ending", ""),
				signals.get("repetition_count", 0),
			]
		)
	# New session clears history (capture does not).
	(
		rules
		. load_position(
			[
				_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
				_man("b3", ChessRules.SIDE_BLACK, ChessRules.KIND_KNIGHT),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	if rules.repetition_history().size() != 1:
		return "END.D3 history clears only on new session"
	if not rules.try_move("a2", "b3"):
		return "END.D3 capture after new session failed"
	if rules.repetition_history().size() != 2:
		return "END.D3 capture must not clear history"
	return ""


func _check_end_d4() -> String:
	var rules := ChessRules.new()
	(
		rules
		. load_position(
			[
				_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
				_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	# Avoid threefold during a long shuffle: seed count at 99, one quiet ply → D4.
	rules._fifty_move_count = ChessRules.FIFTY_MOVE_LIMIT - 1
	if not rules.try_move("a1", "a2"):
		return "END.D4 quiet ply to limit rejected"
	var signals: Dictionary = rules.end_signals()
	if str(signals.get("ending", "")) != ChessRules.END_D4:
		return (
			"END.D4 expected at 100, got %s count=%s"
			% [
				signals.get("ending", ""),
				rules.fifty_move_count(),
			]
		)
	if rules.fifty_move_count() != ChessRules.FIFTY_MOVE_LIMIT:
		return "END.D4 count must be 100"
	(
		rules
		. load_position(
			[
				_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	if not rules.try_move("a2", "a3"):
		return "END.D4 pawn clear move failed"
	if rules.fifty_move_count() != 0:
		return "END.D4 pawn must clear count"
	return ""


func _check_p1_l1_before_d1() -> String:
	var rules := ChessRules.new()
	(
		rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("c6", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	rules.try_move("c7", "b7")
	var signals: Dictionary = rules.end_signals()
	if str(signals.get("ending", "")) != ChessRules.END_L1:
		return "END.P1 L1 before D1 failed: %s" % signals.get("ending", "")
	return ""


func _check_p1_l1_before_d4() -> String:
	var rules := ChessRules.new()
	(
		rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("c6", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	rules._fifty_move_count = ChessRules.FIFTY_MOVE_LIMIT
	rules.try_move("c7", "b7")
	var signals: Dictionary = rules.end_signals()
	if str(signals.get("ending", "")) != ChessRules.END_L1:
		return "END.P1 L1 before D4 failed: %s" % signals.get("ending", "")
	return ""


func _check_schema_fields() -> String:
	var rules := ChessRules.new()
	rules.reset_opening()
	if rules.repetition_history().is_empty():
		return "SCH F8 repetition_history empty at session start"
	if rules.fifty_move_count() != 0:
		return "SCH F9 fifty_move_count not 0 at start"
	return ""


func _man(square: String, color: String, kind: String) -> Dictionary:
	return {"square": square, "color": color, "kind": kind}


func _no_castle() -> Dictionary:
	return {
		"white_kingside": false,
		"white_queenside": false,
		"black_kingside": false,
		"black_queenside": false,
	}
