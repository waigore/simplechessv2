class_name DemoCatalogService
extends RefCounted
## Demo stand-in for the host-served catalog read (ADR-0008, ADR-0013;
## CTR-puzzle-catalog-read O1). F-puzzle-catalog R1: the catalog stays on the
## host and is not shipped in the client; this demo reads a small
## recorded-format slice one record at a time, exactly as it would read a
## single record served by the host. It never parses the slice into Elo bands
## and never sizes it to a sitting (R2). X2: an unreadable slice deals nothing
## and leaves GS.playerElo alone.
##
## The host-side selection the client contract leaves to the host (DIF.Y1 /
## F-puzzle-catalog I1) lives here too, so the demo can show the deal ladder:
## inside the band and not recently solved, then widening the band by
## CFG.ELO_BAND_WIDEN, then allowing a recently solved id, until one is found.

const SLICE_PATH := "res://fixtures/catalog-slice.txt"
const SNAPSHOT_ID := "2026-10-05"
const RECORD_FIELDS := [
	"snapshot_id", "puzzle_id", "fen", "moves", "rating", "rating_deviation",
	"popularity", "nb_plays", "themes", "game_url", "opening_tags",
]

var problems: PackedStringArray = PackedStringArray()
var _records: Array = []
var _ok := false


## Read the slice (a failed open is X2: readable() stays false, nothing deals).
func open(path: String = SLICE_PATH) -> bool:
	_records = []
	_ok = false
	problems = PackedStringArray()
	if not FileAccess.file_exists(path):
		problems.append("catalog slice not readable: %s" % path)
		return false
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		problems.append("catalog slice empty: %s" % path)
		return false
	for raw_line in text.split("\n"):
		var line := raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		var parsed: Variant = JSON.parse_string(line)
		if not (parsed is Dictionary):
			problems.append("catalog record is not an object: %s" % line.substr(0, 24))
			continue
		var record: Dictionary = parsed
		var missing := _missing_fields(record)
		if not missing.is_empty():
			problems.append("record %s is missing %s" % [
				str(record.get("puzzle_id", "?")), ", ".join(missing),
			])
			continue
		if str(record["snapshot_id"]) != SNAPSHOT_ID:
			problems.append("record %s has snapshot_id %s" % [
				record["puzzle_id"], record["snapshot_id"],
			])
			continue
		# F13/I3: any_checkmate_wins is true iff themes holds mateIn1.
		record["any_checkmate_wins"] = bool(record.get(
			"any_checkmate_wins", _has_theme(record, "mateIn1")))
		_records.append(record)
	if _records.is_empty():
		problems.append("catalog slice holds no usable records")
		return false
	_ok = true
	return true


func readable() -> bool:
	return _ok


func records() -> Array:
	return _records


func record_by_id(puzzle_id: String) -> Dictionary:
	for record in _records:
		if str(record.get("puzzle_id", "")) == puzzle_id:
			return record
	return {}


## DIF.Y1 selection result: every puzzle the current Player Elo and history
## could deal at the first ladder rung that yields any. GS.Q1: any member may
## be dealt, and two deals need not match.
func candidate_set(player_elo: float, recent_solved: Array, cfg: Dictionary) -> Array:
	if not _ok:
		return []
	var band := float(cfg["elo_match_range"])
	var widen := maxf(float(cfg["elo_band_widen"]), 1.0)
	var steps := int(ceil(_max_distance(player_elo) / widen)) + 1
	# Prefer ids outside the recent window: in band, then each widen step.
	for step in range(steps + 1):
		var found := _in_band(player_elo, band + widen * step, recent_solved, false)
		if not found.is_empty():
			return found
	# Then allow a recently solved id: in band, then each widen step.
	for step in range(steps + 1):
		var found := _in_band(player_elo, band + widen * step, recent_solved, true)
		if not found.is_empty():
			return found
	return []


## One deal per read (CTR-puzzle-catalog-read O1): the first member of the
## candidate set, or {} when nothing fits (X1/X2 -> nothing is dealt).
func deal(player_elo: float, recent_solved: Array, cfg: Dictionary) -> Dictionary:
	var candidates := candidate_set(player_elo, recent_solved, cfg)
	if candidates.is_empty():
		return {}
	return candidates[0]


func _in_band(player_elo: float, limit: float, recent_solved: Array, allow_recent: bool) -> Array:
	var out: Array = []
	for record in _records:
		var rating := float(record["rating"])
		if absf(rating - player_elo) > limit + 0.001:
			continue
		if not allow_recent and recent_solved.has(str(record["puzzle_id"])):
			continue
		out.append(record)
	return out


func _max_distance(player_elo: float) -> float:
	var span := 0.0
	for record in _records:
		span = maxf(span, absf(float(record["rating"]) - player_elo))
	return span


func _has_theme(record: Dictionary, theme: String) -> bool:
	var themes: Array = record.get("themes", [])
	return themes.has(theme)


func _missing_fields(record: Dictionary) -> Array:
	var missing: Array = []
	for field in RECORD_FIELDS:
		if not record.has(field):
			missing.append(field)
	return missing
