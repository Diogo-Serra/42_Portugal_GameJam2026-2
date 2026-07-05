extends CharacterBody2D

@export var speed := 80.0
@export var max_health := 30
@export var knockback_force := 180.0
@export var hurt_time := 0.15

var health := 30
var player: Node2D

var hurt_timer := 0.0
var knockback_velocity := Vector2.ZERO

enum EnemyState {
	NORMAL,
	HURT,
	DEAD
}

var state: EnemyState = EnemyState.NORMAL

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision: CollisionShape2D = get_node_or_null("CollisionShape2D")


func _ready():
	health = max_health
	add_to_group("enemies")
	z_as_relative = false

	if sprite != null:
		if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)

		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")


func _physics_process(delta):
	z_index = int(global_position.y) + 45

	if state == EnemyState.DEAD:
		velocity = Vector2.ZERO
		return

	if state == EnemyState.HURT:
		hurt_timer -= delta
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)

		move_and_slide()

		if hurt_timer <= 0:
			state = EnemyState.NORMAL
			play_animation("walk")

		return

	if player == null:
		return

	var direction := (player.global_position - global_position).normalized()
	velocity = direction * speed

	update_sprite_direction()
	play_animation("walk")

	move_and_slide()


func take_damage(amount: int, attacker_position: Vector2):
	if state == EnemyState.DEAD:
		return

	health -= amount

	if health <= 0:
		die(attacker_position)
	else:
		get_hit(attacker_position)


func get_hit(attacker_position: Vector2):
	state = EnemyState.HURT
	hurt_timer = hurt_time

	var direction := (global_position - attacker_position).normalized()
	knockback_velocity = direction * knockback_force

	play_animation("hurt")


func die(attacker_position: Vector2):
	state = EnemyState.DEAD
	velocity = Vector2.ZERO

	var direction := (global_position - attacker_position).normalized()
	knockback_velocity = direction * knockback_force

	if collision != null:
		collision.set_deferred("disabled", true)

	if sprite != null and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
	else:
		queue_free()


func update_sprite_direction():
	if sprite == null:
		return

	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true


func play_animation(animation_name: String):
	if sprite == null:
		return

	if not sprite.sprite_frames.has_animation(animation_name):
		return

	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_animation_finished():
	if sprite == null:
		return

	if sprite.animation == "death":
		queue_free()
