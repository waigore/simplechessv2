class_name DemoAutodrive
extends "res://main.gd"
## Scripted stream for the headless smoke of demo #335: a real DIF.Y1 deal from
## mode pick, the Wrong move, the four endings, the refused place, the calm
## leave, the promotion state, the fixture slice, the style measurements, and
## the persistence path. Every case prints; a miss prints `[demo] FAIL <case>`.


func _run_autodrive() -> void:
	print("[demo] autodrive begin")
	await _capture("mode-pick", 20)
	stream.rng.seed = 20261024  # GS.Q1: any candidate may be dealt; the seed fixes it
	stream.player_elo = DemoPuzzleStream.ELO_START
	stream.recent_solved.clear()
	await _scenario_deal_from_mode_pick()
	await _scenario_wrong_move()
	await _scenario_reveal()
	await _scenario_abandon()
	await _scenario_mate_in_one()
	_scenario_refused_place()
	await _scenario_leave()
	_scenario_promotion_state()
	_scenario_fixture_slice()
	_scenario_board_style()
	_scenario_persistence()
	if _problems.is_empty():
		print("[demo] PASS")
	else:
		for problem in _problems:
			print("[demo] FAIL %s" % problem)
		get_tree().quit(1)
		return
	get_tree().quit()


## Saves the live frame when DEMO_SHOT_DIR is set (a graphical run only).
func _capture(tag: String, frames: int = 1) -> void:
	if DisplayServer.get_name() == "headless":
		return
	print("[demo] capture start %s" % tag)
	if frames > 1:
		await get_tree().create_timer(0.1 * float(frames)).timeout
	var image := get_viewport().get_texture().get_image()
	var dir := OS.get_environment("DEMO_SHOT_DIR")
	if dir == "":
		dir = OS.get_user_data_dir()
	var path := dir.path_join("demo-puzzle-stream-%s.png" % tag)
	image.save_png(path)
	print("[demo] screenshot %s -> %s" % [tag, path])


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_problems.append(message)


func _record(puzzle_id: String) -> Dictionary:
	for record in _load_catalog():
		if str(record.get("puzzle_id", "")) == puzzle_id:
			return record
	return {}


## Deal one specific fixture record: the demo stands in a slice, so a scripted
## case narrows the slice to prove one rule at a time.
func _deal_only(puzzle_id: String) -> Dictionary:
	var record := _record(puzzle_id)
	stream.catalog = [record] if not record.is_empty() else []
	var dealt := stream.deal()
	stream.catalog = _load_catalog()
	_draw_board()
	_update_hud()
	return dealt


## The legal move a scripted case needs, as (from, to, promo) indices.
func _uci_pair(uci: String) -> Array:
	return [
		DemoChessRules.square_index(uci.substr(0, 2)),
		DemoChessRules.square_index(uci.substr(2, 2)),
		uci.substr(4, 1).to_lower(),
	]


## K1 / DIF.Y1 - mode pick C2 enters the stream and deals at the player's level.
func _scenario_deal_from_mode_pick() -> void:
	_show_mode_pick()
	_enter_puzzle_stream()
	_expect(screen == PUZZLE_PLAY, "K1/NAV.T2: mode-pick C2 must reach puzzle-play")
	_expect(stream.has_open_puzzle(), "K1: entering the stream must deal a puzzle")
	_expect(
		stream.solving_side == str(stream.pos["side"]), "GS.solvingSide must be the side to move"
	)
	_expect(
		(
			absf(float(stream.puzzle_elo) - stream.player_elo)
			<= float(DemoPuzzleStream.ELO_MATCH_RANGE)
		),
		"DIF.Y1: the dealt puzzle must sit within CFG.ELO_MATCH_RANGE of Player Elo"
	)
	_expect(
		stream.required_sequence.size() >= 1, "F-puzzle-catalog R3: required sequence length >= 1"
	)
	await _capture("puzzle-play", 20)
	print(
		(
			"[demo] deal: puzzle %s at %d for Elo %d (band %d)"
			% [
				stream.puzzle_id,
				stream.puzzle_elo,
				int(stream.player_elo),
				DemoPuzzleStream.ELO_MATCH_RANGE,
			]
		)
	)
	_show_mode_pick()


## The first Solving-side move of the open puzzle that the record does not require.
func _a_non_required_move() -> Dictionary:
	var expected: Dictionary = (
		stream.required_sequence[0] if stream.required_sequence.size() > 0 else {}
	)
	var board: PackedStringArray = stream.pos["board"]
	for index in range(64):
		if board[index] == "" or DemoChessRules.piece_color(board[index]) != stream.solving_side:
			continue
		for move in DemoChessRules.legal_moves(stream.pos, index):
			if (
				not expected.is_empty()
				and int(move["from"]) == int(expected["from"])
				and int(move["to"]) == int(expected["to"])
			):
				continue
			if stream.any_checkmate_wins and _is_mate(move):
				continue
			return move
	return {}


