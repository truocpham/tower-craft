class_name Tuning
extends Resource
## All tuning values. The numbers live in res://data/tuning.tres only.

@export var easy: DifficultyPreset
@export var normal: DifficultyPreset
@export var hard: DifficultyPreset
@export var default_difficulty: String = "normal"

@export_group("Shared")
@export var house_width_screen_fraction: float = 0.0
@export var house_width_max_px: float = 0.0
@export var house_width_max_height_fraction: float = 0.0
@export var house_height_units: float = 0.0
@export var stack_step_units: float = 0.0
@export var swing_amplitude_units: float = 0.0
@export var swing_amplitude_max_width_fraction: float = 0.0
@export var gravity_units: float = 0.0
@export var camera_tower_top_screen_fraction: float = 0.0
@export var camera_ease_per_second: float = 0.0


func preset(difficulty: String) -> DifficultyPreset:
	match difficulty:
		"easy":
			return easy
		"normal":
			return normal
		"hard":
			return hard
	push_error("Unknown difficulty: %s" % difficulty)
	return null
