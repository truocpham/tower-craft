class_name PopupLayer
extends Node2D
## Draws the perfect pop-up in its own canvas item with a high z_index, so the
## swinging block, house and rope always render beneath the text.

const Z := 100

var main: Node


func _init() -> void:
	z_index = Z


func _draw() -> void:
	if main != null:
		main.draw_popup(self)
