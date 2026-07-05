extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	for chest in get_tree().get_nodes_in_group("chests"):
		if chest.has_method("reset"):
			chest.reset()
