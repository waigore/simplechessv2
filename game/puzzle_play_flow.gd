class_name PuzzlePlayFlow
extends RefCounted
## CMP-session-router C3 / R2 — the Puzzle stream journey (#333): entry (NAV.T2),
## the UI-puzzle-play S1–S5 states, the R2 result cue and leave (NAV.T9). The router
## holds one during `puzzle-play` and forwards its screen, cue, telemetry and
## mode-pick events (CTR-presentation E1/E3).
## Specs: UI-puzzle-play, J-puzzle-session, UI-mode-pick.C2, L-puzzle-stream K1–K4 / E1.

## E1 — the puzzle-play screen state to show.
signal screen(state: Dictionary)
## E3 — a cue to play (SND.X5 on a Wrong move; the other result cues are copy-only).
signal cue(cue_id: String)
## TEL.1–TEL.5 — one telemetry row.
signal telemetry(event_name: String, outcome: String, story_id: String)
## NAV.T9 — the stream left; the router returns to mode pick.
signal left

## R5 / GS.locale — the locale the screen copy resolves in.
var locale := "en"
## R2 — the result cue currently on screen, or "" between puzzles.
var cue_key := ""

## CMP-puzzle-session (L2) and its deal source (CMP-puzzle-stream). Built by `enter`
## and dropped by `leave`.
var session: PuzzleSession
var stream: PuzzleStream
var client: CatalogDealClient


## NAV.T2 — open on a fresh session restored from the committed document and ask the
## stream for its first deal. `sim_factory` is the catalog peer for seams builds
## (ADR-0013 Testability); null in a release export, where no read can start.
func enter(persist: PersistStore, endpoint: String, api_key: String, sim_factory: Variant) -> void:
	session = PuzzleSession.new(null, persist)
	if persist != null:
		session.restore(persist.load_document())
	session.save_failed.connect(_on_save_failed)
	client = CatalogDealClient.new()
	client.sim_factory = sim_factory
	client.configure(endpoint, api_key)
	stream = PuzzleStream.new(session, client)
	telemetry.emit("puzzle.enter", "ok", "J-puzzle-session.S1")
	# B5 — T9/T10 unset fails every deal (FAIL.T14); the screen still shows S1.
	stream.request()
	_emit_screen()


func is_open() -> bool:
	return session != null and session.has_open_puzzle()


func ui_state() -> String:
	return session.play_ui_state if session != null else PuzzleSession.UI_S1


## U4 → U2 — apply a finished catalog read; the board stays playable meanwhile.
func tick() -> void:
	if stream == null:
		return
	var outcome := stream.poll()
	if outcome.is_empty():
		return
	if not bool(outcome.get("ok", false)):
		telemetry.emit("puzzle.deal_failed", str(outcome.get("reason", "")), "F-puzzle-catalog.X2")
		return
	telemetry.emit("puzzle.dealt", "ok", "UI-puzzle-play.US1")
	_emit_screen(outcome.get("dealt", {}) as Dictionary)


## The screen state: R1 position, R2 Elo / cue, R3 availability and S1–S5. `move` rides
## along so the board can animate a judged place.
func state(p_move: Dictionary = {}) -> Dictionary:
	if session == null:
		return {"locale": locale, "ui_state": PuzzleSession.UI_S1, "position": {}}
	var live := session.play_state()
	var out := {
		"locale": locale,
		"ui_state": str(live.get("ui_state", PuzzleSession.UI_S1)),
		"puzzle_open": session.has_open_puzzle(),
		"position": live.get("position", {}),
		"selection": session.selected_piece,
		"legal": session.legal_targets_for(session.selected_piece),
		"solving_side": str(live.get("solving_side", "")),
		"side_to_move": side_to_move(),
		"player_elo": float(live.get("player_elo", 0.0)),
		"cue_key": cue_key,
		"confirm_kind": str(live.get("confirm_kind", "")),
		"reject_square": session.reject_square,
		"pending_promote_to": session.pending_promote_to,
		"promote_kinds": PuzzleSession.PROMOTE_ORDER,
	}
	if not p_move.is_empty():
		out["move"] = p_move
	return out


## LAY.D6 / TEL.6 — the puzzle fields the playtest snapshot carries; the router adds mode.
func snapshot(base: Dictionary) -> void:
	if session == null:
		return
	var live := session.play_state()
	base["position"] = live.get("position", null)
	base["selected_piece"] = session.selected_piece
	base["play_ui_state"] = str(live.get("ui_state", PuzzleSession.UI_S1))
	base["player_elo"] = float(live.get("player_elo", 0.0))
	base["puzzle_id"] = str(live.get("puzzle_id", "none"))


## R1 C1 / C2 / C6 — the board gesture path (the B2/B3/B10 reuse from #94). A select
## (empty `to_square`) sets the selection; a place is judged by the puzzle (K2).
func gesture(from_square: String, to_square: String, promotion: String = "") -> bool:
	if not gestures_available():
		return false
	if to_square.is_empty():
		var selected := session.select_own(from_square)
		if not bool(selected.get("ok", false)):
			_emit_screen()
			return false
		cue.emit(SharedAudioCues.CUE_SELECT)
		_emit_tel_result(selected)
		_emit_screen()
		return true
	var result := session.place(from_square, to_square, promotion)
	_after_result(result)
	return bool(result.get("ok", false))


## IN.deselect — B8 / B9 / B11 / S4 cancel.
func deselect() -> bool:
	if session == null:
		return false
	var result := session.clear_selection()
	if not bool(result.get("ok", false)):
		return false
	_emit_tel_result(result)
	_emit_screen()
	return true


