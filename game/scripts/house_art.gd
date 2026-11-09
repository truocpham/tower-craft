class_name HouseArt
extends Node2D
## Procedural house drawing ported from the prototype sprite(). Designed on a
## 360x414 canvas; the owning SubViewport renders it at SCALE x for sharpness.

const W := 360.0
const H := 414.0
const SCALE := 2.0

const PALS := {
	"sunny": {"wall": "#f2b84b", "wall2": "#d99a2e", "trim": "#fff1d0", "shut": "#6b9a3c", "door": "#8a4a26", "glass": "#9fd0e6"},
	"rose": {"wall": "#f08fa6", "wall2": "#d2708a", "trim": "#fff0f3", "shut": "#5a8f86", "door": "#7a3b4a", "glass": "#cfe6f2"},
	"mint": {"wall": "#8fd9b8", "wall2": "#6bbd9a", "trim": "#f2fff9", "shut": "#c4572d", "door": "#6a4130", "glass": "#d6ecf7"},
	"sky": {"wall": "#86b8ee", "wall2": "#6a9ad4", "trim": "#f4f9ff", "shut": "#e0903a", "door": "#4a3a6e", "glass": "#e5f2fb"},
	"clay": {"wall": "#e07d52", "wall2": "#c4623a", "trim": "#fff0e2", "shut": "#3f7a68", "door": "#5a2f1d", "glass": "#cfe3ea"},
	"cream": {"wall": "#f3e3b8", "wall2": "#dcc994", "trim": "#ffffff", "shut": "#4f7fb5", "door": "#7b4a2b", "glass": "#cfe6f2"},
}

var palette: String = "sunny"
var _p: Dictionary


func _ready() -> void:
	scale = Vector2(SCALE, SCALE)


func _rect(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x, y, w, h), c)


func _rr(x: float, y: float, w: float, h: float, r: float, c: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(int(r))
	sb.anti_aliasing = true
	draw_style_box(sb, Rect2(x, y, w, h))


func _disc(x: float, y: float, r: float, c: Color) -> void:
	draw_circle(Vector2(x, y), r, c, true)


func _col(k: String) -> Color:
	return Color(_p[k])


func _window(x: float, y: float, ww: float, hh: float) -> void:
	var trim := _col("trim")
	_rr(x - 6, y - 6, ww + 12, hh + 12, 6, trim)
	_rect(x, y, ww, hh, _col("glass"))
	_rect(x + 4, y + 4, ww * 0.3, hh - 8, Color(1, 1, 1, 0.5))
	_rect(x + ww / 2 - 2, y, 4, hh, trim)
	var shut := _col("shut")
	_rect(x - 30, y - 4, 24, hh + 8, shut)
	_rect(x + ww + 6, y - 4, 24, hh + 8, shut)
	var k := 0.0
	while k < hh + 8:
		_rect(x - 30, y - 4 + k, 24, 3, Color(0, 0, 0, 0.22))
		_rect(x + ww + 6, y - 4 + k, 24, 3, Color(0, 0, 0, 0.22))
		k += 12.0


func _draw() -> void:
	_p = PALS[palette]
	var trim := _col("trim")
	# wall
	_rect(12, 34, W - 24, H - 34, _col("wall"))
	_rect(W - 36, 34, 24, H - 34, _col("wall2"))
	var y := 60.0
	while y < H:
		_rect(12, y, W - 24, 2, Color(0, 0, 0, 0.06))
		y += 34.0
	# cornice
	_rr(0, 6, W, 34, 6, trim)
	_rect(0, 34, W, 6, Color(0, 0, 0, 0.12))
	# drain pipe
	_rect(22, 34, 10, H - 34, Color("#7d8696"))
	_window(78, 70, 56, 78)
	_window(222, 70, 56, 78)
	_window(78, 200, 56, 70)
	# door
	_rr(214, 196, 92, H - 196, 10, trim)
	_rr(222, 206, 76, H - 206, 8, _col("door"))
	var arch := PackedVector2Array()
	for i in range(0, 25):
		var a := PI + PI * i / 24.0
		arch.append(Vector2(260 + cos(a) * 22, 236 + sin(a) * 22))
	draw_colored_polygon(arch, _col("glass"))
	_disc(284, 310, 5, Color("#f1d27a"))
	# laundry line
	var line := PackedVector2Array()
	for i in range(0, 21):
		var t := i / 20.0
		var a := Vector2(44, 160).lerp(Vector2(160, 184), t)
		var b := Vector2(160, 184).lerp(Vector2(300, 158), t)
		line.append(a.lerp(b, t))
	draw_polyline(line, Color("#6b5a4a"), 2.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(104, 170), Vector2(140, 172), Vector2(136, 214), Vector2(108, 210)]), Color.WHITE)
	_rect(170, 172, 22, 28, Color("#ffd6e0"))
	# plants
	_rect(70, H - 36, 60, 22, Color("#b5683d"))
	for i in range(7):
		_disc(76 + i * 8, H - 40 - (i % 3) * 5, 10, Color("#3e8a3c"))
	for x in [88, 104, 118]:
		_disc(x, H - 52, 5, Color("#e85a7a"))
	# bottom edge
	_rect(12, H - 8, W - 24, 8, Color(0, 0, 0, 0.12))
