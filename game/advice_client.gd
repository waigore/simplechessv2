class_name AdviceClient
extends RefCounted
## CMP-advice-client (L4). Owns the advice lifecycle behind CTR-advice-stream and
## writes only the advice fields (SCH-advice-update L2). Never talks to Stockfish
## (R1, ADR-0002); never blocks a local move (R5).

## `CFG.ADVICE_TIME_MS` default and range (specs/technical/configuration.md T6).
const ADVICE_TIME_DEFAULT_MS := 2000
const ADVICE_TIME_MIN_MS := 500
const ADVICE_TIME_MAX_MS := 5000
const FEN_ROWS := ["8", "7", "6", "5", "4", "3", "2", "1"]
const FEN_FILES := ["a", "b", "c", "d", "e", "f", "g", "h"]
const PIECE_FEN := {
	"white": {"pawn": "P", "knight": "N", "bishop": "B", "rook": "R", "queen": "Q", "king": "K"},
	"black": {"pawn": "p", "knight": "n", "bishop": "b", "rook": "r", "queen": "q", "king": "k"},
}

## Configured advice endpoint (`T9`) and API key (`T10`); empty when unset.
var endpoint := ""
var api_key := ""
## `T6` `advice_time_ms`; negative when missing, so the default is sent instead.
var advice_time_ms := -1

var _transport_factory: Callable
## AdviceStreamTransport, or a stand-in with the same four calls (tests).
var _transport: Variant
var _stream_id := 0
var _started_ms := 0
var _failed := false


func _init(transport_factory: Callable = Callable()) -> void:
	_transport_factory = (
		transport_factory
		if transport_factory.is_valid()
		else Callable(AdviceStreamTransport, "new")
	)


## Apply B3: `T9` and `T10` are required; a missing one makes Advice unavailable.
func configure(p_endpoint: String, p_api_key: String, p_advice_time_ms: int = -1) -> void:
	endpoint = p_endpoint.strip_edges()
	api_key = p_api_key
	advice_time_ms = p_advice_time_ms


func is_available() -> bool:
	return not endpoint.is_empty() and not api_key.is_empty()


## O1 `time_ms`: `T6` when configured in range, otherwise the 2000 default (R7).
func request_time_ms() -> int:
	if advice_time_ms < ADVICE_TIME_MIN_MS or advice_time_ms > ADVICE_TIME_MAX_MS:
		return ADVICE_TIME_DEFAULT_MS
	return advice_time_ms


## O1 — request a stream for `position`. False when Advice cannot run (R2, B3).
func start(position: Dictionary, castling_ep: Dictionary = {}) -> bool:
	cancel({})
	_failed = false
	if not is_available():
		return false
	var message := {
		"api_key": api_key,
		"fen": fen_for(position, castling_ep),
		"time_ms": request_time_ms(),
	}
	_transport = _make_transport()
	_stream_id += 1
	_started_ms = Time.get_ticks_msec()
	_transport.start(endpoint, message, request_time_ms())
	return true


## O2 + O3 — stop the stream and clear the advice fields.
func cancel(state: Dictionary) -> void:
	_stream_id += 1
	if _transport != null:
		_transport.cancel()
		_transport = null
	clear_fields(state)


## O3 — clear `GS.adviceBestMove` / `GS.adviceEval` (both unknowable, GS.H2).
func clear_fields(state: Dictionary) -> void:
	state["advice_best_move"] = null
	state["advice_eval"] = null


## U3 → U2 — apply queued E1 updates onto `state`. A stream's messages are only
## read for the stream that is still current, so updates after O2 are dropped
## (SCH-advice-update I3). Returns `{"event", "outcome", "story"}` for telemetry
## or `{}` when nothing happened.
func poll(state: Dictionary) -> Dictionary:
	if _transport == null:
		return {}
	var keep_stream := _stream_id
	var result := {}
	var updates: Array = _transport.poll()
	for message in updates:
		if keep_stream != _stream_id:
			continue
		var kind := str((message as Dictionary).get("kind", ""))
		var value: Dictionary = (message as Dictionary).get("value", {})
		if kind == "update":
			result = apply_update(state, value)
		elif kind == "end":
			result = _ended(value)
	if _transport != null and _transport.is_finished():
		_transport = null
	return result


