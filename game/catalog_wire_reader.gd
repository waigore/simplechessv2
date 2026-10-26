class_name CatalogWireReader
extends RefCounted
## CTR-puzzle-catalog-read wire reading, separated from the socket so the
## exchange rules can be checked without a network. The transport owns an
## HTTPClient and hands this reader the response status and body; the reader
## decides whether the body is exactly one SCH-puzzle-catalog F1–F13 record
## (G1) or a failed read (O2).
##
## Only the record's field names live here; how a dealt record reaches the
## attempt is CMP-puzzle-session's job.

## O2 reasons: what the failed read was.
const REASON_ERROR := "error"
const REASON_TIMEOUT := "timeout"
const REASON_STATUS := "status"
const REASON_BULK := "bulk"
const REASON_MALFORMED := "malformed"
## B5 — `T9` / `T10` unset on the client: no read was sent, so no transport, status, or
## body failure can be the cause. Client-internal label; `CTR-puzzle-catalog-read` O2
## names no reason vocabulary.
const REASON_UNCONFIGURED := "unconfigured"

## SCH-puzzle-catalog I1 — the only snapshot the served records name.
const SNAPSHOT_ID := "2026-10-05"

## Wire names of the F1–F13 fields (CTR-puzzle-catalog-read O1).
const FIELD_SNAPSHOT_ID := "snapshot_id"
const FIELD_PUZZLE_ID := "puzzle_id"
const FIELD_FEN := "fen"
const FIELD_MOVES := "moves"
const FIELD_RATING := "rating"
const FIELD_RATING_DEVIATION := "rating_deviation"
const FIELD_POPULARITY := "popularity"
const FIELD_NB_PLAYS := "nb_plays"
const FIELD_THEMES := "themes"
const FIELD_GAME_URL := "game_url"
const FIELD_OPENING_TAGS := "opening_tags"
const FIELD_DAILY_DATE := "daily_date"
const FIELD_ANY_CHECKMATE_WINS := "any_checkmate_wins"

const REQUIRED_STRINGS := [
	FIELD_SNAPSHOT_ID,
	FIELD_PUZZLE_ID,
	FIELD_FEN,
	FIELD_GAME_URL,
	FIELD_OPENING_TAGS,
	FIELD_DAILY_DATE,
]
const REQUIRED_INTS := [FIELD_RATING, FIELD_RATING_DEVIATION, FIELD_POPULARITY, FIELD_NB_PLAYS]

const MATE_IN_ONE := "mateIn1"
## SCH-puzzle-catalog I2: the first move is the opponent's, so one required move follows.
const MIN_MOVES := 2
const MATE_IN_ONE_MOVES := 2


## O1 response body → `{ok: true, record}` or `{ok: false, reason}`.
## A body that is not a JSON object is a bulk or a malformed read: either way
## the deal fails and nothing is dealt (G1, X2).
static func read(body: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(body)
	if parsed == null or not (parsed is Dictionary):
		return _fail(REASON_BULK if _is_bulk(body) else REASON_MALFORMED)
	return validate(parsed)


## True when the parsed body is a list, page, or file rather than one record.
static func _is_bulk(body: String) -> bool:
	var trimmed := body.strip_edges()
	return trimmed.begins_with("[") or not trimmed.begins_with("{")


## One F1–F13 record check: every required field present and shaped, I1–I3 held.
static func validate(record: Dictionary) -> Dictionary:
	for field in REQUIRED_STRINGS:
		if not (record.get(field) is String):
			return _fail(REASON_MALFORMED)
	for field in REQUIRED_INTS:
		if not (record.get(field) is float or record.get(field) is int):
			return _fail(REASON_MALFORMED)
	if not (record.get(FIELD_ANY_CHECKMATE_WINS) is bool):
		return _fail(REASON_MALFORMED)
	var moves: Variant = record.get(FIELD_MOVES)
	var themes: Variant = record.get(FIELD_THEMES)
	if not _is_string_list(moves) or not _is_string_list(themes):
		return _fail(REASON_MALFORMED)
	if str(record[FIELD_SNAPSHOT_ID]) != SNAPSHOT_ID:
		return _fail(REASON_MALFORMED)
	if str(record[FIELD_PUZZLE_ID]).is_empty() or str(record[FIELD_FEN]).is_empty():
		return _fail(REASON_MALFORMED)
	if (moves as Array).size() < MIN_MOVES:
		return _fail(REASON_MALFORMED)
	# I3: the mark is true iff the themes carry mateIn1, and then there is one reply.
	var any_checkmate_wins := bool(record[FIELD_ANY_CHECKMATE_WINS])
	if any_checkmate_wins != (themes as Array).has(MATE_IN_ONE):
		return _fail(REASON_MALFORMED)
	if any_checkmate_wins and (moves as Array).size() != MATE_IN_ONE_MOVES:
		return _fail(REASON_MALFORMED)
	return {"ok": true, "record": record}


static func _is_string_list(value: Variant) -> bool:
	if not (value is Array):
		return false
	for item in value:
		if not (item is String):
			return false
	return true


static func _fail(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
