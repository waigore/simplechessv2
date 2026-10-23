class_name FakeCatalogTransport
extends RefCounted
## Simulated catalog-service peer for headless tests (ADR-0013 Testability). It
## offers the surface CatalogDealClient uses from CatalogDealTransport —
## `start`, `poll`, `is_finished`, `close` — records the O1 it was given, and
## lets a test deliver the one-record body or a failed read by hand. No network.
##
## It deliberately does not extend the real transport: the coverage build gives
## every main script the same private constant, so a main script that subclasses
## another one inherits a duplicate member.

## Every O1 any peer received: one run's request log.
static var all_requests: Array = []

## Every O1 request this peer received, in order.
var requests: Array = []
## The endpoint the client aimed at.
var endpoint := ""
## When true the peer never answers: the session tick must not wait on it.
var blocking := false
## Closed by the client before answering.
var closed := false

var _outcomes: Array = []
## Finished once an answer was pushed or the read was closed; a peer that has
## not answered yet is still in flight.
var _finished := false


func _init(outcome: Dictionary = {}) -> void:
	if not outcome.is_empty():
		_outcomes.append(outcome)
		_finished = true


func start(url: String, message: Dictionary, _cap_ms: int) -> void:
	endpoint = url
	requests.append(message.duplicate(true))
	all_requests.append(message.duplicate(true))


func poll() -> Array:
	if blocking:
		return []
	var outcomes := _outcomes
	_outcomes = []
	return outcomes


## True once an outcome is ready (never while blocking).
func is_finished() -> bool:
	return _finished or closed


func close() -> void:
	closed = true
	_outcomes = []


## Deliver the O1 success body: one `SCH-puzzle-catalog` record.
func push_record(record: Dictionary) -> void:
	_outcomes.append({"ok": true, "record": record})
	_finished = true


## Deliver a failed read (X2): a transport error, a refusal, or a bad body.
func push_failure(reason: String = CatalogWireReader.REASON_STATUS) -> void:
	_outcomes.append({"ok": false, "reason": reason})
	_finished = true
