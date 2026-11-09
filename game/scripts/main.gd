extends Node2D
## Core game scene: draws the sim (crane, tower, debris, sky, clouds, ground)
## and feeds it input. Look and feel ported from prototype/index.html.

enum Screen { START, PLAY, OVER }

const TUNING_PATH := "res://data/tuning.tres"
const SKY := [
	[Color8(107, 160, 222), Color8(170, 205, 240)],
	[Color8(70, 120, 200), Color8(140, 180, 230)],
	[Color8(32, 50, 120), Color8(80, 100, 180)],
	[Color8(12, 16, 50), Color8(40, 40, 100)],
]
const SKY_FULL_ALTITUDE := 60.0
const MIXED := ["sunny", "rose", "mint", "sky", "clay", "cream"]

var tuning: Tuning
var sim: GameSim
var screen: Screen = Screen.START
var best: int = 0
var difficulty: String = ""
## "sunny", "rose", "mint", "sky", "clay", "cream" or "mixed".
var skin: String = "sunny"
var pop_text: String = ""
var pop_time: float = 99.0
var clouds: Array = []
var textures: Dictionary = {}
var _seen_landing: int = 0
var _font: Font


func _ready() -> void:
	tuning = load(TUNING_PATH)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--difficulty="):
			difficulty = a.substr(13)
		elif a.begins_with("--skin="):
			skin = a.substr(7)
	_font = ThemeDB.fallback_font
	_build_sprites()
	_new_sim()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 9:
		clouds.append({"x": rng.randf(), "y": rng.randf() * 3.0, "s": 0.6 + rng.randf() * 0.9, "v": 0.004 + rng.randf() * 0.01})
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()


func _new_sim() -> void:
	sim = GameSim.new(tuning, difficulty)
	sim.palette_list = MIXED if skin == "mixed" else [skin]
	sim.reset()
	_seen_landing = sim.landed_serial
	_on_resize()


func _build_sprites() -> void:
	for key in HouseArt.PALS:
		var vp := SubViewport.new()
		vp.size = Vector2i(int(HouseArt.W * HouseArt.SCALE), int(HouseArt.H * HouseArt.SCALE))
		vp.transparent_bg = true
		vp.msaa_2d = Viewport.MSAA_4X
		vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		var art := HouseArt.new()
		art.palette = key
		vp.add_child(art)
		add_child(vp)
		textures[key] = vp.get_texture()


func _on_resize() -> void:
	var s := get_viewport_rect().size
	sim.set_view(s.x, s.y)
	sim.cam_y = sim.cam_target()
	sim.cam_t = sim.cam_y


## Tap, click or Space.
func press() -> void:
	match screen:
		Screen.START:
			screen = Screen.PLAY
		Screen.PLAY:
			sim.drop()
		Screen.OVER:
			if sim.game_over_ready():
				_new_sim()
				screen = Screen.PLAY


func _input(event: InputEvent) -> void:
	# Touch arrives as emulated mouse buttons, so only mouse and keys are handled.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		press()
	elif event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		press()


func _process(delta: float) -> void:
	advance(delta)
	queue_redraw()


func advance(delta: float) -> void:
	sim.step(delta)
	pop_time += delta
	if sim.landed_serial != _seen_landing:
		_seen_landing = sim.landed_serial
		if sim.last_kind == "perfect":
			pop_text = sim.last_streak_text
			pop_time = 0.0
		if sim.last_kind == "miss":
			best = maxi(best, sim.score)
	if screen == Screen.PLAY and sim.state == GameSim.State.OVER:
		screen = Screen.OVER
	for c in clouds:
		c["x"] += c["v"] * delta
		if c["x"] > 1.3:
			c["x"] = -0.3


# ---------- drawing ----------

func _px(x: float) -> float:
	return sim.view_w / 2.0 + x * sim.unit_px


func _sy(w: float) -> float:
	return sim.ground_y() - (w - sim.cam_y) * sim.unit_px


