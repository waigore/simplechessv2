class_name AdviceStreamTransport
extends RefCounted
## HTTP transport for CTR-advice-stream (CMP-advice-client R1, R6). One POST per
## O1 opens an NDJSON stream of E1 updates closed by one E2 end. The request runs
## on a worker thread and its messages are queued; the caller reads them from the
## main thread, so U3 advice I/O never blocks U1/U2 (concurrency.md S1).
##
## Only byte movement lives here; what each status or chunk means is
## AdviceWireReader's job, so those rules are testable without a socket.

## Reason reported when the worker fails before the reader names one.
const END_ERROR := "error"

## Messages pushed by the worker: {"kind": "update"|"end", "value": Dictionary}.
var _queue: Array = []
var _thread: Thread
var _cancel_requested := false
var _finished := false


## Start an O1 request. The message carries the wire fields CTR-advice-stream
## names (`api_key`, `fen`, `time_ms`); `cap_ms` bounds the client-side wait.
func start(endpoint: String, message: Dictionary, cap_ms: int) -> void:
	_thread = Thread.new()
	var err := _thread.start(_run.bind(endpoint, message.duplicate(true), cap_ms))
	if err != OK:
		_finished = true
		_enqueue_end(END_ERROR)


## O2: ask the worker to stop. Safe to call from the main thread at any time.
func cancel() -> void:
	_cancel_requested = true


## Take every message that arrived since the last poll.
func poll() -> Array:
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


## Join the worker so a cancelled stream leaves no thread behind.
func close() -> void:
	_cancel_requested = true
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()
	_thread = null
	_finished = true


func _drain() -> Array:
	var messages := _queue
	_queue = []
	return messages


func _enqueue(kind: String, value: Dictionary) -> void:
	_queue.append({"kind": kind, "value": value})


func _enqueue_end(reason: String) -> void:
	_enqueue("end", {"reason": reason})


## Worker thread. Never touches scene state: only appends to `_queue`.
func _run(endpoint: String, message: Dictionary, cap_ms: int) -> void:
	var client := HTTPClient.new()
	var err := _connect(client, endpoint)
	if err != OK:
		if not _cancel_requested:
			_enqueue_end(END_ERROR)
		return
	if _cancel_requested:
		client.close()
		return
	if _send(client, endpoint, message) != OK:
		_enqueue_end(END_ERROR)
		return
	_read_stream(client, cap_ms)
	client.close()


func _connect(client: HTTPClient, endpoint: String) -> Error:
	var tls := endpoint.begins_with("https")
	var host_port := endpoint.trim_prefix("https://").trim_prefix("http://").split("/", true, 1)[0]
	var parts := host_port.split(":")
	var host := str(parts[0])
	var port := int(parts[1]) if parts.size() > 1 else (443 if tls else 80)
	var err := client.connect_to_host(host, port, TLSOptions.client() if tls else null)
	if err != OK:
		push_warning("Advice endpoint unreachable: %s" % endpoint)
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


func _send(client: HTTPClient, endpoint: String, message: Dictionary) -> Error:
	var url := endpoint.trim_prefix("https://").trim_prefix("http://")
	var path := "/" + url.split("/", true, 1)[1] if url.contains("/") else "/"
	var headers := PackedStringArray(
		["Content-Type: application/json", "Accept: application/x-ndjson"]
	)
	return client.request(HTTPClient.METHOD_POST, path, headers, JSON.stringify(message))


## Poll the response until E2, a disconnect, a cancel, or the client deadline.
## STATUS_CONNECTED / STATUS_REQUESTING / STATUS_BODY just mean the exchange is in
## flight, so only a real disconnect ends an unterminated stream (FAIL.T1).
func _read_stream(client: HTTPClient, cap_ms: int) -> void:
	var reader := AdviceWireReader.new()
	var deadline := Time.get_ticks_msec() + cap_ms
	while reader.is_open() and not _cancel_requested:
		var timed_out := Time.get_ticks_msec() >= deadline
		if reader.step(client.poll(), false, timed_out):
			if timed_out:
				client.close()
			break
		var status := client.get_status()
		if status == HTTPClient.STATUS_BODY:
			var chunk := client.read_response_body_chunk()
			if not chunk.is_empty():
				# E1 is a stream tick (CTR-advice-stream E1): hand each update to
				# the main thread as it arrives, so marks appear while the search
				# is still running instead of all at once when it ends (S1).
				_drain_updates(reader, chunk)
		elif AdviceWireReader.is_terminal_status(status):
			reader.closed([])
			break
		OS.delay_msec(5)
	if reader.is_open() and _cancel_requested:
		reader.cancelled()
	_enqueue_end(reader.ended)


## Feed one chunk and push every update it completed to the queue immediately.
func _drain_updates(reader: AdviceWireReader, chunk: PackedByteArray) -> void:
	var arrived: Array = []
	reader.feed(chunk, arrived)
	for update in arrived:
		_enqueue("update", update)
