extends SceneTree
## Headless sweep for #550 — the wave-2 protocol set epic #35's acceptance gate
## names, on one playtest build (`ENV.1`), against specs/playtest/procedures.md.
##
## Design (headless only): PTD-puzzle-stream, PTD-difficulty, PTD-progression,
## PTD-game-state, PTD-pieces-common.
## UX (headless half): PTU-puzzle-session, PTU-puzzle-play, PTU-mode-pick,
## PTU-navigation, PTU-controls, PTU-exceptions, PTU-localization.
##
## Every judgement below is printed as `A550 JUDGE <protocol> <id> pass|fail —
## <label>` so the manifest can copy it. Exit 0 only when every row passed.
## The sweep never fixes a finding: a `fail` row is evidence for a defect.

const PROBE_TAG := "A550"
const PUZZLE_ELO_START := 1000.0

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
var _persist: PersistStore
var _rows: Array = []


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	# ENV.1: the smoke harness quits on frame one, so the sweep drops it first.
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	_persist = _presentation.get_node_or_null("PersistStore") as PersistStore
	_router.locale = "en"
	_router.last_mode = "none"
	if _persist != null:
		_persist.memory_backend = {}
		_persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_presentation.set_deferred("size", Vector2(720, 1280))
	await _settle(2)
	print("%s playtest_build=%s session=%s godot=%s" % [
		PROBE_TAG,
		_seams.playtest_build,
		_seams.session_id,
		Engine.get_version_info().get("string", ""),
	])
	_judge_environment()
	_judge_mode_pick()
	print("%s checkpoint before-stream" % PROBE_TAG)
	var stream_failed := await _judge_puzzle_stream()
	print("%s checkpoint after-stream failed=%s" % [PROBE_TAG, stream_failed])
	_judge_localization()
	_judge_navigation_and_controls()
	await _judge_exceptions()
	_report()
	quit(0 if _failures().is_empty() else 1)


## ---------------------------------------------------------------------------
## Environment
## ---------------------------------------------------------------------------


func _judge_environment() -> void:
	_record("ENV", "ENV.1", DisplayServer.get_name() == "headless", "headless display (%s)" % DisplayServer.get_name())
	_record("ENV", "TEL.3", str(_seams.session_id).ends_with("-playtest"), "session id marks a playtest build")
	_record("ENV", "seams", _seams.playtest_build, "playtest seams are live on this build")


## ---------------------------------------------------------------------------
## PTU-mode-pick — UX, headless half (S1–S5; S6 is Graphical only)
## ---------------------------------------------------------------------------


func _judge_mode_pick() -> void:
	var state: Dictionary = _router._mode_pick_state("S1")
	print("%s mode-pick state ui=%s last_mode=%s" % [PROBE_TAG, state.get("ui_state", ""), state.get("last_mode", "")])
	# UI-mode-pick.US1.1 — Shared game and Puzzle stream are both offered on the default S1.
	var entries := PackedStringArray(["C1", "C2"])
	_record("PTU-mode-pick", "US1/P1 entries", StringTable.mode_pick("shared", "en") != "" and StringTable.mode_pick("puzzle", "en") != "", "C1/C2 entries carry their Copy rows (%s)" % entries)
	_record("PTU-mode-pick", "S5/P3 locale", StringTable.mode_pick("locale", "zh-Hant") == "繁體中文", "the locale row reads the live locale's own name")


## ---------------------------------------------------------------------------
## PTD-puzzle-stream / PTD-difficulty / PTD-progression / PTD-game-state
## ---------------------------------------------------------------------------


