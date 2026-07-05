extends Node2D

@export var villager_scenes: Array[PackedScene]
@export var knight_scene: PackedScene
@export var ranged_scene: PackedScene

@export var spawn_interval := 1.0
@export var spawn_distance := 500.0

@export var knight_start_time := 120.0
@export var ranged_start_time := 240.0

@export var knight_spawn_chance := 0.12
@export var ranged_spawn_chance := 0.10

var timer := 0.0
var game_time := 0.0

@onready var player: Node2D = $"../Player"


func _process(delta):
	game_time += delta
	timer += delta

	if timer >= spawn_interval:
		timer = 0.0
		spawn_enemy()


func spawn_enemy():
	if player == null:
		print("Player not found")
		return

	var enemy_scene := choose_enemy_scene()

	if enemy_scene == null:
		print("No enemy scene selected")
		return

	var enemy = enemy_scene.instantiate()

	var angle = randf() * TAU
	var direction = Vector2.RIGHT.rotated(angle)

	get_parent().add_child(enemy)

	enemy.global_position = player.global_position + direction * spawn_distance

	if "player" in enemy:
		enemy.player = player
	else:
		print("Spawned enemy has no player variable: ", enemy.name)


func choose_enemy_scene() -> PackedScene:
	var roll := randf()

	if game_time >= ranged_start_time:
		if ranged_scene != null and roll < ranged_spawn_chance:
			return ranged_scene

		if knight_scene != null and roll < ranged_spawn_chance + knight_spawn_chance:
			return knight_scene

		return choose_random_villager_scene()

	if game_time >= knight_start_time:
		if knight_scene != null and roll < knight_spawn_chance:
			return knight_scene

		return choose_random_villager_scene()

	return choose_random_villager_scene()


func choose_random_villager_scene() -> PackedScene:
	if villager_scenes.is_empty():
		print("No villager scenes assigned")
		return null

	var index := randi_range(0, villager_scenes.size() - 1)
	return villager_scenes[index]
