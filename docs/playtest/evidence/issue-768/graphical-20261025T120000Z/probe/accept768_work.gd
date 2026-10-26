class_name Accept768Work
extends SceneTree
## Acceptance playtest for #768 (promote the puzzle-stream keep list into main code).
##
## Runs the shipped scene `res://main.tscn` headless and drives it the way a player does:
## mode-pick C2, the puzzle panel's own buttons, and board gestures through
## `SessionRouter`. The deal travels the production path — `PuzzleStream.request()` ->
## `CatalogDealClient` -> `Accept768CatalogPeer` (an answer-capable peer behind the same
## seam the seams build uses) -> `PuzzleStream.poll()` -> `PuzzleSession.deal()`. The
## persisted document is the store's own memory backend, so the commit path is real.
##
## One attempt at a time: nothing is dealt unless `advance()` asks for it, which is what
## K3 does after a scored attempt and its cue. Every row below leaves the stream empty.
##
## Protocols: PTD-puzzle-stream (S1-S10) and PTD-difficulty (S1-S2). Both Design,
## headless only. Throwaway harness, kept inside the evidence folder it produced.
## Run: godot --headless --path . -s res://accept768_work.gd

const MATE_FEN := "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1"
const MATE_MOVES := ["g8h8", "b1b8"]
const WRONG_MOVE := ["b1", "b7"]
## The start position; the record opens with White's `g1f3`, Black to solve.
const BLACK_SOLVE_FEN := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
const BLACK_SOLVE_MOVES := ["g1f3", "e7e5"]
## A king-and-pawn endgame whose solution promotes on g8.
const KPAWN_FEN := "k7/6P1/8/8/8/8/8/7K b - - 0 1"

var _main: Presentation
var _router: SessionRouter
var _panel: PuzzlePlayPanel
var _peer: Accept768CatalogPeer
var _failures: Array[String] = []
var _row := ""
var _dealt: Array[String] = []
## The last Elo read from a session before its stream was left (the session is freed).
var _last_elo := 1000.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate() as Presentation
	# The shipped PlaytestHarness ends a headless run after its smoke
	# (SEQ-playtest-headless-smoke); remove it so this probe drives the session, as
	# game/puzzle_play_test.gd does.
	var harness := _main.get_node("PlaytestHarness")
	_main.remove_child(harness)
	harness.free()
	_main.name = "PresentationRoot"
	var persist := _main.get_node("PersistStore") as PersistStore
	persist.memory_backend = {}
	persist.clear_storage()
	root.add_child(_main)
	await _pump(6)
	_router = _main.get_node("SessionRouter") as SessionRouter
	_router.locale = "en"
	_panel = _main.find_child("PuzzlePlay", true, false) as PuzzlePlayPanel
	# T9 / T10 unset fails every read (B5); the answer comes from the peer below.
	_router.advice_endpoint = "http://accept768.invalid"
	_router.advice_api_key = "accept768"
	_peer = Accept768CatalogPeer.new()
	_router.call("_set_accept768_peer", _peer)
	var seams := _main.get_node("PlaytestSeams")
	print("display=", DisplayServer.get_name())
	print("session_id=", seams.get("session_id"))

	await _s1_entry_and_deal()
	await _s2_clean_solve()
	await _s3_mate_in_one()
	await _s4_recent_not_dealt()
	await _s5_widen()
	await _s6_one_move_and_unreadable()
	await _s7_wrong_move()
	await _s8_reveal_and_abandon()
	await _s9_leave_keeps_elo()
	await _s10_fail_after_wrong()
	await _dif_s1_s2()

	print("DEALT=", JSON.stringify(_dealt))
	print("FAILURES=", JSON.stringify(_failures))
	quit(0 if _failures.is_empty() else 1)



