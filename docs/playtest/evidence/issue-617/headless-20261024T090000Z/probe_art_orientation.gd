extends SceneTree
## Acceptance probe for #617 (headless, ENV.1).
##
## Loads the catalogued piece art through the shipped AssetResolver, builds the
## real BoardPresentation scene (subclass instances do not get `_ready`, so the
## probe hosts them in a Control and lays the camera out itself), and reports per
## seat:
##   - the sprite's local scale (art space, #617 fix site),
##   - the composed global basis determinant and rotation (seat space),
##   - where the art's own top edge lands on screen (a square block), which is
##     the only thing a corner can report without an asymmetric marker.
## It also prints, for every catalogued piece PNG, which row carries the widest
## ink run: a base-up sprite has its widest row near the bottom of the image, a
## base-down sprite near the top, and Godot draws image row 0 at the sprite's
## local top. That is the check the corner placement cannot make.
## Finally it drives the PlaytestSeams telemetry path and verifies TEL.1-TEL.5.

const BOARD_SCRIPT := preload("res://board_presentation.gd")
const RESOLVER_SCRIPT := preload("res://asset_resolver.gd")

var _lines: PackedStringArray = PackedStringArray()
var _fails := 0
var _pending := true
var _code := 0


func _process(_delta: float) -> bool:
	if _pending:
		_pending = false
		_code = _run()
		var out := OS.get_environment("PROBE_LOG")
		if not out.is_empty():
			var f := FileAccess.open(out, FileAccess.WRITE)
			if f != null:
				f.store_string("\n".join(_lines) + "\n")
				f.close()
		quit(_code)
	return false


func say(line: String) -> void:
	_lines.append(line)
	print(line)


func fail(line: String) -> void:
	_fails += 1
	say("FAIL " + line)


func _run() -> int:
	say("engine=%s" % str(Engine.get_version_info().get("string", "")))
	say("build=origin/main@%s" % OS.get_environment("BUILD_SHA"))
	say("session_id=probe-617-%d" % int(Time.get_unix_time_from_system()))

	var resolver = RESOLVER_SCRIPT.new()
	resolver._read_manifest_file()
	var ids: Array = []
	for key in BOARD_SCRIPT.PIECE_IDS.keys():
		ids.append(BOARD_SCRIPT.PIECE_IDS[key])
	ids.append(BOARD_SCRIPT.BOARD_BG_ID)
	var loaded := {}
	var missing: PackedStringArray = PackedStringArray()
	for id in ids:
		var res: Variant = resolver.resolve(str(id))
		if res is Texture2D:
			loaded[str(id)] = res
		else:
			missing.append(str(id))
	say("catalog_textures_loaded=%d/%d" % [loaded.size(), ids.size()])
	for id in missing:
		fail("missing catalog texture %s" % id)

	var board = BOARD_SCRIPT.new()
	var host := Control.new()
	host.size = Vector2(720, 1280)
	root.add_child(host)
	host.add_child(board)
	board._layout_camera()
	board.provide_assets(loaded)

	for seat in ["bottom", "top"]:
		_seat(board, seat)

	_art_skew(loaded)
	_moves()
	say("RESULT fails=%d %s" % [_fails, "PASS" if _fails == 0 else "FAIL"])
	return 0 if _fails == 0 else 1


func _occupancy() -> Dictionary:
	var occ := {}
	var back := ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
	for f in range(8):
		var file := String.chr("a".unicode_at(0) + f)
		occ["%s1" % file] = {"color": "white", "kind": back[f]}
		occ["%s2" % file] = {"color": "white", "kind": "pawn"}
		occ["%s7" % file] = {"color": "black", "kind": "pawn"}
		occ["%s8" % file] = {"color": "black", "kind": back[f]}
	return occ


