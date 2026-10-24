class_name PlaytestSeamsMeasureTest
extends SceneTree
## SIT.4 / S11 / O10 — frame-time and load-time capture (D1–D5 of #544).
## The seam is fed a fake frame sequence and a fake `O3` snapshot: no call here
## sleeps, submits input, or touches the move path (`G3`).

const MODE_SHARED := SessionRouter.MODE_SHARED
const MODE_PUZZLE := SessionRouter.MODE_PUZZLE
const STAGE_SHARED_PLAY := SessionRouter.STAGE_SHARED_PLAY
const STAGE_PUZZLE_PLAY := SessionRouter.STAGE_PUZZLE_PLAY

var _snapshot: Dictionary = {}
var _frames: Array = []


func _initialize() -> void:
	if not _check_all():
		return
	quit(0)


## One pass, every leg. A leg that fails has already quit non-zero.
func _check_all() -> bool:
	var legs := [
		_check_shared_close,
		_check_shared_negatives,
		_check_puzzle_close,
		_check_puzzle_negatives,
		_check_loading_ready,
		_check_refusals,
		_check_report_shape,
		_check_consumed_report,
		_check_loading_never_empty,
		_check_disarm_measurement,
		_check_debug_control,
	]
	for leg in legs:
		if not bool(leg.call()):
			return false
	return true


func _new_seam() -> PlaytestSeams:
	var seams := PlaytestSeams.new()
	seams.playtest_override = 1
	root.add_child(seams)
	seams.configure()
	_snapshot = {}
	_frames = []
	seams.bind_state(_read_snapshot)
	seams.measurement = PlaytestMeasure.new()
	seams.measurement.snapshot_provider = _read_snapshot
	seams.measurement.frame_provider = _next_frame
	seams.measurement.tel_sink = seams._emit_measure_tel
	return seams


## D1 shared play — the window opens on the arm snapshot, samples the frames the
## fake ticker pushes, and closes only when occupancy moved *and* the side flipped.
func _check_shared_close() -> bool:
	var seams := _new_seam()
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	var armed := seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	var problem := ""
	if str(armed.get("status", "")) != "ok":
		problem = "shared arm %s" % [armed.get("detail", "")]
	elif str(armed.get("mode", "")) != PlaytestMeasure.REPORT_SHARED:
		problem = "shared report mode"
	elif str(armed.get("solver", "")) != "white":
		problem = "shared solver must be the armed side"
	elif str(armed.get("events", {}).get("start", {}).get("TEL.1", "")) != "measure.start":
		problem = "shared measure.start event"
	if not problem.is_empty():
		return _fail(problem)
	_frames = [16.0, 17.5, 33.25]
	## A select/deselect moves `selected_piece`, never the position: the window stays open.
	seams._process(0.0)
	seams._process(0.0)
	_snapshot = _shared_snapshot(ChessRules.SIDE_BLACK)
	seams._process(0.0)
	var report := _report(seams)
	if str(report.get("status", "")) != "ok":
		problem = "shared window close"
	elif not is_equal_approx(float(report.get("max_ms", 0.0)), 17.5):
		problem = "shared max_ms is the slowest frame inside the window"
	elif int(report.get("sample_count", 0)) != 2:
		## The frame the move landed on is not one the window held: the two frames
		## of the move precede it, and the move frame closes the window.
		problem = "shared sample_count must count the window's own frames"
	elif str(report.get("solver", "")) != "white":
		problem = "shared solver after close"
	elif str(report.get("events", {}).get("end", {}).get("TEL.4", "")) != "PTU-shared-play":
		problem = "shared measure.end story"
	elif report.has("armed"):
		problem = "armed snapshot must not reach the report"
	if not problem.is_empty():
		return _fail(problem)
	return true