## ENV.2 — save the window as a screenshot of a judged state. `--path .` runs the native
## window, so this is the same build the headless run measured, rendered.
func _shot(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	# What the cue *is*, for the shots whose frame lands after the cue cleared (notes.md).
	var cue_label := _panel.find_child("ResultCue", true, false) as Label
	print(
		"SHOT_CUE ", name,
		" panel_cue=[", _panel.get("cue_key"), "]",
		" label=[", cue_label.text if cue_label != null else "none", "]",
		" rect=", cue_label.get_global_rect() if cue_label != null else "?"
	)
	var dir := OS.get_environment("ACCEPT768_SHOTS_DIR")
	if dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		print("SHOT_FAILED name=", name)
		return
	var path := dir.path_join(name + ".png")
	var err := image.save_png(path)
	print("SHOT ", "ok" if err == OK else "err=%d" % err, " ", path, " ", image.get_width(), "x", image.get_height())


func _pump(frames: int) -> void:
	for i in frames:
		await process_frame


func _row_head(id: String) -> void:
	_row = id
	print("ROW ", id)


func _check(ok: bool, label: String, detail: String = "") -> void:
	print("CHECK %s [%s] %s %s" % ["PASS" if ok else "FAIL", _row, label, detail])
	if not ok:
		_failures.append("[%s] %s :: %s" % [_row, label, detail])


func _flow() -> PuzzlePlayFlow:
	return _router.puzzle_flow if _router != null and is_instance_valid(_router) else null


func _session() -> PuzzleSession:
	var flow := _flow()
	return flow.session if flow != null else null


## Read an attempt's ending straight after the action that settles it, before any
## engine frame runs: the K3 deal and the next tick replace the attempt and clear the
## cue in the same call, so a frame later the reading is gone.
func _result_of(action: Callable) -> Dictionary:
	var s := _session()
	action.call()
	var out := {
		"last_result": s.last_result.duplicate(true) if is_instance_valid(s) else {},
		"cue": _cue(),
		"open": s.has_open_puzzle() if is_instance_valid(s) else false,
	}
	return out


func _record(id: String, rating: int, fen: String, moves: Array, themes: Array = ["mateIn1"]) -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": id,
		"fen": fen,
		"moves": moves,
		"rating": rating,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": themes,
		"game_url": "",
		"opening_tags": "",
		"daily_date": "",
	}


func _mate(id: String, rating := 1000) -> Dictionary:
	return _record(id, rating, MATE_FEN, MATE_MOVES)


## A non-mating two-move record: its opening move leaves nothing to solve in one,
## so a wrong move can follow (the S8 Abandon leg uses it after Reveal).
func _promotion(id: String, rating: int) -> Dictionary:
	return _record(id, rating, KPAWN_FEN, ["a8b8", "g7g8q"], [])


func _dealt_id() -> String:
	var s := _session()
	return s.puzzle_id if s != null else ""


## NAV.T2 — enter the stream through the shipped mode-pick control (C2). The peer
## answers the first read at once; a tick applies it.
func _enter_with(records: Array) -> void:
	if _router.stage != SessionRouter.STAGE_MODE_PICK:
		_router.call("_go_mode_pick", "S1")
		await _pump(5)
	_peer.serve(records)
	_router.handle_control("mode-pick", "C2")
	await _pump(8)


## Leave the stream (NAV.T9 / E1) when one is open, so the next entry starts clean.
func _exit_stream() -> void:
	var s := _session()
	if s != null:
		_last_elo = float(s.player_elo)
	if s != null and _router.stage == SessionRouter.STAGE_PUZZLE_PLAY:
		s.leave()
		await _pump(4)
	if _router.stage != SessionRouter.STAGE_MODE_PICK:
		_router.call("_go_mode_pick", "S1")
		await _pump(4)


