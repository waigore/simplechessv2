class_name PuzzleStream
extends RefCounted
## CMP-puzzle-session R1 — the stream's deal source: reads one record through
## `CTR-puzzle-catalog-read` (CatalogDealClient) off the move path and deals only that
## record (`concurrency.md` U4, O5, S3, S4). A test that deals a small array calls
## `PuzzleSession.deal()` directly instead of travelling through here.

## F-puzzle-catalog X2 — raised with the reason when a read failed; nothing was dealt.
signal deal_failed
## I2 — a dealt record carries a first move and at least one required reply.
const MIN_MOVES := 2
## CMP-puzzle-session R1 — at most one read in flight at a time (O5).
var single_read := true

## The session whose `GS.playerElo` / `GS.recentSolved` feed the O1 request and whose
## attempt the dealt record opens (CMP-puzzle-session R1).
var session: PuzzleSession
## The catalog-service peer (CMP-catalog-service, C5); null means this stream cannot
## reach a catalog, so every request is a failed read that deals nothing (X2, B5).
var client: Variant = null
## True while a deal is owed: requested, in flight, or answered but not yet dealt.
var due := false
## The O2 reason the last failed read reported, seen by a caller that only has the signal.
var last_failure := ""
var min_move_count := MIN_MOVES
## S4 — the stream this read belongs to is still open.
var stream_open := true


func _init(p_session: PuzzleSession, p_client: Variant = null) -> void:
	session = p_session
	client = p_client
	if session != null:
		session.deal_due.connect(request)


## R1 — ask the catalog service for one puzzle at the player's level. False when a
## deal is already owed (one at a time) or the read could not start, which is a failed
## read that deals nothing (X2, B5).
func request() -> bool:
	if due:
		return false
	if client == null:
		refused(CatalogWireReader.REASON_ERROR)
		return false
	if not bool(client.is_available()):
		refused(CatalogWireReader.REASON_UNCONFIGURED)
		return false
	if not started(client.request(session.player_elo, session.recent_solved)):
		refused(CatalogWireReader.REASON_STATUS)
		return false
	due = true
	last_failure = ""
	return true


## U4 -> U2 — apply a finished read to the session. A read still in flight returns {}
## and the board stays playable (G3). Returns `{ok, dealt, reason, event}`; a
## successful read deals the one record it returned.
func poll() -> Dictionary:
	if not due or client == null:
		return {}
	var outcome: Dictionary = client.poll()
	if outcome.is_empty():
		return {}
	due = false
	if not bool(outcome.get("ok", false)):
		return _failed(str(outcome.get("reason", CatalogWireReader.REASON_ERROR)), {})
	var record: Dictionary = outcome.get("record", {})
	if not usable(record):
		return _failed(CatalogWireReader.REASON_MALFORMED, {})
	var dealt: Dictionary = session.deal([record])
	if not bool(dealt.get("ok", false)):
		return _failed(str(dealt.get("reason", CatalogWireReader.REASON_MALFORMED)), dealt)
	return {"ok": true, "dealt": dealt, "reason": "", "event": "puzzle.dealt"}


## S4 — leave: a read in flight is retired and its record never deals. An owed deal is
## dropped, not failed, so the caller keeps its Elo and no new read starts (K4, PRG.P1).
func leave() -> void:
	due = false
	if client != null:
		client.cancel()


## B5 — `T9` / `T10` unset means the read cannot be sent; an available client that
## refuses to start is a refusal, not a request (one deal at a time, G6).
func started(accepted: Variant) -> bool:
	return bool(client.is_available()) and bool(accepted)


## X2 — nothing was dealt (an O1 failure, X1, or a request that could not start): the
## session holds no puzzle, its Elo is untouched, and `deal_failed` carries the reason.
##
## The failed read is never handed to `PuzzleSession.deal()`: a deal takes at least the
## two moves a puzzle needs (I2), so a failure passed to it would read as X1
## `empty_solution` rather than the O2 reason the peer reported.
func refused(reason: String) -> void:
	last_failure = reason
	push_warning("puzzle stream: deal read failed (%s)" % reason)
	deal_failed.emit(reason)


## True iff `record` carries at least the two moves a deal needs (I2, X1 precondition).
static func usable(record: Dictionary) -> bool:
	var moves: Variant = record.get(PuzzleSession.FIELD_MOVES, [])
	if moves is Array:
		return (moves as Array).size() >= MIN_MOVES
	if moves is String:
		return str(moves).split(" ", false).size() >= MIN_MOVES
	return false


## A failed read: record the reason and tell the caller. `GS.puzzleId` stays none and
## `GS.playerElo` is never written by a read.
func _failed(reason: String, dealt: Dictionary) -> Dictionary:
	refused(reason)
	return {"ok": false, "dealt": dealt, "reason": reason, "event": "puzzle.read_failed"}
