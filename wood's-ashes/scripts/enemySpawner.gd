extends Node2D

@export var enemy_scene: PackedScene
@export var player: Node2D

@export var spawn_interval := 1.0
@export var spawn_distance := 500.0

var timer := 0.0
<<<<<<< Updated upstream
=======
var game_time := 0.0


func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D

>>>>>>> Stashed changes

func _process(delta):
	timer += delta

	if timer >= spawn_interval:
		timer = 0.0
		spawn_enemy()

func spawn_enemy():
<<<<<<< Updated upstream
	if enemy_scene == null:
		print("Enemy Scene não foi definido")
=======
	var player := get_player()
	if player == null:
		print("Player not found")
>>>>>>> Stashed changes
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