## One judged place per row goes through the shipped control path: select, then place.
## The ending a row reads:
## - the attempt itself is `PuzzleSession.last_result`, written by `_apply_outcome`
##   before the result cue is painted;
## - the R2 cue is what the panel paints while the ending is up (`screen.cue_key`),
##   because K3's cue shows only until the next deal;
## - the sequence is the attempt's own `required_sequence`, captured while that screen
##   is up: `advance()` runs inside the same call and drops the attempt.
## Nothing here reads a product internal private to a different layer, and no frame is
## processed inside the judging call, so what is read is the ending, not the next deal.
func _play_move(from_sq: String, to_sq: String, next_records: Array = []) -> Dictionary:
	_router.handle_input_commit(from_sq, "", "")
	# The ending raises the K3 read inside the judging call; the peer answers a read
	# when it starts, so the record that read should receive is queued first.
	if not next_records.is_empty():
		_peer.serve(next_records)
	return _capture_ending(func() -> void: _router.handle_input_commit(from_sq, to_sq, ""))


## Drive `action` and read the ending from the last screen it painted.
func _capture_ending(action: Callable) -> Dictionary:
	var screens: Array = []
	var sequences: Array = []
	var capture := func(state: Dictionary) -> void:
		screens.append(state)
		var s := _session()
		if s != null and not (s.last_result as Dictionary).is_empty():
			sequences.append((s.required_sequence as Array).duplicate(true))
	_router.play_rendered.connect(capture)
	action.call()
	_router.play_rendered.disconnect(capture)
	if screens.is_empty():
		return {"settled": {}, "sequence": [], "cue": "", "ui_state": "", "player_elo": -1.0}
	var last: Dictionary = screens[screens.size() - 1]
	var s := _session()
	return {
		"settled": (s.last_result as Dictionary).duplicate(true) if s != null else {},
		"sequence": sequences[sequences.size() - 1] if not sequences.is_empty() else [],
		"cue": str(last.get("cue_key", "")),
		"ui_state": str(last.get("ui_state", "")),
		"player_elo": float(last.get("player_elo", -1.0)),
	}


func _place(from_sq: String, to_sq: String) -> bool:
	_router.handle_input_commit(from_sq, "", "")
	await _pump(1)
	return _router.handle_input_commit(from_sq, to_sq, "")


func _cue() -> String:
	return str(_flow().cue_key) if _flow() != null else ""


## S1 — mode pick defaults to Shared game; C2 enters; the deal matches the served record.
func _s1_entry_and_deal() -> void:
	_row_head("P1/K1 R1-R3")
	_router.call("_go_mode_pick", "S1")
	await _pump(5)
	_check(_router.stage == SessionRouter.STAGE_MODE_PICK, "mode pick opens", str(_router.stage))
	var shared := _main.find_child("SharedGame", true, false) as Button
	_check(shared != null, "Shared game is the first mode-pick row", shared.text if shared else "?")
	await _enter_with([_mate("accept768-s1", 1000)])
	var s := _session()
	_dealt.append(_dealt_id())
	_check(s != null and s.has_open_puzzle(), "the served record deals through the stream", _dealt_id())
	if s == null or not s.has_open_puzzle():
		return
	_check(s.puzzle_id == "accept768-s1", "GS.puzzleId is the record's id", s.puzzle_id)
	_check(int(s.puzzle_elo) == 1000, "GS.puzzleElo is the record rating", str(s.puzzle_elo))
	_check(s.solving_side == "white", "solvingSide is the side to move after the opening move", s.solving_side)
	_check(s.sequence_index == 0, "sequenceIndex starts at 0", str(s.sequence_index))
	_check(s.required_sequence.size() == 1 and str(s.required_sequence[0]["to"]) == "b8", "requiredSequence is the later move only")
	var board := _main.find_child("BoardPresentation", true, false) as Node
	_check(String(board.get("white_seat")) == BoardGeometry.SEAT_BOTTOM, "board faces the solving side", str(board.get("white_seat")))
	_check(String(_panel.get("ui_state")) == "S1", "puzzle-play S1 on deal", str(_panel.get("ui_state")))
	var elo := _panel.find_child("PlayerElo", true, false) as Label
	print("elo_label=", elo.text if elo != null else "?")
	await _shot("s1-dealt-first-record")


