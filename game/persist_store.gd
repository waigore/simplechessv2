class_name PersistStore
extends Node
## CMP-persist-store: SCH-persist-doc via CTR-persist-document (ADR-0003).

signal write_failed

const STORAGE_KEY := "simplechessv2.persist.v1"
const VERSION := 1
const ELO_START := 1000
const MODE_NONE := "none"
const MODE_SHARED := "shared"
const MODE_PUZZLE := "puzzle"
const MAX_RECENT := 20

## When true, the next commit fails without mutating storage (tests / forced fail).
var force_write_failure := false

## In-memory map for headless/editor and injectable test doubles. Web uses localStorage.
var memory_backend: Dictionary = {}

var _committed: Dictionary = {}


func _ready() -> void:
	_committed = defaults()


func defaults() -> Dictionary:
	return {
		"version": VERSION,
		"player_elo": float(ELO_START),
		"last_mode": MODE_NONE,
		"recent_solved": [],
	}


## CTR-persist-document.O1 — load or defaults (FAIL.T3).
func load_document() -> Dictionary:
	var raw := _backend_get()
	if raw.is_empty():
		_committed = defaults()
		return _committed.duplicate(true)
	var parsed: Variant = JSON.parse_string(raw)
	if parsed == null or not (parsed is Dictionary):
		push_warning("PersistStore: corrupt document; using defaults")
		_committed = defaults()
		return _committed.duplicate(true)
	_committed = _normalize(parsed as Dictionary)
	return _committed.duplicate(true)


## CTR-persist-document.O2 — whole-document replace; false leaves prior intact (G2).
func commit(document: Dictionary) -> bool:
	var normalized := _normalize(document)
	if force_write_failure:
		force_write_failure = false
		push_error("PersistStore: forced write failure")
		write_failed.emit()
		return false
	var payload := JSON.stringify(normalized)
	if not _backend_set(payload):
		push_error("PersistStore: write failed; prior commit kept")
		write_failed.emit()
		return false
	_committed = normalized
	return true


## CTR-persist-document.O3 — last successful document without I/O.
func read_committed() -> Dictionary:
	return _committed.duplicate(true)


func clear_storage() -> void:
	_backend_clear()
	_committed = defaults()


func commit_last_mode(mode: String) -> bool:
	var doc := read_committed()
	doc["last_mode"] = _normalize_mode(mode)
	return commit(doc)


func _normalize(data: Dictionary) -> Dictionary:
	var out := defaults()
	if data.has("version"):
		out["version"] = int(data["version"])
	else:
		out["version"] = VERSION
	if data.has("player_elo"):
		out["player_elo"] = float(data["player_elo"])
	if data.has("last_mode"):
		out["last_mode"] = _normalize_mode(str(data["last_mode"]))
	if data.has("recent_solved"):
		out["recent_solved"] = _normalize_recent(data["recent_solved"])
	return out


func _normalize_mode(mode: String) -> String:
	match mode:
		MODE_SHARED, "Shared game":
			return MODE_SHARED
		MODE_PUZZLE, "Puzzle stream":
			return MODE_PUZZLE
		_:
			return MODE_NONE


func _normalize_recent(value: Variant) -> Array:
	var out: Array = []
	if value is Array:
		for item in value:
			out.append(str(item))
	if out.size() > MAX_RECENT:
		out = out.slice(out.size() - MAX_RECENT, out.size())
	return out


func _backend_get() -> String:
	if OS.has_feature("web"):
		return _web_get()
	return str(memory_backend.get(STORAGE_KEY, ""))


func _backend_set(payload: String) -> bool:
	if OS.has_feature("web"):
		return _web_set(payload)
	memory_backend[STORAGE_KEY] = payload
	return true


func _backend_clear() -> void:
	memory_backend.erase(STORAGE_KEY)
	if OS.has_feature("web"):
		_web_clear()


func _web_get() -> String:
	var storage := JavaScriptBridge.get_interface("localStorage")
	if storage == null:
		push_warning("PersistStore: localStorage unavailable")
		return ""
	var value: Variant = storage.getItem(STORAGE_KEY)
	if value == null:
		return ""
	return str(value)


func _web_set(payload: String) -> bool:
	var storage := JavaScriptBridge.get_interface("localStorage")
	if storage == null:
		return false
	# setItem may throw on quota; Godot surfaces that as a failed call / error.
	storage.setItem(STORAGE_KEY, payload)
	var roundtrip: Variant = storage.getItem(STORAGE_KEY)
	if roundtrip == null or str(roundtrip) != payload:
		return false
	return true


func _web_clear() -> void:
	var storage := JavaScriptBridge.get_interface("localStorage")
	if storage == null:
		return
	storage.removeItem(STORAGE_KEY)
