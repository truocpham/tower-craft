extends Node2D
## Placeholder main scene.

const TUNING_PATH := "res://data/tuning.tres"


func _ready() -> void:
	var tuning: Tuning = load(TUNING_PATH)
	print("Tower Craft ready, default difficulty: ", tuning.default_difficulty)
