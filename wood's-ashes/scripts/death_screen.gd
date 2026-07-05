extends CanvasLayer

@onready var darken: ColorRect = $Control/Darken

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	darken.color.a = 0.0
	fade_in()

func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(darken, "color:a", 0.6, 0.5)

func _on_back_pressed() -> void:
	get_tree().paused = false
	var tween = create_tween()
	tween.tween_property(darken, "color:a", 0.0, 0.1)
	await tween.finished
	queue_free()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
