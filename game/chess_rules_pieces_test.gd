class_name ChessRulesPiecesTest
extends SceneTree
## Headless proofs for E-pieces I12–I34, I9, and PTD king/officers/pawn.


func _initialize() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array = [
		_check_king_and_castling,
		_check_officers,
		_check_pawn_ep_promotion,
		_check_ptd_pieces_king,
		_check_ptd_pieces_officers,
		_check_ptd_pieces_pawn,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return problem
	return ""


func _check_king_and_castling() -> String:
	var problem := _king_step_i12()
	if problem.is_empty():
		problem = _castling_form_i13_i15()
	if problem.is_empty():
		problem = _castling_refused_i16_i21()
	if problem.is_empty():
		problem = _castling_rights_i22()
	return problem


func _king_step_i12() -> String:
	var rules := _with(
		[
			_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var targets := rules.legal_targets("e4")
	if not targets.has("e5") or not targets.has("d5") or targets.has("e6"):
		return "E-pieces.I12 king step"
	var before := _snapshot(rules)
	if _attempt(rules, "e4", "e6")["ok"] or not _same(before, rules):
		return "E-pieces.I12 multi-square illegal"
	return ""


func _castling_form_i13_i15() -> String:
	var white := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not white.legal_targets("e1").has("g1") or not white.legal_targets("e1").has("c1"):
		return "E-pieces.I14 I15 castling targets"
	if not _attempt(white, "e1", "g1")["ok"]:
		return "E-pieces.I14 kingside apply"
	if (
		white.piece_on("g1").get("kind", "") != ChessRules.KIND_KING
		or white.piece_on("f1").get("kind", "") != ChessRules.KIND_ROOK
		or not white.piece_on("e1").is_empty()
		or not white.piece_on("h1").is_empty()
	):
		return "E-pieces.I13 I14 king rook landings"
	var black := _with(
		[
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK,
	)
	if not _attempt(black, "e8", "c8")["ok"]:
		return "E-pieces.I15 queenside apply"
	if (
		black.piece_on("c8").get("kind", "") != ChessRules.KIND_KING
		or black.piece_on("d8").get("kind", "") != ChessRules.KIND_ROOK
	):
		return "E-pieces.I13 I15 queenside landings"
	return ""


func _castling_refused_i16_i21() -> String:
	var problem := _castling_rights_and_path()
	if problem.is_empty():
		problem = _castling_check_blocks()
	return problem


func _castling_rights_and_path() -> String:
	var moved_king := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_WHITE,
		{
			"white_kingside": false,
			"white_queenside": false,
			"black_kingside": false,
			"black_queenside": false
		},
	)
	var before := _snapshot(moved_king)
	var problem := ""
	if moved_king.legal_targets("e1").has("g1") or _attempt(moved_king, "e1", "g1")["ok"]:
		problem = "E-pieces.I16 king moved"
	elif not _same(before, moved_king):
		problem = "E-pieces.I21 refused unchanged"
	var path_block := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("f1", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if problem.is_empty() and path_block.legal_targets("e1").has("g1"):
		problem = "E-pieces.I18 path occupied"
	return problem


func _castling_check_blocks() -> String:
	var problem := ""
	var in_check := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if in_check.legal_targets("e1").has("g1"):
		problem = "E-pieces.I19 castling in check"
	var through_check := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("f8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if problem.is_empty() and through_check.legal_targets("e1").has("g1"):
		problem = "E-pieces.I20 through check"
	var into_check := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("g8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if problem.is_empty() and into_check.legal_targets("e1").has("g1"):
		problem = "E-pieces.I20 into check"
	var rook_attacked := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if problem.is_empty() and not rook_attacked.legal_targets("e1").has("g1"):
		problem = "E-pieces.I20 rook start may be attacked"
	return problem


func _castling_rights_i22() -> String:
	var rules := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not _attempt(rules, "e1", "g1")["ok"]:
		return "E-pieces.I22 castling apply"
	var rights: Dictionary = rules.castling_ep()
	if rights["white_kingside"] or rights["white_queenside"]:
		return "E-pieces.I22 rights cleared"
	var rook_move := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not _attempt(rook_move, "h1", "h2")["ok"]:
		return "E-pieces.I25 rook move"
	if rook_move.castling_ep()["white_kingside"] or not rook_move.castling_ep()["white_queenside"]:
		return "E-pieces.I17 I25 rook right cleared"
	if rook_move.legal_targets("e1").has("g1"):
		return "E-pieces.I17 after rook moved"
	return ""


func _check_officers() -> String:
	var problem := _officer_slide_i23_i26()
	if problem.is_empty():
		problem = _officer_knight_i27()
	return problem


func _officer_slide_i23_i26() -> String:
	var rook := _with(
		[
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_ROOK),
			_man("a4", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("h1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var rook_targets := rook.legal_targets("a1")
	if not rook_targets.has("a2") or not rook_targets.has("a4") or rook_targets.has("a5"):
		return "E-pieces.I23 I25 rook slide"
	var bishop := _with(
		[
			_man("c1", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			_man("e3", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var bishop_targets := bishop.legal_targets("c1")
	if not bishop_targets.has("d2") or not bishop_targets.has("e3") or bishop_targets.has("f4"):
		return "E-pieces.I23 I26 bishop slide"
	var queen := _with(
		[
			_man("d1", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
			_man("d4", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var queen_targets := queen.legal_targets("d1")
	if not queen_targets.has("d3") or not queen_targets.has("d4") or queen_targets.has("d5"):
		return "E-pieces.I23 I24 queen slide"
	if not queen_targets.has("e2"):
		return "E-pieces.I24 queen diagonal"
	return ""


func _officer_knight_i27() -> String:
	var knight := _with(
		[
			_man("b1", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			_man("c3", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			_man("b2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("c2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
		]
	)
	var targets := knight.legal_targets("b1")
	if not targets.has("a3") or not targets.has("c3") or not targets.has("d2"):
		return "E-pieces.I27 knight jump"
	if targets.has("b3"):
		return "E-pieces.I27 non L-shape"
	return ""


func _check_pawn_ep_promotion() -> String:
	var problem := _pawn_steps_i28_i30()
	if problem.is_empty():
		problem = _pawn_en_passant_i9_i31_i32()
	if problem.is_empty():
		problem = _pawn_promotion_i33_i34()
	return problem


func _pawn_steps_i28_i30() -> String:
	var problem := _pawn_push_rules()
	if problem.is_empty():
		problem = _pawn_capture_and_color()
	return problem


func _pawn_push_rules() -> String:
	var rules := ChessRules.new()
	rules.reset_opening()
	var single := rules.legal_targets("e2")
	var problem := ""
	if not single.has("e3") or not single.has("e4"):
		problem = "E-pieces.I28 I29 double step"
	elif single.has("d3") or single.has("f3"):
		problem = "E-pieces.I30 diagonal without capture"
	elif not _attempt(rules, "e2", "e3")["ok"]:
		problem = "E-pieces.I28 single apply"
	elif str(rules.castling_ep()["en_passant"]) != "":
		problem = "E-pieces.I29 single clears ep"
	return problem


func _pawn_capture_and_color() -> String:
	var capture := _with(
		[
			_man("e4", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("d5", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("e5", ChessRules.SIDE_BLACK, ChessRules.KIND_KNIGHT),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	var targets := capture.legal_targets("e4")
	var problem := ""
	if not targets.has("d5") or targets.has("e5"):
		problem = "E-pieces.I30 diagonal only"
	var black := _with(
		[
			_man("e7", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_BLACK,
	)
	var black_targets := black.legal_targets("e7")
	if problem.is_empty() and (not black_targets.has("e6") or not black_targets.has("e5")):
		problem = "E-pieces.I2 PS1.10 black forward"
	return problem


func _pawn_en_passant_i9_i31_i32() -> String:
	var problem := _pawn_ep_apply()
	if problem.is_empty():
		problem = _pawn_ep_expire_and_pin()
	return problem


func _pawn_ep_apply() -> String:
	var rules := _with(
		[
			_man("e5", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("d5", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_WHITE,
		{},
		"d6",
	)
	var problem := ""
	if not rules.is_pseudo_legal("e5", "d6"):
		problem = "E-pieces.I9 PS1.3 pseudo-legal"
	elif not rules.legal_targets("e5").has("d6"):
		problem = "E-pieces.I31 en passant legal"
	elif not _attempt(rules, "e5", "d6")["ok"]:
		problem = "E-pieces.I31 en passant apply"
	elif (
		rules.piece_on("d6").get("kind", "") != ChessRules.KIND_PAWN
		or not rules.piece_on("d5").is_empty()
		or not rules.piece_on("e5").is_empty()
	):
		problem = "E-pieces.I3 I31 ep removal"
	return problem


func _pawn_ep_expire_and_pin() -> String:
	var expired := _with(
		[
			_man("e5", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("d5", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("a2", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_WHITE,
		{},
		"d6",
	)
	var problem := ""
	if not _attempt(expired, "a2", "a3")["ok"]:
		problem = "E-pieces.I32 other move"
	elif str(expired.castling_ep()["en_passant"]) != "" or expired.legal_targets("e5").has("d6"):
		problem = "E-pieces.I32 ep expired"
	var pinned := _with(
		[
			_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("e5", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("d5", ChessRules.SIDE_BLACK, ChessRules.KIND_PAWN),
			_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		],
		ChessRules.SIDE_WHITE,
		{},
		"d6",
	)
	if problem.is_empty() and not pinned.is_pseudo_legal("e5", "d6"):
		problem = "E-pieces.I9 pinned still pseudo-legal"
	elif problem.is_empty() and pinned.legal_targets("e5").has("d6"):
		problem = "E-pieces.I9 I10 filter removes ep"
	return problem


func _pawn_promotion_i33_i34() -> String:
	for kind in [
		ChessRules.KIND_QUEEN,
		ChessRules.KIND_ROOK,
		ChessRules.KIND_BISHOP,
		ChessRules.KIND_KNIGHT,
	]:
		var rules := _with(
			[
				_man("e7", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
				_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
			]
		)
		if not _attempt(rules, "e7", "e8", kind)["ok"]:
			return "E-pieces.I33 I34 promote %s" % kind
		if rules.piece_on("e8").get("kind", "") != kind:
			return "E-pieces.I33 promoted unit %s" % kind
		if rules.piece_on("e8").get("color", "") != ChessRules.SIDE_WHITE:
			return "E-pieces.I34 color %s" % kind
	var bad := _with(
		[
			_man("e7", ChessRules.SIDE_WHITE, ChessRules.KIND_PAWN),
			_man("a1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			_man("h8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
		]
	)
	if not _only_reject(_attempt(bad, "e7", "e8", "king"), ChessRules.REASON_PROMOTION):
		return "E-pieces.I33 refuse king"
	return ""


func _check_ptd_pieces_king() -> String:
	var problem := _king_step_i12()
	if problem.is_empty():
		problem = _castling_form_i13_i15()
	if problem.is_empty():
		problem = _castling_refused_i16_i21()
	if problem.is_empty():
		problem = _castling_rights_i22()
	if problem.is_empty():
		print("PTD-pieces-king pass")
	return problem


func _check_ptd_pieces_officers() -> String:
	var problem := _officer_slide_i23_i26()
	if problem.is_empty():
		problem = _officer_knight_i27()
	if problem.is_empty():
		print("PTD-pieces-officers pass")
	return problem


func _check_ptd_pieces_pawn() -> String:
	var problem := _pawn_steps_i28_i30()
	if problem.is_empty():
		problem = _pawn_en_passant_i9_i31_i32()
	if problem.is_empty():
		problem = _pawn_promotion_i33_i34()
	if problem.is_empty():
		print("PTD-pieces-pawn pass")
	return problem


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