## S2 — a clean sequence: the reply plays, END.W1, Elo rises, one next deal starts.
func _s2_clean_solve() -> void:
	_row_head("P1/K1 R4 I2 K3")
	var s := _session()
	var elo_before := s.player_elo
	var record_before: Array = s.required_sequence.duplicate(true)
	# The ending and the K3 read happen inside the same judged-place call, so the next
	# record is queued first; the read it starts then lands as one deal on the next tick.
	var ending := await _play_move("b1", "b8", [_mate("accept768-s2-next", 1000)])
	var settled: Dictionary = ending["settled"]
	var sequence_after: Array = ending["sequence"]
	var cue_at_ending := str(ending["cue"])
	var due := _flow().stream.due
	print("s2_last_result=", JSON.stringify(settled), " sequence=", sequence_after, " cue=", cue_at_ending, " due=", due)
	_check(str(settled.get("end_reason", "")) == "END.W1", "clean solve is END.W1", str(settled.get("end_reason")))
	_check(float(settled.get("score", -1.0)) == 1.0, "END.W1 scores S = 1", str(settled.get("score")))
	_check(sequence_after == record_before, "requiredSequence unchanged by the solve", "%s vs %s" % [str(record_before), str(sequence_after)])
	_check(cue_at_ending == "cue_solved", "cue_solved shows at the ending", cue_at_ending)
	_check(due, "the ending asks the stream for one next deal", str(due))
	_check(float(s.player_elo) > elo_before, "Elo rises on a solve", "%.3f -> %.3f" % [elo_before, s.player_elo])
	var elo := _panel.find_child("PlayerElo", true, false) as Label
	_check(elo != null and elo.text.contains(str(roundi(float(settled.get("player_elo", 0.0))))), "R2 shows the new Elo", elo.text if elo != null else "?")
	_check(_dealt_id().is_empty(), "the settled attempt is dropped for the next deal", _dealt_id())
	await _shot("s2-solved-cue")
	print("s2_after_ending cue=", _cue(), " due=", _flow().stream.due)
	# K3 — that read lands as one deal on the next tick.
	await _pump(3)
	_dealt.append(_dealt_id())
	print("s2_next=", _dealt_id(), " due=", _flow().stream.due)
	_check(_dealt_id() == "accept768-s2-next", "the next deal followed the cue", _dealt_id())
	_check(_cue().is_empty(), "the deal ends the previous cue", _cue())


## S3 — a mateIn1 record accepts any legal mate; the recorded list is not rewritten.
func _s3_mate_in_one() -> void:
	_row_head("P1/X1-3 R5")
	var s := _session()
	_check(_dealt_id() == "accept768-s2-next", "S3 solves the deal S2 advanced to", _dealt_id())
	_check(s != null and s.puzzle_id == "accept768-s2-next", "the next deal is live for S3", s.puzzle_id if s != null else "null")
	if s == null or s.puzzle_id != "accept768-s2-next":
		return
	var before: Array = s.required_sequence.duplicate(true)
	var elo_before := s.player_elo
	# A mateIn1 record: any legal mate wins, whatever the record lists next.
	var ending := await _play_move("b1", "b8")
	var settled: Dictionary = ending["settled"]
	var sequence_after: Array = ending["sequence"]
	print("s3_result=", JSON.stringify(settled), " cue=", ending["cue"], " due=", _flow().stream.due)
	_check(str(settled.get("end_reason", "")) == "END.W1", "the recorded mate solves", str(settled.get("end_reason")))
	_check(sequence_after == before, "requiredSequence not rewritten by the solve", "%s vs %s" % [str(before), str(sequence_after)])
	_check(float(settled.get("score", -1.0)) == 1.0, "END.W1 scores S = 1", str(settled.get("score")))
	print("s3_elo=", elo_before, "->", s.player_elo)
	await _shot("s3-mate-in-one-solved")
	_peer.serve([_mate("accept768-s3-next", 1000)])
	await _pump(4)
	_dealt.append(_dealt_id())
	print("s3_next=", _dealt_id(), " recent=", s.recent_solved)


