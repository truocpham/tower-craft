class_name DifficultyPreset
extends Resource
## One difficulty preset. Values live in res://data/tuning.tres.

@export var perfect_tolerance: float = 0.0
@export var regrow_streak: int = 0
@export var regrow_amount: float = 0.0
@export var swing_speed_start: float = 0.0
@export var swing_speed_growth: float = 0.0
@export var swing_speed_cap: float = 0.0


## Swing speed (rad/s) after the given number of houses placed.
func swing_speed(houses: int) -> float:
	return minf(swing_speed_start + swing_speed_growth * houses, swing_speed_cap)