func _seat(board, seat: String) -> void:
	board.render_position(
		{"occupancy": _occupancy()}, "", PackedStringArray(), {"white_seat": seat}
	)
	var n := 0
	for square in ["e1", "e8", "a1", "h8", "d1", "d8"]:
		var piece: Node2D = board.find_child("piece_%s" % square, true, false) as Node2D
		if piece == null:
			fail("%s piece_%s missing" % [seat, square])
			continue
		var sprite: Sprite2D = piece.get_node_or_null("Sprite") as Sprite2D
		if sprite == null or sprite.texture == null:
			fail("%s piece_%s sprite texture missing" % [seat, square])
			continue
		var xf := sprite.get_global_transform()
		var det := xf.x.x * xf.y.y - xf.y.x * xf.x.y
		var rot := snappedf(xf.get_rotation(), 0.0001)
		# Godot textures draw with local +y downward; the art's top row is at local y = -1.
		var top: Vector2 = xf * Vector2(0.0, -1.0)
		var origin := xf.origin
		var corner := "%s-%s" % [
			("left" if top.x < origin.x else "right"),
			("above" if top.y < origin.y else "below"),
		]
		var verdict := true
		if sprite.scale.x <= 0.0 or sprite.scale.y >= 0.0:
			verdict = false
			fail("%s piece_%s art space is not (+,−)" % [seat, square])
		if det <= 0.0:
			verdict = false
			fail("%s piece_%s global determinant is not positive" % [seat, square])
		if seat == "bottom" and absf(rot) > 0.001:
			verdict = false
			fail("%s piece_%s is rotated (CAM-board.M2 wants 0)" % [seat, square])
		if seat == "top" and absf(absf(rot) - PI) > 0.001:
			verdict = false
			fail("%s piece_%s is not rotated 180° (CAM-board.M2)" % [seat, square])
		var want := "left-above" if seat == "bottom" else "right-below"
		if corner != want:
			verdict = false
			fail("%s piece_%s art top lands %s, want %s" % [seat, square, corner, want])
		say(
			(
				"%s %s local_scale=(%.5f,%.5f) global_det=%+.3f global_rot=%.4f art_top_corner=%s %s"
				% [
					seat,
					square,
					sprite.scale.x,
					sprite.scale.y,
					det,
					rot,
					corner,
					("PASS" if verdict else "FAIL"),
				]
			)
		)
		n += 1
	say("%s pieces_checked=%d" % [seat, n])


## Which way the catalogued art itself points. A base-up sprite has its widest
## ink row in the lower half of the image; on screen (with the #617 fix) that row
## must land below the sprite centre at seat Bottom.
func _art_skew(loaded: Dictionary) -> void:
	for key in BOARD_SCRIPT.PIECE_IDS.keys():
		var tex: Texture2D = loaded.get(str(BOARD_SCRIPT.PIECE_IDS[key]), null) as Texture2D
		if tex == null:
			continue
		var img := tex.get_image()
		if img == null:
			continue
		var w := img.get_width()
		var h := img.get_height()
		var best_row := -1
		var best_run := -1
		var mid_run := 0
		for y in range(0, h):
			var run := 0
			for x in range(0, w, 2):
				if img.get_pixel(x, y).a > 0.5:
					run += 1
			if absi(y - h / 2) <= 2:
				mid_run = maxi(mid_run, run)
			if run > best_run:
				best_run = run
				best_row = y
		# Read literally: Godot draws PNG row 0 at the sprite's local top, so a
		# piece whose top (finial/crown) is drawn first has its widest row (the
		# base) in the lower half and asks for no vertical flip.
		var base := (
			"upright-as-stored (widest row = base, in the lower half)"
			if best_row > h / 2
			else "VERTICALLY MIRRORED artwork (widest row = base at the top)"
		)
		if best_row <= h / 2:
			fail("art %s stores its base at the top of the PNG" % key)
		say(
			(
				"art %s %dx%d widest_ink_row=%d (%.2f of height) widest_run=%d middle_run=%d -> %s"
				% [key, w, h, best_row, float(best_row) / float(h), best_run, mid_run, base]
			)
		)


func _moves() -> void:
	var seams: Node = load("res://playtest_seams.gd").new()
	seams.name = "PlaytestSeams"
	root.add_child(seams)
	seams.configure()
	say("playtest_build=%s" % str(seams.playtest_build))
	seams.set_overlay(true, PackedStringArray(["UI-shared-play.US1", "UI-shared-play.US2"]))
	seams.emit_tel("probe_shared_play", "pass", "UI-shared-play.US1")
	seams.emit_tel("probe_shared_play", "pass", "UI-shared-play.US2")
	var verdict: Dictionary = seams.assert_telemetry(
		[
			{"event": "probe_shared_play", "outcome": "pass", "story_id": "UI-shared-play.US1"},
			{"event": "probe_shared_play", "outcome": "pass", "story_id": "UI-shared-play.US2"},
		]
	)
	say("telemetry_verdict=%s" % str(verdict.get("verdict", "?")))
	if str(verdict.get("verdict", "")) != "pass":
		fail("telemetry correlation")
