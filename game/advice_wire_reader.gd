class_name AdviceWireReader
extends RefCounted
## CTR-advice-stream response reading, separated from the socket so the exchange
## rules can be checked without a network. The transport owns an HTTPClient and
## feeds this reader its status, body chunks, and poll errors; the reader decides
## what each step means and reports E2 ends through its `ended` reason.

## E2 reasons (CTR-advice-stream Wire, End message).
const REASON_CAP := "cap"
const REASON_ERROR := "error"
const REASON_TIMEOUT := "timeout"
## A chunked NDJSON stream is newline-delimited; a partial line waits for more.
const NEWLINE := "\n"

## Set once the stream ended: `cap`, `error`, `cancel`, or `timeout`.
var ended := ""

var _buffer := ""


## True while the exchange may keep running.
func is_open() -> bool:
	return ended.is_empty()


## One poll step. `poll_err` is the HTTPClient error, `failed` marks the backend
## as unreachable. Returns true when the caller should stop reading.
func step(poll_err: Error, failed: bool, timed_out: bool) -> bool:
	if poll_err != OK or failed:
		ended = REASON_ERROR
		return true
	if timed_out:
		ended = REASON_TIMEOUT
		return true
	return not ended.is_empty()


## Feed a response chunk. Returns true when an E2 end arrived inside it.
func feed(chunk: PackedByteArray, updates: Array) -> bool:
	_buffer += chunk.get_string_from_utf8()
	while _buffer.contains(NEWLINE):
		var lines := _buffer.split(NEWLINE, true, 1)
		_buffer = str(lines[1])
		_read_line(str(lines[0]), updates)
	return not ended.is_empty()


## The connection closed: buffered lines still count, and an unterminated stream
## is a failure (FAIL.T1 - "stream timeout" / "backend error").
func closed(updates: Array) -> void:
	if not _buffer.strip_edges().is_empty():
		_read_line(_buffer, updates)
		_buffer = ""
	if ended.is_empty():
		ended = REASON_ERROR


## E2 reached the client before the cap (CTR-advice-stream.G2).
func capped() -> bool:
	return ended == REASON_CAP or ended == REASON_TIMEOUT


## O2 or a completed exchange: not a backend failure.
func cancelled() -> void:
	if ended.is_empty():
		ended = REASON_CAP


func _read_line(line: String, updates: Array) -> void:
	var trimmed := line.strip_edges()
	if trimmed.is_empty():
		return
	var parsed: Variant = JSON.parse_string(trimmed)
	if not (parsed is Dictionary):
		return
	var message: Dictionary = parsed
	if message.has("reason"):
		ended = str(message["reason"])
	elif message.has("best_move_uci"):
		updates.append(message)