func _is_mate(move: Dictionary) -> bool:
	var after := DemoChessRules.apply(stream.pos, move)
	var defender := str(after["side"])
	return DemoChessRules.in_check(after, defender) and not DemoChessRules.any_legal_move(after)


## K2 / END.L4 - a Wrong move resets the puzzle, deals nothing, and turns the
## eventual completion into a failure.
func _scenario_wrong_move() -> void:
	await get_tree().process_frame
	_deal_only("0002")
	var start_board := (stream.start_pos["board"] as PackedStringArray).duplicate()
	var before_elo := stream.player_elo
	var open_id := stream.puzzle_id
	var wrong := _a_non_required_move()
	_expect(not wrong.is_empty(), "K2: the demo needs a non-required legal move to script")
	if wrong.is_empty():
		return
	var judged := stream.play(int(wrong["from"]), int(wrong["to"]), str(wrong["promo"]))
	_expect(
		str(judged.get("outcome", "")) == "wrong", "K2: a move off the sequence is a Wrong move"
	)
	_expect(stream.wrong_move_on_puzzle, "GS.wrongMoveOnPuzzle must be true after a Wrong move")
	_expect(stream.sequence_index == 0, "GS.sequenceIndex must return to 0 after a Wrong move")
	_expect(stream.pos["board"] == start_board, "K2: a Wrong move returns the puzzle to its start")
	_expect(stream.puzzle_id == open_id, "K2: a Wrong move deals nothing")
	_expect(is_equal_approx(stream.player_elo, before_elo), "K2: a Wrong move does not update Elo")
	print(
		(
			"[demo] wrong move reset: %d -> %d, board back to the deal, no new puzzle"
			% [
				int(wrong["from"]),
				int(wrong["to"]),
			]
		)
	)
	# Finish the sequence: after a Wrong move that is END.L4, a loss.
	while stream.has_open_puzzle() and stream.sequence_index < stream.required_sequence.size():
		var step: Dictionary = stream.required_sequence[stream.sequence_index]
		stream.play(int(step["from"]), int(step["to"]), str(step["promo"]))
	_expect(
		stream.ending == DemoPuzzleStream.END_L4,
		"END.L4: completing after a Wrong move is a failure"
	)
	_expect(stream.player_elo < before_elo, "DIF.Y1: END.L4 lowers Player Elo")
	_expect(
		not stream.recent_solved.has("0002"),
		"F-puzzle-catalog I3: a failed puzzle is not recentSolved"
	)
	print(
		(
			"[demo] END.L4: Elo %d -> %d, recentSolved %d"
			% [
				int(before_elo),
				int(round(stream.player_elo)),
				stream.recent_solved.size(),
			]
		)
	)


## END.L5 - reveal the solution: failed, Elo drops, nothing joins recentSolved.
func _scenario_reveal() -> void:
	await get_tree().process_frame
	_deal_only("0003")
	var before := stream.player_elo
	stream.reveal()
	_expect(stream.ending == DemoPuzzleStream.END_L5, "END.L5: reveal ends the puzzle")
	_expect(stream.player_elo < before, "DIF.Y1: END.L5 lowers Player Elo")
	_expect(stream.cue == "cue_failed", "UI-puzzle-play R2: reveal shows the failed cue")
	_expect(not stream.has_open_puzzle(), "END.L5 settles the open puzzle")
	print("[demo] END.L5: Elo %d -> %d" % [int(before), int(round(stream.player_elo))])


## END.L6 - abandoning scores S = 0 and the stream continues after the update.
func _scenario_abandon() -> void:
	await get_tree().process_frame
	_deal_only("0005")
	var before := stream.player_elo
	stream.abandon()
	_expect(stream.ending == DemoPuzzleStream.END_L6, "END.L6: abandon ends the puzzle")
	_expect(stream.player_elo < before, "DIF.Y1: END.L6 (abandon) lowers Player Elo")
	_expect(stream.cue == "cue_abandon", "UI-puzzle-play R2: abandon shows the abandoned cue")
	print("[demo] END.L6: Elo %d -> %d" % [int(before), int(round(stream.player_elo))])


