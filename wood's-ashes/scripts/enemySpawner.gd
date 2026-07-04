extends Node2D

@export var enemy_scene: PackedScene
@export var player: Node2D

@export var spawn_interval := 1.0
@export var spawn_distance := 500.0

var timer := 0.0

func _process(delta):
	timer += delta

	if timer >= spawn_interval:
		timer = 0.0
		spawn_enemy()

func spawn_enemy():
	if enemy_scene == null:
		print("Enemy Scene não foi definido")
		return

	if player == null:
		print("Player não foi definido")
		return

	var enemy = enemy_scene.instantiate()

	var angle = randf() * TAU
	var direction = Vector2.RIGHT.rotated(angle)

	enemy.global_position = player.global_position + direction * spawn_distance
	enemy.player = player

	get_tree().current_scene.add_child(enemy)