## D1 shared negatives — neither a select/deselect nor a later reply closes the
## window, and an unclosed window is `cancelled` with no `max_ms` claim.
func _check_shared_negatives() -> bool:
	var seams := _new_seam()
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	_frames = [10.0, 11.0, 12.0]
	## Three frames, and only a selection changed: the board and the side are as
	## armed, so no frame meets the close predicate (`D1`).
	for index in 3:
		var selected := _shared_snapshot(ChessRules.SIDE_WHITE)
		selected["selected_piece"] = "a1" if index == 1 else ""
		_snapshot = selected
		seams._process(0.0)
	var open_report := _report(seams)
	if str(open_report.get("status", "")) != "ok":
		return _fail("negatives arm")
	var cancelled := seams.measure("")
	if str(cancelled.get("status", "")) != "cancelled":
		return _fail("shared disarm status")
	if not is_zero_approx(float(cancelled.get("max_ms", -1.0))):
		return _fail("cancelled window must claim no max_ms")
	if int(cancelled.get("sample_count", 0)) != 3:
		return _fail("cancelled window keeps its samples")
	return true


## D1 puzzle play — closes on the `sequence_index` advance alone, so an odd-length
## sequence (index +1, side flipped) closes.
func _check_puzzle_close() -> bool:
	var seams := _new_seam()
	var session := _puzzle_session("white")
	_snapshot = _puzzle_snapshot(session)
	var armed := seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	if str(armed.get("status", "")) != "ok":
		return _fail("puzzle arm %s" % [armed.get("detail", "")])
	if str(armed.get("mode", "")) != PlaytestMeasure.REPORT_PUZZLE:
		return _fail("puzzle report mode")
	if str(armed.get("solver", "")) != "white":
		return _fail("puzzle solver")
	_frames = [40.0]
	session.sequence_index = 1
	session.rules._side_to_move = ChessRules.SIDE_BLACK
	_snapshot = _puzzle_snapshot(session)
	seams._process(0.0)
	var report := _report(seams)
	if str(report.get("status", "")) != "ok":
		return _fail("puzzle odd-length close")
	if str(report.get("events", {}).get("end", {}).get("TEL.4", "")) != "PTU-puzzle-play":
		return _fail("puzzle measure.end story")
	return true


## D1 puzzle negatives — an even-length sequence (index +2, side back on the armed
## side) still closes, and a refused move (no advance) never closes.
func _check_puzzle_negatives() -> bool:
	var even := _new_seam()
	var session := _puzzle_session("white")
	_snapshot = _puzzle_snapshot(session)
	even.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	_frames = [12.0]
	session.sequence_index = 2
	_snapshot = _puzzle_snapshot(session)
	even._process(0.0)
	if str(_report(even).get("status", "")) != "ok":
		return _fail("puzzle even-length must close")
	var refused := _new_seam()
	var other := _puzzle_session("white")
	_snapshot = _puzzle_snapshot(other)
	refused.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	_frames = [12.0]
	## S5 → S1 on a refused move: the UI state changes, the sequence does not.
	_snapshot = _puzzle_snapshot(other)
	_snapshot["play_ui_state"] = "S5"
	refused._process(0.0)
	_snapshot = _puzzle_snapshot(other)
	_snapshot["play_ui_state"] = "S1"
	refused._process(0.0)
	if str(_report(refused).get("status", "")) != "ok":
		return _fail("refused-move arm")
	if str(refused.measure("").get("status", "")) != "cancelled":
		return _fail("refused move must not close a puzzle window")
	return true


## D1 `loading_ready` — `EX.loading` start to mode-pick ready, cold and warm.
func _check_loading_ready() -> bool:
	var seams := _new_seam()
	for _leg in 2:
		_snapshot = {"stage": SessionRouter.STAGE_LOADING, "mode": ""}
		var armed := seams.start_measurement(PlaytestMeasure.KIND_LOADING_READY)
		var problem := ""
		if str(armed.get("status", "")) != "ok":
			problem = "loading arm %s" % [armed.get("detail", "")]
		elif str(armed.get("mode", "")) != "":
			problem = "loading report mode"
		if not problem.is_empty():
			return _fail(problem)
		_frames = [120.0]
		seams._process(0.0)
		_snapshot = {"stage": SessionRouter.STAGE_MODE_PICK, "mode": ""}
		seams._process(0.0)
		var report := _report(seams)
		var end: Dictionary = report.get("events", {}).get("end", {})
		if str(report.get("status", "")) != "ok":
			problem = "loading close"
		elif str(report.get("kind", "")) != PlaytestMeasure.KIND_LOADING_READY:
			problem = "loading kind"
		elif str(end.get("TEL.4", "")) != "PTU-mode-pick":
			problem = "loading measure.end story"
		elif str(end.get("TEL.5", "")) != "pass":
			problem = "loading measure.end outcome"
		if not problem.is_empty():
			return _fail(problem)
	return true


