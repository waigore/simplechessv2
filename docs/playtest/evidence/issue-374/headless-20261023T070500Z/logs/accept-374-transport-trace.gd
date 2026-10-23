extends SceneTree
## Root-cause trace for the #374 acceptance failure (no scene, no session).
##
## 1. `AdviceStreamTransport` (the shipped client transport) is started against
##    a reachable simulated peer and against the real #373 backend.
## 2. The HTTP statuses the transport compares are printed, so Godot 4.7.2's
##    real enum values are visible next to the comparison it makes.

var _fails: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var peer := OS.get_environment("ACCEPT_PEER")
	var real := OS.get_environment("ACCEPT_PEER_REAL")
	var key := OS.get_environment("ACCEPT_KEY")
	print("TRACE enum STATUS_DISCONNECTED=", HTTPClient.STATUS_DISCONNECTED,
		" STATUS_CONNECTED=", HTTPClient.STATUS_CONNECTED,
		" STATUS_REQUESTING=", HTTPClient.STATUS_REQUESTING,
		" STATUS_BODY=", HTTPClient.STATUS_BODY,
		" STATUS_CONNECTION_ERROR=", HTTPClient.STATUS_CONNECTION_ERROR)
	print("TRACE advice_stream_transport.gd: `status >= HTTPClient.STATUS_DISCONNECTED` is",
		" always true, because STATUS_DISCONNECTED is the lowest value")

	for endpoint in [peer, real]:
		if endpoint.is_empty():
			continue
		print("TRACE === AdviceStreamTransport -> ", endpoint)
		var transport := AdviceStreamTransport.new()
		var started := Time.get_ticks_msec()
		transport.start(endpoint, {"api_key": key, "fen":
			"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "time_ms": 2000}, 2000)
		var updates := 0
		var ended := ""
		var first := ""
		while Time.get_ticks_msec() - started < 2500:
			for message in transport.poll():
				var entry: Dictionary = message
				if str(entry.get("kind", "")) == "update":
					updates += 1
					if updates == 1:
						first = JSON.stringify(entry)
				else:
					ended = str((entry.get("value", {}) as Dictionary).get("reason", ""))
			if transport.is_finished():
				break
			OS.delay_msec(5)
		print("TRACE finished=", transport.is_finished(), " ms=", Time.get_ticks_msec() - started,
			" updates=", updates, " ended=", ended)
		print("TRACE first_message=", first)
		if updates == 0:
			print("TRACE FAIL: a reachable endpoint yielded no update; ended '", ended, "'")
			_fails.append(endpoint)
		transport.close()

	var probe_endpoint: String = real if not real.is_empty() else peer
	print("TRACE === HTTP statuses seen by the mirrored exchange -> ", probe_endpoint)
	var parts: PackedStringArray = probe_endpoint.trim_prefix("http://").split("/", true, 1)
	var host_port: PackedStringArray = str(parts[0]).split(":")
	var client := HTTPClient.new()
	var err := client.connect_to_host(str(host_port[0]), int(host_port[1]))
	while err == OK and client.get_status() != HTTPClient.STATUS_CONNECTED:
		err = client.poll()
		OS.delay_msec(5)
	var path: String = "/" + str(parts[1])
	err = client.request(HTTPClient.METHOD_POST, path,
		PackedStringArray(["Content-Type: application/json", "Accept: application/x-ndjson"]),
		JSON.stringify({"api_key": key, "fen":
			"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "time_ms": 2000}))
	print("TRACE request err=", err, " status_after_request=", client.get_status())
	var started2 := Time.get_ticks_msec()
	var seen := 0
	var printed := 0
	while Time.get_ticks_msec() - started2 < 900:
		err = client.poll()
		var status := client.get_status()
		var judged := "BODY" if status == HTTPClient.STATUS_BODY else (
			"closed-by-transport" if status >= HTTPClient.STATUS_DISCONNECTED else "streaming")
		if printed < 4 or status != HTTPClient.STATUS_BODY:
			print("TRACE t=", Time.get_ticks_msec() - started2, " poll=", err, " status=", status,
				" transport-judgement=", judged)
			printed += 1
		if status == HTTPClient.STATUS_BODY:
			seen += client.read_response_body_chunk().size()
		OS.delay_msec(40)
	client.close()
	print("TRACE body_bytes_observed=", seen)
	if _fails.is_empty():
		print("TRACE PASS")
		quit(0)
	else:
		print("TRACE FAIL endpoints=", _fails)
		quit(1)
