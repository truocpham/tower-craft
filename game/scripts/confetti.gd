class_name Confetti
extends RefCounted
## Colourful paper pieces that burst from the top and fall. Pure state plus a
## draw helper so it is easy to test.

const MILESTONES := [5, 10, 20, 50]
const COLORS := [Color8(255, 201, 60), Color8(255, 120, 150), Color8(110, 220, 170), Color8(120, 190, 255), Color8(255, 160, 80)]

var pieces: Array = []
var _rng := RandomNumberGenerator.new()


static func is_milestone(score: int) -> bool:
	return score in MILESTONES


func burst(w: float, h: float, count: int = 90) -> void:
	for i in count:
		pieces.append({
			"x": _rng.randf() * w, "y": -_rng.randf() * h * 0.2,
			"vx": _rng.randf_range(-80.0, 80.0), "vy": _rng.randf_range(120.0, 380.0),
			"r": _rng.randf() * TAU, "vr": _rng.randf_range(-6.0, 6.0),
			"s": _rng.randf_range(10.0, 20.0), "c": COLORS[_rng.randi() % COLORS.size()],
			"life": _rng.randf_range(2.0, 3.5)})


func step(dt: float) -> void:
	for i in range(pieces.size() - 1, -1, -1):
		var p: Dictionary = pieces[i]
		p["x"] += p["vx"] * dt
		p["y"] += p["vy"] * dt
		p["r"] += p["vr"] * dt
		p["life"] -= dt
		if p["life"] <= 0.0:
			pieces.remove_at(i)


func draw(ci: CanvasItem) -> void:
	for p in pieces:
		var col: Color = p["c"]
		col.a = minf(p["life"], 1.0)
		ci.draw_set_transform(Vector2(p["x"], p["y"]), p["r"])
		ci.draw_rect(Rect2(-p["s"] / 2.0, -p["s"] / 4.0, p["s"], p["s"] / 2.0), col)
	ci.draw_set_transform(Vector2.ZERO, 0.0)