## S4 — a recently solved id is not re-dealt. The live Player Elo and recentSolved feed
## the Domain the session commits from, and the read the stream sends carries the same
## recent ids, so the service is asked for something other than what was just solved.
func _s4_recent_not_dealt() -> void:
	_row_head("P3/I1")
	await _exit_stream()
	var s := _session()
	print("s4_recent_before=", s.recent_solved)
	_check(s.recent_solved.has("accept768-s1"), "recentSolved holds a solved id", str(s.recent_solved))
	var elo := float(s.player_elo)
	var offer := [_mate("accept768-s1", 1000), _mate("accept768-s4-fresh", 1000)]
	var up := PuzzleProgression.candidate_set(offer, elo, s.recent_solved, 100, 50, "puzzle_id", "rating")
	print("s4_candidates=", JSON.stringify(up))
	_check(up.size() == 1 and str(up[0].get("puzzle_id", "")) == "accept768-s4-fresh", "the recent id is skipped for the unsolved one", str(up))
	# Through the stream: the entry's own read carries recentSolved, and the deal of the
	# next read skips the recent offer for the unsolved one.
	await _enter_with([_mate("accept768-s4-seed", 1000)])
	print("s4_entry_read_recent=", _peer.sent_recent)
	_check(_peer.sent_recent.has("accept768-s1"), "the O1 request carries recentSolved", str(_peer.sent_recent))
	await _play_move("b1", "b8", [_mate("accept768-s1", 1000), _mate("accept768-s4-fresh", 1000)])
	await _pump(3)
	_dealt.append(_dealt_id())
	print("s4_dealt=", _dealt_id(), " recent=", s.recent_solved)
	# The stream's own selection path: the Domain is given the session's live
	# Player Elo and recentSolved at the moment of the deal, and skips the recent id.
	var picked := PuzzleProgression.candidate_set(
		offer,
		float(s.player_elo),
		s.recent_solved,
		PuzzleSession.ELO_MATCH_RANGE,
		PuzzleSession.ELO_BAND_WIDEN,
		PuzzleSession.FIELD_PUZZLE_ID,
		PuzzleSession.FIELD_RATING
	)
	_check(
		picked.size() == 1 and str(picked[0].get("puzzle_id", "")) == "accept768-s4-fresh",
		"the deal's own selection skips the solved id",
		JSON.stringify(picked.map(func(r: Variant) -> String: return str(r.get("puzzle_id", ""))))
	)
	var elo_pick := float(s.player_elo)
	print("s4_pick_elo=", elo_pick, " offer_dealt=", _dealt_id(), " answered=", _peer.answered)
	var down := PuzzleProgression.candidate_set(offer, elo, s.recent_solved, 100, 50, "puzzle_id", "rating")
	print("s4_recent=", s.recent_solved, " candidates_after=", JSON.stringify(down))
	_check(down.size() == 1 and str(down[0].get("puzzle_id", "")) == "accept768-s4-fresh", "the dealt id is not recent; the solved one still is", str(down))


## S5 — nothing inside ±ELO_MATCH_RANGE: the ladder widens and still deals, no band.
func _s5_widen() -> void:
	_row_head("P3/I1 D1")
	await _exit_stream()
	var elo := float(_last_elo)
	var far := roundi(elo) + 400
	await _enter_with([_mate("accept768-far", far)])
	var s := _session()
	_dealt.append(_dealt_id())
	print("s5_player_elo=", elo, " dealt=", _dealt_id(), " rating=", s.puzzle_elo)
	_check(_dealt_id() == "accept768-far", "an out-of-band offer still widens and deals", _dealt_id())
	_check(int(s.puzzle_elo) == far, "no authored band replaces the record rating", str(s.puzzle_elo))
	await _shot("s5-widened-deal")