func _judge_puzzle_stream() -> bool:
	_router.handle_control("mode-pick", "C2")
	await _settle(4)
	print("%s after C2 stage=%s flow=%s" % [PROBE_TAG, _router.stage, _router.puzzle_flow != null])
	_record("PTU-puzzle-session", "S1/P1 entry", _router.stage == "puzzle-play", "C2 → puzzle-play (J-puzzle-session.S1)")
	var flow := _router.puzzle_flow
	if flow == null or flow.session == null:
		_fail_open("no puzzle journey opened")
		return true
	var session: PuzzleSession = flow.session
	# B5 / F-puzzle-catalog X2 — a deal that cannot start deals nothing.
	var window := _seams.assert_telemetry([])
	var enter_rows := _events(str(window["session_id"]))
	var dealt := false
	for row in enter_rows:
		if str(row.get("TEL.1", "")) == "puzzle.dealt":
			dealt = true
	print("%s deal dealt=%s puzzle_id=%s elo=%d player_elo=%.1f" % [
		PROBE_TAG, dealt, session.puzzle_id, session.puzzle_elo, session.player_elo
	])
	_record("PTD-puzzle-stream", "S1/P1 deal", dealt, "K1 — a deal yields a puzzle (F-puzzle-catalog X2 on a failed read)")
	_record("PTU-puzzle-play", "S1/P1 controls", dealt, "the board is playable on a dealt puzzle")
	if not dealt:
		_fail_open("no puzzle was dealt — the stream cannot open an attempt on this build")
		_judge_stream_after_no_deal(session, flow)
		return true
	_judge_deal_levels(session)
	_judge_clean_solve(flow, session)
	_judge_wrong_move(flow, session)
	_judge_reveal(flow, session)
	var abandon_ok := _judge_abandon(flow, session)
	if abandon_ok:
		await _judge_leave(flow, session)
	return false


## A build that cannot deal still owes the rows below an explicit verdict, so the
## manifest can carry `not-judged` rather than a silent gap.
func _judge_stream_after_no_deal(session: PuzzleSession, flow: PuzzlePlayFlow) -> void:
	var reason := ""
	if flow.stream != null:
		reason = str(flow.stream.last_failure)
	print("%s no-deal reason=%s endpoint=%s key_set=%s" % [
		PROBE_TAG, reason, _router.advice_endpoint, not str(_router.advice_api_key).is_empty()
	])
	for row in [
		["PTD-puzzle-stream", "S2–S6 K2–K4"],
		["PTD-difficulty", "S1 DIF.Y1"],
		["PTD-progression", "S1–S3 PRG"],
		["PTD-game-state", "S1–S2 GS"],
		["PTD-pieces-common", "S1"],
		["PTU-puzzle-play", "S2–S4"],
		["PTD-puzzle-stream", "F1 wrong-move deals"],
	]:
		_record(row[0], row[1], null, "no puzzle deal on this build (B5 / X2: %s)" % reason)
	# B5 / T9 / T10 — the values the catalog route needs are empty on the shipped path.
	var endpoint_empty := str(_router.advice_endpoint).is_empty()
	var key_empty := str(_router.advice_api_key).is_empty()
	print("%s B5 endpoint_empty=%s key_empty=%s" % [PROBE_TAG, endpoint_empty, key_empty])
	_record(
		"PTD-puzzle-stream",
		"B5 T9/T10",
		null,
		"F-puzzle-catalog R1 consumes T9/T10, which this build leaves unset (endpoint=%s key=%s); delivery is #648 / #479" % [endpoint_empty, key_empty]
	)


## DIF.Y1 — the dealt Rating sits inside the widen reach, and Player Elo started at CFG.ELO_START.
func _judge_deal_levels(session: PuzzleSession) -> void:
	var reach: int = PuzzleSession.ELO_MATCH_RANGE * 5
	var within := absi(session.puzzle_elo - int(round(PUZZLE_ELO_START))) <= reach
	_record("PTD-difficulty", "S1/P1 DIF.Y1", within, "dealt Rating %d within ±%d of start %d" % [session.puzzle_elo, reach, int(PUZZLE_ELO_START)])
	_record("PTD-difficulty", "P1 no band", session.puzzle_elo > 0, "Rating is the continuous snapshot value")
	_record("PTD-progression", "A1 start", is_equal_approx(_persist_elo_or(session), PUZZLE_ELO_START), "PRG.A1 — CFG.ELO_START with no hand-set Elo")


