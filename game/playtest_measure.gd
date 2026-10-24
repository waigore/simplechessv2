class_name PlaytestMeasure
extends RefCounted
## SIT.4 / S11 / O10 — frame-time and `EX.loading` capture (#544).
## `CMP-playtest-seams` owns the seam and the gate; this class owns the window, the
## passive frame source, and the report. It reads the same `O3` snapshot as
## `inspect` and never submits input, times the move, or is called by the move path
## (`CTR-playtest-drive` `C2` / `G3`).

const KIND_FRAME_TIMES := "frame_times"
const KIND_LOADING_READY := "loading_ready"
## The report names the judged story, not the router constant (`D1`).
const REPORT_SHARED := "shared-play"
const REPORT_PUZZLE := "puzzle-play"
const STORY_SHARED := "PTU-shared-play"
const STORY_PUZZLE := "PTU-puzzle-play"
const STORY_LOADING := "PTU-mode-pick"

## The O3 snapshot provider, and the passive frame source: empty reads the real
## frame delta, a test pushes a fake sequence so nothing sleeps.
var snapshot_provider: Callable = Callable()
var frame_provider: Callable = Callable()
## Set by the seam so a refused / cancelled report still carries TEL fields.
var tel_sink: Callable = Callable()

var _report: Dictionary = {}
var _armed := false


## Arm the next window for `kind`. It refuses rather than arming on a placeholder,
## and the refusal names the first predicate that failed (`D1`).
func start(kind: String, paused: bool) -> Dictionary:
	if _armed:
		return _refuse(kind, "window open")
	if kind == KIND_FRAME_TIMES:
		return _arm_frame_times(paused)
	if kind == KIND_LOADING_READY:
		return _arm_loading_ready(paused)
	return _refuse(kind, "unknown kind")


## The report for the armed window. It closes and disarms, so one arm measures one
## window and no caller can hand in samples or a `max` (`D2`). An open window that
## never met its close predicate comes back `cancelled` (`D1`).
func report(kind: String) -> Dictionary:
	if not _armed:
		return _refuse(kind, "no window")
	var closed := _close("ok" if str(_report.get("kind", "")) == kind else "cancelled")
	_armed = false
	_report = closed.duplicate(true)
	_emit_end(closed)
	return closed


## Closes an open window as `cancelled`, keeping the samples seen but claiming no
## `max_ms` (`D1`).
func disarm() -> Dictionary:
	if not _armed:
		return _refuse("", "no window")
	var closed := _close("cancelled")
	_armed = false
	_report = closed.duplicate(true)
	_emit_end(closed)
	return closed


func last() -> Dictionary:
	return _report.duplicate(true)


## `D3` — a release build has no `O10`: the same always-shaped refusal, no samples.
func refuse_release(kind: String, remember: bool = false) -> Dictionary:
	var refusal := _refuse(kind, "release")
	if remember:
		_report = refusal.duplicate(true)
		_armed = false
	return refusal


func is_armed() -> bool:
	return _armed


## One passive frame for an open window. A snapshot that has not met the window's
## close predicate leaves it open; nothing is invented across a different window.
func observe() -> void:
	if not _armed:
		return
	(_report["samples"] as Array).append(_frame_ms())
	_report["sample_count"] = (_report["samples"] as Array).size()
	if _closes(_report, _snapshot()):
		report(str(_report["kind"]))


## `D1` — one close predicate per mode, each reading a field that exists *after*
## the move. Shared play needs the occupancy moved *and* the side flipped, so a
## select/deselect or a later reply cannot close it. Puzzle play closes on the
## `sequence_index` advance alone: an even-length sequence advances it by two and
## leaves the armed side to move, and a refused move advances nothing.
func _closes(open_report: Dictionary, snap: Dictionary) -> bool:
	var armed: Dictionary = open_report.get("armed", {})
	if str(open_report.get("kind", "")) == KIND_LOADING_READY:
		return str(snap.get("stage", "")) == "mode-pick"
	if str(open_report.get("mode", "")) == REPORT_SHARED:
		var now: Variant = snap.get("position")
		var before: Variant = armed.get("position")
		if not (now is Dictionary) or not (before is Dictionary):
			return false
		return (
			(now["occupancy"] != before["occupancy"])
			and (str(now.get("side_to_move", "")) != str(before.get("side_to_move", "")))
		)
	if str(open_report.get("mode", "")) == REPORT_PUZZLE:
		if not snap.has("sequence_index"):
			return false
		return int(snap["sequence_index"]) != int(armed.get("sequence_index", 0))
	return false