## D1 / D2 refusals — an out-of-order arm, a missing key, and the `session == null`
## puzzle snapshot that writes none of its keys. No window is armed on a placeholder.
func _check_refusals() -> bool:
	var seams := _new_seam()
	var problem := ""
	## Each row is one arm or report and the `detail` it must name (D1 box 1).
	var cases := [
		[
			{"stage": SessionRouter.STAGE_MODE_PICK, "mode": ""},
			PlaytestMeasure.KIND_FRAME_TIMES,
			"mode"
		],
		[
			{"stage": SessionRouter.STAGE_MODE_PICK, "mode": ""},
			PlaytestMeasure.KIND_LOADING_READY,
			"stage",
		],
		[
			{"stage": STAGE_PUZZLE_PLAY, "mode": MODE_PUZZLE},
			PlaytestMeasure.KIND_FRAME_TIMES,
			"position",
		],
		[
			{
				"stage": STAGE_PUZZLE_PLAY,
				"mode": MODE_PUZZLE,
				"position": {"occupancy": {}, "side_to_move": "white"},
				"sequence_index": 0,
				"puzzle_id": "none",
			},
			PlaytestMeasure.KIND_FRAME_TIMES,
			"puzzle_id",
		],
		[
			{"stage": STAGE_SHARED_PLAY, "mode": MODE_SHARED},
			PlaytestMeasure.KIND_FRAME_TIMES,
			"position",
		],
	]
	for one in cases:
		_snapshot = one[0]
		var detail := str(seams.start_measurement(str(one[1])).get("detail", ""))
		if detail != str(one[2]) and problem.is_empty():
			problem = "refused arm must name %s, got %s" % [one[2], detail]
	## A paused session is refused before any window opens.
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	seams.pause()
	if (
		(
			str(seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES).get("detail", ""))
			!= "paused"
		)
		and problem.is_empty()
	):
		problem = "paused arm"
	seams.resume()
	if str(seams.start_measurement("nonsense").get("detail", "")) != "unknown kind":
		if problem.is_empty():
			problem = "unknown kind"
	if str(seams.measure(PlaytestMeasure.KIND_FRAME_TIMES).get("detail", "")) != "no window":
		if problem.is_empty():
			problem = "measure before arm"
	if not problem.is_empty():
		return _fail(problem)
	return true


## D2 — every report has the same shape, refused and cancelled included.
func _check_report_shape() -> bool:
	var seams := _new_seam()
	var refused := seams.start_measurement("nonsense")
	for key in ["kind", "mode", "status", "solver", "samples", "sample_count", "max_ms"]:
		if not refused.has(key):
			return _fail("report missing %s" % key)
	if not refused.has("events") or not refused["events"].has("start"):
		return _fail("report missing events")
	if not refused.has("detail"):
		return _fail("report missing detail")
	## One arm, one window: a second arm while open is refused, not stacked.
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	var stacked := seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	## A report asked for the wrong kind closes the window as cancelled.
	var wrong := seams.measure(PlaytestMeasure.KIND_LOADING_READY)
	var problem := ""
	if str(stacked.get("detail", "")) != "window open":
		problem = "second arm must refuse"
	elif str(wrong.get("status", "")) != "cancelled":
		problem = "mis-kinded measure must cancel"
	## Repeat runs carry distinct session ids, so a repeat count is expressible.
	else:
		var first := _new_seam()
		var second := _new_seam()
		if first.session_id == second.session_id:
			problem = "repeat runs need distinct session ids"
	if not problem.is_empty():
		return _fail(problem)
	return true


