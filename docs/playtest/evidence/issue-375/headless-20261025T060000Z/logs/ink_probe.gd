extends SceneTree
## #375 AC4 — PER.R5 ink coverage of the advice marks on the SHIPPED release
## scene graph.
##
## Loads `res://main_release.tscn`, enters Shared play through the real
## Presentation controls, renders every piece type on the from square in turn,
## and measures what the compositor actually paints: the pixels the advice marks
## add on top of the same position without advice, counted against that piece's
## opaque body (the silhouette pixels), the comparison PER.R1 / PER.R5 make. No
## seam, no simulated peer, no Stockfish.
##
## Run from the repo root:
##   xvfb-run -a godot --path game -s ../docs/playtest/evidence/issue-375/graphical-20261024T033000Z/logs/ink_probe.gd
## Talk on stdout as `R375-INK {...}` JSON lines. Exit code is the failed checks.

const RELEASE_SCENE := "res://main_release.tscn"
const FROM_SQUARE := "e4"
const TO_SQUARE := "e2"
## PER.R5 — marks and arrow together cover ≤ 10% of any body.
const BODY_BOUND := 0.10
const PIECES := [
	["white", "pawn"],
	["white", "knight"],
	["white", "bishop"],
	["white", "rook"],
	["white", "queen"],
	["white", "king"],
	["black", "pawn"],
	["black", "knight"],
	["black", "bishop"],
	["black", "rook"],
	["black", "queen"],
	["black", "king"],
]

var _checks := 0
var _failures := 0
var _worst := 0.0


func _initialize() -> void:
	_run.call_deferred()


func _check(name: String, ok: bool, detail: String = "") -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("R375-INK ", JSON.stringify({"check": name, "ok": ok, "detail": detail}))


func _run() -> void:
	_check("scene_is_release", ResourceLoader.exists(RELEASE_SCENE), RELEASE_SCENE)
	var root: Node = (load(RELEASE_SCENE) as PackedScene).instantiate()
	get_root().add_child(root)
	await _frames(3)
	var router := root.get_node_or_null("SessionRouter") as SessionRouter
	var presentation := root.get_node_or_null("Presentation") as Presentation
	if presentation == null and root is Presentation:
		presentation = root as Presentation
	_check("router_present", router != null)
	_check("presentation_present", presentation != null)
	if router == null or presentation == null:
		await _finish()
		return
	# Advice Off: the marks this probe renders are the only ink it adds.
	router.advice_on = false
	presentation.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	presentation.control_activate.emit("shared-setup", "C5")
	await _frames(3)
	_check("play_reached", router.stage == SessionRouter.STAGE_SHARED_PLAY, router.stage)
	var board := _find_board(root)
	_check("board_present", board != null)
	if board == null:
		await _finish()
		return

	var empty := await _capture(board, {}, false)
	for entry in PIECES:
		var color := str(entry[0])
		var kind := str(entry[1])
		var one := {FROM_SQUARE: {"color": color, "kind": kind}}
		var plain := await _capture(board, one, false)
		var inked := await _capture(board, one, true)
		board.render_advice(null)
		await _frames(1)
		var m := _measure(plain, inked, empty)
		var coverage := float(m["coverage"])
		_worst = maxf(_worst, coverage)
		print(
			"R375-INK ",
			JSON.stringify(
				{
					"piece": "%s|%s" % [color, kind],
					"ink_px": m["ink"],
					"body_px": m["body"],
					"ink_on_body_px": m["overlap"],
					"coverage": coverage
				}
			)
		)
		_check(
			"per_r5_%s_%s" % [color, kind],
			coverage <= BODY_BOUND and int(m["body"]) > 0,
			(
				"body=%d ink=%d on_body=%d coverage=%.2f%%"
				% [m["body"], m["ink"], m["overlap"], coverage * 100.0]
			)
		)
	print("R375-INK ", JSON.stringify({"worst_coverage": _worst}))
	await _finish()


## Render one position with or without advice and read the frame back.
## `render_advice` follows `render_position`: the presentation re-applies the
## advice fields when it renders a position (E4), so the marks must come last.
func _capture(board: BoardPresentation, occupancy: Dictionary, with_advice: bool) -> Image:
	board.render_position({"occupancy": occupancy})
	board.render_advice({"from": FROM_SQUARE, "to": TO_SQUARE} if with_advice else null)
	await _frames(2)
	await RenderingServer.frame_post_draw
	return get_root().get_texture().get_image()


func _measure(plain: Image, inked: Image, empty: Image) -> Dictionary:
	var ink := 0
	var body := 0
	var overlap := 0
	for y in plain.get_height():
		for x in plain.get_width():
			var p := plain.get_pixel(x, y)
			var is_ink := _diff(p, inked.get_pixel(x, y))
			var is_body := _diff(p, empty.get_pixel(x, y))
			if is_ink:
				ink += 1
			if is_body:
				body += 1
			if is_ink and is_body:
				overlap += 1
	return {
		"ink": ink,
		"body": body,
		"overlap": overlap,
		"coverage": 0.0 if body == 0 else float(overlap) / float(body),
	}


func _diff(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) > 0.02 or absf(a.g - b.g) > 0.02 or absf(a.b - b.b) > 0.02


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


func _find_board(root: Node) -> BoardPresentation:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is BoardPresentation:
			return node as BoardPresentation
		for child in node.get_children():
			stack.append(child)
	return null


func _finish() -> void:
	print("R375-INK ", JSON.stringify({"summary": {"checks": _checks, "failed": _failures}}))
	quit(_failures)
