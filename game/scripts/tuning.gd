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
@export var hang_height_units: float = 0.0
@export var hang_sag_units: float = 0.0
@export var hang_tilt_radians: float = 0.0
@export var hook_offset_units: float = 0.0
@export var debris_speed_partial: float = 0.0
@export var debris_spin_partial: float = 0.0
@export var debris_speed_miss: float = 0.0
@export var debris_spin_miss: float = 0.0
@export var game_over_delay_seconds: float = 0.0
@export var ground_screen_fraction: float = 0.0
@export var fall_rotation_damping: float = 0.0
@export var max_step_seconds: float = 0.0
@export var debris_cull_below_camera_units: float = 0.0
@export var sky_full_altitude_units: float = 0.0
@export var pop_seconds: float = 0.0
@export var demo_restart_delay_seconds: float = 0.0
@export var demo_tower_blocks: int = 0
@export var demo_drop_window_units: float = 0.0

@export_group("Parent area")
## Widest the parent area content gets, in screen units; wider windows centre it.
@export var parent_column_max_width: float = 0.0

@export_group("Break reminder")
## Minutes of play the parent can choose from, and the default.
@export var break_minutes_options: PackedInt32Array = PackedInt32Array()
@export var break_minutes_default: int = 0


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
