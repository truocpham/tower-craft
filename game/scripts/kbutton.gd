class_name KButton
extends Button
## Big rounded button with a vector icon. At least MIN_SIZE tall and wide.

const MIN_SIZE := 80.0

var icon_kind: String = ""
var _color: Color


func _init(label: String = "", icon: String = "", color: Color = Color("#3b6fb6"), min_w: float = MIN_SIZE, font_size: int = 36) -> void:
	text = label
	icon_kind = icon
	_color = color
	custom_minimum_size = Vector2(maxf(min_w, MIN_SIZE), MIN_SIZE)
	focus_mode = Control.FOCUS_NONE
	add_theme_font_size_override("font_size", font_size)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.WHITE)
	add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.6))
	var pad := 32.0
	if icon != "" and label != "":
		pad = 24.0 + MIN_SIZE * 0.7
	_style("normal", color, pad)
	_style("hover", color.lightened(0.1), pad)
	_style("pressed", color.darkened(0.2), pad)
	_style("disabled", color.darkened(0.3), pad)
	draw.connect(_draw_icon)


func _style(slot: String, col: Color, pad: float) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(28)
	sb.shadow_color = Color(0, 0, 0, 0.25)
	sb.shadow_size = 4
	sb.shadow_offset = Vector2(0, 3)
	sb.content_margin_left = pad if text != "" else 8.0
	sb.content_margin_right = 20.0 if text != "" else 8.0
	add_theme_stylebox_override(slot, sb)
	if slot == "normal":
		add_theme_stylebox_override("focus", sb)


func set_color(col: Color) -> void:
	_color = col
	var pad := get_theme_stylebox("normal").content_margin_left
	_style("normal", col, pad)
	_style("hover", col.lightened(0.1), pad)
	_style("pressed", col.darkened(0.2), pad)


func _draw_icon() -> void:
	if icon_kind == "":
		return
	var s := MIN_SIZE * 0.42
	var c := Vector2(size.x / 2.0, size.y / 2.0)
	if text != "":
		c = Vector2(24.0 + MIN_SIZE * 0.25, size.y / 2.0)
	Icons.draw(self, icon_kind, c, s, Color.WHITE)