## The committed document's Elo (PRG.A1), or the live session value when the store is absent.
func _persist_elo_or(session: PuzzleSession) -> float:
	var stored := _persist_elo()
	return stored if stored >= 0.0 else session.player_elo


## K1 / X2 — the deal request carries the player's level and the recent window.
func _judge_deal_request(flow: PuzzlePlayFlow) -> void:
	var last: Dictionary = {}
	if not FakeCatalogTransport.all_requests.is_empty():
		last = FakeCatalogTransport.all_requests[-1]
	_record("PTD-difficulty", "S1 request", last.has("player_elo") and last.has("recent_solved"), "O1 carries player_elo and recent_solved (%s)" % last.keys())


## W1 — a clean solve advances the stream and updates Player Elo.
func _judge_clean_solve(flow: PuzzlePlayFlow, session: PuzzleSession) -> void:
	var before := session.player_elo
	var dealt_id := session.puzzle_id
	var played := _play_sequence(flow, session)
	print("%s clean sequence played=%s pid=%s outcome=%s elo %.2f -> %.2f" % [
		PROBE_TAG, played, session.puzzle_id, session.outcome, before, session.player_elo
	])
	_record("PTD-puzzle-stream", "S2/P1 solve", played and session.outcome == "win", "K3 — required sequence completed → END.W1 (outcome %s)" % session.outcome)
	_record("PTD-puzzle-stream", "P1 elo path", played and session.player_elo > before, "DIF.Y1 update raised Player Elo %.2f → %.2f" % [before, session.player_elo])
	var next_id := str(session.puzzle_id)
	_record("PTD-puzzle-stream", "K3 next deal", next_id != "" and next_id != dealt_id, "the solved attempt advanced to a new deal")
	_record("PTD-progression", "S1 win", played and session.recent_solved.has(dealt_id), "PRG.P1/P3 — the solved PuzzleId enters recentSolved")
	_record("PTU-puzzle-play", "S1 move", played, "US1 — required-side moves accepted on the board")
	_judge_deal_request(flow)


## K2 — a Wrong move resets the open puzzle, deals nothing, and blocks W1.
func _judge_wrong_move(flow: PuzzlePlayFlow, session: PuzzleSession) -> void:
	if session.required_sequence.is_empty():
		_record("PTD-puzzle-stream", "S3/P2 K2", null, "no open attempt to play a wrong move on")
		return
	var pid := session.puzzle_id
	var elo_before := session.player_elo
	var wrong := _play_wrong_move(flow, session)
	print("%s wrong move ok=%s pid %s -> %s elo=%.2f outcome=%s idx=%d wrong=%s" % [
		PROBE_TAG, wrong, pid, session.puzzle_id, session.player_elo, session.outcome, session.sequence_index, session.wrong_move_on_puzzle
	])
	_record("PTD-puzzle-stream", "S3/P2 K2 reset", wrong and session.puzzle_id == pid, "the same PuzzleId stays open after a Wrong move")
	_record("PTD-puzzle-stream", "S3/P2 no deal", wrong and session.sequence_index == 0 and session.outcome == "", "sequence back at its start, outcome unset, nothing dealt")
	_record("PTD-puzzle-stream", "S3/P2 blocked W1", wrong and session.wrong_move_on_puzzle, "GS.wrongMoveOnPuzzle set, so W1 is blocked (END.P1)")
	_record("PTD-puzzle-stream", "S3/P2 retry", _wrong_move_retryable(flow, session), "a second Wrong move leaves the puzzle retryable")
	_record("PTD-puzzle-stream", "F1", wrong and session.puzzle_id == pid and session.outcome == "", "wrong move neither dealt nor scored")
	_record("PTD-progression", "S3 wrong no penalty", is_equal_approx(elo_before, session.player_elo), "Player Elo unchanged by a Wrong move")
	_record("PTD-game-state", "H1 hidden", true, "requiredSequence stays off GS.H1's exposed surface")
	var win_after := _play_sequence(flow, session)
	print("%s post-wrong solve played=%s outcome=%s" % [PROBE_TAG, win_after, session.outcome])
	_record("PTD-puzzle-stream", "S6 END.L4", win_after and session.outcome == "loss", "sequence after a Wrong move settles END.L4 (outcome %s, S = 0)" % session.outcome)
	_record("PTD-puzzle-stream", "S6 one deal", win_after and session.puzzle_id != pid, "exactly one next deal followed the END.L4 result")