func _draw() -> void:
	if sim == null:
		return
	var w := sim.view_w
	var h := sim.view_h
	_draw_sky(w, h)
	for c in clouds:
		var cy := fmod(c["y"] * h * 0.9 + sim.cam_y * sim.unit_px * 0.25, h * 2.7) - h * 0.2
		_draw_cloud(c["x"] * w, cy, c["s"] * (sim.unit_px / 150.0))
	_draw_ground(w, h)
	for b in sim.blocks:
		_piece(b["pal"], b["fcx"], b["fw"], b["lo"], b["hi"], b["wb"], 0.0)
	for d in sim.debris:
		_piece(d["pal"], d["fcx"], d["fw"], d["lo"], d["hi"], d["wb"], d["rot"])
	if not sim.fall.is_empty():
		var f := sim.fall
		_hang(f["x"], f["wb"], f["w"], f["pal"], f["rot"], false)
	elif sim.state == GameSim.State.PLAY:
		var hp := sim.hang_pos()
		_hang(hp["x"], hp["wb"], sim.top_block()["w"], sim.palette_for(sim.blocks.size()), hp["rot"], true)
	_draw_ui(w, h)


func _draw_sky(w: float, h: float) -> void:
	var t := minf(sim.cam_y / SKY_FULL_ALTITUDE, 1.0) * (SKY.size() - 1)
	var i := mini(int(floor(t)), SKY.size() - 2)
	var f := t - i
	var top: Color = SKY[i][0].lerp(SKY[i + 1][0], f)
	var bot: Color = SKY[i][1].lerp(SKY[i + 1][1], f)
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
	draw_polygon(pts, PackedColorArray([top, top, bot, bot]))


func _draw_cloud(x: float, y: float, s: float) -> void:
	var col := Color(1, 1, 1, 0.28)
	var r := 46.0 * s
	# Opaque-looking union drawn as one translucent layer would double-blend, so
	# draw into a single polygon-free pass with circles on a shared alpha.
	draw_circle(Vector2(x, y), r, col)
	draw_circle(Vector2(x + r * 1.1, y + r * 0.2), r * 0.8, col)
	draw_circle(Vector2(x + r * 2.0, y + r * 0.35), r * 0.65, col)
	draw_circle(Vector2(x - r * 1.1, y + r * 0.3), r * 0.7, col)
	draw_rect(Rect2(x - r * 1.6, y + r * 0.3, r * 4.2, r * 0.45), col)


func _draw_ground(w: float, h: float) -> void:
	var y := _sy(0.0)
	if y > h + 40.0:
		return
	draw_rect(Rect2(0, y, w, h - y + 40.0), Color("#4c6b8a"))
	draw_rect(Rect2(0, y, w, 10), Color("#1d2433"))
	var sw := 36.0
	var x := 0.0
	while x < w:
		draw_rect(Rect2(x, y, sw, 10), Color("#ffc93c"))
		x += sw * 2.0


func _piece(pal: String, fcx: float, fw: float, lo: float, hi: float, wb: float, rot: float) -> void:
	var u := sim.unit_px
	var top := _sy(wb + tuning.house_height_units)
	var hh := tuning.house_height_units * u
	var left := fcx - fw / 2.0
	var tex: Texture2D = textures[pal]
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	var a := clampf((lo - left) / fw, 0.0, 1.0)
	var b := clampf((hi - left) / fw, 0.0, 1.0)
	if b <= a:
		return
	var cx := _px((lo + hi) / 2.0)
	if rot != 0.0:
		draw_set_transform(Vector2(cx, top + hh / 2.0), rot)
		cx = 0.0
		top = -hh / 2.0
		draw_texture_rect_region(tex, Rect2(_px(lo) - _px((lo + hi) / 2.0), top, (hi - lo) * u, hh), Rect2(a * tw, 0, (b - a) * tw, th))
		draw_set_transform(Vector2.ZERO, 0.0)
	else:
		draw_texture_rect_region(tex, Rect2(_px(lo), top, (hi - lo) * u, hh), Rect2(a * tw, 0, (b - a) * tw, th))


