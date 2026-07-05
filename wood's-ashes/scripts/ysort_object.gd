extends Node2D

## Y-sort depth offset — set this to the Y position of the object's base/feet
## relative to the node's origin (usually the bottom of its collision shape).
@export var sort_y_offset: float = 0.0

func _ready() -> void:
	z_as_relative = false
	z_index = int(global_position.y + sort_y_offset)
