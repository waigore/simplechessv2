class_name CatalogWireReaderTest
extends SceneTree
## CTR-puzzle-catalog-read response reading (#528): one `SCH-puzzle-catalog`
## F1–F13 record or a failed read (O2). A list, page, or file body is a failed
## read (G1), and so is a record missing or malforming any field. No network.


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		printerr("FAIL: %s" % problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array[Callable] = [
		_check_one_record_reads,
		_check_bulk_bodies_fail,
		_check_every_required_field_is_checked,
		_check_types_are_checked,
		_check_snapshot_is_the_served_one,
		_check_i2_and_i3_hold,
		_check_extra_fields_pass,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return "%s: %s" % [check.get_method(), problem]
	return ""


## A real server body: the wire names CTR-puzzle-catalog-read O1 returns.
func _body() -> Dictionary:
	return {
		"snapshot_id": "2026-10-05",
		"puzzle_id": "abc12",
		"fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
		"moves": ["e2e4", "e7e5"],
		"rating": 1040,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": ["fork"],
		"game_url": "https://example.test/game",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}


func _check_one_record_reads() -> String:
	var outcome := CatalogWireReader.read(JSON.stringify(_body()))
	if not bool(outcome.get("ok", false)):
		return "one F1–F13 record must read (got %s)" % outcome
	var record: Dictionary = outcome.get("record", {})
	if str(record.get("puzzle_id", "")) != "abc12":
		return "the read record must be the body's record"
	return ""


func _check_bulk_bodies_fail() -> String:
	for body in [
		"[%s]" % JSON.stringify(_body()),
		JSON.stringify([_body(), _body()]),
		"snapshot_id,puzzle_id\n2026-10-05,abc12\n",
		"",
		"null",
		"not json",
	]:
		var outcome := CatalogWireReader.read(body)
		if bool(outcome.get("ok", true)):
			return "a bulk or non-record body must fail (got %s)" % body.substr(0, 12)
		if str(outcome.get("reason", "")).is_empty():
			return "a failed read must name a reason"
	return ""


func _check_every_required_field_is_checked() -> String:
	for field in [
		"snapshot_id",
		"puzzle_id",
		"fen",
		"moves",
		"rating",
		"rating_deviation",
		"popularity",
		"nb_plays",
		"themes",
		"game_url",
		"opening_tags",
		"daily_date",
		"any_checkmate_wins",
	]:
		var body := _body()
		body.erase(field)
		var outcome := CatalogWireReader.read(JSON.stringify(body))
		if bool(outcome.get("ok", true)):
			return "a record missing %s must be a failed read" % field
	return ""


func _check_types_are_checked() -> String:
	# Numeric strings are still a malformed F5–F8: the wire carries numbers.
	for field in ["rating", "rating_deviation", "popularity", "nb_plays"]:
		var body := _body()
		body[field] = "1040"
		if bool(CatalogWireReader.read(JSON.stringify(body)).get("ok", true)):
			return "%s must be a number, not a string" % field
	var not_string := _body()
	not_string["game_url"] = null
	if bool(CatalogWireReader.read(JSON.stringify(not_string)).get("ok", true)):
		return "a non-string game_url must be a failed read"
	var not_list := _body()
	not_list["moves"] = "e2e4 e7e5"
	if bool(CatalogWireReader.read(JSON.stringify(not_list)).get("ok", true)):
		return "moves must be a list, not a string"
	var not_bool := _body()
	not_bool["any_checkmate_wins"] = "false"
	if bool(CatalogWireReader.read(JSON.stringify(not_bool)).get("ok", true)):
		return "any_checkmate_wins must be a bool"
	return ""


func _check_snapshot_is_the_served_one() -> String:
	var body := _body()
	body["snapshot_id"] = "2026-10-04"
	if bool(CatalogWireReader.read(JSON.stringify(body)).get("ok", true)):
		return "SCH-puzzle-catalog I1: only snapshot 2026-10-05 may be dealt"
	for field in ["puzzle_id", "fen"]:
		var empty := _body()
		empty[field] = ""
		if bool(CatalogWireReader.read(JSON.stringify(empty)).get("ok", true)):
			return "%s must not be empty" % field
	return ""


func _check_i2_and_i3_hold() -> String:
	var one_move := _body()
	one_move["moves"] = ["e2e4"]
	# Unmarked, so I3 (the mate mark) cannot be what refuses this record: I2 does.
	var too_short := CatalogWireReader.read(JSON.stringify(one_move))
	if bool(too_short.get("ok", true)):
		return "SCH-puzzle-catalog I2: moves shorter than two must fail"
	var got := str(too_short.get("reason", ""))
	if got != CatalogWireReader.REASON_MALFORMED:
		return "SCH-puzzle-catalog I2: a one-move record is malformed, not %s" % got
	var marked_long := _body()
	marked_long["themes"] = ["mateIn1"]
	marked_long["any_checkmate_wins"] = true
	marked_long["moves"] = ["e2e4", "e7e5", "g1f3"]
	if bool(CatalogWireReader.read(JSON.stringify(marked_long)).get("ok", true)):
		return "SCH-puzzle-catalog I3: a mate-in-one has exactly two moves"
	var marks_disagree := _body()
	marks_disagree["themes"] = ["mateIn1"]
	if bool(CatalogWireReader.read(JSON.stringify(marks_disagree)).get("ok", true)):
		return "SCH-puzzle-catalog I3: the mark is true iff themes has mateIn1"
	var mate := _body()
	mate["themes"] = ["mateIn1"]
	mate["any_checkmate_wins"] = true
	if not bool(CatalogWireReader.read(JSON.stringify(mate)).get("ok", false)):
		return "a consistent mate-in-one record must read"
	return ""


func _check_extra_fields_pass() -> String:
	var body := _body()
	body["server_ms"] = 12
	if not bool(CatalogWireReader.read(JSON.stringify(body)).get("ok", false)):
		return "an extra field must not fail the record"
	return ""
