class_name SessionRouterAdviceParametersTest
extends SceneTree
## CMP-session-router R7 (#892): `T9`/`T10` reach the router at boot from one
## deployment-supplied pair shared by both presets, and a miss of any kind leaves
## the `""` absence default that `CFG.B5` reads. Exercised through the production
## helpers and the real `PuzzlePlayFlow.enter()` seam; nothing is committed and no
## fixture is written at the constant's route.

const ENDPOINT := "http://advice.test/advice"
const API_KEY := "test-key"

var _failures: Array = []
var _temp_dir := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_temp_dir = OS.get_temp_dir().path_join("session_router_advice_parameters_test")
	DirAccess.make_dir_recursive_absolute(_temp_dir)

	_check_applier_present()
	_check_applier_misses()
	_check_pair_reaches_the_wire()
	_check_absence_through_the_initialisers()
	_check_no_committed_value()

	if _failures.is_empty():
		print("session_router_advice_parameters_test OK")
		quit(0)
	else:
		for failure in _failures:
			print("session_router_advice_parameters_test FAIL: %s" % failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


## A fixture under the operator temp path only, never at the constant's route.
func _fixture(file_name: String, body: String) -> String:
	var path := _temp_dir.path_join(file_name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(body)
	file.close()
	return path


func _applied(path: String) -> SessionRouter:
	var router := SessionRouter.new()
	router._apply_advice_parameters(path)
	return router


## R7: a supplied pair fills both fields, stripped of surrounding space.
func _check_applier_present() -> void:
	var path := _fixture(
		"present.json", '{"endpoint": "  %s  ", "api_key": " %s "}' % [ENDPOINT, API_KEY]
	)
	var router := _applied(path)
	_check(
		router.advice_endpoint == ENDPOINT,
		"R7: the endpoint arrives stripped (got '%s')" % router.advice_endpoint
	)
	_check(
		router.advice_api_key == API_KEY,
		"R7: the api key arrives stripped (got '%s')" % router.advice_api_key
	)
	router.free()


## R7: absent file, non-object body, unparseable body, missing key, empty value,
## and whitespace value are all misses that leave the absence default.
func _check_applier_misses() -> void:
	var cases := [
		["absent file", _temp_dir.path_join("absent.json")],
		["non-object body", _fixture("not-an-object.json", '["endpoint", "api_key"]')],
		["unparseable body", _fixture("unparseable.json", "{not json")],
		["missing key", _fixture("missing-key.json", '{"something_else": "x"}')],
		["empty value", _fixture("empty.json", '{"endpoint": "", "api_key": ""}')],
		["whitespace value", _fixture("whitespace.json", '{"endpoint": "  ", "api_key": " \\t "}')],
	]
	for entry in cases:
		var label: String = entry[0]
		var router := _applied(entry[1])
		_check(
			router.advice_endpoint == "" and router.advice_api_key == "",
			(
				"R7: a %s leaves both fields empty (got '%s' / '%s')"
				% [label, router.advice_endpoint, router.advice_api_key]
			)
		)
		router.free()


## R7: the pair an applier produced is what the catalog peer is handed — through
## `PuzzlePlayFlow.enter()`, asserted on the wire, not from a private field.
func _check_pair_reaches_the_wire() -> void:
	var path := _fixture("wire.json", '{"endpoint": "%s", "api_key": "%s"}' % [ENDPOINT, API_KEY])
	var router := _applied(path)
	FakeCatalogTransport.all_requests.clear()
	var flow := PuzzlePlayFlow.new()
	flow.enter(
		null, router.advice_endpoint, router.advice_api_key, Callable(FakeCatalogTransport, "new")
	)
	_check(
		FakeCatalogTransport.all_requests.size() == 1,
		(
			"R7: a supplied pair starts exactly one catalog read (got %d)"
			% [FakeCatalogTransport.all_requests.size()]
		)
	)
	if FakeCatalogTransport.all_requests.size() == 1:
		var request: Dictionary = FakeCatalogTransport.all_requests[0]
		_check(
			str(request.get("api_key", "")) == API_KEY,
			"R7: the peer receives exactly T10 on the wire (got '%s')" % request.get("api_key", "")
		)
	_check(
		flow.client != null and flow.client.endpoint == ENDPOINT,
		(
			"R7: the client is configured with exactly T9 (got '%s')"
			% (flow.client.endpoint if flow.client != null else "<no client>")
		)
	)
	router.free()


## R7 / B5: with either value empty the stream refuses for the configuration
## reason (not a wire reason), deals nothing, and keeps GS.playerElo.
func _check_absence_through_the_initialisers() -> void:
	for missing in ["endpoint", "api_key"]:
		var router := SessionRouter.new()
		router.advice_endpoint = "" if missing == "endpoint" else ENDPOINT
		router.advice_api_key = "" if missing == "api_key" else API_KEY
		FakeCatalogTransport.all_requests.clear()
		var flow := PuzzlePlayFlow.new()
		flow.enter(
			null,
			router.advice_endpoint,
			router.advice_api_key,
			Callable(FakeCatalogTransport, "new")
		)
		if flow.stream == null:
			_check(false, "B5: %s empty still opens the stream" % missing)
			router.free()
			continue
		_check(not flow.stream.due, "B5: %s empty deals nothing" % missing)
		_check(
			flow.stream.last_failure == CatalogWireReader.REASON_UNCONFIGURED,
			(
				"B5: %s empty gives REASON_UNCONFIGURED without reaching the wire (got %s)"
				% [missing, flow.stream.last_failure]
			)
		)
		_check(
			FakeCatalogTransport.all_requests.is_empty(),
			"B5: %s empty starts no catalog read" % missing
		)
		_check(
			flow.session != null and flow.session.player_elo == PuzzleSession.ELO_START,
			"B5: %s empty keeps GS.playerElo" % missing
		)
		router.free()


## AC5: the constant names a bare file name, and the tree holds no such file.
func _check_no_committed_value() -> void:
	_check(
		SessionRouter.ADVICE_PARAMETERS_PATH == "advice_parameters.json",
		(
			"AC5: the constant names the bare file name (got '%s')"
			% SessionRouter.ADVICE_PARAMETERS_PATH
		)
	)
	_check(
		not FileAccess.file_exists("res://" + SessionRouter.ADVICE_PARAMETERS_PATH),
		"AC5: advice_parameters.json must not be packed with the game"
	)
	var output: Array = []
	var status := OS.execute("git", ["ls-files", "advice_parameters.json"], output)
	if status == 0:
		_check(
			str(output).strip_edges() == "" or str(output).find("advice_parameters.json") < 0,
			"AC5: git tracks no advice_parameters.json (got %s)" % [output]
		)
