class_name ChessRulesTest
extends SceneTree
## Headless proofs for E-pieces board, attack, check, and CTR-local-move.


func _initialize() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array = [
		_check_board,
		_check_opening,
		_check_turn_and_events,
		_check_capture_and_friendly,
		_check_attack,
		_check_check_and_filter,
		_check_layer,
		_check_ptd_pieces_common,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return problem
	return ""


func _check_board() -> String:
	var rules := ChessRules.new()
	var problem := _board_colors(rules)
	if problem.is_empty():
		problem = _board_occupancy(rules)
	return problem


func _board_colors(rules: ChessRules) -> String:
	var names := rules.squares()
	var problem := ""
	if names.size() != 64:
		problem = "E-pieces.I1 square count"
	var seen := {}
	var dark := 0
	for square in names:
		if not problem.is_empty():
			break
		problem = _board_square(rules, seen, str(square))
		if problem.is_empty() and rules.is_dark_square(str(square)):
			dark += 1
	if problem.is_empty() and (dark != 32 or not rules.is_dark_square("a1")):
		problem = "E-pieces.I35 a1 dark"
	if problem.is_empty():
		var a1 := rules.orthogonal_neighbors("a1")
		var corners := a1.size() == 2 and a1.has("a2") and a1.has("b1")
		if not corners:
			problem = "E-pieces.I1 a1 neighbors"
	if (
		problem.is_empty()
		and (rules.is_dark_square("a9") or not rules.orthogonal_neighbors("zz").is_empty())
	):
		problem = "E-pieces.I35 invalid square"
	return problem


func _board_square(rules: ChessRules, seen: Dictionary, square: String) -> String:
	if seen.has(square):
		return "E-pieces.I1 duplicate %s" % square
	seen[square] = true
	if not _square_form(square):
		return "E-pieces.I1 form %s" % square
	var file := square.unicode_at(0) - 96
	var rank := square.unicode_at(1) - 48
	if rules.is_dark_square(square) != ((file + rank) % 2 == 0):
		return "E-pieces.I35 color %s" % square
	for neighbor in rules.orthogonal_neighbors(square):
		if rules.is_dark_square(str(neighbor)) == rules.is_dark_square(square):
			return "E-pieces.I35 adjacent %s" % square
	return ""


func _board_occupancy(rules: ChessRules) -> String:
	(
		rules
		. load_position(
			[
				_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
				_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
			],
			ChessRules.SIDE_WHITE,
		)
	)
	var occupancy: Dictionary = rules.position_field()["occupancy"]
	if occupancy.size() != 1 or rules.piece_on("e4")["kind"] != ChessRules.KIND_QUEEN:
		return "E-pieces.I1 at most one piece"
	return ""


func _check_opening() -> String:
	var rules := ChessRules.new()
	rules.reset_opening()
	var problem := _opening_ranks(rules)
	if problem.is_empty():
		problem = _opening_rights(rules)
	if problem.is_empty():
		problem = _opening_targets(rules)
	return problem


func _opening_ranks(rules: ChessRules) -> String:
	var back := [
		ChessRules.KIND_ROOK,
		ChessRules.KIND_KNIGHT,
		ChessRules.KIND_BISHOP,
		ChessRules.KIND_QUEEN,
		ChessRules.KIND_KING,
		ChessRules.KIND_BISHOP,
		ChessRules.KIND_KNIGHT,
		ChessRules.KIND_ROOK,
	]
	var problem := ""
	for index in range(8):
		if not problem.is_empty():
			break
		problem = _opening_file(rules, char(97 + index), str(back[index]))
	if problem.is_empty() and rules.position_field()["occupancy"].size() != 32:
		problem = "E-pieces.I2 piece count"
	if problem.is_empty() and rules.position_field()["side_to_move"] != ChessRules.SIDE_WHITE:
		problem = "SCH-play-state F1 side"
	return problem


func _opening_file(rules: ChessRules, file: String, kind: String) -> String:
	var problem := _expect_piece(rules, "%s1" % file, ChessRules.SIDE_WHITE, kind)
	if problem.is_empty():
		problem = _expect_piece(rules, "%s2" % file, ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN)
	if problem.is_empty():
		problem = _expect_piece(rules, "%s7" % file, ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN)
	if problem.is_empty():
		problem = _expect_piece(rules, "%s8" % file, ChessRules.SIDE_BLACK, kind)
	if problem.is_empty():
		return ""
	return "E-pieces.I2 %s" % problem


func _opening_rights(rules: ChessRules) -> String:
	var rights: Dictionary = rules.castling_ep()
	var problem := ""
	for key in ["white_kingside", "white_queenside", "black_kingside", "black_queenside"]:
		if rights[key] != true:
			problem = "SCH-play-state F2 %s" % key
	if problem.is_empty() and str(rights["en_passant"]) != "":
		problem = "SCH-play-state F2 en passant"
	rights["white_kingside"] = false
	if problem.is_empty() and rules.castling_ep()["white_kingside"] != true:
		problem = "SCH-play-state F2 writer"
	var field: Dictionary = rules.position_field()
	field["occupancy"]["e2"]["kind"] = ChessRules.KIND_QUEEN
	if problem.is_empty() and rules.piece_on("e2")["kind"] != ChessRules.KIND_PAWN:
		problem = "SCH-play-state F1 writer"
	return problem


func _opening_targets(rules: ChessRules) -> String:
	if rules.in_check(ChessRules.SIDE_WHITE) or rules.in_check(ChessRules.SIDE_BLACK):
		return "opening check"
	if not rules.legal_targets("d1").is_empty():
		return "opening queen boxed"
	var pawn_targets := rules.legal_targets("e2")
	var pawn_ok := pawn_targets.has("e3") and pawn_targets.has("e4") and not pawn_targets.has("d3")
	if not pawn_ok:
		return "E-pieces.I11 e2 targets"
	return ""


func _check_turn_and_events() -> String:
	var rules := ChessRules.new()
	rules.reset_opening()
	var problem := _turn_rejects(rules)
	if problem.is_empty():
		problem = _turn_applies(rules)
	return problem


func _turn_rejects(rules: ChessRules) -> String:
	if not rules.legal_targets("e7").is_empty():
		return "E-pieces.I11 opponent targets"
	var before := _snapshot(rules)
	var wrong := _attempt(rules, "e7", "e5")
	var wrong_side: bool = wrong["ok"] or not _same(before, rules)
	if wrong_side or not _only_reject(wrong, ChessRules.REASON_SIDE):
		return "E-pieces.I11 GS.V1 E2 wrong side"
	var empty := _attempt(rules, "e3", "e4")
	if not _only_reject(empty, ChessRules.REASON_EMPTY) or not _same(before, rules):
		return "CTR-local-move E2 empty"
	var bad := _attempt(rules, "e9", "e8")
	if not _only_reject(bad, ChessRules.REASON_SQUARE) or not _same(before, rules):
		return "CTR-local-move E2 square"
	var promoted := _attempt(rules, "e2", "e4", "queen")
	var promotion_rejected := _only_reject(promoted, ChessRules.REASON_PROMOTION)
	if not promotion_rejected or not _same(before, rules):
		return "CTR-local-move E2 promotion argument"
	return ""


func _turn_applies(rules: ChessRules) -> String:
	var problem := ""
	var applied := _attempt(rules, "e2", "e4")
	var moved: bool = (
		rules.piece_on("e2").is_empty() and rules.piece_on("e4")["kind"] == ChessRules.KIND_PAWN
	)
	if not applied["ok"] or not _only_apply(applied, "e2", "e4", ChessRules.SIDE_BLACK):
		problem = "E-pieces.I11 PS1.7 E1"
	elif not moved or str(rules.castling_ep()["en_passant"]) != "e3":
		problem = "SCH-play-state F1 F2 e2-e4 I29"
	var black := _attempt(rules, "a7", "a5") if problem.is_empty() else {}
	if (
		problem.is_empty()
		and (not black["ok"] or not _only_apply(black, "a7", "a5", ChessRules.SIDE_WHITE))
	):
		problem = "E-pieces.I11 black turn"
	elif problem.is_empty() and str(rules.castling_ep()["en_passant"]) != "a6":
		problem = "SCH-play-state F2 a7-a5 ep"
	var quiet := _attempt(rules, "e4", "e5") if problem.is_empty() else {}
	if (
		problem.is_empty()
		and (not quiet["ok"] or rules.piece_on("e5")["color"] != ChessRules.SIDE_WHITE)
	):
		problem = "E-pieces.I11 single step"
	elif problem.is_empty() and str(rules.castling_ep()["en_passant"]) != "":
		problem = "E-pieces.I32 ep cleared"
	var black_quiet := _attempt(rules, "a5", "a4") if problem.is_empty() else {}
	var black_step: bool = (
		problem.is_empty()
		and black_quiet["ok"]
		and rules.piece_on("a4")["color"] == ChessRules.SIDE_BLACK
	)
	if problem.is_empty() and (not black_step or not rules.legal_targets("z9").is_empty()):
		problem = "E-pieces.I11 black single step"
	return problem


func _check_capture_and_friendly() -> String:
	var problem := _capture_removes()
	if problem.is_empty():
		problem = _friendly_and_king()
	if problem.is_empty():
		problem = _last_rank_pawns()
	return problem


func _capture_removes() -> String:
	var capture := _with(
		[
			_man("c3", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("d5", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var took := _attempt(capture, "c3", "d5")
	if not took["ok"] or capture.piece_on("d5")["kind"] != ChessRules.KIND_KNIGHT:
		return "E-pieces.I3 capture"
	if capture.piece_on("c3").size() != 0:
		return "E-pieces.I3 origin cleared"
	return ""


func _friendly_and_king() -> String:
	var friendly := _with(
		[
			_man("a4", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var before := _snapshot(friendly)
	var blocked := _attempt(friendly, "a4", "e4")
	var friendly_ok: bool = not blocked["ok"] and _same(before, friendly)
	if not friendly_ok or not _only_reject(blocked, ChessRules.REASON_ILLEGAL):
		return "E-pieces.I4 friendly"
	var king_take := _with(
		[
			_man("d5", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
			_man("d8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
		]
	)
	var before_king := _snapshot(king_take)
	var regicide := _attempt(king_take, "d5", "d8")
	var king_ok: bool = not regicide["ok"] and _same(before_king, king_take)
	if not king_ok or king_take.piece_on("d8")["kind"] != ChessRules.KIND_KING:
		return "E-pieces.I4 king remains"
	return ""


func _last_rank_pawns() -> String:
	var last_rank := _with(
		[
			_man("e7", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("d8", ChessRules.SIDE_BLACK, ChessRules.KIND_KNIGHT),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var targets := last_rank.legal_targets("e7")
	if not targets.has("e8") or not targets.has("d8"):
		return "E-pieces.I33 promotion targets"
	if not last_rank.attacks(ChessRules.SIDE_WHITE, "d8"):
		return "E-pieces.I5 last-rank pawn attack"
	var missing := _attempt(last_rank, "e7", "e8")
	if not _only_reject(missing, ChessRules.REASON_PROMOTION):
		return "E-pieces.I33 promotion required"
	var stranded := _with(
		[
			_man("e8", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not stranded.legal_targets("e8").is_empty():
		return "pawn on last rank has no quiet step"
	var black_last := _with(
		[
			_man("e2", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("d1", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK,
	)
	var black_targets := black_last.legal_targets("e2")
	if not black_targets.has("e1") or not black_targets.has("d1"):
		return "E-pieces.I33 black promotion targets"
	return ""


func _check_attack() -> String:
	var problem := _attack_pawn_and_rook()
	if problem.is_empty():
		problem = _attack_pin_knight_king()
	if problem.is_empty():
		problem = _attack_sliders_and_edges()
	if problem.is_empty():
		problem = _attack_pawn_blocks()
	return problem


func _attack_pawn_and_rook() -> String:
	var pawns := _with(
		[
			_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("d5", ChessRules.SIDE_BLACK, ChessRules.KIND_KNIGHT),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not pawns.attacks(ChessRules.SIDE_WHITE, "d5") or pawns.attacks(ChessRules.SIDE_WHITE, "e5"):
		return "E-pieces.I5 PS2.1 pawn attack"
	var captured := _attempt(pawns, "e4", "d5")
	if not captured["ok"] or pawns.piece_on("d5")["color"] != ChessRules.SIDE_WHITE:
		return "E-pieces.I5 PS2.1 capture"
	var rook := _with(
		[
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("a3", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not rook.legal_targets("a1").has("a2") or rook.legal_targets("a1").has("a4"):
		return "E-pieces.I5 PS2.2 rook ray"
	var occupied := (
		rook.attacks(ChessRules.SIDE_WHITE, "a3") and not rook.attacks(ChessRules.SIDE_WHITE, "a4")
	)
	if not occupied:
		return "E-pieces.I5 first occupied"
	var blocked := _snapshot(rook)
	if _attempt(rook, "a1", "a4")["ok"] or not _same(blocked, rook):
		return "E-pieces.I5 blocked path"
	return ""


func _attack_pin_knight_king() -> String:
	var pin := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("e2", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("d4", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK,
	)
	if not pin.attacks(ChessRules.SIDE_WHITE, "e3"):
		return "E-pieces.I6 PS2.3 pinned attack"
	var into := _snapshot(pin)
	if _attempt(pin, "d4", "e3")["ok"] or not _same(into, pin):
		return "E-pieces.I6 PS2.3 king step"
	var knight := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("b1", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("a2", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("b2", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("c3", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK,
	)
	var jumped := (
		knight.attacks(ChessRules.SIDE_WHITE, "c3") and knight.in_check(ChessRules.SIDE_BLACK)
	)
	if not jumped:
		return "E-pieces.I6 PS2.4 knight jump"
	var kings := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("d3", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK,
	)
	if not kings.attacks(ChessRules.SIDE_WHITE, "e2"):
		return "E-pieces.I6 PS2.5 king attack"
	var adjacent := _snapshot(kings)
	if _attempt(kings, "d3", "e2")["ok"] or not _same(adjacent, kings):
		return "E-pieces.I6 PS2.5 illegal"
	return ""


func _attack_sliders_and_edges() -> String:
	var queen := _with(
		[
			_man("d4", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
			_man("d6", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var queen_targets := queen.legal_targets("d4")
	var queen_ok := queen_targets.has("d5") and queen_targets.has("d6") and queen_targets.has("e5")
	if not queen_ok or queen_targets.has("d7") or queen.attacks(ChessRules.SIDE_WHITE, "d7"):
		return "E-pieces.I5 queen ray"
	var edge := _with(
		[
			_man("a2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("a7", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var edge_ok := (
		edge.attacks(ChessRules.SIDE_WHITE, "b3") and not edge.attacks(ChessRules.SIDE_WHITE, "e4")
	)
	if not edge_ok or not edge.attacks(ChessRules.SIDE_BLACK, "b6"):
		return "E-pieces.I5 pawn edge"
	if edge.attacks(ChessRules.SIDE_WHITE, "z9"):
		return "E-pieces.I5 bad square"
	return ""


func _attack_pawn_blocks() -> String:
	var doubled := _with(
		[
			_man("e2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("e3", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if doubled.legal_targets("e2").has("e3") or doubled.legal_targets("e2").has("e4"):
		return "E-pieces.I5 pawn blocked"
	var occupied_dest := _with(
		[
			_man("e2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("e4", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var dests := occupied_dest.legal_targets("e2")
	if not dests.has("e3") or dests.has("e4"):
		return "E-pieces.I5 pawn double blocked"
	var unknown := _with(
		[
			_man("a4", ChessRules.SIDE_WHITE, "camel"),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not unknown.legal_targets("a4").is_empty() or _attempt(unknown, "a4", "a5")["ok"]:
		return "unknown kind"
	var no_king := ChessRules.new()
	no_king.load_position(
		[_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK)], ChessRules.SIDE_WHITE
	)
	if no_king.in_check(ChessRules.SIDE_WHITE) or not _attempt(no_king, "a1", "a2")["ok"]:
		return "E-pieces.I7 no king"
	return ""


func _check_check_and_filter() -> String:
	var problem := _filter_self_check()
	if problem.is_empty():
		problem = _filter_pin_and_discovery()
	return problem


func _filter_self_check() -> String:
	var checked := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not checked.in_check(ChessRules.SIDE_WHITE):
		return "E-pieces.I7 in check"
	var step := _with(
		[
			_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h5", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var safe_before := _snapshot(step)
	var illegal := _attempt(step, "e4", "e5")
	var rejected: bool = not illegal["ok"] and _same(safe_before, step)
	if not rejected or not _only_reject(illegal, ChessRules.REASON_ILLEGAL):
		return "E-pieces.I8 I10 PS1.5 self-check"
	var safe := _attempt(step, "e4", "e3")
	if not safe["ok"] or not _only_apply(safe, "e4", "e3", ChessRules.SIDE_BLACK):
		return "E-pieces.I10 PS1.4 safe king"
	return ""


func _filter_pin_and_discovery() -> String:
	var pinned := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("e2", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var pin_before := _snapshot(pinned)
	var escape := _attempt(pinned, "e2", "d4")
	if escape["ok"] or not _same(pin_before, pinned):
		return "E-pieces.I8 I10 pin escape"
	if not _attempt(pinned, "e1", "f1")["ok"]:
		return "E-pieces.I10 king leaves pin file"
	var discovered := _with(
		[
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e2", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if discovered.in_check(ChessRules.SIDE_BLACK):
		return "E-pieces.I7 discovered before"
	var opened: bool = (
		_attempt(discovered, "e2", "d4")["ok"] and discovered.in_check(ChessRules.SIDE_BLACK)
	)
	if not opened or not _double_check():
		return "E-pieces.I7 discovered or double check"
	return ""


func _double_check() -> bool:
	var both := _with(
		[
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("a4", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			_man("c1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK
	)
	var rook_only := _with(
		[
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("c1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK
	)
	var bishop_only := _with(
		[
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			_man("a4", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			_man("c1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK
	)
	var neither := _with(
		[
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			_man("c1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK
	)
	return (
		both.in_check(ChessRules.SIDE_BLACK)
		and rook_only.in_check(ChessRules.SIDE_BLACK)
		and bishop_only.in_check(ChessRules.SIDE_BLACK)
		and not neither.in_check(ChessRules.SIDE_BLACK)
	)


func _check_layer() -> String:
	var source := str(ChessRules.new().get_script().source_code)
	if not source.contains("move_applied"):
		return "layers.md D2 source unavailable"
	for token in [
		"PlaytestSeams", "Presentation", "SessionRouter", "AssetResolver", "localStorage"
	]:
		if source.contains(token):
			return "layers.md D2 references %s" % token
	if source.contains("TEL.4") or ChessRules.new().has_method("emit_tel"):
		return "layers.md D2 TEL.4"
	return ""


func _check_ptd_pieces_common() -> String:
	var steps: Array = [_ptd_s1, _ptd_s2, _ptd_s3, _ptd_s4, _ptd_s5]
	var problem := ""
	for step in steps:
		if not problem.is_empty():
			break
		problem = step.call()
	return problem


func _ptd_s1() -> String:
	var problem := _ptd_s1_capture()
	if problem.is_empty():
		problem = _ptd_s1_block()
	if problem.is_empty():
		print("PTD-pieces-common S1 pass")
	return problem


func _ptd_s2() -> String:
	var self_check := _with(
		[
			_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h5", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var before := _snapshot(self_check)
	if _attempt(self_check, "e4", "e5")["ok"] or not _same(before, self_check):
		return "PTD-pieces-common S2"
	print("PTD-pieces-common S2 pass")
	return ""


func _ptd_s4() -> String:
	var own := _with(
		[
			_man("a4", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var own_before := _snapshot(own)
	if _attempt(own, "a4", "e4")["ok"] or not _same(own_before, own):
		return "PTD-pieces-common S4"
	print("PTD-pieces-common S4 pass")
	return ""


func _ptd_s1_capture() -> String:
	var rules := _with(
		[
			_man("c3", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("d5", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if (
		not _attempt(rules, "c3", "d5")["ok"]
		or rules.piece_on("d5")["kind"] != ChessRules.KIND_KNIGHT
	):
		return "PTD-pieces-common S1 capture"
	return ""


func _ptd_s1_block() -> String:
	var rules := _with(
		[
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("a3", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var before := _snapshot(rules)
	if not rules.legal_targets("a1").has("a2"):
		return "PTD-pieces-common S1 open step"
	if _attempt(rules, "a1", "a4")["ok"] or not _same(before, rules):
		return "PTD-pieces-common S1 blocked"
	return ""


func _ptd_s3() -> String:
	var rules := _with(
		[
			_man("a2", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var problem := ""
	if not _attempt(rules, "a2", "e2")["ok"]:
		problem = "PTD-pieces-common S3 deliver"
	if problem.is_empty() and rules.position_field()["side_to_move"] != ChessRules.SIDE_BLACK:
		problem = "PTD-pieces-common S3 side"
	if problem.is_empty() and not rules.in_check(ChessRules.SIDE_BLACK):
		problem = "PTD-pieces-common S3 check"
	var during := _snapshot(rules)
	var illegal := _attempt(rules, "e8", "e7")
	if problem.is_empty() and (illegal["ok"] or not _same(during, rules)):
		problem = "PTD-pieces-common S3 illegal escape"
	if problem.is_empty() and not _attempt(rules, "e8", "d8")["ok"]:
		problem = "PTD-pieces-common S3 legal escape"
	var side_after: bool = rules.position_field()["side_to_move"] == ChessRules.SIDE_WHITE
	if problem.is_empty() and not side_after:
		problem = "PTD-pieces-common S3 after escape"
	if problem.is_empty():
		print("PTD-pieces-common S3 pass")
	return problem


func _ptd_s5() -> String:
	var template := [
		_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
		_man("a3", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
		_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
		_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
	]
	var rules := _with(template)
	var targets := rules.legal_targets("a1")
	if targets.is_empty():
		return "PTD-pieces-common S5 empty"
	for square in rules.squares():
		var probe := _with(template)
		var result := _attempt(probe, "a1", str(square))
		if targets.has(square) and not result["ok"]:
			return "PTD-pieces-common S5 rejected %s" % square
		if not targets.has(square) and result["ok"]:
			return "PTD-pieces-common S5 accepted %s" % square
	print("PTD-pieces-common S5 pass")
	return ""


func _with(
	pieces: Array,
	side: String = ChessRules.SIDE_WHITE,
	castling: Dictionary = {},
	en_passant: String = "",
) -> ChessRules:
	var rules := ChessRules.new()
	rules.load_position(pieces, side, castling, en_passant)
	return rules


func _man(square: String, color: String, kind: String) -> Dictionary:
	return {"square": square, "color": color, "kind": kind}


func _expect_piece(rules: ChessRules, square: String, color: String, kind: String) -> String:
	var piece := rules.piece_on(square)
	if piece.get("color", "") != color or piece.get("kind", "") != kind:
		return "%s occupancy" % square
	return ""


func _square_form(square: String) -> bool:
	if square.length() != 2:
		return false
	var file := square.unicode_at(0)
	var rank := square.unicode_at(1)
	return file >= 97 and file <= 104 and rank >= 49 and rank <= 56


func _snapshot(rules: ChessRules) -> Dictionary:
	return {"f1": rules.position_field(), "f2": rules.castling_ep()}


func _same(before: Dictionary, rules: ChessRules) -> bool:
	var after := _snapshot(rules)
	if not _dict_same(before["f1"], after["f1"]):
		return false
	return _dict_same(before["f2"], after["f2"])


func _rights_unchanged(before: Dictionary, rules: ChessRules) -> bool:
	return _dict_same(before["f2"], rules.castling_ep())


func _dict_same(left: Dictionary, right: Dictionary) -> bool:
	return JSON.stringify(left) == JSON.stringify(right)


func _attempt(
	rules: ChessRules, from_square: String, to_square: String, promotion := ""
) -> Dictionary:
	var applied: Array = []
	var rejected: Array = []
	var on_applied := func(move: Dictionary, side: String) -> void:
		applied.append({"move": move, "side": side})
	var on_rejected := func(reason: String) -> void: rejected.append(reason)
	rules.move_applied.connect(on_applied)
	rules.move_rejected.connect(on_rejected)
	var ok := rules.try_move(from_square, to_square, promotion)
	rules.move_applied.disconnect(on_applied)
	rules.move_rejected.disconnect(on_rejected)
	return {"ok": ok, "applied": applied, "rejected": rejected}


func _only_reject(result: Dictionary, reason: String) -> bool:
	var rejected: Array = result["rejected"]
	var applied: Array = result["applied"]
	return rejected.size() == 1 and str(rejected[0]) == reason and applied.is_empty()


func _only_apply(result: Dictionary, from_square: String, to_square: String, side: String) -> bool:
	var applied: Array = result["applied"]
	var rejected: Array = result["rejected"]
	if applied.size() != 1 or not rejected.is_empty():
		return false
	var event: Dictionary = applied[0]
	var move: Dictionary = event["move"]
	return move["from"] == from_square and move["to"] == to_square and event["side"] == side
