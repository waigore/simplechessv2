class_name CatalogDealTransport
extends RefCounted
## HTTP transport for CTR-puzzle-catalog-read (CMP-puzzle-session R1, C5). One
## POST carries the O1 request (player Elo, recent solved ids, API key) and the
## response is exactly one record or no record. The request runs on a worker
## thread and its outcome is queued; the caller reads it from the session tick,
## so a deal never blocks a frame (G3, ADR-0008 Performance row).
##
## Only byte movement and the client-side deadline live here; what a status or
## body means is CatalogWireReader's job, so those rules are testable without a
## socket. Leaving the stream retires the worker without waiting on it (S4).

## CTR-puzzle-catalog-read O1: the one deal route on the advice server's host.
const PATH := "/catalog/deal"
## Client-side wait bound; a route slower than this is a failed read.
const DEFAULT_CAP_MS := 3000

## Reads retired by `close()` and not yet joined. Each one is held here until a later
## call can join it, so leaving the stream never waits on the host (G3, S4).
static var _retiring: Array = []

## Messages pushed by the worker: {"ok": bool, "record"|"reason": ...}.
var _queue: Array = []
var _thread: Thread
var _cancel_requested := false
var _finished := false


## Start an O1 request. `cap_ms` bounds the client-side wait.
func start(endpoint: String, message: Dictionary, cap_ms: int = DEFAULT_CAP_MS) -> void:
	reap()
	_thread = Thread.new()
	var err := _thread.start(_run.bind(endpoint, message.duplicate(true), cap_ms))
	if err != OK:
		_finished = true
		_queue.append({"ok": false, "reason": CatalogWireReader.REASON_ERROR})


## Take every outcome that arrived since the last poll. A retired read reports nothing,
## even if its worker finished the exchange after the stream was left (S4).
func poll() -> Array:
	if _cancel_requested:
		return []
	if _thread != null and _thread.is_started():
		if _thread.is_alive():
			return _drain()
		_thread.wait_to_finish()
		_thread = null
		_finished = true
	return _drain()


## True once the worker has stopped; the caller may release this object.
func is_finished() -> bool:
	return _finished


## Drop the read (concurrency S4). The worker sees `_cancel_requested` within one poll
## and the outcome it was building is discarded; the join waits for a later call rather
## than this one, so leaving the stream cannot stall on an unresponsive host (G3).
func close() -> void:
	_cancel_requested = true
	_finished = true
	if _thread != null and _thread.is_started():
		# `_thread` stays here: the worker is still running, and dropping the last
		# reference to it would destroy it mid-read. `reap()` releases both later.
		_retiring.append(self)
	reap()


## Join every retired worker that has stopped; returns how many were joined. A worker
## still blocked on an unreachable host stays retired for the next call. Held transports
## carry the only reference to their worker, so this is what lets a retired read go.
static func reap() -> int:
	var joined := 0
	var pending: Array = []
	for item: Variant in _retiring:
		var transport: CatalogDealTransport = item
		if transport._thread == null or not transport._thread.is_alive():
			transport._join()
			joined += 1
			continue
		pending.append(transport)
	_retiring = pending
	return joined


func _join() -> void:
	if _thread != null:
		_thread.wait_to_finish()
	_thread = null


func _drain() -> Array:
	var outcomes := _queue
	_queue = []
	return outcomes


## Worker thread. Never touches scene state: only appends to `_queue`.
func _run(endpoint: String, message: Dictionary, cap_ms: int) -> void:
	if _cancel_requested:
		return
	var client := HTTPClient.new()
	if _connect(client, endpoint) != OK:
		_queue.append({"ok": false, "reason": CatalogWireReader.REASON_ERROR})
		return
	if _cancel_requested:
		client.close()
		return
	if _send(client, message) != OK:
		_queue.append({"ok": false, "reason": CatalogWireReader.REASON_ERROR})
		client.close()
		return
	var outcome := _read(client, cap_ms)
	client.close()
	_queue.append(outcome)


func _connect(client: HTTPClient, endpoint: String) -> Error:
	var tls := endpoint.begins_with("https")
	var host_port := endpoint.trim_prefix("https://").trim_prefix("http://").split("/", true, 1)[0]
	var parts := host_port.split(":")
	var host := str(parts[0])
	var port := int(parts[1]) if parts.size() > 1 else (443 if tls else 80)
	var err := client.connect_to_host(host, port, TLSOptions.client() if tls else null)
	if err != OK:
		push_warning("Catalog endpoint unreachable: %s" % endpoint)
		return err
	while not _cancel_requested:
		err = client.poll()
		if err != OK:
			return err
		match client.get_status():
			HTTPClient.STATUS_CONNECTED:
				return OK
			HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CANT_RESOLVE:
				return ERR_CANT_CONNECT
		OS.delay_msec(5)
	return ERR_BUSY


func _send(client: HTTPClient, message: Dictionary) -> Error:
	var headers := PackedStringArray(["Content-Type: application/json", "Accept: application/json"])
	return client.request(HTTPClient.METHOD_POST, PATH, headers, JSON.stringify(message))


## Poll the response to its body, a real disconnect, or the deadline. A
## non-success status is a failed read whatever its body says.
func _read(client: HTTPClient, cap_ms: int) -> Dictionary:
	var deadline := Time.get_ticks_msec() + cap_ms
	var body := ""
	while not _cancel_requested:
		if Time.get_ticks_msec() >= deadline:
			return {"ok": false, "reason": CatalogWireReader.REASON_TIMEOUT}
		var err := client.poll()
		if err != OK or AdviceWireReader.is_terminal_status(client.get_status()):
			return {"ok": false, "reason": CatalogWireReader.REASON_ERROR}
		var status := client.get_status()
		if status == HTTPClient.STATUS_BODY:
			var chunk := client.read_response_body_chunk()
			if chunk.is_empty():
				break
			body += chunk.get_string_from_utf8()
		OS.delay_msec(5)
	if _cancel_requested:
		return {"ok": false, "reason": CatalogWireReader.REASON_ERROR}
	if client.get_response_code() != HTTPClient.RESPONSE_OK:
		return {"ok": false, "reason": CatalogWireReader.REASON_STATUS}
	return CatalogWireReader.read(body)