## S6 — a one-move record and an unreadable route deal nothing and keep the Elo.
func _s6_one_move_and_unreadable() -> void:
	_row_head("P3/F4 X1-X2")
	var s := _session()
	var elo_before := s.player_elo
	await _exit_stream()
	await _enter_with([_record("accept768-x1", 1000, MATE_FEN, ["g8h8"])])
	var after_x1 := _session()
	var flow := _flow()
	print("x1 dealt=", _dealt_id(), " failure=", flow.stream.last_failure if flow != null else "?")
	_check(not after_x1.has_open_puzzle(), "a one-move record deals nothing", _dealt_id())
	_check(is_equal_approx(after_x1.player_elo, elo_before), "playerElo kept after X1", "%f" % after_x1.player_elo)
	await _exit_stream()
	# An unreadable route: the peer answers no read, which is the X2 failure.
	await _enter_with([])
	var after_x2 := _session()
	flow = _flow()
	print("x2 dealt=", _dealt_id(), " failure=", flow.stream.last_failure if flow != null else "?")
	_check(not after_x2.has_open_puzzle(), "an unreadable route deals nothing", _dealt_id())
	_check(is_equal_approx(after_x2.player_elo, elo_before), "playerElo kept after X2", "%f" % after_x2.player_elo)
	_check(not flow.stream.last_failure.is_empty(), "the failed read carries a reason", flow.stream.last_failure)
	await _shot("s6-unreadable-nothing-dealt")


## S7 — a wrong move resets the same puzzle, deals nothing, and is retryable.
func _s7_wrong_move() -> void:
	_row_head("P2/K2 S7")
	await _exit_stream()
	await _enter_with([_mate("accept768-s7", 1000)])
	var s := _session()
	_dealt.append(_dealt_id())
	_check(_dealt_id() == "accept768-s7", "the fixture deals", _dealt_id())
	await _place(str(WRONG_MOVE[0]), str(WRONG_MOVE[1]))
	_check(s.puzzle_id == "accept768-s7", "same puzzleId after a wrong move", s.puzzle_id)
	_check(int(s.sequence_index) == 0, "sequenceIndex back to 0", str(s.sequence_index))
	_check(String(_panel.get("cue_key")) == "cue_wrong", "cue_wrong shows", str(_panel.get("cue_key")))
	_check(_router.stage == SessionRouter.STAGE_PUZZLE_PLAY, "no next deal on a wrong move", str(_router.stage))
	await _shot("s7-wrong-move-reset")
	await _place("b1", "a1")
	_check(s.puzzle_id == "accept768-s7", "a second wrong move is retryable", s.puzzle_id)
	var rook: Dictionary = s.rules.piece_on("b1")
	_check(str(rook.get("kind", "")) == "rook", "the board reset to the dealt position", str(rook))


