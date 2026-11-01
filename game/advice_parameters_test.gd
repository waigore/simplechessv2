class_name AdviceParametersTest
extends SceneTree
## CMP-session-router R7 (#892) — T9/T10 enter `SessionRouter` from one source both
## presets share, and their absence stays the ordinary no-backend build (CFG.B5):
## every deal fails FAIL.T14 with REASON_UNCONFIGURED, nothing is dealt, and Elo is kept.
## Fixtures are written under the operator temp path only, never at the constant's route.

const TEST_ENDPOINT := "http://advice.test/advice"
const TEST_KEY := "test-key"


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem := await _run_all()
	if not problem.is_empty():
		printerr("FAIL: %s" % problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	## The boot check installs a deployment file at the constant's own route, so it
	## runs last: every other check must see the untouched `""` default.
	var checks: Array[Callable] = [
		_check_constant_is_a_bare_file_name,
		_check_applier_fills_both_values,
		_check_applier_leaves_the_absence_default,
		_check_present_pair_reaches_the_peer_on_the_wire,
		_check_absent_pair_fails_at_unconfigured_through_the_router,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return "%s: %s" % [check.get_method(), problem]
	var boot_problem: String = await _check_boot_applies_the_constant_route()
	if not boot_problem.is_empty():
		return "_check_boot_applies_the_constant_route: %s" % boot_problem
	return ""


## AC5 — the constant names the file and nothing else: no `res://`, no directory.
func _check_constant_is_a_bare_file_name() -> String:
	var path := AdviceParameters.PARAMETERS_PATH
	if path != "advice_parameters.json":
		return "the constant must be the bare file name (got %s)" % path
	if path.contains("/") or path.contains(":"):
		return "the constant must not carry a directory or scheme (got %s)" % path
	return ""


func _check_applier_fills_both_values() -> String:
	var path := _write_fixture({"endpoint": "  %s  " % TEST_ENDPOINT, "api_key": TEST_KEY})
	var router := SessionRouter.new()
	_apply(router, path)
	_cleanup(path)
	if router.advice_endpoint != TEST_ENDPOINT:
		return "the endpoint must be filled and stripped (got %s)" % router.advice_endpoint
	if router.advice_api_key != TEST_KEY:
		return "the key must be filled (got %s)" % router.advice_api_key
	return ""


## AC2 — a missing file, a non-object body, a missing key, and an empty or
## whitespace value are all misses that keep the `""` default.
func _check_applier_leaves_the_absence_default() -> String:
	var cases: Array = [
		{"what": "a missing file", "path": "", "body": null},
		{"what": "a non-object body", "path": "list.json", "body": [TEST_ENDPOINT]},
		{"what": "a missing key", "path": "half.json", "body": {"endpoint": TEST_ENDPOINT}},
		{"what": "an empty value", "path": "empty.json", "body": {"endpoint": "", "api_key": ""}},
		{
			"what": "a whitespace value",
			"path": "blank.json",
			"body": {"endpoint": "   ", "api_key": "\t"},
		},
	]
	for case: Dictionary in cases:
		var path := str(case["path"])
		path = _temp_path(path) if path.is_empty() else _write_fixture(case["body"], path)
		var router := SessionRouter.new()
		_apply(router, path)
		_cleanup(path)
		if not router.advice_endpoint.is_empty() or not router.advice_api_key.is_empty():
			return (
				"%s must leave the absence default (got %s / %s)"
				% [case["what"], router.advice_endpoint, router.advice_api_key]
			)
	return ""


## AC1 — the present pair an applier produced reaches the fake peer on the wire,
## through PuzzlePlayFlow.enter exactly as the router calls it.
func _check_present_pair_reaches_the_peer_on_the_wire() -> String:
	var path := _write_fixture({"endpoint": TEST_ENDPOINT, "api_key": TEST_KEY})
	var router := SessionRouter.new()
	_apply(router, path)
	_cleanup(path)
	var peer := FakeCatalogTransport.new()
	var flow := PuzzlePlayFlow.new()
	## `enter` already asks the stream for its first deal (NAV.T2).
	flow.enter(null, router.advice_endpoint, router.advice_api_key, _peer_factory(peer))
	if not bool(flow.client.is_available()):
		return "a supplied pair must make the deal client available"
	if not flow.stream.due:
		return "the entry read must be owed on a supplied pair"
	if peer.requests.size() != 1:
		return "the fake peer must receive exactly one read (got %d)" % peer.requests.size()
	if peer.endpoint != TEST_ENDPOINT:
		return "the peer must be aimed at the supplied endpoint (got %s)" % peer.endpoint
	var request: Dictionary = peer.requests[0]
	if str(request.get("api_key", "")) != TEST_KEY:
		return "the peer must receive the supplied key (got %s)" % request.get("api_key", "")
	return ""


## AC3 — with the pair absent, the router's own initialisers produce
## REASON_UNCONFIGURED, nothing dealt, GS.playerElo kept.
func _check_absent_pair_fails_at_unconfigured_through_the_router() -> String:
	for field: String in ["advice_endpoint", "advice_api_key"]:
		var pair := {"endpoint": TEST_ENDPOINT, "api_key": TEST_KEY}
		pair["endpoint" if field == "advice_endpoint" else "api_key"] = ""
		var path := _write_fixture(pair)
		var router := SessionRouter.new()
		_apply(router, path)
		_cleanup(path)
		var flow := PuzzlePlayFlow.new()
		flow.enter(null, router.advice_endpoint, router.advice_api_key, null)
		var session: PuzzleSession = flow.session
		if session.player_elo != PuzzleSession.ELO_START:
			return "GS.playerElo must be unchanged with %s absent" % field
		if flow.stream.client.is_available():
			return "an absent %s must leave the deal client unavailable" % field
		if flow.stream.last_failure != CatalogWireReader.REASON_UNCONFIGURED:
			return (
				"an absent %s must surface REASON_UNCONFIGURED (got %s)"
				% [field, flow.stream.last_failure]
			)
		if flow.stream.due or session.puzzle_id != "":
			return "an absent %s must deal nothing" % field
	return ""


## The applier is the first executable block of `_ready()`, so a deployment that
## supplies the file at the constant's route is applied before Boot ready: a router
## added beside a resolver reads it without anyone calling the applier by hand.
## The constant is a bare name, so the engine reads it from the process cwd. The
## check reports itself as not-applicable when the cwd is not the project root,
## rather than asserting that the run's launcher set one.
func _check_boot_applies_the_constant_route() -> String:
	var route := AdviceParameters.PARAMETERS_PATH
	var file := FileAccess.open(route, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify({"endpoint": TEST_ENDPOINT, "api_key": TEST_KEY}))
	file.close()
	var host := Node.new()
	var resolver := AssetResolver.new()
	resolver.name = "AssetResolver"
	var router := SessionRouter.new()
	router.name = "SessionRouter"
	host.add_child(resolver)
	host.add_child(router)
	root.add_child(host)
	await process_frame
	var endpoint := router.advice_endpoint
	var api_key := router.advice_api_key
	host.queue_free()
	_cleanup(route)
	if endpoint != TEST_ENDPOINT or api_key != TEST_KEY:
		return (
			"_ready() must apply the deployment file before Boot ready (got %s / %s)"
			% [endpoint, api_key]
		)
	return ""


## The same two statements `_ready()` runs, against a fixture path.
func _apply(router: SessionRouter, path: String) -> void:
	var pair := AdviceParameters.pair(path)
	router.advice_endpoint = pair["endpoint"]
	router.advice_api_key = pair["api_key"]


func _peer_factory(peer: FakeCatalogTransport) -> Callable:
	## PuzzlePlayFlow takes a catalog peer factory; the fake records what it is handed.
	return func() -> RefCounted: return peer


func _write_fixture(body: Variant, name := "advice_parameters.json") -> String:
	var path := _temp_path(name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(body))
	file.close()
	return path


## Never at the constant's route: the operator temp path, uniquely named per call.
func _temp_path(name: String) -> String:
	return OS.get_temp_dir().path_join("issue-892-%d-%s" % [Time.get_ticks_usec(), name])


func _cleanup(path: String) -> void:
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	DirAccess.remove_absolute(path)