func _arm_frame_times(paused: bool) -> Dictionary:
	var snap := _snapshot()
	var mode := str(snap.get("mode", ""))
	var report_mode := ""
	var missing := ""
	if mode == "shared":
		report_mode = REPORT_SHARED
		missing = _first_missing(snap, ["position"])
		if missing.is_empty() and str(snap.get("stage", "")) != "shared-play":
			missing = "stage"
	elif mode == "puzzle":
		report_mode = REPORT_PUZZLE
		missing = _first_missing(snap, ["position", "sequence_index", "puzzle_id"])
		if missing.is_empty() and str(snap.get("stage", "")) != "puzzle-play":
			missing = "stage"
		if missing.is_empty() and str(snap.get("puzzle_id", "none")) == "none":
			missing = "puzzle_id"
	else:
		missing = "mode"
	if missing.is_empty() and paused:
		missing = "paused"
	if not missing.is_empty():
		return _refuse(KIND_FRAME_TIMES, missing)
	var empty := _blank(KIND_FRAME_TIMES, "ok", "")
	empty["mode"] = report_mode
	empty["solver"] = str((snap["position"] as Dictionary).get("side_to_move", ""))
	_arm(empty, snap, report_mode)
	return empty


func _arm_loading_ready(paused: bool) -> Dictionary:
	var snap := _snapshot()
	if str(snap.get("stage", "")) != "loading":
		return _refuse(KIND_LOADING_READY, "stage")
	if paused:
		return _refuse(KIND_LOADING_READY, "paused")
	var empty := _blank(KIND_LOADING_READY, "ok", "")
	_arm(empty, snap, "")
	return empty


## The armed snapshot is the window's origin and never reaches a report.
func _arm(open_report: Dictionary, snap: Dictionary, report_mode: String) -> void:
	open_report["armed"] = snap.duplicate(true)
	open_report["events"] = {"start": _emit_start(report_mode), "end": {}}
	_report = open_report
	_armed = true


func _close(status: String) -> Dictionary:
	var closed := _report.duplicate(true)
	closed.erase("armed")
	closed["status"] = status
	var samples: Array = closed.get("samples", [])
	## An unclosed window keeps what it sampled but claims no maximum (`D1`).
	var top := 0.0
	if status == "ok":
		for sample in samples:
			top = maxf(top, float(sample))
	closed["max_ms"] = top
	closed["sample_count"] = samples.size()
	_report = closed
	if status != "ok" and str(closed.get("detail", "")).is_empty():
		closed["detail"] = "window did not close"
	return closed


func _frame_ms() -> float:
	return float(frame_provider.call()) if frame_provider.is_valid() else 0.0


func _snapshot() -> Dictionary:
	return snapshot_provider.call() if snapshot_provider.is_valid() else {}


func _refuse(kind: String, detail: String) -> Dictionary:
	return _blank(kind, "refused", detail)


## `D2` — every report has this shape, refused and cancelled included. Device,
## browser, build id and repeat count are recorded beside it, never here.
func _blank(kind: String, status: String, detail: String) -> Dictionary:
	return {
		"kind": kind,
		"mode": "",
		"status": status,
		"solver": "",
		"samples": [],
		"sample_count": 0,
		"max_ms": 0.0,
		"events": {"start": {}, "end": {}},
		"detail": detail,
	}


func _first_missing(snap: Dictionary, keys: Array) -> String:
	for key in keys:
		if not snap.has(key):
			return str(key)
	return ""


func _emit_start(report_mode: String) -> Dictionary:
	return _emit("measure.start", "pass", report_mode)


func _emit_end(closed: Dictionary) -> void:
	_report["events"]["end"] = _emit(
		"measure.end", _outcome(str(closed["status"])), str(closed["mode"])
	)


## `TEL.4` is the judged story; `TEL.5` stays pass / fail, not the report's status.
func _emit(event_name: String, outcome: String, report_mode: String) -> Dictionary:
	var story := STORY_LOADING
	if report_mode == REPORT_SHARED:
		story = STORY_SHARED
	elif report_mode == REPORT_PUZZLE:
		story = STORY_PUZZLE
	if not tel_sink.is_valid():
		return {}
	return tel_sink.call(event_name, outcome, story)


func _outcome(status: String) -> String:
	return "pass" if status == "ok" else "fail"