## E1 → SCH-advice-update L2. Maps `best_move_uci` to board squares.
func apply_update(state: Dictionary, update: Dictionary) -> Dictionary:
	var squares := squares_for_uci(str(update.get("best_move_uci", "")))
	if squares.is_empty():
		return {}
	state["advice_best_move"] = squares
	state["advice_eval"] = int(update.get("eval_cp", 0))
	_failed = false
	# Observability: advice timing is logged for playtests (quality.md).
	print("advice: ready after %d ms" % elapsed_ms())
	return {"event": "advice.ready", "outcome": "ok", "story": "F-move-advice.R4"}


func _ended(value: Dictionary) -> Dictionary:
	var reason := str(value.get("reason", AdviceWireReader.REASON_ERROR))
	if reason == AdviceWireReader.REASON_TIMEOUT or reason == AdviceWireReader.REASON_ERROR:
		if not _failed:
			# Observability: the advice failure is logged with its timing.
			push_warning("advice: %s after %d ms" % [reason, elapsed_ms()])
		_failed = true
		return {"event": "advice.error", "outcome": reason, "story": "F-move-advice.R2"}
	return {}


## True once the backend failed; the session then reports `FAIL.T1` (failures M1).
func failed() -> bool:
	return _failed


## Milliseconds since O1 was sent; 0 when no stream is in flight.
func elapsed_ms() -> int:
	if _transport == null:
		return 0
	return Time.get_ticks_msec() - _started_ms


func _make_transport() -> Variant:
	return _transport_factory.call()


## FEN of a `SCH-play-state` position plus its `castling_ep` field, for the O1
## request. Advice is for the side to move only (F-move-advice.R5).
static func fen_for(position: Dictionary, castling_ep: Dictionary = {}) -> String:
	var occupancy: Dictionary = position.get("occupancy", {})
	var rows: Array[String] = []
	for row in FEN_ROWS:
		var line := ""
		var empty := 0
		for file in FEN_FILES:
			var piece: Dictionary = occupancy.get(file + row, {})
			if piece.is_empty():
				empty += 1
				continue
			if empty > 0:
				line += str(empty)
				empty = 0
			line += _piece_letter(piece)
		if empty > 0:
			line += str(empty)
		rows.append(line)
	var side := "w" if str(position.get("side_to_move", "white")) == "white" else "b"
	var en_passant := str(castling_ep.get("en_passant", ""))
	var ep := "-" if en_passant.is_empty() else en_passant
	return "%s %s %s %s 0 1" % ["/".join(rows), side, _castling_field(castling_ep), ep]


## Castling rights in FEN order: White kingside, White queenside, Black kingside,
## Black queenside. `castling_ep` keys are flat (`white_kingside`, …).
static func _castling_field(castling_ep: Dictionary) -> String:
	var rights := ""
	for entry in [
		["white_kingside", "K"],
		["white_queenside", "Q"],
		["black_kingside", "k"],
		["black_queenside", "q"]
	]:
		if bool(castling_ep.get(str(entry[0]), false)):
			rights += str(entry[1])
	return "-" if rights.is_empty() else rights


## `best_move_uci` → `{"from": square, "to": square}` (SCH-advice-update F1 / F2).
static func squares_for_uci(uci: String) -> Dictionary:
	if uci.length() < 4:
		return {}
	var from_square := uci.substr(0, 2)
	var to_square := uci.substr(2, 2)
	if not BoardGeometry.is_square(from_square) or not BoardGeometry.is_square(to_square):
		return {}
	return {"from": from_square, "to": to_square}


static func _piece_letter(piece: Dictionary) -> String:
	var color := str(piece.get("color", ""))
	var letters: Dictionary = PIECE_FEN.get(color, {})
	return str(letters.get(str(piece.get("kind", "")), "P"))
