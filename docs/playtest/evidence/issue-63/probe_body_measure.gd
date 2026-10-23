extends SceneTree
## Acceptance measurement for #63: rendered piece body size in board units.
## Fit used by demos/shared-game/board_view.gd `_apply_piece_texture`:
## scale = PIECE_EXTENT / opaque_body_width, so the rendered width is exactly
## PIECE_EXTENT and the rendered height is PIECE_EXTENT * body_h / body_w.
const EXTENT := 0.85
func _init():
	var project := ProjectSettings.globalize_path("res://")
	# This script runs from the repo root; the demo tree sits beside game_assets/.
	var root := "/home/waigore/simplechessv2/1/game_assets/piece-sprites/"
	print("code-colour  body_w  body_h  (board units; SPC.E1/FRM.P1 extent = 0.85 x 0.85)")
	for code in ["k", "q", "r", "b", "n", "p"]:
		for col in ["white", "black"]:
			var img := Image.load_from_file(root + "%s-%s.png" % [code, col])
			var used := img.get_used_rect()
			var scale := EXTENT / float(maxi(used.size.x, 1))
			print("%s-%-6s  %.3f   %.3f" % [code, col, used.size.x * scale, used.size.y * scale])
	quit()