## F-puzzle-catalog R5 + END.W1 - a mate-in-one accepts any checkmating move.
func _scenario_mate_in_one() -> void:
	await get_tree().process_frame
	_deal_only("0001")
	var before := stream.player_elo
	var alternative := _uci_pair("b1b8")  # the record names a1a8
	var judged := stream.play(int(alternative[0]), int(alternative[1]), str(alternative[2]))
	_expect(
		str(judged.get("ending", "")) == DemoPuzzleStream.END_W1,
		"F-puzzle-catalog R5: another checkmating move must solve a mate-in-one"
	)
	_expect(stream.player_elo > before, "DIF.Y1: END.W1 raises Player Elo")
	_expect(stream.recent_solved.has("0001"), "F-puzzle-catalog I3: END.W1 appends the PuzzleId")
	_expect(stream.cue == "cue_solved", "UI-puzzle-play R2: a solve shows the solved cue")
	print(
		(
			"[demo] END.W1: mate-in-one solved by an unrecorded mate; Elo %d -> %d; recentSolved %d"
			% [
				int(before),
				int(round(stream.player_elo)),
				stream.recent_solved.size(),
			]
		)
	)


## EX.rejected / S5 - an illegal place is refused and is not a Wrong move.
func _scenario_refused_place() -> void:
	_deal_only("0003")
	var board: PackedStringArray = stream.pos["board"]
	var empty := -1
	for index in range(64):
		if board[index] == "":
			empty = index
			break
	var wrong_before := stream.wrong_move_on_puzzle
	var refused := stream.play(empty, empty)
	_expect(
		not bool(refused.get("ok", true)), "UI-puzzle-play S5: an illegal place must be refused"
	)
	_expect(stream.wrong_move_on_puzzle == wrong_before, "S5: a refused place is not a Wrong move")
	_expect(stream.has_open_puzzle(), "S5: a refused place leaves the puzzle open")
	print("[demo] EX.rejected: illegal place refused, puzzle untouched")


## K4 / E1 / NAV.T9 - leaving scores nothing and keeps Player Elo.
func _scenario_leave() -> void:
	_deal_only("0003")
	var before := stream.player_elo
	var recent_before := stream.recent_solved.size()
	_ask(CONFIRM_LEAVE)
	_expect(ui_state == S2, "EX.confirm: leave asks before it acts (S2)")
	await _confirm_action()
	_expect(screen == MODE_PICK, "J-puzzle-session S2 / NAV.T9: leave returns to mode pick")
	_expect(not stream.has_open_puzzle(), "K4: leaving closes the open puzzle")
	_expect(is_equal_approx(stream.player_elo, before), "K4 / PRG.P1: leaving keeps Player Elo")
	_expect(
		stream.recent_solved.size() == recent_before,
		"END.L6: the open puzzle is not scored as abandon on leave"
	)
	print("[demo] leave: back at mode pick, Elo kept at %d" % int(round(stream.player_elo)))


## EX.promote / S4 - a last-rank pawn asks for its type before the move is judged.
func _scenario_promotion_state() -> void:
	var board := PackedStringArray()
	board.resize(64)
	for index in range(64):
		board[index] = ""
	board[DemoChessRules.square_index("a5")] = "bK"  # away from the promotion square
	board[DemoChessRules.square_index("g1")] = "wK"
	board[DemoChessRules.square_index("h7")] = "wP"
	var probe := {
		"board": board,
		"moved": PackedByteArray(),
		"ep_target": -1,
		"side": "w",
		"king": {},
	}
	probe["moved"].resize(64)
	DemoChessRules.init_king(probe)
	stream._close_puzzle()
	stream.pos = probe
	stream.start_pos = DemoChessRules.duplicate_position(probe)
	stream.required_sequence = [DemoPuzzleStream._move_of(probe, "h7h8q")]
	stream.sequence_index = 0
	stream.solving_side = "w"
	stream.puzzle_id = "probe"
	stream.puzzle_elo = 1000
	var from_index := DemoChessRules.square_index("h7")
	var to_index := DemoChessRules.square_index("h8")
	var asked := stream.play(from_index, to_index, "")
	_expect(
		bool(asked.get("promote", false)), "EX.promote S4: a last-rank pawn place asks for the type"
	)
	var judged := stream.play(from_index, to_index, "q")
	_expect(
		str(judged.get("ending", "")) == DemoPuzzleStream.END_W1,
		"UI-puzzle-play C6: the judged move runs once the type is committed"
	)
	print("[demo] EX.promote: type asked, then the place was judged")
	stream._close_puzzle()


