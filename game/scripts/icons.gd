class_name Icons
extends RefCounted
## Simple vector icons drawn with canvas primitives, so every button can carry
## one without image files. Call from inside a CanvasItem draw.


## Draws `kind` centred on `c`, fitting a square of side `s`.
static func draw(ci: CanvasItem, kind: String, c: Vector2, s: float, col: Color) -> void:
	var h := s / 2.0
	var w := maxf(s * 0.11, 3.0)
	match kind:
		"play":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-h * 0.55, -h * 0.8), c + Vector2(h * 0.8, 0), c + Vector2(-h * 0.55, h * 0.8)]), col)
		"home":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-h, -h * 0.05), c + Vector2(0, -h), c + Vector2(h, -h * 0.05)]), col)
			ci.draw_rect(Rect2(c + Vector2(-h * 0.68, -h * 0.1), Vector2(h * 1.36, h * 1.0)), col)
			ci.draw_rect(Rect2(c + Vector2(-h * 0.18, h * 0.3), Vector2(h * 0.36, h * 0.6)), Color(0, 0, 0, 0.35))
		"replay":
			ci.draw_arc(c, h * 0.7, -PI * 0.4, PI * 1.35, 24, col, w, true)
			var tip := c + Vector2(cos(-PI * 0.4), sin(-PI * 0.4)) * h * 0.7
			ci.draw_colored_polygon(PackedVector2Array([tip + Vector2(-h * 0.1, -h * 0.55), tip + Vector2(h * 0.6, h * 0.1), tip + Vector2(-h * 0.5, h * 0.2)]), col)
		"gear":
			for i in 8:
				var a := i * PI / 4.0
				ci.draw_line(c + Vector2(cos(a), sin(a)) * h * 0.6, c + Vector2(cos(a), sin(a)) * h * 0.95, col, w * 1.4)
			ci.draw_circle(c, h * 0.68, col)
			ci.draw_circle(c, h * 0.3, Color(0, 0, 0, 0.4))
		"plus":
			ci.draw_line(c + Vector2(-h * 0.8, 0), c + Vector2(h * 0.8, 0), col, w * 1.3)
			ci.draw_line(c + Vector2(0, -h * 0.8), c + Vector2(0, h * 0.8), col, w * 1.3)
		"trash":
			ci.draw_rect(Rect2(c + Vector2(-h * 0.55, -h * 0.35), Vector2(h * 1.1, h * 1.3)), col)
			ci.draw_rect(Rect2(c + Vector2(-h * 0.8, -h * 0.65), Vector2(h * 1.6, h * 0.2)), col)
			ci.draw_rect(Rect2(c + Vector2(-h * 0.25, -h * 0.9), Vector2(h * 0.5, h * 0.25)), col)
		"pencil":
			ci.draw_line(c + Vector2(-h * 0.7, h * 0.7), c + Vector2(h * 0.6, -h * 0.6), col, w * 2.0)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-h * 0.95, h * 0.95), c + Vector2(-h * 0.85, h * 0.4), c + Vector2(-h * 0.4, h * 0.85)]), col)
		"check":
			ci.draw_polyline(PackedVector2Array([c + Vector2(-h * 0.8, 0), c + Vector2(-h * 0.2, h * 0.6), c + Vector2(h * 0.85, -h * 0.6)]), col, w * 1.4, true)
		"x":
			ci.draw_line(c + Vector2(-h * 0.7, -h * 0.7), c + Vector2(h * 0.7, h * 0.7), col, w * 1.4)
			ci.draw_line(c + Vector2(-h * 0.7, h * 0.7), c + Vector2(h * 0.7, -h * 0.7), col, w * 1.4)
		"back":
			ci.draw_polyline(PackedVector2Array([c + Vector2(h * 0.2, -h * 0.8), c + Vector2(-h * 0.6, 0), c + Vector2(h * 0.2, h * 0.8)]), col, w * 1.4, true)
			ci.draw_line(c + Vector2(-h * 0.55, 0), c + Vector2(h * 0.85, 0), col, w * 1.4)
		"music":
			ci.draw_circle(c + Vector2(-h * 0.3, h * 0.6), h * 0.35, col)
			ci.draw_line(c + Vector2(h * 0.02, h * 0.55), c + Vector2(h * 0.02, -h * 0.8), col, w)
			ci.draw_line(c + Vector2(h * 0.02, -h * 0.8), c + Vector2(h * 0.7, -h * 0.4), col, w * 1.4)
		"sound":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-h * 0.9, -h * 0.3), c + Vector2(-h * 0.4, -h * 0.3), c + Vector2(h * 0.1, -h * 0.8), c + Vector2(h * 0.1, h * 0.8), c + Vector2(-h * 0.4, h * 0.3), c + Vector2(-h * 0.9, h * 0.3)]), col)
			ci.draw_arc(c + Vector2(h * 0.1, 0), h * 0.5, -0.9, 0.9, 10, col, w)
			ci.draw_arc(c + Vector2(h * 0.1, 0), h * 0.9, -0.9, 0.9, 12, col, w)
		"voice":
			ci.draw_rect(Rect2(c + Vector2(-h * 0.25, -h * 0.9), Vector2(h * 0.5, h * 1.0)), col)
			ci.draw_circle(c + Vector2(0, -h * 0.9), h * 0.25, col)
			ci.draw_circle(c + Vector2(0, h * 0.1), h * 0.25, col)
			ci.draw_arc(c + Vector2(0, -h * 0.1), h * 0.6, 0, PI, 14, col, w)
			ci.draw_line(c + Vector2(0, h * 0.5), c + Vector2(0, h * 0.9), col, w)
		"clock":
			ci.draw_arc(c, h * 0.85, 0, TAU, 28, col, w)
			ci.draw_line(c, c + Vector2(0, -h * 0.55), col, w)
			ci.draw_line(c, c + Vector2(h * 0.4, h * 0.2), col, w)
		"lock":
			ci.draw_arc(c + Vector2(0, -h * 0.2), h * 0.45, PI, TAU, 12, col, w)
			ci.draw_rect(Rect2(c + Vector2(-h * 0.65, -h * 0.2), Vector2(h * 1.3, h * 1.0)), col)
		"people":
			ci.draw_circle(c + Vector2(-h * 0.4, -h * 0.3), h * 0.33, col)
			ci.draw_circle(c + Vector2(h * 0.4, -h * 0.3), h * 0.33, col)
			ci.draw_arc(c + Vector2(-h * 0.4, h * 0.85), h * 0.6, PI, TAU, 10, col, h * 0.35)
			ci.draw_arc(c + Vector2(h * 0.4, h * 0.85), h * 0.6, PI, TAU, 10, col, h * 0.35)
		"bars":
			ci.draw_rect(Rect2(c + Vector2(-h * 0.8, h * 0.1), Vector2(h * 0.45, h * 0.7)), col)
			ci.draw_rect(Rect2(c + Vector2(-h * 0.22, -h * 0.3), Vector2(h * 0.45, h * 1.1)), col)
			ci.draw_rect(Rect2(c + Vector2(h * 0.35, -h * 0.8), Vector2(h * 0.45, h * 1.6)), col)
		"star":
			var pts := PackedVector2Array()
			for i in 10:
				var r := h if i % 2 == 0 else h * 0.45
				var a := -PI / 2.0 + i * PI / 5.0
				pts.append(c + Vector2(cos(a), sin(a)) * r)
			ci.draw_colored_polygon(pts, col)