func _hang(x: float, wb: float, w: float, pal: String, rot: float, rope: bool) -> void:
	var u := sim.unit_px
	var top := _sy(wb + tuning.house_height_units)
	var hh := tuning.house_height_units * u
	var cx := _px(x)
	if rope:
		var hook_y := top - u * tuning.hook_offset_units
		var rc := Color("#3b3f4d")
		draw_line(Vector2(sim.view_w / 2.0, -10), Vector2(cx, hook_y), rc, 2.5, true)
		draw_line(Vector2(cx, hook_y), Vector2(_px(x - w / 2.0) + 2, top + 4), rc, 1.5, true)
		draw_line(Vector2(cx, hook_y), Vector2(_px(x + w / 2.0) - 2, top + 4), rc, 1.5, true)
		draw_rect(Rect2(cx - 9, hook_y - 18, 18, 18), Color("#ffc93c"))
		for k in 3:
			var poly := PackedVector2Array([
				Vector2(cx - 9 + k * 6, hook_y - 18), Vector2(cx - 3 + k * 6, hook_y - 18),
				Vector2(cx - 9 + k * 6 + 3, hook_y), Vector2(cx - 12 + k * 6 + 3, hook_y)])
			draw_colored_polygon(poly, Color("#2b2f3a"))
		draw_arc(Vector2(cx, hook_y + 5), 6, 0, PI * 1.7, 20, Color("#8a93a6"), 3.0, true)
	draw_set_transform(Vector2(cx, top), rot)
	draw_texture_rect(textures[pal], Rect2(_px(x - w / 2.0) - cx, 0, w * u, hh), false)
	draw_set_transform(Vector2.ZERO, 0.0)


func _text(s: String, y: float, size: int, col: Color, shadow: bool = true) -> void:
	var w := sim.view_w
	if shadow:
		draw_string(_font, Vector2(2, y + 3), s, HORIZONTAL_ALIGNMENT_CENTER, w, size, Color(0.12, 0.2, 0.35, 0.45))
	draw_string(_font, Vector2(0, y), s, HORIZONTAL_ALIGNMENT_CENTER, w, size, col)


func _draw_ui(w: float, h: float) -> void:
	var vmin := minf(w, h)
	if screen != Screen.START:
		_text(str(sim.score), h * 0.05 + vmin * 0.11, int(clampf(vmin * 0.11, 48, 100) * 1.4), Color.WHITE)
	if pop_time < 0.7 and pop_text != "":
		var a := 1.0 - pop_time / 0.7
		_text(pop_text, h * 0.18 + vmin * 0.045, int(clampf(vmin * 0.045, 20, 36) * 1.6), Color(1, 1, 1, a))
	var small := int(maxf(vmin * 0.03, 16.0))
	if screen == Screen.START:
		draw_rect(Rect2(0, 0, w, h), Color(0.16, 0.31, 0.55, 0.5))
		_text("Tower Craft", h * 0.38, int(clampf(vmin * 0.08, 34, 64) * 1.6), Color("#ffc93c"))
		_text("Drop the houses. Land them perfectly to grow back.", h * 0.45, small, Color.WHITE)
		_text("Tap / click / Space to start", h * 0.52, small, Color.WHITE)
	elif screen == Screen.PLAY and sim.fall.is_empty() and sim.score == 0:
		_text("Tap / click / Space to drop", h * 0.97, small, Color.WHITE)
	elif screen == Screen.OVER and sim.game_over_ready():
		draw_rect(Rect2(0, 0, w, h), Color(0.16, 0.31, 0.55, 0.5))
		_text("Game Over", h * 0.4, int(clampf(vmin * 0.08, 34, 64) * 1.6), Color("#ffc93c"))
		_text("Score %d  -  Best %d" % [sim.score, best], h * 0.47, int(small * 1.5), Color.WHITE)
		_text("Tap / click / Space to play again", h * 0.54, small, Color.WHITE)
