extends ProgressBar

@onready var player = get_node("/root/Game/Player")


func _ready():
	max_value = player.max_health
	value = player.health
	player.health_changed.connect(_on_health_changed)


func _on_health_changed(current_health, max_health):
	max_value = max_health
	value = current_health