## S8 — Reveal fails then deals once; Abandon fails S = 0 then deals once.
func _s8_reveal_and_abandon() -> void:
	_row_head("P2/K2 S8")
	await _exit_stream()
	await _enter_with([_mate("accept768-s8", 1000)])
	var s := _session()
	_check(_dealt_id() == "accept768-s8", "the reveal fixture deals", _dealt_id())
	var elo_before := s.player_elo
	_peer.serve([_promotion("accept768-s8b", 1000)])
	_router.handle_control("puzzle-play", "C3")
	await _pump(3)
	_check(String(_panel.get("ui_state")) == "S2", "Reveal asks confirm", str(_panel.get("ui_state")))
	await _shot("s8-reveal-confirm")
	var reveal := _result_of(func() -> void: _router.handle_control("puzzle-play", "confirm"))
	var settled: Dictionary = reveal["last_result"]
	print("reveal_result=", JSON.stringify(settled), " cue=", reveal["cue"], " stage=", _router.stage)
	_check(str(settled.get("end_reason", "")) == "END.L5", "Reveal is END.L5", str(settled.get("end_reason")))
	_check(float(settled.get("score", -1.0)) == 0.0, "Reveal scores S = 0", str(settled.get("score")))
	await _pump(4)
	_check(float(s.player_elo) <= elo_before, "Reveal does not raise Elo", "%f" % s.player_elo)
	await _shot("s8-reveal-result-then-deal")
	_check(
		is_equal_approx(float(s.store.read_committed().get("player_elo", -1.0)), s.player_elo),
		"the result is committed to the store",
		str(s.store.read_committed().get("player_elo", -1.0))
	)
	_dealt.append(_dealt_id())
	_check(_dealt_id() == "accept768-s8b", "one next puzzle after Reveal", _dealt_id())
	# Abandon the freshly dealt puzzle.
	var elo_mid := s.player_elo
	_router.handle_control("puzzle-play", "C4")
	await _pump(3)
	var abandon := _result_of(func() -> void: _router.handle_control("puzzle-play", "confirm"))
	var abandoned: Dictionary = abandon["last_result"]
	print("abandon_result=", JSON.stringify(abandoned), " cue=", abandon["cue"])
	_check(str(abandoned.get("end_reason", "")) == "END.L6", "Abandon is END.L6", str(abandoned.get("end_reason")))
	_check(float(abandoned.get("score", -1.0)) == 0.0, "Abandon scores S = 0", str(abandoned.get("score")))
	await _pump(4)
	_check(float(s.player_elo) <= elo_mid, "Abandon does not raise Elo", "%f" % s.player_elo)


## S9 — Leave confirmed: the open puzzle is unscored, the Elo kept, mode pick returns.
func _s9_leave_keeps_elo() -> void:
	_row_head("P2/K4 E1")
	await _exit_stream()
	var committed_before := float(_session()._committed_elo()) if _session() != null else -1.0
	await _enter_with([_mate("accept768-s9", 1000)])
	var s := _session()
	var recent_before: Array = s.recent_solved.duplicate()
	_check(_dealt_id() == "accept768-s9", "the leave fixture deals", _dealt_id())
	var elo_before := s.player_elo
	_router.handle_control("puzzle-play", "C5")
	await _pump(3)
	_check(String(_panel.get("ui_state")) == "S2", "Leave asks confirm", str(_panel.get("ui_state")))
	await _shot("s9-leave-confirm")
	_router.handle_control("puzzle-play", "confirm")
	await _pump(5)
	print("after_leave stage=", _router.stage, " elo=", s.player_elo, " open=", s.has_open_puzzle(), " committed=", s._committed_elo())
	_check(_router.stage == SessionRouter.STAGE_MODE_PICK, "leave returns to mode pick", str(_router.stage))
	_check(is_equal_approx(s.player_elo, elo_before), "the open puzzle is not scored", "%f" % s.player_elo)
	_check(s.recent_solved == recent_before, "recentSolved unchanged by leaving", str(s.recent_solved))
	await _shot("s9-back-on-mode-pick")
	_check(is_equal_approx(s._committed_elo(), committed_before), "the committed Elo is unchanged", str(s._committed_elo()))


## S10 — after a wrong move, completing the sequence is END.L4 with S = 0.
func _s10_fail_after_wrong() -> void:
	_row_head("P2/K3 S10")
	await _exit_stream()
	await _enter_with([_mate("accept768-s10", 1000)])
	var s := _session()
	_dealt.append(_dealt_id())
	var elo_before := s.player_elo
	await _place(str(WRONG_MOVE[0]), str(WRONG_MOVE[1]))
	await _place("b1", "b8")
	print("s10_result=", JSON.stringify(s.last_result))
	_check(str(s.last_result.get("end_reason", "")) == "END.L4", "complete after a wrong move is END.L4", str(s.last_result.get("end_reason")))
	_check(float(s.last_result.get("score", -1.0)) == 0.0, "END.L4 scores S = 0", str(s.last_result.get("score")))
	_check(float(s.player_elo) < elo_before, "Elo drops on END.L4", "%f -> %f" % [elo_before, s.player_elo])
	await _shot("s10-end-l4")
	_dealt.append(_dealt_id())