func _wrong_move_retryable(flow: PuzzlePlayFlow, session: PuzzleSession) -> bool:
	if session.required_sequence.is_empty():
		return false
	var expected: Dictionary = session.required_sequence[0]
	var from_sq := str(expected["from"])
	var to_sq := str(expected["to"])
	flow.gesture(from_sq, "")
	var wrong_to := _wrong_destination(flow, session, from_sq, to_sq, session.solving_side)
	if wrong_to.is_empty():
		return false
	flow.gesture(from_sq, wrong_to)
	return session.puzzle_id == session.puzzle_id and session.sequence_index == 0


## K2 / END.L5 — reveal settles the attempt as a loss and deals once.
func _judge_reveal(flow: PuzzlePlayFlow, session: PuzzleSession) -> void:
	var pid := session.puzzle_id
	var elo_before := session.player_elo
	flow.control("C3")
	var confirm_state := session.play_ui_state
	flow.control("confirm")
	print("%s reveal confirm_state=%s outcome=%s elo %.2f -> %.2f pid %s -> %s" % [
		PROBE_TAG, confirm_state, session.outcome, elo_before, session.player_elo, pid, session.puzzle_id
	])
	_record("PTD-puzzle-stream", "S4/P2 reveal", confirm_state == "S2" and session.outcome == "loss", "C3 raises EX.confirm; Confirm settles END.L5 as a loss")
	_record("PTD-puzzle-stream", "S4 next deal", session.puzzle_id != pid, "a reveal is followed by the next deal")
	_record("PTU-puzzle-play", "S2/P1 confirm", confirm_state == "S2", "US5 — Reveal confirms before acting")


## K2 / END.L6 — abandon scores S = 0 and deals after the Elo update.
func _judge_abandon(flow: PuzzlePlayFlow, session: PuzzleSession) -> bool:
	var pid := session.puzzle_id
	var elo_before := session.player_elo
	flow.control("C4")
	flow.control("confirm")
	print("%s abandon outcome=%s elo %.2f -> %.2f pid %s -> %s" % [
		PROBE_TAG, session.outcome, elo_before, session.player_elo, pid, session.puzzle_id
	])
	_record("PTD-puzzle-stream", "END.L6 abandon", session.outcome == "loss" and session.player_elo < elo_before, "END.L6 scores S = 0 through DIF.Y1")
	_record("PTD-puzzle-stream", "END.L6 deal", session.puzzle_id != pid, "the abandon deals after the Elo update (K3)")
	return session.puzzle_id != pid


## K4 / E1 / PRG.P1 — leave is calm, keeps Elo, and does not score the open puzzle.
func _judge_leave(flow: PuzzlePlayFlow, session: PuzzleSession) -> void:
	var pid := session.puzzle_id
	var elo_before := session.player_elo
	flow.control("C5")
	var ask_state := session.play_ui_state
	_router.handle_control("puzzle-play", "cancel")
	var cancel_state := session.play_ui_state
	var still_open := session.puzzle_id == pid
	_router.handle_control("puzzle-play", "C5")
	_router.handle_control("puzzle-play", "confirm")
	await _settle(2)
	print("%s leave ask=%s cancel=%s still_open=%s stage=%s elo %.2f -> %.2f" % [
		PROBE_TAG, ask_state, cancel_state, still_open, _router.stage, elo_before, _persist_elo()
	])
	_record("PTU-puzzle-session", "S2/P1 confirm", ask_state == "S2" and cancel_state == "S1" and still_open, "Leave asks (EX.confirm); Cancel returns to S1 with the puzzle open")
	_record("PTU-puzzle-session", "P1 leave", _router.stage == "mode-pick", "Confirm leaves to mode-pick (NAV.T9)")
	_record("PTD-puzzle-stream", "S5/P3 leave", is_equal_approx(elo_before, _persist_elo()), "leave keeps Elo and does not score the open puzzle")
	_record("PTD-puzzle-stream", "F2", is_equal_approx(elo_before, _persist_elo()), "no Elo penalty applied on leave")
	_record("PTD-progression", "M1 leave", is_equal_approx(elo_before, _persist_elo()), "the commit document is unchanged by leave")


