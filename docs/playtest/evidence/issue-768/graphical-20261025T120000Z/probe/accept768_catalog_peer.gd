class_name Accept768CatalogPeer
extends FakeCatalogTransport
## Playtest catalog peer for the #768 acceptance run (ADR-0013 Testability).
##
## The shipped seams build installs `FakeCatalogTransport`, which answers no read by
## default, so nothing is ever dealt through the production path. This peer answers
## every read from its queue, so `PTD-puzzle-stream` runs through
## `CTR-puzzle-catalog-read` -> `PuzzleStream.poll()` -> `PuzzleSession.deal()`.
##
## A read that starts with an empty queue is left open and unread, as a slow peer would
## be; `serve` then hands it the record, which is what lets a row look at the solved cue
## before the next deal arrives. A read that never receives a record is the X2 case.

var _queue: Array = []
## The read that started with nothing to answer, waiting for `serve`.
var _waiting := false
## Reads answered with a record so far.
var answered := 0
## The `recent_solved` ids the last read carried (the O1 G6 window).
var sent_recent: Array = []


func serve(records: Array) -> void:
	_queue = records.duplicate(true)
	# A read is already open and unread: answer it now, the way a peer that replies
	# late does.
	if _waiting and not _queue.is_empty():
		_answer()


func _init(_outcome: Dictionary = {}) -> void:
	super._init()


func start(url: String, message: Dictionary, cap_ms: int) -> void:
	super.start(url, message, cap_ms)
	sent_recent = (message.get("recent_solved", []) as Array).duplicate()
	if _queue.is_empty():
		_waiting = true
		return
	_answer()


## Hand the open read the next queued record.
func _answer() -> void:
	_waiting = false
	var record: Variant = _queue.pop_front()
	answered += 1
	print("CATALOG_ANSWER puzzle_id=", record.get("puzzle_id", "?") if record is Dictionary else "?")
	push_record(record if record is Dictionary else {})