## PTD-difficulty S1/S2 — the Elo's direction and size after a solve and after a fail.
func _dif_s1_s2() -> void:
	_row_head("DIF S1-S2")
	await _exit_stream()
	await _enter_with([_mate("accept768-dif1", 1200)])
	var s := _session()
	var elo0 := s.player_elo
	var expected := PuzzleProgression.expected_score(elo0, 1200.0)
	# The solve raises the next read; queue one record so that read is answered and the
	# delta is the ending's own, not the one a failed follow-up read leaves behind.
	var solve_ending := await _play_move("b1", "b8", [_mate("accept768-dif-next", 1200)])
	var solve: Dictionary = solve_ending["settled"]
	print("dif_solve delta=", float(solve.get("player_elo", elo0)) - elo0, " expected=", expected, " K=", s.elo_k, " cue=", solve_ending["cue"])
	_check(float(solve.get("score", -1.0)) == 1.0, "solve scores S = 1")
	_check(
		is_equal_approx(float(solve.get("player_elo", elo0)) - elo0, s.elo_k * (1.0 - expected)),
		"the solve's delta is CFG.ELO_K x (1 - E)",
		"%.4f" % (float(solve.get("player_elo", elo0)) - elo0)
	)
	var elo1 := float(solve.get("player_elo", elo0))
	var expected1 := PuzzleProgression.expected_score(elo1, 1200.0)
	# S2 — the fail's direction, read at the ending: a wrong move then the whole
	# sequence is END.L4 with S = 0, a Reveal on the next puzzle is END.L5.
	await _pump(3)
	var next_s := _session()
	_check(next_s != null and next_s.has_open_puzzle() and next_s.puzzle_id == "accept768-dif-next", "the solve deals the next record once", next_s.puzzle_id if next_s != null else "null")
	await _exit_stream()
	await _enter_with([_mate("accept768-dif2", 1200)])
	s = _session()
	var elo2 := s.player_elo
	_router.handle_control("puzzle-play", "C4")
	await _pump(3)
	var fail := _result_of(func() -> void: _router.handle_control("puzzle-play", "confirm"))
	var failed: Dictionary = fail["last_result"]
	print("dif_fail_read=", JSON.stringify(failed), " cue=", fail["cue"], " stage=", _router.stage)
	var elo_fail := float(failed.get("player_elo", elo2))
	_check(str(failed.get("end_reason", "")) == "END.L6", "the fail is an ending", str(failed.get("end_reason")))
	_check(
		is_equal_approx(elo_fail - elo2, s.elo_k * (0.0 - PuzzleProgression.expected_score(elo2, 1200.0))),
		"the fail's delta is CFG.ELO_K x (0 - E)",
		"%.4f (E=%.4f)" % [elo_fail - elo2, PuzzleProgression.expected_score(elo2, 1200.0)]
	)
	await _pump(2)
	print("dif_store=", s.store.read_committed().get("player_elo", -1.0))
	# S3 / P2 — the shared path holds no puzzle Elo; the committed value stands.
	var committed_now := float(s.store.read_committed().get("player_elo", -1.0))
	await _exit_stream()
	var shared := _main.find_child("SharedGame", true, false) as Button
	await _pump(2)
	_check(shared != null, "the shared control is still on mode pick")
	if shared != null:
		shared.pressed.emit()
		await _pump(6)
		print("shared_stage=", _router.stage)
	_check(
		is_equal_approx(float(_main.get_node("PersistStore").call("read_committed").get("player_elo", -1.0)), committed_now),
		"the shared path leaves the committed Puzzle Elo unchanged"
	)
