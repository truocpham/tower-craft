class_name ParentGate
extends Control
## Corner gear icon. Opens the parent area only after a 3-second press-and-hold.

signal opened

const HOLD_SECONDS := 3.0
const SIZE := 96.0

var held: float = 0.0
var holding: bool = false


func _init() -> void:
	custom_minimum_size = Vector2(SIZE, SIZE)
	size = Vector2(SIZE, SIZE)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			begin_hold()
		else:
			cancel_hold()
		accept_event()


func begin_hold() -> void:
	holding = true
	held = 0.0
	queue_redraw()


func cancel_hold() -> void:
	holding = false
	held = 0.0
	queue_redraw()


## Adds hold time; emits `opened` once when the hold reaches HOLD_SECONDS.
func advance(delta: float) -> void:
	if not holding:
		return
	held += delta
	if held >= HOLD_SECONDS:
		cancel_hold()
		opened.emit()
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		cancel_hold()


func _draw() -> void:
	var c := size / 2.0
	draw_circle(c, SIZE * 0.5, Color(0.1, 0.15, 0.3, 0.55))
	Icons.draw(self, "gear", c, SIZE * 0.5, Color(1, 1, 1, 0.9))
	if holding:
		draw_arc(c, SIZE * 0.47, -PI / 2.0, -PI / 2.0 + TAU * clampf(held / HOLD_SECONDS, 0.0, 1.0), 40, Color("#ffc93c"), 6.0, true)
