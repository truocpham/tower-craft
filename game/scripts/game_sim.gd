class_name GameSim
extends RefCounted
## Core loop simulation with no nodes: tower, swinging house, fall, debris,
## camera. All lengths are world units (full house width = 1.0). The view
## only reads this state. Ported from prototype/index.html.

enum State { PLAY, OVER }

const PALETTES := ["sunny", "rose", "mint", "sky", "clay", "cream"]

var tuning: Tuning
var preset: DifficultyPreset
var stack: Landing.Stack
## Palette keys cycled by tower index (one key, or all six for Mixed).
var palette_list: Array = ["sunny"]

var state: State = State.PLAY
## Tower blocks: {cx, w, fcx, fw, lo, hi, wb, pal}. fcx/fw = sprite span, lo/hi = visible clip.
var blocks: Array = []
## Falling debris: same fields plus vx, vy, rot, vr.
var debris: Array = []
## The dropped house in flight, or empty.
var fall: Dictionary = {}
var score: int = 0
var streak: int = 0
var phase: float = 0.0
var cam_y: float = 0.0
var cam_t: float = 0.0
var over_time: float = 0.0
## Last landing, for the view: "perfect", "partial", "miss" or "".
var last_kind: String = ""
var last_streak_text: String = ""
var landed_serial: int = 0

## Screen metrics the sim needs (set by the view).
var unit_px: float = 200.0
var view_w: float = 1080.0
var view_h: float = 1920.0
var ground_frac: float = 0.9


func _init(t: Tuning, difficulty: String = "") -> void:
	tuning = t
	preset = t.preset(difficulty if difficulty != "" else t.default_difficulty)
	stack = Landing.Stack.new(preset)
	reset()


func set_view(w: float, h: float) -> void:
	view_w = w
	view_h = h
	unit_px = layout_unit(w, h, tuning)


## The single layout unit: 30% of width, capped at 240 px and 22% of height.
static func layout_unit(w: float, h: float, t: Tuning) -> float:
	return minf(minf(w * t.house_width_screen_fraction, h * t.house_width_max_height_fraction), t.house_width_max_px)


func ground_y() -> float:
	return view_h * ground_frac


func palette_for(i: int) -> String:
	return palette_list[i % palette_list.size()]


func _add_block(cx: float, w: float, i: int, pal: String) -> Dictionary:
	var b := {"cx": cx, "w": w, "fcx": cx, "fw": w, "lo": cx - w / 2.0, "hi": cx + w / 2.0, "wb": i * tuning.stack_step_units, "pal": pal}
	blocks.append(b)
	return b


func reset() -> void:
	blocks.clear()
	debris.clear()
	fall = {}
	score = 0
	streak = 0
	stack.reset()
	phase = 0.0
	cam_y = 0.0
	cam_t = 0.0
	over_time = 0.0
	last_kind = ""
	state = State.PLAY
	_add_block(0.0, 1.0, 0, palette_for(0))


func amplitude() -> float:
	return minf(view_w * tuning.swing_amplitude_max_width_fraction / unit_px, tuning.swing_amplitude_units)


func omega() -> float:
	return preset.swing_speed(score)


## Position of the hanging house: x, bottom height wb, tilt.
func hang_pos() -> Dictionary:
	var a := amplitude()
	var hx := a * sin(phase)
	var r := hx / a
	return {"x": hx, "wb": blocks.size() * tuning.stack_step_units + tuning.hang_height_units - tuning.hang_sag_units * r * r, "rot": r * tuning.hang_tilt_radians}


func top_block() -> Dictionary:
	return blocks[blocks.size() - 1]


func cam_target() -> float:
	var n := blocks.size()
	return maxf(0.0, n * tuning.stack_step_units - (ground_y() - tuning.camera_tower_top_screen_fraction * view_h) / unit_px)


## Release the hanging house. Ignored while one is falling or the run is over.
func drop() -> bool:
	if state != State.PLAY or not fall.is_empty():
		return false
	var h := hang_pos()
	fall = {"x": h["x"], "wb": h["wb"], "vy": 0.0, "w": top_block()["w"], "pal": palette_for(blocks.size()), "rot": h["rot"]}
	return true


func step(dt: float) -> void:
	dt = minf(dt, 0.05)
	phase += dt * omega()
	if state == State.OVER:
		over_time += dt
	if state == State.PLAY and not fall.is_empty():
		fall["vy"] += tuning.gravity_units * dt
		fall["wb"] -= fall["vy"] * dt
		fall["rot"] *= pow(0.9, dt * 60.0)
		var target: float = blocks.size() * tuning.stack_step_units
		if fall["wb"] <= target:
			fall["wb"] = target
			_land()
	for i in range(debris.size() - 1, -1, -1):
		var d: Dictionary = debris[i]
		d["vy"] += tuning.gravity_units * dt
		d["wb"] -= d["vy"] * dt
		d["lo"] += d["vx"] * dt
		d["hi"] += d["vx"] * dt
		d["fcx"] += d["vx"] * dt
		d["rot"] += d["vr"] * dt
		if d["wb"] < cam_y - 12.0:
			debris.remove_at(i)
	cam_y += (cam_t - cam_y) * minf(dt * tuning.camera_ease_per_second, 1.0)


func _land() -> void:
	var f := fall
	fall = {}
	var top := top_block()
	var i := blocks.size()
	var r := Landing.evaluate(top["cx"], top["w"], f["x"], f["w"], preset)
	stack.apply(r)
	streak = stack.streak
	landed_serial += 1
	var half: float = f["w"] / 2.0
	match r.kind:
		Landing.Kind.PERFECT:
			_add_block(r.center, r.width, i, f["pal"])
			last_kind = "perfect"
			last_streak_text = "PERFECT x%d" % streak
			if streak >= preset.regrow_streak:
				last_streak_text += " - GROW!"
		Landing.Kind.PARTIAL:
			var nb := _add_block(r.center, r.width, i, f["pal"])
			nb["fcx"] = f["x"]
			nb["fw"] = f["w"]
			nb["lo"] = r.center - r.width / 2.0
			nb["hi"] = r.center + r.width / 2.0
			_spawn_debris(f, r.overhang_lo, r.overhang_hi, r.side, tuning.debris_speed_partial, tuning.debris_spin_partial, i)
			last_kind = "partial"
		_:
			_spawn_debris(f, f["x"] - half, f["x"] + half, r.side, tuning.debris_speed_miss, tuning.debris_spin_miss, i)
			last_kind = "miss"
			state = State.OVER
			over_time = 0.0
			return
	score += 1
	cam_t = cam_target()


func _spawn_debris(f: Dictionary, lo: float, hi: float, side: int, speed: float, spin: float, i: int) -> void:
	debris.append({"pal": f["pal"], "fcx": f["x"], "fw": f["w"], "lo": lo, "hi": hi, "wb": i * tuning.stack_step_units, "vy": 0.0, "vx": side * speed, "rot": 0.0, "vr": side * spin})


func game_over_ready() -> bool:
	return state == State.OVER and over_time >= tuning.game_over_delay_seconds