## C6 — commit the tapped Q/R/B/N; the puzzle judges the move only now (I33/I34).
func promotion(kind: String) -> bool:
	if session == null:
		return false
	if not session.gestures_available() and session.play_ui_state != PuzzleSession.UI_S4:
		return false
	var result := session.commit_promotion(kind)
	_after_result(result)
	return bool(result.get("ok", false))


func finish_reject_flash() -> void:
	if session == null or session.play_ui_state != PuzzleSession.UI_S5:
		return
	session.finish_reject_flash()
	_emit_screen()


## UI-puzzle-play C3–C5 / S2 — the named confirm, Confirm, Cancel and the S3 Dismiss.
func control(control_id: String) -> void:
	if session == null:
		return
	match control_id:
		"C3", "C4", "C5":
			var asked := session.request_confirm(control_id)
			if bool(asked.get("ok", false)):
				_emit_tel_result(asked)
			_emit_screen()
		"confirm":
			_run_confirm()
		"cancel":
			var cancelled := session.cancel_confirm()
			if bool(cancelled.get("ok", false)):
				_emit_tel_result(cancelled)
			_emit_screen()
		"dismiss":
			# S3 Dismiss → S1; the stream continues.
			var dismissed := session.dismiss_save_failure()
			if bool(dismissed.get("ok", false)):
				_emit_tel_result(dismissed)
				cue_key = ""
				_advance_if_owed()
			_emit_screen()


## NAV.T9 / J-puzzle-session.S2 + N2 — Leave confirmed: the open puzzle is not scored
## (K4 / PRG.P1), the read in flight is retired, and mode pick returns.
func leave() -> void:
	cue_key = ""
	if stream != null:
		stream.leave()
	if session != null:
		var left := session.leave()
		telemetry.emit(
			"puzzle.leave", str(left.get("event", "puzzle.leave")), "J-puzzle-session.S2"
		)
	stream = null
	session = null
	client = null
	left.emit()


func gestures_available() -> bool:
	return session != null and session.gestures_available()


func legal_targets_for(square: String) -> PackedStringArray:
	if session == null:
		return PackedStringArray()
	return session.legal_targets_for(square)


func occupancy_at(square: String) -> Dictionary:
	if session == null:
		return {}
	var occ: Dictionary = session.rules.position_field().get("occupancy", {})
	return occ.get(square, {}) as Dictionary


func side_to_move() -> String:
	if session == null:
		return ChessRules.SIDE_WHITE
	return str(session.rules.position_field().get("side_to_move", ChessRules.SIDE_WHITE))


func can_place(from_square: String, to_square: String, promotion: String = "") -> bool:
	if not gestures_available():
		return false
	return session.rules._can_apply_move(from_square, to_square, promotion)


## Performs one stream action (C3 Reveal, C4 Abandon, C5 Leave) after Confirm.
func _run_confirm() -> void:
	match session.confirm_kind:
		PuzzleSession.CONFIRM_REVEAL, PuzzleSession.CONFIRM_ABANDON:
			_after_result(session.confirm())
		PuzzleSession.CONFIRM_LEAVE:
			leave()


## R2 — one result cue at a time after W1 / L4–L6, before the next deal. `cue_wrong`
## shows for a wrong move (K2 resets the same open attempt); an ending's cue
## (W1 / L4 / L5 / L6) shows until the stream invites the next deal.
func _after_result(result: Dictionary) -> void:
	_emit_tel_result(result)
	var key := _cue_for(result)
	if key == "cue_wrong":
		cue.emit(SharedAudioCues.CUE_X5)
		telemetry.emit("puzzle.wrong", "wrong", str(result.get("story", "")))
	elif not key.is_empty():
		telemetry.emit("puzzle.result", key, str(result.get("story", "")))
	cue_key = key
	_emit_screen()
	# K3 — the ending's cue shows before the next deal; the deal ends it.
	if not key.is_empty() and key != "cue_wrong":
		_advance_if_owed()


## The R2 cue for one judged move: `cue_wrong` for a reset attempt, else the ending's.
static func _cue_for(result: Dictionary) -> String:
	if str(result.get("outcome", "")) == "wrong":
		return "cue_wrong"
	return str(result.get("cue", ""))


## K3 / E1 — a solved, failed or abandoned attempt stays open behind its cue; the
## stream asks for the next puzzle once the actor moves on (E1 `advance`). `advance`
## drops the settled attempt and raises `deal_due`, which the stream listens to
## (`PuzzleStream._init`), so the next read starts from there. An attempt that has not
## settled refuses, and S3 holds the deal until Dismiss (SEQ-puzzle-result-commit B2).
func _advance_if_owed() -> void:
	if session == null or stream == null:
		return
	if session.play_ui_state == PuzzleSession.UI_S3:
		return
	if session.has_open_puzzle() and session.outcome.is_empty():
		return
	cue_key = ""
	session.advance()


func _on_save_failed() -> void:
	# EX.save-failure / SEQ-puzzle-result-commit B2 — S3 over the open puzzle.
	telemetry.emit("puzzle.save_failed", "fail", "UI-puzzle-play.S3")
	_emit_screen()


func _emit_tel_result(result: Dictionary) -> void:
	var event := str(result.get("event", ""))
	if event.is_empty() or event == "puzzle.none":
		return
	telemetry.emit(event, str(result.get("outcome", "ok")), str(result.get("story", "")))


func _emit_screen(move: Dictionary = {}) -> void:
	screen.emit(state(move))