## #544 acceptance finding 1 — a window that closes by itself is not lost. The
## first `measure(kind)` this window measured hands the report over, and only once:
## a second ask is a refusal, so one arm never yields two reports.
func _check_consumed_report() -> bool:
	var seams := _new_seam()
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	_frames = [10.0, 20.0]
	## One frame inside the window, then the move frame that closes it.
	seams._process(0.0)
	_snapshot = _shared_snapshot(ChessRules.SIDE_BLACK)
	seams._process(0.0)
	var got := seams.measure(PlaytestMeasure.KIND_FRAME_TIMES)
	var problem := ""
	if str(got.get("status", "")) != "ok":
		problem = "self-closed window must hand its report over, got %s" % [got.get("status", "")]
	elif str(got.get("detail", "")) != "":
		problem = "consumed report carries no detail"
	elif int(got.get("sample_count", 0)) != 1:
		problem = "consumed report keeps its samples"
	elif not is_equal_approx(float(got.get("max_ms", 0.0)), 10.0):
		problem = "consumed report carries its max_ms"
	elif str(got.get("events", {}).get("end", {}).get("TEL.4", "")) != "PTU-shared-play":
		problem = "consumed report carries its measure.end event"
	elif str(seams.measure(PlaytestMeasure.KIND_FRAME_TIMES).get("detail", "")) != "no window":
		problem = "a consumed report must not be handed over twice"
	elif str(seams.dump_state().get("measurement", {}).get("status", "")) != "ok":
		problem = "the handed-over report stays readable in dump_state"
	if not problem.is_empty():
		return _fail(problem)
	## A wrong kind leaves the window's own reading for the kind that measured it.
	var other := _new_seam()
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	other.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	_frames = [10.0]
	_snapshot = _shared_snapshot(ChessRules.SIDE_BLACK)
	other._process(0.0)
	if str(other.measure(PlaytestMeasure.KIND_LOADING_READY).get("status", "")) != "refused":
		return _fail("a wrong kind must not take another window's report")
	if str(other.measure(PlaytestMeasure.KIND_FRAME_TIMES).get("status", "")) != "ok":
		return _fail("a wrong kind must leave the measured report for its own kind")
	return true


## #544 acceptance finding 2 — a `loading_ready` window that met its close
## predicate always carries a real reading. The window spans the frames whose
## snapshot is still `loading`, so `ok` with no samples is unreachable: even a
## load that finished between two ticks reports the frame it was still loading on.
func _check_loading_never_empty() -> bool:
	var shortest := _new_seam()
	## `mode-pick` is already current on the very first observation: the shortest
	## possible span, and the one that reported `ok` about nothing before.
	_snapshot = {"stage": SessionRouter.STAGE_LOADING, "mode": ""}
	shortest.start_measurement(PlaytestMeasure.KIND_LOADING_READY)
	_frames = [33.0]
	_snapshot = {"stage": SessionRouter.STAGE_MODE_PICK, "mode": ""}
	shortest._process(0.0)
	var report := shortest.measure(PlaytestMeasure.KIND_LOADING_READY)
	var problem := ""
	if str(report.get("status", "")) != "ok":
		problem = "shortest loading span never measured"
	elif int(report.get("sample_count", 0)) <= 0:
		problem = "a closed loading window must carry a reading, got 0 samples"
	elif not is_equal_approx(float(report.get("max_ms", 0.0)), 33.0):
		problem = "the loading frame is the reading"
	## A load that lasts: every frame it observed belongs to it, `mode-pick` closes.
	var lasting := _new_seam()
	_snapshot = {"stage": SessionRouter.STAGE_LOADING, "mode": ""}
	lasting.start_measurement(PlaytestMeasure.KIND_LOADING_READY)
	_frames = [20.0, 25.0, 40.0]
	lasting._process(0.0)
	lasting._process(0.0)
	_snapshot = {"stage": SessionRouter.STAGE_MODE_PICK, "mode": ""}
	lasting._process(0.0)
	var long_report := lasting.measure(PlaytestMeasure.KIND_LOADING_READY)
	if problem.is_empty() and int(long_report.get("sample_count", 0)) != 3:
		problem = (
			"loading window keeps its own frames, got %d"
			% [int(long_report.get("sample_count", 0))]
		)
	if problem.is_empty() and not is_equal_approx(float(long_report.get("max_ms", 0.0)), 40.0):
		problem = "loading max_ms is the slowest frame of the load"
	if not problem.is_empty():
		return _fail(problem)
	return true


