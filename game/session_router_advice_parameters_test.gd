class_name SessionRouterAdviceParametersTest
extends SceneTree
## CMP-session-router R7 / CFG.B3 / CFG.B5 (#892) — T9/T10 enter the router on boot
## from one `advice_parameters.json` read both presets share, and their absence stays
## the `""` default every deal then fails on (FAIL.T14).
##
## The router is the real `main.tscn` node, so `_ready()` runs the applier itself;
## the catalog peer is simulated (ADR-0013 Testability) and nothing here touches a
## network. No fixture is written at the applier's own route: `res://` is read-only
## on Web, and a packed `advice_parameters.json` is what the issue forbids.

## The fake pair the fixtures carry, as `game/advice_ui_test.gd` uses.
const ENDPOINT := "http://advice.test/advice"
const API_KEY := "test-key"

var _presentation: Presentation
var _router: SessionRouter


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	var problem := _run_all()
	_presentation.free()
	if not problem.is_empty():
		printerr("FAIL: %s" % problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array[Callable] = [
		_check_present_pair_is_read_and_wired,
		_check_every_miss_leaves_the_default,
		_check_absent_path_is_unconfigured_not_status,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return "%s: %s" % [check.get_method(), problem]
	return ""


## AC1 / AC2 — the applier fills both fields from a temp-path fixture, and the stream
## built from them reaches the peer with exactly the supplied endpoint and key.
func _check_present_pair_is_read_and_wired() -> String:
	var path := _fixture('{"endpoint": "  %s  ", "api_key": "%s"}' % [ENDPOINT, API_KEY])
	if not FileAccess.file_exists(path):
		return "the fixture must be written off-tree"
	_router._apply_advice_parameters(path)
	DirAccess.remove_absolute(path)
	if _router.advice_endpoint != ENDPOINT or _router.advice_api_key != API_KEY:
		return "R7: the applier must fill and strip both values (got %s / %s)" % [
			_router.advice_endpoint, _router.advice_api_key
		]
	var peer := FakeCatalogTransport.new()
	var flow := PuzzlePlayFlow.new()
	var factory := func() -> RefCounted:
		return peer
	flow.enter(null, _router.advice_endpoint, _router.advice_api_key, factory)
	if peer.requests.size() != 1:
		return "AC1: an available client must start exactly one read (%d)" % peer.requests.size()
	if peer.endpoint != ENDPOINT:
		return "AC1: the peer must be read at the supplied endpoint (got %s)" % peer.endpoint
	var message: Dictionary = peer.requests[0]
	if str(message.get("api_key", "")) != API_KEY:
		return "AC1: the peer must carry the supplied key (got %s)" % message.get("api_key", "")
	return ""


## AC2 — no file, a non-object, an unparseable body, a missing key, an empty or
## whitespace value, and a bare JSON string are all misses that leave the `""`
## initialisers. Half a pair is no pair (B5).
func _check_every_miss_leaves_the_default() -> String:
	var misses := {
		"a missing file": "",
		"a non-object body": "[1, 2]",
		"an unparseable body": "{not json",
		"a bare string body": '"%s"' % ENDPOINT,
		"a missing key": '{"endpoint": "%s"}' % ENDPOINT,
		"a missing endpoint": '{"api_key": "%s"}' % API_KEY,
		"an empty value": '{"endpoint": "", "api_key": "   "}',
		"a non-string value": '{"endpoint": 42, "api_key": "%s"}' % API_KEY,
	}
	for label in misses:
		var path := _fixture(str(misses[label]))
		_clear_pair()
		_router._apply_advice_parameters(path)
		DirAccess.remove_absolute(path)
		if not _router.advice_endpoint.is_empty() or not _router.advice_api_key.is_empty():
			return "R7: %s must not supply T9/T10 (got %s / %s)" % [
				label, _router.advice_endpoint, _router.advice_api_key
			]
	return ""


## The router's own initialisers (`game/session_router.gd:36-37`).
func _clear_pair() -> void:
	_router.advice_endpoint = ""
	_router.advice_api_key = ""


## AC3 — through the router's own initialisers, an absent pair fails the deal with
## REASON_UNCONFIGURED (not REASON_STATUS), deals nothing, and keeps GS.playerElo.
func _check_absent_path_is_unconfigured_not_status() -> String:
	for absent in ["endpoint", "key"]:
		_router.advice_endpoint = "" if absent == "endpoint" else ENDPOINT
		_router.advice_api_key = "" if absent == "key" else API_KEY
		var flow := PuzzlePlayFlow.new()
		flow.enter(null, _router.advice_endpoint, _router.advice_api_key, null)
		var reason: String = flow.stream.last_failure
		if reason != CatalogWireReader.REASON_UNCONFIGURED:
			return "B5/FAIL.T14: an absent T9 or T10 must carry REASON_UNCONFIGURED (got %s)" % reason
		if flow.session.puzzle_id != "" or flow.session.puzzle_elo != null:
			return "B5/FAIL.T14: an absent %s must deal nothing" % absent
		if flow.session.player_elo != PuzzleSession.ELO_START:
			return "B5/FAIL.T14: an absent %s must keep GS.playerElo" % absent
	return ""


## A fixture under a temp path only; "" body means no file is written.
func _fixture(body: String) -> String:
	var path := OS.get_temp_dir().path_join("advice_parameters_%d.json" % Time.get_ticks_usec())
	if body.is_empty():
		return path
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(body)
		file.close()
	return path