## The fixture slice is a recorded-format slice (epic #35 Notes): every FEN opens,
## every move is legal in order, and every mate-in-one mark is a real mate.
func _scenario_fixture_slice() -> void:
	var checked := 0
	for record in _load_catalog():
		var pid := str(record.get("puzzle_id", ""))
		var opened := DemoPuzzleStream.position_from_fen(str(record.get("fen", "")))
		_expect(not opened.is_empty(), "fixture %s: unreadable FEN" % pid)
		if opened.is_empty():
			continue
		var rolling := opened
		var moves: Array = record.get("moves", [])
		for uci in moves:
			var step := DemoPuzzleStream._move_of(rolling, str(uci))
			_expect(not step.is_empty(), "fixture %s: illegal move %s" % [pid, str(uci)])
			if step.is_empty():
				break
			rolling = DemoChessRules.apply(rolling, step)
		var marked: bool = (record.get("themes", []) as Array).has("mateIn1")
		_expect(
			marked == bool(record.get("any_checkmate_wins", false)),
			"fixture %s: SCH-puzzle-catalog I3 mark disagrees with themes" % pid
		)
		if marked:
			var first := DemoPuzzleStream._move_of(opened, str(moves[0]))
			var presented := DemoChessRules.apply(opened, first)
			var mate := DemoPuzzleStream._move_of(presented, str(moves[1]))
			var after := DemoChessRules.apply(presented, mate)
			var defender := str(after["side"])
			_expect(
				(
					not mate.is_empty()
					and DemoChessRules.in_check(after, defender)
					and not DemoChessRules.any_legal_move(after)
				),
				"fixture %s: the recorded mate-in-1 move is not mate" % pid
			)
		checked += 1
	_expect(checked >= 6, "fixture slice: expected at least six recorded puzzles")
	print(
		(
			"[demo] fixture slice: %d records legal and marked correctly (stand-in for the host snapshot)"
			% checked
		)
	)


## SPC / FRM / PER.R7 - the copied board view still measures its piece bodies and
## coordinate labels against the style specs, and every panel clears the board.
func _scenario_board_style() -> void:
	_deal_only("0003")
	for problem in view.measure_piece_bodies():
		_expect(false, "SPC.E1 / FRM.P2: %s" % str(problem))
	for problem in view.measure_coord_labels():
		_expect(false, "PER.R7: %s" % str(problem))
	var board := Rect2(BOARD_ORIGIN + Vector2(-0.36, -0.36) * UNIT, Vector2(8.72, 8.72) * UNIT)
	var hud := Rect2(Vector2(48.0, HUD_TOP), Vector2(624.0, 190.0))
	var actions := Rect2(Vector2(40.0, ACTION_TOP), Vector2(640.0, 96.0))
	_expect(
		not board.intersects(hud),
		"UI-puzzle-play R1/R2: the Elo and status region must clear the board"
	)
	_expect(
		not board.intersects(actions),
		"UI-puzzle-play R1/R3: the action region must clear the board"
	)
	_expect(
		Rect2(Vector2.ZERO, FRAME_SIZE).encloses(actions),
		"UI-puzzle-play R3: the action bar must stay inside the frame"
	)
	print("[demo] board style: bodies and labels inside the specs; panels clear the board")


## PRG.M1 / P1 / P3 + EX.save-failure - commit, restore, trim, and a failed write.
func _scenario_persistence() -> void:
	stream.player_elo = 1043.0
	stream.recent_solved = ["0001"]
	_commit_save()
	var reloaded := DemoPuzzleStream.new(_load_catalog())
	reloaded.restore(_read_save())
	_expect(is_equal_approx(reloaded.player_elo, 1043.0), "PRG.P1: Player Elo round-trips")
	_expect(reloaded.recent_solved == ["0001"], "PRG.P3: recentSolved round-trips")
	for index in range(30):
		reloaded.recent_solved.append("x%d" % index)
	reloaded._trim_recent()
	_expect(
		reloaded.recent_solved.size() == DemoPuzzleStream.ELO_RECENT_WINDOW,
		"PRG.M1: recentSolved is trimmed to CFG.ELO_RECENT_WINDOW"
	)
	# EX.save-failure: the save reports failure (`DEMO_FORCE_SAVE_FAIL=1`), so the
	# prior committed Elo is kept and S3 opens with the S1 board still usable.
	stream.player_elo = 1200.0  # an uncommitted bump
	commit_failed = true
	_commit_save()
	commit_failed = false
	_expect(
		not is_equal_approx(stream.player_elo, 1200.0),
		"EX.save-failure: a failed write keeps the prior Player Elo"
	)
	_expect(ui_state == S3, "EX.save-failure: a failed write reaches S3")
	_dismiss_save_failure()
	_expect(ui_state == S1, "S3: Dismiss returns to S1")
	print("[demo] EX.save-failure: prior Elo kept at %d" % int(round(stream.player_elo)))