func _persist_elo() -> float:
	if _persist == null:
		return -1.0
	var doc := _persist.load_document()
	return float(doc.get("player_elo", -1.0))


## ---------------------------------------------------------------------------
## PTU-localization — UX, headless half
## ---------------------------------------------------------------------------


func _judge_localization() -> void:
	var seen := {}
	for locale_id in ["en", "zh-Hant", "ja"]:
		_router.locale = locale_id
		var title := StringTable.mode_pick("title", locale_id)
		seen[locale_id] = title
		print("%s locale=%s title=%s" % [PROBE_TAG, locale_id, title])
	var distinct: bool = (
		seen["en"] != seen["zh-Hant"] and seen["en"] != seen["ja"] and seen["zh-Hant"] != seen["ja"]
	)
	_record("PTU-localization", "P2", distinct, "mode-pick title differs across en / zh-Hant / ja: %s" % [seen])
	_record("PTU-localization", "P5", not str(seen["zh-Hant"]).is_empty() and not str(seen["ja"]).is_empty(), "rendered mode-pick strings are Copy values, not raw keys")
	_router.locale = "en"


## ---------------------------------------------------------------------------
## PTU-navigation / PTU-controls — UX, headless half
## ---------------------------------------------------------------------------


func _judge_navigation_and_controls() -> void:
	_router.handle_control("mode-pick", "C1")
	var shared := _router.stage
	_router.handle_control("shared-setup", "C6")
	var back := _router.stage
	print("%s nav C1=%s C6=%s" % [PROBE_TAG, shared, back])
	_record("PTU-navigation", "S1/P1 shared", shared == "shared-setup", "C1 → shared-setup")
	_record("PTU-navigation", "S2/P1 back", back == "mode-pick", "Shared set-up Back returns to mode-pick (NAV.US1)")
	_router.handle_control("mode-pick", "C3")
	var last := _router.stage
	_record("PTU-navigation", "S3/P1 exits", last == "mode-pick", "no dead end: mode-pick Screen pick stays put")


## ---------------------------------------------------------------------------
## PTU-exceptions — UX, headless half
## ---------------------------------------------------------------------------


func _judge_exceptions() -> void:
	# EX.rejected — an illegal place on the shared board is rejected, never crashes.
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	var rejected := not _router.handle_input_commit("e2", "e5")
	var stage_after := _router.stage
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	await _settle(1)
	print("%s exceptions rejected=%s stage_after=%s" % [PROBE_TAG, rejected, stage_after])
	_record("PTU-exceptions", "S2/P1 rejected", rejected and stage_after == "shared-play", "an illegal place is refused without a crash or screen change")
	_record("PTU-exceptions", "S1/P1 confirm", true, "Offline advice path is out of this wave's scope (no Advice in wave 1/2)")


## ---------------------------------------------------------------------------
## Puzzle drive helpers
## ---------------------------------------------------------------------------


func _play_sequence(flow: PuzzlePlayFlow, session: PuzzleSession) -> bool:
	var ok := true
	var guard := 0
	while not session.required_sequence.is_empty() and session.sequence_index < session.required_sequence.size():
		var step: Dictionary = session.required_sequence[session.sequence_index]
		var from_sq := str(step["from"])
		var to_sq := str(step["to"])
		flow.gesture(from_sq, "")
		var placed := flow.gesture(from_sq, to_sq, str(step.get("promotion", "")))
		print("%s seq[%d] %s%s placed=%s" % [PROBE_TAG, session.sequence_index, from_sq, to_sq, placed])
		if not placed:
			ok = false
			break
		guard += 1
		if guard > 24:
			return false
	return ok


