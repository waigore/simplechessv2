class_name CatalogDealClient
extends RefCounted
## CMP-puzzle-session's catalog-service peer (C5). Owns one deal read behind
## CTR-puzzle-catalog-read: sends the O1 request, validates the one record the
## server returns (SCH-puzzle-catalog F1–F13), and reports either that record
## or a failed read. It never selects a puzzle (G2), never downloads a catalog
## (G1), and never runs on the move path (G3).

## Configured endpoint (`T9`) and API key (`T10`); empty when unset.
var endpoint := ""
var api_key := ""
## Client-side wait bound for one deal.
var cap_ms := CatalogDealTransport.DEFAULT_CAP_MS

## A simulated peer for headless tests / playtests. When set it replaces the
## network transport; the shipped export never sets it, so production stays on
## CatalogDealTransport.
var sim_factory: Variant = null
var _transport_factory: Callable
## CatalogDealTransport, or a stand-in with the same four calls (tests).
var _transport: Variant
var _request_id := 0


func _init(transport_factory: Callable = Callable()) -> void:
	_transport_factory = (
		transport_factory if transport_factory.is_valid() else Callable(CatalogDealTransport, "new")
	)


## Apply B5: `T9` and `T10` are required; a missing one fails every deal.
func configure(p_endpoint: String, p_api_key: String) -> void:
	endpoint = p_endpoint.strip_edges()
	api_key = p_api_key


func is_available() -> bool:
	return not endpoint.is_empty() and not api_key.is_empty()


## True while a deal read is in flight; a second request waits for this one.
func in_flight() -> bool:
	return _transport != null


## O1 — ask for one puzzle for `player_elo` / `recent_solved`. Returns false when
## the read could not even start (B5, one deal at a time, G6).
func request(player_elo: float, recent_solved: Array) -> bool:
	if _transport != null or not is_available():
		return false
	var message := {
		"api_key": api_key,
		"player_elo": player_elo,
		"recent_solved": _recent_ids(recent_solved),
	}
	_transport = _make_transport()
	_request_id += 1
	_transport.start(endpoint, message, cap_ms)
	return true


## Read the in-flight outcome, if any: `{}` while the read is still running,
## otherwise `{ok: true, record}` or `{ok: false, reason}` (X2). A read only ends
## once the peer finished, so a peer that has not answered yet ends nothing; a
## peer that finished without a record is a failed read.
func poll() -> Dictionary:
	if _transport == null:
		return {}
	var keep_request := _request_id
	var messages: Array = _transport.poll()
	var finished: bool = _transport.is_finished()
	if keep_request != _request_id or not finished:
		return {}
	_transport = null
	if not messages.is_empty():
		return messages[0]
	return {"ok": false, "reason": CatalogWireReader.REASON_ERROR}


## Drop an in-flight read: its outcome never deals.
func cancel() -> void:
	_request_id += 1
	if _transport != null:
		_transport.close()
		_transport = null


## G6 — at most `CFG.ELO_RECENT_WINDOW` ids, newest last, as strings.
func _recent_ids(recent_solved: Array) -> Array:
	var ids: Array = []
	for item in recent_solved:
		ids.append(str(item))
	if ids.size() > PuzzleSession.ELO_RECENT_WINDOW:
		ids = ids.slice(ids.size() - PuzzleSession.ELO_RECENT_WINDOW, ids.size())
	return ids


func _make_transport() -> Variant:
	if sim_factory != null:
		return sim_factory.call()
	return _transport_factory.call()
