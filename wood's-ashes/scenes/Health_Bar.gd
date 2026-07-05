extends ProgressBar

var tracked_player: Node = null

func _process(_delta: float) -> void:
	var current = get_tree().get_first_node_in_group("player")
	if current == tracked_player:
		return
	if tracked_player != null and is_instance_valid(tracked_player):
		if tracked_player.health_changed.is_connected(_on_health_changed):
			tracked_player.health_changed.disconnect(_on_health_changed)
	tracked_player = current
	if tracked_player != null:
		max_value = tracked_player.max_health
		value = tracked_player.health
		if not tracked_player.health_changed.is_connected(_on_health_changed):
			tracked_player.health_changed.connect(_on_health_changed)

func _on_health_changed(current_health, new_max_health):
	max_value = new_max_health
	value = current_health