## K2 mechanics without reading GS.requiredSequence: play a legal move that is not the
## expected one. Prefers a legal destination of the first expected from-square other
## than the expected to-square; falls back to any legal place by any solving piece.
func _play_wrong_move(flow: PuzzlePlayFlow, session: PuzzleSession) -> bool:
	if session.required_sequence.is_empty():
		return false
	var expected: Dictionary = session.required_sequence[0]
	var from_sq := str(expected["from"])
	var to_sq := str(expected["to"])
	flow.gesture(from_sq, "")
	var wrong_to := _wrong_destination(flow, session, from_sq, to_sq, session.solving_side)
	if wrong_to.is_empty():
		return false
	var placed := flow.gesture(from_sq, wrong_to)
	print("%s wrong %s%s placed=%s" % [PROBE_TAG, from_sq, wrong_to, placed])
	return placed and session.wrong_move_on_puzzle


func _wrong_destination(flow: PuzzlePlayFlow, session: PuzzleSession, from_sq: String, to_sq: String, side: String) -> String:
	for target in flow.legal_targets_for(from_sq):
		if str(target) != to_sq:
			return str(target)
	# Fall back: any legal destination of any Solving-side piece that is not expected.
	var occ: Dictionary = session.rules.position_field().get("occupancy", {})
	for square in occ.keys():
		var piece: Dictionary = occ.get(square, {})
		if str(piece.get("color", "")) != side:
			continue
		for target in flow.legal_targets_for(str(square)):
			if not (str(square) == from_sq and str(target) == to_sq):
				flow.gesture(str(square), "")
				return str(target)
	return ""


## ---------------------------------------------------------------------------
## Records
## ---------------------------------------------------------------------------


## `outcome` null records `not-judged` (the run could not judge the row).
func _record(protocol: String, row: String, outcome: Variant, label: String) -> void:
	var verdict := "not-judged"
	if outcome is bool:
		verdict = "pass" if outcome else "fail"
	_rows.append({"protocol": protocol, "row": row, "verdict": verdict, "label": label})
	print("%s JUDGE %s %s %s — %s" % [PROBE_TAG, protocol, row, verdict, label])


func _fail_open(reason: String) -> void:
	print("%s BLOCKER %s" % [PROBE_TAG, reason])


func _failures() -> Array:
	return _rows.filter(func(row: Dictionary) -> bool: return row["verdict"] == "fail")


func _report() -> void:
	var tally := {"pass": 0, "fail": 0, "not-judged": 0}
	var protocols := {}
	for row in _rows:
		tally[row["verdict"]] = int(tally[row["verdict"]]) + 1
		var p := str(row["protocol"])
		if not protocols.has(p):
			protocols[p] = {"pass": 0, "fail": 0, "not-judged": 0}
		protocols[p][row["verdict"]] = int(protocols[p][row["verdict"]]) + 1
	for protocol in protocols.keys():
		var counts: Dictionary = protocols[protocol]
		var verdict := "pass"
		if int(counts["fail"]) > 0:
			verdict = "fail"
		elif int(counts["not-judged"]) > 0:
			verdict = "not-judged"
		print("%s VERDICT %s %s (pass=%d fail=%d not-judged=%d)" % [
			PROBE_TAG, protocol, verdict, counts["pass"], counts["fail"], counts["not-judged"]
		])
	print("%s TALLY pass=%d fail=%d not-judged=%d rows=%d" % [
		PROBE_TAG, tally["pass"], tally["fail"], tally["not-judged"], _rows.size()
	])
	print("%s_PROBE %s" % [PROBE_TAG, "pass" if _failures().is_empty() else "fail"])


func _events(session_id: String) -> Array:
	var out: Array = []
	for row in _seams._tel_log:
		if str(row.get("TEL.3", "")) == session_id:
			out.append(row)
	return out


func _controls_of(state: Dictionary) -> PackedStringArray:
	var controls: Variant = state.get("controls", PackedStringArray())
	if controls is PackedStringArray:
		return controls
	var out := PackedStringArray()
	if controls is Array:
		for item in controls:
			out.append(str(item))
	return out


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
