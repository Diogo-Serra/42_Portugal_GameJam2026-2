extends CharacterBody2D

@export var speed := 70.0
@export var max_health := 20

@export var attack_damage := 10
@export var attack_range := 260.0
@export var keep_distance := 180.0
@export var attack_cooldown := 1.8
@export var projectile_scene: PackedScene

@export var attack_impact_frame := 2

var health := 20
var player: Node2D

var attack_timer := 0.0
var attack_has_fired := false

enum EnemyState {
	NORMAL,
	ATTACKING,
	HURT,
	DEAD
}

var state: EnemyState = EnemyState.NORMAL

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready():
	health = max_health
	add_to_group("enemies")

	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

	if not sprite.frame_changed.is_connected(_on_sprite_frame_changed):
		sprite.frame_changed.connect(_on_sprite_frame_changed)

	play_animation("idle")


func _physics_process(delta):
	if state == EnemyState.DEAD:
		velocity = Vector2.ZERO
		return

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	if attack_timer > 0:
		attack_timer -= delta

	if state == EnemyState.ATTACKING or state == EnemyState.HURT:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)
	var direction_to_player := (player.global_position - global_position).normalized()

	update_sprite_direction(direction_to_player)

	if distance_to_player <= attack_range and attack_timer <= 0:
		start_attack()
		return

	if distance_to_player > keep_distance:
		velocity = direction_to_player * speed
		play_animation("walk")
	else:
		velocity = Vector2.ZERO
		play_animation("idle")

	move_and_slide()


func start_attack():
	state = EnemyState.ATTACKING
	velocity = Vector2.ZERO
	attack_timer = attack_cooldown
	attack_has_fired = false
	play_animation("attack")


func _on_sprite_frame_changed():
	if state != EnemyState.ATTACKING:
		return

	if sprite.animation != "attack":
		return

	if attack_has_fired:
		return

	if sprite.frame >= attack_impact_frame:
		attack_has_fired = true
		shoot_projectile()


func shoot_projectile():
	if projectile_scene == null:
		print("Projectile scene not assigned")
		return

	if player == null:
		return

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position

	var direction := (player.global_position - global_position).normalized()

	if projectile.has_method("setup"):
		projectile.setup(direction, attack_damage)


func take_damage(amount: int, _attacker_position: Vector2):
	if state == EnemyState.DEAD:
		return

	health -= amount

	if health <= 0:
		die()
	else:
		get_hit()


func get_hit():
	state = EnemyState.HURT
	velocity = Vector2.ZERO
	play_animation("hurt")


func die():
	state = EnemyState.DEAD
	velocity = Vector2.ZERO

	if collision != null:
		collision.set_deferred("disabled", true)

	queue_free()


func update_sprite_direction(direction: Vector2):
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true


func play_animation(animation_name: String):
	if sprite.sprite_frames == null:
		return

	if not sprite.sprite_frames.has_animation(animation_name):
		print("Missing animation: ", animation_name)
		return

	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_animation_finished():
	if state == EnemyState.ATTACKING:
		state = EnemyState.NORMAL
		play_animation("idle")

	elif state == EnemyState.HURT:
		state = EnemyState.NORMAL
		play_animation("idle")
