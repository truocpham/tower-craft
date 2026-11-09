class_name SmilingSun
extends RefCounted
## Friendly sun in the top-left corner. Beams and bounces after a perfect.

var joy: float = 0.0  # 1 right after a perfect, fades to 0
var t: float = 0.0


func cheer() -> void:
	joy = 1.0


func step(dt: float) -> void:
	t += dt
	joy = maxf(0.0, joy - dt / 1.2)


## `inset` moves the sun right, to clear a corner button.
func draw(ci: CanvasItem, unit: float, inset: float = 0.0) -> void:
	var r := clampf(unit * 0.16, 28.0, 56.0) * (1.0 + 0.25 * joy)
	var c := Vector2(inset + r * 1.8, r * 1.8 - joy * r * 0.3 * absf(sin(t * 14.0)))
	for k in 12:
		var d := Vector2.from_angle(TAU * k / 12.0 + t * 0.4)
		ci.draw_line(c + d * r * 1.25, c + d * r * (1.6 + 0.35 * joy), Color8(255, 201, 60), 4.0, true)
	ci.draw_circle(c, r, Color8(255, 214, 80))
	var eye := Color8(70, 50, 30)
	ci.draw_circle(c + Vector2(-r * 0.35, -r * 0.2), r * 0.1, eye)
	ci.draw_circle(c + Vector2(r * 0.35, -r * 0.2), r * 0.1, eye)
	var depth := 0.35 + 0.35 * joy
	ci.draw_arc(c + Vector2(0, r * 0.05), r * 0.55, PI * (0.5 - depth * 0.5), PI * (0.5 + depth * 0.5), 16, eye, 3.0, true)
	if joy > 0.0:
		var blush := Color(1, 0.5, 0.5, 0.5 * joy)
		ci.draw_circle(c + Vector2(-r * 0.6, r * 0.2), r * 0.15, blush)
		ci.draw_circle(c + Vector2(r * 0.6, r * 0.2), r * 0.15, blush)