## #544 acceptance finding 3 — `measure("")` is the documented disarm. An open
## window comes back `cancelled`; a window that already closed by itself is still
## handed over rather than lost.
func _check_disarm_measurement() -> bool:
	var seams := _new_seam()
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	seams.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	_frames = [10.0, 12.0]
	seams._process(0.0)
	var cancelled := seams.measure("")
	var problem := ""
	if str(cancelled.get("status", "")) != "cancelled":
		problem = "measure('') must cancel an open window"
	elif int(cancelled.get("sample_count", 0)) != 1:
		problem = "cancelled window keeps its samples"
	elif not is_zero_approx(float(cancelled.get("max_ms", -1.0))):
		problem = "cancelled window claims no max_ms"
	elif str(seams.measure("").get("detail", "")) != "no window":
		problem = "disarm with nothing open is refused"
	## A window that closed by itself is handed over by the disarm, not lost.
	var self_closed := _new_seam()
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	self_closed.start_measurement(PlaytestMeasure.KIND_FRAME_TIMES)
	_frames = [10.0]
	_snapshot = _shared_snapshot(ChessRules.SIDE_BLACK)
	self_closed._process(0.0)
	var handed := self_closed.measure("")
	if problem.is_empty() and str(handed.get("status", "")) != "ok":
		problem = "the disarm must hand over a self-closed window"
	if not problem.is_empty():
		return _fail(problem)
	return true


## D4 — the `Measure` control only arms: it submits no input and plays no move.
func _check_debug_control() -> bool:
	var seams := _new_seam()
	_snapshot = _shared_snapshot(ChessRules.SIDE_WHITE)
	var field := seams.get_node("PlaytestDebug/DebugPanel/Controls/MeasureKind") as LineEdit
	var button := seams.get_node("PlaytestDebug/DebugPanel/Controls/Measure") as Button
	if field == null or button == null:
		return _fail("measure debug control missing")
	field.text = PlaytestMeasure.KIND_FRAME_TIMES
	button.pressed.emit()
	var armed := _report(seams)
	if str(armed.get("status", "")) != "ok":
		return _fail("measure control arm")
	if seams.input_log.size() != 0:
		return _fail("measure control must not submit input")
	if str(_snapshot["position"]["occupancy"].get("a1", "")) != "rook":
		return _fail("measure control must not play the move")
	_frames = [8.0]
	_snapshot = _shared_snapshot(ChessRules.SIDE_BLACK)
	seams._process(0.0)
	if str(_report(seams).get("status", "")) != "ok":
		return _fail("measure control close")
	return true


## The report the seam keeps beside the screen (`dump_state`, `S10`).
func _report(seams: PlaytestSeams) -> Dictionary:
	return seams.dump_state().get("measurement", {})


func _read_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func _next_frame() -> float:
	if _frames.is_empty():
		return 16.0
	return float(_frames.pop_front())


func _shared_snapshot(side: String) -> Dictionary:
	## One rook walks `a1 -> a8` and back, so a move and a reply are different boards
	## on the same squares: a reply restores the armed side with the armed occupancy.
	var occupancy := {"a1": "rook"}
	if side == ChessRules.SIDE_BLACK:
		occupancy = {"a8": "rook"}
	return {
		"stage": STAGE_SHARED_PLAY,
		"mode": MODE_SHARED,
		"position": {"occupancy": occupancy, "side_to_move": side},
		"selected_piece": "",
	}


func _puzzle_session(side: String) -> PuzzleSession:
	var session := PuzzleSession.new()
	var rules := ChessRules.new()
	rules.reset_opening()
	rules._side_to_move = side
	session.rules = rules
	session.puzzle_id = "p-1"
	session.required_sequence = [{"from": "a2", "to": "a3"}, {"from": "h7", "to": "h6"}]
	return session


## Composed the way `SessionRouter.play_snapshot()` composes it: the router keys
## plus `PuzzlePlayFlow.snapshot(base)`'s keys, including the `sequence_index` D1 adds.
func _puzzle_snapshot(session: PuzzleSession) -> Dictionary:
	return {
		"stage": STAGE_PUZZLE_PLAY,
		"mode": MODE_PUZZLE,
		"position": session.rules.position_field(),
		"selected_piece": session.selected_piece,
		"play_ui_state": session.play_ui_state,
		"puzzle_id": session.puzzle_id,
		"sequence_index": session.sequence_index,
	}


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
